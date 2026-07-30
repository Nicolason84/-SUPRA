import Foundation
import Combine

// MARK: - Ω4 — Context Engine
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
public final class ContextEngine: ObservableObject, ExecutiveEngine {
    public static let shared = ContextEngine()

    // MARK: - Executive Engine Conformance

    public let engineID = "context-engine"
    public let engineName = "Context Engine"
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
        await shutdown()
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
        detectNetwork()

        // Detect services
        detectServices()

        eventBus.emit(.contextUpdated, source: engineID, detail: "Context refreshed")
    }

    private func detectMissions() async {
        // Look for mission indicators in the filesystem
        let missionDir = fileManager.currentDirectoryPath + "/Missions"
        var fileExists: ObjCBool = false
        if fileManager.fileExists(atPath: missionDir, isDirectory: &fileExists), fileExists.boolValue {
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: missionDir)
                let activeMissions = contents.filter { $0.hasSuffix(".md") || $0.hasSuffix(".json") }
                if !activeMissions.isEmpty {
                    availableContexts["missions"] = "\(activeMissions.count) mission files"
                    currentMission = activeMissions.first
                }
            } catch {
                availableContexts["missions"] = "error reading missions"
            }
        }
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

    private func detectNetwork() {
        // Simple reachability check
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/sbin/ping")
        process.arguments = ["-c", "1", "-t", "2", "8.8.8.8"]

        let output = Pipe()
        process.standardOutput = output
        process.standardError = output

        do {
            try process.run()
            process.waitUntilExit()
            networkStatus = process.terminationStatus == 0 ? "connected" : "disconnected"
        } catch {
            networkStatus = "unknown"
        }
    }

    private func detectServices() {
        // Detect available git
        let gitCheck = shell("which git 2>/dev/null && git --version 2>/dev/null | head -1 || echo \"not found\"")
        connectedServices["git"] = !gitCheck.contains("not found") && !gitCheck.isEmpty

        // Detect Xcode
        let xcodeCheck = shell("xcode-select -p 2>/dev/null || echo \"not found\"")
        connectedServices["xcode"] = !xcodeCheck.contains("not found") && !xcodeCheck.isEmpty

        // Detect ollama
        let ollamaCheck = shell("which ollama 2>/dev/null || echo \"not found\"")
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

    // MARK: - Shell Helper

    private func shell(_ command: String) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]

        let output = Pipe()
        process.standardOutput = output

        do {
            try process.run()
            process.waitUntilExit()
            let data = output.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        } catch {
            return ""
        }
    }
}
