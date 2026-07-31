import Foundation
import Combine

// MARK: - Ω4 — Executive Context Engine
//
// The contextual awareness center of SUPRA's living runtime.
// The Context Engine aggregates:
// - Current mission context
// - Decision state
// - Provider status
// - System load and resources
// - Network state
// - Connected services
//
// It produces the raw material for the Executive Context Snapshot.

@MainActor
public final class ExecutiveContextEngine: ObservableObject, ExecutiveEngine {
    public static let shared = ExecutiveContextEngine()

    // MARK: - Executive Engine Conformance

    public let engineID = "executive-context-engine"
    public let engineName = "Executive Context Engine"
    @Published public private(set) var status: ExecutiveEngineStatus = .uninitialized
    public var statusPublisher: Published<ExecutiveEngineStatus>.Publisher { $status }

    // MARK: - Context State

    @Published public private(set) var currentMission: String?
    @Published public private(set) var currentDecision: String?
    @Published public private(set) var activeProviders: [String] = []
    @Published public private(set) var systemLoad: Double = 0
    @Published public private(set) var memoryPressure: String = "unknown"
    @Published public private(set) var networkStatus: String = "unknown"
    @Published public private(set) var contextAge: TimeInterval = 0
    @Published public private(set) var lastContextUpdate: Date = Date()

    /// Available contexts that SUPRA is aware of
    @Published public private(set) var availableContexts: [String: String] = [:]

    /// Connected services
    @Published public private(set) var connectedServices: [String: Bool] = [:]

    // MARK: - Mission Summary (Bridge to Snapshot Bus)

    /// Lightweight mission data populated from MissionStore, published via the Snapshot Bus.
    @Published public private(set) var missionsSummary: ExecutiveContextSnapshot.MissionsSummary = .initial

    // MARK: - Dashboard Summary (Bridge to ExecutiveCockpit & ExecutiveMissionControl)

    /// Aggregated dashboard data populated from multiple services, published via the Snapshot Bus.
    @Published public private(set) var dashboard: ExecutiveContextSnapshot.DashboardSummary = .initial

    // MARK: - Internal

    private var contextTimer: Timer?
    private let eventBus = ExecutiveEventBus.shared
    private let snapshotBus = ExecutiveSnapshotBus.shared
    private let fileManager = FileManager.default
    private var contextStartTime: Date?

    private init() {}

    // MARK: - Executive Engine Boot

    public func boot() async throws {
        status = .initializing
        contextStartTime = Date()

        // Scan initial context
        await scanContext()

        // Start context refresh timer
        contextTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.scanContext()
            }
        }

        status = .active
        eventBus.emit(.contextUpdated, source: engineID, detail: "Context Engine active")
    }

    public func shutdown() async throws {
        contextTimer?.invalidate()
        contextTimer = nil
        status = .uninitialized
    }

    public func healthCheck() async -> ExecutiveEngineStatus {
        guard contextTimer?.isValid ?? false else {
            status = .degraded
            eventBus.emit(.contextEngineDegraded, source: engineID, detail: "Context refresh timer not active")
            return .degraded
        }

        contextAge = contextStartTime.map { Date().timeIntervalSince($0) } ?? 0
        status = .active
        return .active
    }

    public func reset() async throws {
        try await shutdown()
        try await boot()
    }

    // MARK: - Context Scanning

    public func scanContext() async {
        lastContextUpdate = Date()

        // Detect active missions from MissionStore
        await detectMissions()

        // Detect providers
        await detectProviders()

        // Detect system load
        detectSystemLoad()

        // Detect network
        await detectNetwork()

        // Detect services
        await detectServices()

        // Detect dashboard data
        await detectDashboard()

        eventBus.emit(.contextUpdated, source: engineID, detail: "Context refreshed")
    }

    private func detectMissions() async {
        // Read missions from MissionStore (the canonical write-side service)
        let missionStore = SUPRACompositionRoot.shared.missionStore
        missionStore.load()

        let missions = missionStore.missions
        let currentMissionItem = missionStore.currentMission
        currentMission = currentMissionItem?.title

        let autoMissions = missionStore.autoMissions
        let supervisionMissions = missionStore.supervisionMissions
        let humanMissions = missionStore.humanMissions
        let visibleMissions = missionStore.visibleMissions

        // Build the summary for the Snapshot Bus
        // (pre-compute values to help Swift's type-checker)
        let total = missions.count
        let active = missions.filter { $0.status == .active }.count
        let planned = missions.filter { $0.status == .planned }.count
        let completed = missions.filter { $0.status == .completed }.count
        let blocked = missions.filter { $0.status == .blocked }.count
        let auto = autoMissions.count
        let supervised = supervisionMissions.count
        let human = humanMissions.count

        let currentSummary = currentMissionItem.map { ExecutiveContextSnapshot.MissionSummaryItem.from(mission: $0) }
        let autoSummary = autoMissions.map { ExecutiveContextSnapshot.MissionSummaryItem.from(mission: $0) }
        let supervisedSummary = supervisionMissions.map { ExecutiveContextSnapshot.MissionSummaryItem.from(mission: $0) }
        let humanSummary = humanMissions.map { ExecutiveContextSnapshot.MissionSummaryItem.from(mission: $0) }
        let visibleSummary = visibleMissions.map { ExecutiveContextSnapshot.MissionSummaryItem.from(mission: $0) }

        self.missionsSummary = ExecutiveContextSnapshot.MissionsSummary(
            totalCount: total,
            activeCount: active,
            plannedCount: planned,
            completedCount: completed,
            blockedCount: blocked,
            autoCount: auto,
            supervisionCount: supervised,
            humanCount: human,
            current: currentSummary,
            autoMissions: autoSummary,
            supervisionMissions: supervisedSummary,
            humanMissions: humanSummary,
            visibleMissions: visibleSummary
        )

        availableContexts["missions"] = "\(missions.count) missions (\(autoMissions.count) auto, \(supervisionMissions.count) supervised, \(humanMissions.count) human)"
    }

    private func detectProviders() async {
        // Read the runtime registry for active providers
        let registryPath = fileManager.currentDirectoryPath + "/.kernel/Runtime.json"
        if fileManager.fileExists(atPath: registryPath) {
            activeProviders = ["local"] // Default provider
        }
    }

    private func detectSystemLoad() {
        // Use ProcessInfo for basic system info
        let processInfo = ProcessInfo.processInfo
        systemLoad = Double(processInfo.activeProcessorCount) > 0 ? 0.5 : 0 // Placeholder
        memoryPressure = processInfo.isLowPowerModeEnabled ? "low_power" : "normal"
    }

    private func detectNetwork() async {
        // Simple reachability check — executed OFF the main thread with a hard
        // timeout. Runtime Hang Investigation: `ping` may block indefinitely
        // (ICMP/sandbox), and a synchronous `waitUntilExit()` on the main thread
        // froze the entire app during boot. The network status is now resolved
        // asynchronously and is always bounded in time.
        let result = await Task.detached(priority: .utility) { () -> Bool in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/sbin/ping")
            process.arguments = ["-c", "1", "-t", "2", "8.8.8.8"]

            let output = Pipe()
            process.standardOutput = output
            process.standardError = output

            do {
                try process.run()
            } catch {
                return false
            }

            // Bounded wait (max 4s): terminate the probe if ping hangs.
            let deadline = ContinuousClock.now + .seconds(4)
            while process.isRunning && ContinuousClock.now < deadline {
                try? await Task.sleep(for: .milliseconds(50))
            }
            if process.isRunning {
                process.terminate()
                // Grace window so terminationStatus settles before reading it.
                var graceTicks = 0
                while process.isRunning && graceTicks < 20 {
                    try? await Task.sleep(for: .milliseconds(50))
                    graceTicks += 1
                }
            }

            return process.terminationStatus == 0
        }.value

        networkStatus = result ? "connected" : "disconnected"
    }

    private func detectDashboard() async {
        // Runtime metrics
        let runtime = RuntimeDataService.shared
        let hasMetrics = runtime.runtimeMetrics != nil

        // Decision count
        let decisionStore = SUPRACompositionRoot.shared.decisionStore
        let decisionCount = decisionStore.decisions.count

        // Conversation count
        let conversations = ConversationMemoryStore.shared
        let conversationCount = conversations.conversations.count

        // Recommendations
        let recommendations = SUPRARecommendationEngine.shared
        let activeRecs = recommendations.recommendations.filter { !$0.isDismissed && $0.executedAt == nil }.count

        // Environment
        let environment = SUPRAEnvironmentWorldModel.shared
        let envExists = environment.state != nil

        // Evolution proposals
        let evolution = SUPRAEvolutionEngine.shared
        let proposalCount = evolution.proposals.count

        // Runtime version
        let registry = SUPRARuntimeRegistry.shared
        let runtimeVersion = registry.runtimeVersion

        // ExecutiveMissionControl data
        let emcStore = ExecutiveMissionControlStore.shared
        let agentCount = emcStore.agents.count
        let alertCount = emcStore.alerts.count
        let buildStatus = emcStore.runtime?.buildStatus.rawValue ?? "idle"
        let freezeStatus = emcStore.runtime?.freezeStatus.rawValue ?? "missing"
        let providerCount = emcStore.runtime?.providers.count ?? 0
        let timelineEventCount = emcStore.timeline.count

        // Copilot data
        let copilotSection = SUPRACommandCenterState.shared.copilotSection
        let cpProposalCount = copilotSection?.proposalCount ?? 0
        let cpAutoQueueCount = copilotSection?.autoQueueCount ?? 0
        let cpSupervisionQueueCount = copilotSection?.supervisionQueueCount ?? 0
        let cpHumanQueueCount = copilotSection?.humanQueueCount ?? 0
        let cpExecutedCount = copilotSection?.executedCount ?? 0

        self.dashboard = ExecutiveContextSnapshot.DashboardSummary(
            hasRuntimeMetrics: hasMetrics,
            runtimeVersion: runtimeVersion,
            decisionCount: decisionCount,
            conversationCount: conversationCount,
            activeRecommendationCount: activeRecs,
            humanRequiredRecommendationCount: activeRecs / 2,
            environmentStateExists: envExists,
            evolutionProposalCount: proposalCount,
            agentCount: agentCount,
            alertCount: alertCount,
            buildStatus: buildStatus,
            freezeStatus: freezeStatus,
            providerCount: providerCount,
            timelineEventCount: timelineEventCount,
            copilotProposalCount: cpProposalCount,
            copilotAutoQueueCount: cpAutoQueueCount,
            copilotExecutionQueueCount: cpSupervisionQueueCount + cpHumanQueueCount,
            copilotSupervisionQueueCount: cpSupervisionQueueCount,
            copilotHumanQueueCount: cpHumanQueueCount,
            copilotExecutedCount: cpExecutedCount
        )
    }

    private func detectServices() async {
        // Service probes run OFF the main thread (bounded async helper).
        // Runtime Hang Investigation: synchronous subprocess waits on the main
        // thread freeze the UI during context refreshes.
        async let gitProbe = probeService("which git 2>/dev/null && git --version 2>/dev/null | head -1 || echo \"not found\"")
        async let xcodeProbe = probeService("xcode-select -p 2>/dev/null || echo \"not found\"")
        async let ollamaProbe = probeService("which ollama 2>/dev/null || echo \"not found\"")

        let (gitCheck, xcodeCheck, ollamaCheck) = await (gitProbe, xcodeProbe, ollamaProbe)

        // Detect available git
        connectedServices["git"] = !gitCheck.contains("not found") && !gitCheck.isEmpty

        // Detect Xcode
        connectedServices["xcode"] = !xcodeCheck.contains("not found") && !xcodeCheck.isEmpty

        // Detect ollama
        connectedServices["ollama"] = !ollamaCheck.contains("not found") && !ollamaCheck.isEmpty
    }

    // MARK: - Context Updates

    public func setCurrentMission(_ missionID: String?) {
        currentMission = missionID
        if let missionID {
            eventBus.emit(.contextUpdated, source: engineID, detail: "Current mission: \(missionID)")
        }
    }

    public func setCurrentDecision(_ decisionID: String?) {
        currentDecision = decisionID
    }

    // MARK: - Shell Probe Helper

    /// Runs a shell probe OFF the main thread with a hard time bound.
    /// Never blocks the UI, even if a probed command misbehaves.
    private func probeService(_ command: String) async -> String {
        await Task.detached(priority: .utility) { () -> String in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-c", command]

            let output = Pipe()
            process.standardOutput = output
            process.standardError = output

            do {
                try process.run()
            } catch {
                return ""
            }

            // Bounded wait (max 3s) — terminate a hung probe.
            let deadline = ContinuousClock.now + .seconds(3)
            while process.isRunning && ContinuousClock.now < deadline {
                try? await Task.sleep(for: .milliseconds(50))
            }
            if process.isRunning {
                process.terminate()
            }

            let data = output.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }.value
    }
}
