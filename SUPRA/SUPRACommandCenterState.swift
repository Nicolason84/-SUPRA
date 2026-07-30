import Foundation
import Combine
import CAnnoNicoContracts

struct CommandCenterSystemHealth {
    let overall: String
    let build: String
    let runtime: String
    let git: String
    let agents: String
    let storage: String
    let capabilities: Int
    let activeProjects: Int
    let swiftFiles: Int
    let gitRepos: Int

    init(from health: TowerSystemHealth?) {
        overall = health?.overall ?? "—"
        build = health?.build ?? "—"
        runtime = health?.runtime ?? "—"
        git = health?.git ?? "—"
        agents = health?.agents ?? "—"
        storage = health?.storage ?? "—"
        capabilities = health?.capabilities ?? 0
        activeProjects = health?.active_projects ?? 0
        swiftFiles = health?.swift_files_canonical ?? 0
        gitRepos = health?.git_repos_total ?? 0
    }
}

struct CommandCenterMissions {
    let total: Int
    let active: Int
    let blocked: Int
    let completed: Int
    let recentMissions: [Mission]

    init(from missions: [Mission]) {
        total = missions.count
        active = missions.filter { $0.status == .active }.count
        blocked = missions.filter { $0.status == .blocked }.count
        completed = missions.filter { $0.status == .completed }.count
        recentMissions = Array(missions
            .sorted { $0.timeline.last?.date ?? .distantPast > $1.timeline.last?.date ?? .distantPast }
            .prefix(5))
    }
}

struct CommandCenterResources {
    let cpuUsage: Double
    let ramFraction: Double
    let activeProcessCount: Int
    let freeDiskGB: Double
    let isHighLoad: Bool
    let isCritical: Bool
    let schedulerActiveTasks: Int
    let schedulerPending: Int
    let schedulerPaused: Bool

    init(from governor: SUPRAResourceGovernor, scheduler: SUPRAScheduler) {
        cpuUsage = governor.cpuUsage
        ramFraction = governor.ramFraction
        activeProcessCount = governor.snapshot.activeProcessCount
        freeDiskGB = governor.snapshot.freeDiskGB
        isHighLoad = governor.isHighLoad
        isCritical = governor.isCritical
        schedulerActiveTasks = scheduler.activeTaskCount
        schedulerPending = scheduler.pendingTasks.count
        schedulerPaused = scheduler.isPaused
    }
}

struct CommandCenterCannonico {
    let recoveredCount: Int
    let totalSources: Int
    let cachedAt: Date?
    let age: TimeInterval
    let references: [CAnnoNicoSourceReference]

    init(from store: CAnnoNicoSnapshotStore) {
        recoveredCount = store.recoveredCount
        totalSources = store.references.count
        cachedAt = store.cachedAt
        age = store.age
        references = store.references
    }
}

struct CommandCenterRuntime {
    let isConnected: Bool
    let agentCount: Int
    let activeMissions: Int
    let lastSync: String
    let connectionState: RuntimeConnectionState
    let events: [RuntimeEvent]
    let gatewayConnected: Bool
    let gatewayActiveMissions: Int
    let gatewayActiveWorkers: Int

    init(from monitor: RuntimeMonitor, gateway: RuntimeGateway) {
        isConnected = monitor.health.isConnected
        agentCount = monitor.health.agentCount
        activeMissions = monitor.health.activeMissionCount
        lastSync = monitor.health.lastSyncFormatted
        connectionState = monitor.health.connectionState
        events = Array(monitor.events.prefix(10))
        gatewayConnected = gateway.isConnected
        gatewayActiveMissions = gateway.status?.activeMissions ?? 0
        gatewayActiveWorkers = gateway.status?.activeWorkers ?? 0
    }
}

struct CommandCenterMultiMemory {
    let memories: [MemorySourceInfo]
    let globalHealth: String

    init(from store: MultiMemoryStore) {
        let s = store.snapshot
        memories = s.memories
        globalHealth = s.globalHealth
    }
}

struct CommandCenterDecision {
    let autoCount: Int
    let supervisionCount: Int
    let humanCount: Int
    let totalClassified: Int
    let verdicts: [UUID: DecisionVerdict]
    let missionTitles: [UUID: String]

    var autonomyLevel: Double {
        guard totalClassified > 0 else { return 0 }
        return Double(autoCount) / Double(totalClassified)
    }

    init(from store: MissionStore) {
        autoCount = store.autoMissions.count
        supervisionCount = store.supervisionMissions.count
        humanCount = store.humanMissions.count
        totalClassified = autoCount + supervisionCount + humanCount
        verdicts = store.verdicts
        var titles: [UUID: String] = [:]
        for m in store.missions { titles[m.id] = m.title }
        missionTitles = titles
    }
}

struct CommandCenterIntelligence {
    let healthScore: Double
    let anomalyCount: Int
    let nextBestAction: String?
    let insightCount: Int

    init(from engine: SUPRAIntelligenceEngine) {
        let s = engine.state
        healthScore = s.healthScore
        anomalyCount = s.anomalyCount
        nextBestAction = s.nextBestAction
        insightCount = s.insights.count
    }
}

struct CommandCenterCopilot {
    let observationCount: Int
    let proposalCount: Int
    let autoQueueCount: Int
    let supervisionQueueCount: Int
    let humanQueueCount: Int
    let executedCount: Int
    let pendingCount: Int

    init() {
        let observer = SUPRAMissionObserver.shared
        let engine = SUPRAMissionProposalEngine.shared
        let executor = SUPRAMissionExecutor.shared
        observationCount = observer.observations.count
        proposalCount = engine.proposals.count
        autoQueueCount = engine.autoQueue.count
        supervisionQueueCount = engine.supervisionQueue.count
        humanQueueCount = engine.humanQueue.count
        executedCount = executor.autoExecutedCount
        pendingCount = executor.pendingCount
    }
}

struct CommandCenterActions {
    let warnings: [TowerWarning]
    let nextActions: [TowerNextAction]

    init(from status: TowerStatus?) {
        warnings = status?.warnings ?? []
        nextActions = status?.next_actions ?? []
    }
}

struct CommandCenterSnapshot {
    let health: CommandCenterSystemHealth
    let missions: CommandCenterMissions
    let resources: CommandCenterResources
    let cannonico: CommandCenterCannonico
    let runtime: CommandCenterRuntime
    let multiMemory: CommandCenterMultiMemory
    let intelligence: CommandCenterIntelligence
    let decision: CommandCenterDecision
    let copilot: CommandCenterCopilot
    let actions: CommandCenterActions
    let lastUpdated: Date

    init(
        health: CommandCenterSystemHealth,
        missions: CommandCenterMissions,
        resources: CommandCenterResources,
        cannonico: CommandCenterCannonico,
        runtime: CommandCenterRuntime,
        multiMemory: CommandCenterMultiMemory,
        intelligence: CommandCenterIntelligence,
        decision: CommandCenterDecision,
        copilot: CommandCenterCopilot,
        actions: CommandCenterActions
    ) {
        self.health = health
        self.missions = missions
        self.resources = resources
        self.cannonico = cannonico
        self.runtime = runtime
        self.multiMemory = multiMemory
        self.intelligence = intelligence
        self.decision = decision
        self.copilot = copilot
        self.actions = actions
        self.lastUpdated = Date()
    }
}

@MainActor
final class SUPRACommandCenterState: ObservableObject {
    static let shared = SUPRACommandCenterState()

    @Published private(set) var snapshot: CommandCenterSnapshot?
    @Published private(set) var isReady = false

    private let governor = SUPRAResourceGovernor.shared
    private let scheduler = SUPRAScheduler.shared
    private let snapshotStore = CAnnoNicoSnapshotStore.shared
    private let gateway = RuntimeGateway.shared
    private let missionStore = SUPRACompositionRoot.shared.missionStore
    private let multiMemoryStore = MultiMemoryStore.shared
    private let intelligenceEngine = SUPRAIntelligenceEngine.shared
    private let proposalEngine = SUPRAMissionProposalEngine.shared
    private var monitor: RuntimeMonitor?
    private var towerState: ControlTowerState?
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    func configure(towerState: ControlTowerState, monitor: RuntimeMonitor) {
        self.towerState = towerState
        self.monitor = monitor
        observeAll()
        scheduler.start()
        scheduler.register(id: "command_center_refresh", priority: .low, label: "Command Center Refresh", cooldown: 15) { [weak self] in
            self?.rebuild()
        }
        scheduler.register(id: "copilot_refresh", priority: .low, label: "Copilot Refresh", cooldown: 30) { [weak self] in
            self?.proposalEngine.refresh()
        }
        rebuild()
        isReady = true
    }

    private func observeAll() {
        towerState?.$status.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        towerState?.$cannonicoReferences.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        monitor?.$health.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        monitor?.$events.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        gateway.$status.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        gateway.$isConnected.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        governor.$snapshot.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        scheduler.$isPaused.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        scheduler.$activeTaskCount.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        snapshotStore.$state.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        multiMemoryStore.$snapshot.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        intelligenceEngine.$state.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        proposalEngine.$proposals.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        proposalEngine.$autoQueue.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
    }

    func rebuild() {
        let health = CommandCenterSystemHealth(from: towerState?.status?.system_health)
        let missions = CommandCenterMissions(from: missionStore.missions)
        let resources = CommandCenterResources(from: governor, scheduler: scheduler)
        let cannonico = CommandCenterCannonico(from: snapshotStore)
        let runtime = CommandCenterRuntime(
            from: monitor ?? SUPRACompositionRoot.shared.runtimeMonitor,
            gateway: gateway
        )
        let multiMemory = CommandCenterMultiMemory(from: multiMemoryStore)
        let intelligence = CommandCenterIntelligence(from: intelligenceEngine)
        let decision = CommandCenterDecision(from: missionStore)
        let copilot = CommandCenterCopilot()
        let actions = CommandCenterActions(from: towerState?.status)

        snapshot = CommandCenterSnapshot(
            health: health,
            missions: missions,
            resources: resources,
            cannonico: cannonico,
            runtime: runtime,
            multiMemory: multiMemory,
            intelligence: intelligence,
            decision: decision,
            copilot: copilot,
            actions: actions
        )
    }

    func loadMissions() {
        missionStore.load()
    }

    var healthSection: CommandCenterSystemHealth? { snapshot?.health }
    var missionsSection: CommandCenterMissions? { snapshot?.missions }
    var resourcesSection: CommandCenterResources? { snapshot?.resources }
    var cannonicoSection: CommandCenterCannonico? { snapshot?.cannonico }
    var runtimeSection: CommandCenterRuntime? { snapshot?.runtime }
    var multiMemorySection: CommandCenterMultiMemory? { snapshot?.multiMemory }
    var intelligenceSection: CommandCenterIntelligence? { snapshot?.intelligence }
    var decisionSection: CommandCenterDecision? { snapshot?.decision }
    var copilotSection: CommandCenterCopilot? { snapshot?.copilot }
    var actionsSection: CommandCenterActions? { snapshot?.actions }

    func summary() -> String {
        guard let s = snapshot else { return "Command Center not ready" }
        return """
        COMMAND CENTER
        Santé: \(s.health.overall) | Missions: \(s.missions.active) active / \(s.missions.total) total
        CPU: \(Int(s.resources.cpuUsage * 100))% | RAM: \(Int(s.resources.ramFraction * 100))%
        Sources: \(s.cannonico.totalSources) | Runtime: \(s.runtime.isConnected ? "OK" : "NOK")
        Dernière mise à jour: \(s.lastUpdated.formatted(date: .omitted, time: .standard))
        """
    }
}
