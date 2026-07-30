# SUPRA COMPOSITION ROOT REPORT

sam. 25 juil. 2026 01:01:02 CEST

========================================
1. COMPOSITION ROOT
========================================

Entry point : ./SUPRA/SUPRAOperationalCoreApp.swift

import SwiftUI

@main
struct SUPRAOperationalCoreApp: App {
    @StateObject private var state = SUPRACommandCenterState.shared
    @StateObject private var governor = SUPRAResourceGovernor.shared
    @StateObject private var snapshotStore = CAnnoNicoSnapshotStore.shared

    var body: some Scene {
        WindowGroup {
            SUPRAOSProductRootView()
                .environmentObject(state)
                .environmentObject(TwinUniverse.shared)
                .onAppear {
                    governor.startMonitoring()
                    let monitor = RuntimeMonitor(dataService: RuntimeDataService())
                    monitor.start()
                    let towerState = ControlTowerState(dataService: RuntimeDataService())
                    towerState.load()
                    state.configure(towerState: towerState, monitor: monitor)
                    state.loadMissions()
                    snapshotStore.refreshIfNeeded()
                    SUPRABackgroundScheduler.shared.start()
                    SUPRAResourceIntelligenceEngine.shared.start()
                    SUPRAEvolutionEngine.shared.observe()
                    SUPRAMacPotential.shared.compute()
                    SUPRAEnvironmentWorldModel.shared.startAutoRefresh()
                    SUPRARecommendationEngine.shared.analyze()
                    SUPRAPassiveRefreshCoordinator.shared.start()
                    ConversationMemoryStore.shared.startAutoRefresh()
                }
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1400, height: 900)
    }
}

========================================
2. INSTANCES CREES
========================================


## MissionStore

./SUPRA/SUPRACommandCenterState.swift:247:    private let missionStore = MissionStore()
./SUPRA/MultiMemoryStore.swift:44:        MissionStore().$missions.sink { [weak self] _ in
./SUPRA/MultiMemoryStore.swift:112:        let missions = MissionStore().missions
./SUPRA/SUPRAIntelligenceEngine.swift:14:    private let missionStore = MissionStore()
./SUPRA/SUPRACanonicalWorldAccess.swift:147:        let ms = MissionStore()
./SUPRA/SUPRACanonicalWorldAccess.swift:230:        h.combine(MissionStore().missions.count)

## DecisionStore

./SUPRA/DecisionInboxView.swift:5:    @StateObject private var store = DecisionStore()

## KnowledgeGraph

./SUPRA/ConversationMemoryStore.swift:110:        connectToKnowledgeGraph()
./SUPRA/ConversationMemoryStore.swift:133:            connectToKnowledgeGraph()
./SUPRA/ConversationMemoryStore.swift:278:    private func connectToKnowledgeGraph() {

## ConversationMemoryStore

./SUPRA/ConversationMemoryStore.swift:43:    static let shared = ConversationMemoryStore()

========================================
3. SINGLETONS
========================================

./SUPRA/SUPRADataTwin.swift:18:    static let shared = SUPRADataTwin()
./SUPRA/SUPRADeveloperTwin.swift:21:    static let shared = SUPRADeveloperTwin()
./SUPRA/SUPRAWorldMapView.swift:24:    static let shared = SUPRAWorldMapState()
./SUPRA/SUPRACommandCenterState.swift:238:    static let shared = SUPRACommandCenterState()
./SUPRA/ConversationMemoryStore.swift:43:    static let shared = ConversationMemoryStore()
./SUPRA/SUPRAEnvironmentWorldModel.swift:17:    static let shared = SUPRAEnvironmentWorldModel()
./SUPRA/SUPRAResourceIntelligenceView.swift:17:    static let shared = SUPRAResourceIntelligence()
./SUPRA/TwinUniverse.swift:24:    static let shared = TwinUniverse()
./SUPRA/SUPRASoftwareTwin.swift:29:    static let shared = SUPRASoftwareTwin()
./SUPRA/ExecutiveDemoMode.swift:14:    static let shared = ExecutiveDemoMode()
./SUPRA/SUPRARecommendationCenter.swift:23:    static let shared = SUPRARecommendationEngine()
./SUPRA/NOVAKnowledgeKernel.swift:6:    static let shared = NOVAKnowledgeKernel()
./SUPRA/MultiMemoryStore.swift:6:    static let shared = MultiMemoryStore()
./SUPRA/CAnnoNicoSnapshotStore.swift:18:    static let shared = CAnnoNicoSnapshotStore()
./SUPRA/SUPRAEnvironmentSnapshotStore.swift:26:    static let shared = SUPRAEnvironmentSnapshotStore()
./SUPRA/SUPRABackgroundScheduler.swift:23:    static let shared = SUPRABackgroundScheduler()
./SUPRA/SUPRAPassiveRefreshCoordinator.swift:6:    static let shared = SUPRAPassiveRefreshCoordinator()
./SUPRA/UniverseEngine.swift:6:    static let shared = UniverseEngine()
./SUPRA/SUPRAMissionObserver.swift:30:    static let shared = SUPRAMissionObserver()
./SUPRA/SUPRAScheduler.swift:34:    static let shared = SUPRAScheduler()
./SUPRA/SUPRAWorldModel.swift:69:    static let shared = SUPRAWorldModel()
./SUPRA/OpenCodeBridge.swift:45:    static let shared = OpenCodeBridge()
./SUPRA/SUPRAHardwareTwin.swift:26:    static let shared = SUPRAHardwareTwin()
./SUPRA/SUPRAMissionExecutor.swift:25:    static let shared = SUPRAMissionExecutor()
./SUPRA/RuntimeGateway.swift:45:    static let shared = RuntimeGateway()
./SUPRA/SUPRAIntelligenceEngine.swift:6:    static let shared = SUPRAIntelligenceEngine()
./SUPRA/SUPRACanonicalWorldAccess.swift:86:    static let shared = SUPRACanonicalWorldAccess()
./SUPRA/SUPRAEnvironmentAutoMissions.swift:6:    static let shared = SUPRAEnvironmentAutoMissions()
./SUPRA/TwinRegistry.swift:6:    static let shared = TwinRegistry()
./SUPRA/SUPRAResourceGovernor.swift:61:    static let shared = SUPRAResourceGovernor()
./SUPRA/SUPRAIntelligenceGraph.swift:32:    static let shared = SUPRAIntelligenceGraph()
./SUPRA/SUPRAMacPotentialMap.swift:17:    static let shared = SUPRAMacPotential()
./SUPRA/SUPRAResourceIntelligenceEngine.swift:30:    static let shared = SUPRAResourceIntelligenceEngine()
./SUPRA/SUPRAEnvironmentResolver.swift:22:    static let shared = SUPRAEnvironmentResolver()
./SUPRA/SUPRABusinessPlatform.swift:67:    static let shared = SUPRABusinessPlatform()
./SUPRA/SUPRAWorkerFabric.swift:169:    static let shared = SUPRAWorkerFabric()
./SUPRA/SUPRAOSFoundation.swift:64:    static let shared = SUPRAOSFoundation()
./SUPRA/SUPRAEvolutionEngine.swift:30:    static let shared = SUPRAEvolutionEngine()
./SUPRA/SUPRAOptimizationCopilot.swift:21:    static let shared = SUPRAOptimizationCopilot()
./SUPRA/SUPRAMissionProposalEngine.swift:6:    static let shared = SUPRAMissionProposalEngine()
./SUPRA/WorkspaceObject.swift:6:    static let shared = WorkspaceObjectFactory()
./SUPRA/OpenCodeClient.swift:7:    static let shared = OpenCodeClient()

========================================
4. CONFIGURE / REGISTER / BIND
========================================

./SUPRA/SUPRAChatView.swift:61:    case connected
./SUPRA/SUPRAChatView.swift:67:        case .connected: "Runtime · Connected"
./SUPRA/SUPRAChatView.swift:75:        case .connected: "checkmark.circle.fill"
./SUPRA/SUPRAChatView.swift:83:        case .connected: .green
./SUPRA/SUPRAChatView.swift:89:        self == .connected
./SUPRA/SUPRAChatView.swift:348:                runtimeHealth = .connected
./SUPRA/MissionGraphView.swift:15:                    ContentUnavailableView("No graph data", systemImage: "point.connected", description: Text("Run a mission graph to visualize."))
./SUPRA/UniverseDashboard.swift:61:    func configure() {
./SUPRA/SUPRACommandCenterState.swift:94:    let connectionState: RuntimeConnectionState
./SUPRA/SUPRACommandCenterState.swift:105:        connectionState = monitor.health.connectionState
./SUPRA/SUPRACommandCenterState.swift:257:    func configure(towerState: ControlTowerState, monitor: RuntimeMonitor) {
./SUPRA/SUPRACommandCenterState.swift:262:        scheduler.register(id: "command_center_refresh", priority: .low, label: "Command Center Refresh", cooldown: 15) { [weak self] in
./SUPRA/SUPRACommandCenterState.swift:265:        scheduler.register(id: "copilot_refresh", priority: .low, label: "Copilot Refresh", cooldown: 30) { [weak self] in
./SUPRA/RuntimeMonitor.swift:23:        OpenCodeClient.shared.configure(dataService: dataService)
./SUPRA/ConversationMemoryStore.swift:75:    func configure(knowledgeGraph: KnowledgeGraph, decisionStore: DecisionStore, missionStore: MissionStore) {
./SUPRA/ConversationMemoryStore.swift:110:        connectToKnowledgeGraph()
./SUPRA/ConversationMemoryStore.swift:133:            connectToKnowledgeGraph()
./SUPRA/ConversationMemoryStore.swift:278:    private func connectToKnowledgeGraph() {
./SUPRA/SettingsView.swift:46:                            .fill(color(for: client.connectionState))
./SUPRA/SettingsView.swift:48:                        Text(client.connectionState.rawValue)
./SUPRA/SettingsView.swift:111:        case .disconnected, .offline: .red
./SUPRA/SettingsView.swift:112:        case .connecting: .blue
./SUPRA/SettingsView.swift:113:        case .connected: .green
./SUPRA/RuntimeConnectionState.swift:4:    case disconnected = "Disconnected"
./SUPRA/RuntimeConnectionState.swift:5:    case connecting = "Connecting"
./SUPRA/RuntimeConnectionState.swift:6:    case connected = "Connected"
./SUPRA/RuntimeConnectionState.swift:12:        case .disconnected: "circle.dashed"
./SUPRA/RuntimeConnectionState.swift:13:        case .connecting: "arrow.triangle.2.circlepath"
./SUPRA/RuntimeConnectionState.swift:14:        case .connected: "circle.fill"
./SUPRA/RuntimeConnectionState.swift:22:        case .disconnected: "gray"
./SUPRA/RuntimeConnectionState.swift:23:        case .connecting: "blue"
./SUPRA/RuntimeConnectionState.swift:24:        case .connected: "green"
./SUPRA/TwinRenderer.swift:59:    private let bindings: TwinBindings
./SUPRA/TwinRenderer.swift:63:         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
./SUPRA/TwinRenderer.swift:66:        self.bindings = bindings
./SUPRA/TwinRenderer.swift:77:            let twinBindings = bindings.bindings(for: twin.id)
./SUPRA/TwinRenderer.swift:93:                for binding in twinBindings.prefix(config.maxNeighbours) {
./SUPRA/TwinRenderer.swift:95:                        id: binding.id,
./SUPRA/TwinRenderer.swift:96:                        label: binding.sourceName,
./SUPRA/TwinRenderer.swift:97:                        type: "binding",
./SUPRA/TwinRenderer.swift:102:                        confidence: binding.strength,
./SUPRA/TwinRenderer.swift:107:                        id: "edge_\(twin.id)_\(binding.id)",
./SUPRA/TwinRenderer.swift:109:                        targetId: binding.id,
./SUPRA/TwinRenderer.swift:110:                        label: binding.bindingType,
./SUPRA/TwinRenderer.swift:111:                        weight: binding.strength,
./SUPRA/TwinRenderer.swift:112:                        bidirectional: binding.bidirectional
./SUPRA/SUPRAOSUniverseView.swift:48:                connectionWeb(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
./SUPRA/SUPRAOSUniverseView.swift:87:    private func connectionWeb(center: CGPoint) -> some View {
./SUPRA/CockpitRuntimeView.swift:17:                    Label("Steps: \(trace.traces.count)", systemImage: "point.connected")
./SUPRA/TwinUniverse.swift:9:    let bindingCount: Int
./SUPRA/TwinUniverse.swift:32:    private lazy var bindings = TwinBindings()
./SUPRA/TwinUniverse.swift:90:    var bindingsInstance: TwinBindings { bindings }
./SUPRA/TwinUniverse.swift:111:            bindingCount: bindings.bindings.count,
./SUPRA/TwinUniverse.swift:126:        Twins: \(s.twinCount) | Bindings: \(s.bindingCount)
./SUPRA/NOVAKnowledgeKernel.swift:46:    func registerObjects(_ objects: [CAnnoNicoObject]) {
./SUPRA/NOVAKnowledgeKernel.swift:54:    func registerRelations(_ relations: [KnowledgeRelationship]) {
./SUPRA/NOVAKnowledgeKernel.swift:59:    func registerSources(_ sources: [KnowledgeSource]) {
./SUPRA/MultiMemoryStore.swift:57:        let disconnected = memories.filter { !$0.isConnected }
./SUPRA/MultiMemoryStore.swift:62:            globalHealth: disconnected.isEmpty && !hasAnomalies ? "healthy"
./SUPRA/MultiMemoryStore.swift:63:                : disconnected.count <= 2 ? "degraded" : "critical",
./SUPRA/MultiMemoryStore.swift:106:            anomalies: health.isConnected ? [] : ["Runtime disconnected"],
./SUPRA/TwinAnalytics.swift:27:    private let bindings: TwinBindings
./SUPRA/TwinAnalytics.swift:32:         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
./SUPRA/TwinAnalytics.swift:36:        self.bindings = bindings
./SUPRA/TwinAnalytics.swift:43:        let allBindings = bindings.bindings
./SUPRA/TwinAnalytics.swift:78:        Twin Analytics: \(s.totalTwins) twins, \(s.totalBindings) bindings
./SUPRA/SUPRAOSLiveView.swift:8:        ("Bridge connecté", "il y a 30s", .supraGreen),
./SUPRA/SUPRABackgroundScheduler.swift:30:    @Published private(set) var registeredTaskCount = 0
./SUPRA/SUPRABackgroundScheduler.swift:61:    func register(id: String, label: String, interval: TimeInterval = 120, action: @escaping () async -> Void) {
./SUPRA/SUPRABackgroundScheduler.swift:63:        registeredTaskCount = tasks.count
./SUPRA/SUPRABackgroundScheduler.swift:66:    func unregister(id: String) {
./SUPRA/SUPRABackgroundScheduler.swift:68:        registeredTaskCount = tasks.count
./SUPRA/UniverseEngine.swift:86:        Bridge: \(bridge.isConnected ? "connecté" : "déconnecté")
./SUPRA/RuntimeEventSource.swift:8:    @Published private(set) var connectionState: RuntimeConnectionState = .disconnected
./SUPRA/RuntimeEventSource.swift:31:        connectionState = .connecting
./SUPRA/RuntimeEventSource.swift:36:            self.connectionState = .connected
./SUPRA/RuntimeEventSource.swift:48:        connectionState = .disconnected
./SUPRA/RuntimeEventSource.swift:153:    @Published private(set) var connectionState: RuntimeConnectionState = .disconnected
./SUPRA/RuntimeEventSource.swift:156:        connectionState = .connecting
./SUPRA/RuntimeEventSource.swift:159:            connectionState = .disconnected
./SUPRA/RuntimeEventSource.swift:164:        connectionState = .disconnected
./SUPRA/SUPRAMissionObserver.swift:6:    case memoryDisconnected = "MEMORY_DISCONNECTED"
./SUPRA/SUPRAMissionObserver.swift:77:                    id: UUID(), type: .memoryDisconnected,
./SUPRA/SUPRAMissionObserver.swift:78:                    title: "\(mem.name) disconnected",
./SUPRA/Models/SUPRAStructureMode.swift:11:        case .arbo: return "point.3.connected.trianglepath.dotted"
./SUPRA/SUPRAScheduler.swift:70:    func register(id: String, priority: SchedulerPriority = .medium, label: String,
./SUPRA/SUPRAScheduler.swift:78:    func unregister(id: String) {
./SUPRA/WorkerPoolView.swift:43:                Label(monitor.health.isConnected ? "Connected" : "Disconnected", systemImage: monitor.health.statusIcon)
./SUPRA/SUPRAWorldModel.swift:26:    let connectionState: String
./SUPRA/SUPRAWorldModel.swift:91:            .autoconnect()
./SUPRA/SUPRAWorldModel.swift:142:                connectionState: all.runtime.connectionState,
./SUPRA/OpenCodeBridge.swift:56:    func connect() {
./SUPRA/OpenCodeBridge.swift:61:    func disconnect() {
./SUPRA/ProjectsCardView.swift:13:            subtitle: projectsSource.map { $0.isConnected ? "\($0.objectCount) active" : "Disconnected" } ?? "—",
./SUPRA/ProjectsCardView.swift:26:                    row("Status", value: source.isConnected ? "Connected" : "Disconnected")
./SUPRA/UniverseGraph.swift:12:    private let bindings: TwinBindings
./SUPRA/UniverseGraph.swift:17:         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
./SUPRA/UniverseGraph.swift:21:        self.bindings = bindings
./SUPRA/UniverseGraph.swift:44:            let twinBindings = bindings.bindings(for: twin.id)
./SUPRA/UniverseGraph.swift:66:            for binding in twinBindings.prefix(5) {
./SUPRA/UniverseGraph.swift:67:                let bindingNode = UniverseGraphNode(
./SUPRA/UniverseGraph.swift:68:                    id: binding.id,
./SUPRA/UniverseGraph.swift:69:                    name: binding.sourceName,
./SUPRA/UniverseGraph.swift:70:                    type: "binding",
./SUPRA/UniverseGraph.swift:71:                    group: "binding",
./SUPRA/UniverseGraph.swift:74:                    description: "Binding: \(binding.bindingType)",
./SUPRA/UniverseGraph.swift:77:                if !nodes.contains(where: { $0.id == binding.id }) {
./SUPRA/UniverseGraph.swift:78:                    nodes.append(bindingNode)
./SUPRA/UniverseGraph.swift:82:                    id: "edge_bind_\(edgeCounter)",
./SUPRA/UniverseGraph.swift:84:                    targetId: binding.id,
./SUPRA/UniverseGraph.swift:85:                    type: "binds",
./SUPRA/UniverseGraph.swift:86:                    weight: binding.strength
./SUPRA/KnowledgeIdentity.swift:15:    let registeredAt: String
./SUPRA/SUPRAImmersiveSpaceView.swift:64:                // Composant de données attaché à chaque entité
./SUPRA/RuntimeGateway.swift:56:    func connect() {
./SUPRA/RuntimeGateway.swift:61:    func disconnect() {
./SUPRA/KnowledgeContextEngine.swift:11:    func connect(to graph: KnowledgeGraph) {
./SUPRA/TwinBindings.swift:10:    let bindingType: String
./SUPRA/TwinBindings.swift:24:    @Published var bindings: [TwinBinding] = []
./SUPRA/TwinBindings.swift:26:    func register(_ binding: TwinBinding) {
./SUPRA/TwinBindings.swift:27:        bindings.append(binding)
./SUPRA/TwinBindings.swift:30:    func bindings(for twinId: String) -> [TwinBinding] {
./SUPRA/TwinBindings.swift:31:        bindings.filter { $0.twinId == twinId }
./SUPRA/TwinBindings.swift:34:    func bindings(forSourceId sourceId: String) -> [TwinBinding] {
./SUPRA/TwinBindings.swift:35:        bindings.filter { $0.sourceId == sourceId }
./SUPRA/TwinBindings.swift:39:        bindings.filter { $0.twinId == twinId }.map(\.sourceId)
./SUPRA/TwinBindings.swift:43:        bindings.filter { $0.sourceId == sourceId }.map(\.twinId)
./SUPRA/TwinBindings.swift:46:    func unregister(twinId: String) {
./SUPRA/TwinBindings.swift:47:        bindings.removeAll { $0.twinId == twinId }
./SUPRA/TwinBindings.swift:51:        Dictionary(grouping: bindings, by: { $0.bindingType }).mapValues(\.count)
./SUPRA/TwinBindings.swift:56:            id: "bind_\(twinId)_\(object.id)",
./SUPRA/TwinBindings.swift:61:            bindingType: "canonical",
./SUPRA/TwinExplorer.swift:18:    let bindings: [TwinBinding]
./SUPRA/TwinExplorer.swift:36:    private let bindings: TwinBindings
./SUPRA/TwinExplorer.swift:41:         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
./SUPRA/TwinExplorer.swift:45:        self.bindings = bindings
./SUPRA/TwinExplorer.swift:79:            let twinBindings = bindings.bindings(for: twin.id)
./SUPRA/TwinExplorer.swift:105:            let twinBindings = bindings.bindings(for: twin.id)
./SUPRA/TwinExplorer.swift:110:                bindings.bindings(forSourceId: b.sourceId).map(\.twinId)
./SUPRA/TwinExplorer.swift:118:                bindings: twinBindings,
./SUPRA/TwinExplorer.swift:129:    private func scoreExplanation(_ twin: TwinIdentity, _ score: Double, _ bindingCount: Int, _ neighbourCount: Int) -> String {
./SUPRA/TwinExplorer.swift:130:        "Twin \(twin.name) (\(twin.type.rawValue)): score \(String(format: "%.2f", score)), \(bindingCount) bindings, \(neighbourCount) voisins"
./SUPRA/TwinComparison.swift:14:    let bindingOverlap: Double
./SUPRA/TwinComparison.swift:40:    private let bindings: TwinBindings
./SUPRA/TwinComparison.swift:44:         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
./SUPRA/TwinComparison.swift:47:        self.bindings = bindings
./SUPRA/TwinComparison.swift:52:        let bindingsA = Set(bindings.bindings(for: twinA.id).map(\.sourceId))
./SUPRA/TwinComparison.swift:53:        let bindingsB = Set(bindings.bindings(for: twinB.id).map(\.sourceId))
./SUPRA/TwinComparison.swift:55:        let bindingOverlap = bindingsA.isEmpty && bindingsB.isEmpty ? 0 :
./SUPRA/TwinComparison.swift:56:            Double(bindingsA.intersection(bindingsB).count) / Double(max(bindingsA.union(bindingsB).count, 1))
./SUPRA/TwinComparison.swift:76:        let overall = (bindingOverlap * 0.3) + (descOverlap * 0.2) + (nameOverlap * 0.2) +
./SUPRA/TwinComparison.swift:94:            sourceOverlap: Double(bindingsA.intersection(bindingsB).count),
./SUPRA/TwinComparison.swift:95:            bindingOverlap: bindingOverlap,
./SUPRA/RuntimeHealth.swift:13:    var connectionState: RuntimeConnectionState = .disconnected
./SUPRA/SUPRAIntelligenceEngine.swift:86:            result.append(SUPRAInsight(id: "health_critical", category: .health, severity: .critical, confidence: 0.95, message: "MultiMemory health is critical", suggestedAction: "Inspect memory source connectivity"))
./SUPRA/SUPRAIntelligenceEngine.swift:102:                id: "mm_disconnected_\(memory.id)",
./SUPRA/SUPRAIntelligenceEngine.swift:106:                message: "\(memory.name) memory source is disconnected",
./SUPRA/SUPRAIntelligenceEngine.swift:158:        let disconnected = mm.memories.filter { !$0.isConnected }.count
./SUPRA/SUPRAIntelligenceEngine.swift:161:        if disconnected == mm.memories.count {
./SUPRA/SUPRAIntelligenceEngine.swift:162:            result.append(SUPRAInsight(id: "memory_all_down", category: .anomaly, severity: .critical, confidence: 0.95, message: "All memory sources are disconnected", suggestedAction: "Verify MultiMemoryStore registry files exist"))
./SUPRA/SUPRAIntelligenceEngine.swift:165:        if lowConfidence > 0 && lowConfidence <= disconnected {
./SUPRA/SUPRACanonicalWorldAccess.swift:36:    let connectionState: String
./SUPRA/SUPRACanonicalWorldAccess.swift:132:            return CanonicalRuntimeState(isConnected: false, agentCount: 0, activeMissions: 0, lastSync: "—", connectionState: "unknown", gatewayConnected: false, gatewayWorkers: 0, eventCount: 0)
./SUPRA/SUPRACanonicalWorldAccess.swift:139:            connectionState: r.connectionState.rawValue,
./SUPRA/SUPRACompanionView.swift:43:            Projects: \(all.projects.totalProjects). Runtime: \(all.runtime.isConnected ? "connected" : "disconnected").
./SUPRA/SUPRAEnvironmentCommandCenterView.swift:344:                    detailCard("Network", hw.networkReachable ? hw.networkInterface : "Offline", hw.networkReachable ? "Connected" : "Disconnected", hw.networkReachable ? .supraGreen : .supraRed)
./SUPRA/DecisionKnowledgeProvider.swift:55:            "runtime_bindings.json"
./SUPRA/SUPRAOperationalCoreApp.swift:12:                .environmentObject(state)
./SUPRA/SUPRAOperationalCoreApp.swift:13:                .environmentObject(TwinUniverse.shared)
./SUPRA/SUPRAOperationalCoreApp.swift:20:                    state.configure(towerState: towerState, monitor: monitor)
./SUPRA/UniverseSearch.swift:13:    private let bindings: TwinBindings
./SUPRA/UniverseSearch.swift:18:         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
./SUPRA/UniverseSearch.swift:22:        self.bindings = bindings
./SUPRA/TwinLifecycle.swift:58:    func register(_ lifecycle: TwinLifecycle) {
./SUPRA/TwinRegistry.swift:12:    private lazy var bindings = TwinBindings()
./SUPRA/TwinRegistry.swift:16:    func register(_ twin: TwinIdentity) {
./SUPRA/TwinRegistry.swift:25:    func registerBatch(_ newTwins: [TwinIdentity]) {
./SUPRA/TwinRegistry.swift:27:            register(twin)
./SUPRA/TwinRegistry.swift:51:    func bindings(for twinId: String) -> [TwinBinding] {
./SUPRA/TwinRegistry.swift:52:        bindings.bindings(for: twinId)
./SUPRA/TwinFactory.swift:21:    private let bindings: TwinBindings
./SUPRA/TwinFactory.swift:26:         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
./SUPRA/TwinFactory.swift:30:        self.bindings = bindings
./SUPRA/TwinFactory.swift:88:        registry.register(identity)
./SUPRA/TwinFactory.swift:89:        lifecycles.register(lifecycle)
./SUPRA/TwinFactory.swift:109:                    let binding = TwinBindings.createBinding(twinId: twin.id, object: obj, strength: 0.9)
./SUPRA/TwinFactory.swift:110:                    bindings.register(binding)
./SUPRA/TwinFactory.swift:129:                let binding = TwinBindings.createBinding(twinId: twin.id, object: obj, strength: 0.7)
./SUPRA/TwinFactory.swift:130:                bindings.register(binding)
./SUPRA/TwinFactory.swift:150:                    let binding = TwinBindings.createBinding(twinId: twin.id, object: obj, strength: 1.0)
./SUPRA/TwinFactory.swift:151:                    bindings.register(binding)
./SUPRA/TwinFactory.swift:170:                let binding = TwinBindings.createBinding(twinId: twin.id, object: decision, strength: 1.0)
./SUPRA/TwinFactory.swift:171:                bindings.register(binding)
./SUPRA/TwinFactory.swift:193:                    let binding = TwinBindings.createBinding(twinId: twin.id, object: first, strength: 0.8)
./SUPRA/TwinFactory.swift:194:                    bindings.register(binding)
./SUPRA/TwinFactory.swift:213:                let binding = TwinBindings.createBinding(twinId: twin.id, object: obj, strength: 0.9)
./SUPRA/TwinFactory.swift:214:                bindings.register(binding)
./SUPRA/CockpitNavigation.swift:22:        case .graph: "point.connected"
./SUPRA/CockpitNavigation.swift:50:        .environmentObject(monitor)
./SUPRA/SUPRAApp.swift:17:                .environmentObject(TwinUniverse.shared)
./SUPRA/EvidenceExplorerView.swift:78:        if file.contains("trace") { return "point.connected" }
./SUPRA/SUPRABusinessPlatform.swift:101:            runtimeStatus: w.runtime.connectionState,
./SUPRA/RuntimeView.swift:9:            subtitle: state.runtimeSection.map { $0.isConnected ? "Connected" : "Disconnected" } ?? "—",
./SUPRA/RuntimeView.swift:19:                    connectionBadge(runtime.connectionState)
./SUPRA/RuntimeView.swift:73:    private func connectionBadge(_ state: RuntimeConnectionState) -> some View {
./SUPRA/RuntimeView.swift:75:            Circle().fill(connectionColor(state)).frame(width: 6, height: 6)
./SUPRA/RuntimeView.swift:78:                .foregroundColor(connectionColor(state))
./SUPRA/RuntimeView.swift:82:        .background(connectionColor(state).opacity(0.12))
./SUPRA/RuntimeView.swift:86:    private func connectionColor(_ state: RuntimeConnectionState) -> Color {
./SUPRA/RuntimeView.swift:88:        case .connected: .supraGreen
./SUPRA/RuntimeView.swift:89:        case .connecting: .supraBlue
./SUPRA/RuntimeView.swift:91:        case .disconnected, .offline: .supraRed
./SUPRA/SUPRACommandCenterApp.swift:13:                .environmentObject(state)
./SUPRA/SUPRACommandCenterApp.swift:20:                    state.configure(towerState: towerState, monitor: monitor)
./SUPRA/SUPRAEvolutionEngine.swift:54:        scheduler.register(id: "evolution_engine", label: "Evolution Engine", interval: 120) { [weak self] in
./SUPRA/SUPRAEvolutionEngine.swift:61:        scheduler.unregister(id: "evolution_engine")
./SUPRA/Infrastructure/SUPRATerminalMegabusBridge.swift:73:    static func registerSUPRAAndGabriel() {
./SUPRA/UniverseTimeline.swift:16:    case bridgeConnected = "bridge_connected"
./SUPRA/UniverseTimeline.swift:17:    case bridgeDisconnected = "bridge_disconnected"
./SUPRA/UniverseTimeline.swift:104:            title: "Bridge connecté",
./SUPRA/UniverseTimeline.swift:105:            description: "OpenCode Bridge connecté au Runtime",
./SUPRA/Views/CAnnoNicoCircuitBoardView.swift:64:                            ? "point.3.connected.trianglepath.dotted"
./SUPRA/SUPRAMissionProposalEngine.swift:67:        case .memoryDisconnected:
./SUPRA/SUPRAMissionProposalEngine.swift:117:        case .memoryDisconnected: "Reconnect memory source"
./SUPRA/ContentView.swift:71:            SUPRATerminalMegabusBridge.registerSUPRAAndGabriel()
./SUPRA/ContentView.swift:137:                structureHero("ARBO", title: "Naviguer du sens vers la preuve.", subtitle: "Source → module → capacité → produit → preuve → décision → action.", symbol: "point.3.connected.trianglepath.dotted")
./SUPRA/ContentView.swift:403:                subtitle: "Backend existant connecté à la façade",
./SUPRA/ContentView.swift:642:                        Label("Fuse", systemImage: "point.3.filled.connected.trianglepath.dotted")
./SUPRA/ContentView.swift:956:                        Label("Lineage", systemImage: "point.3.connected.trianglepath.dotted")
./SUPRA/ContentView.swift:1914:                Text("connected")
./SUPRA/ContentView.swift:2036:                icon: "point.3.connected.trianglepath.dotted"
./SUPRA/ContentView.swift:2091:                        + "Le registre correspondant doit être reconnecté."
./SUPRA/ContentView.swift:2190:                    subtitle: "Façade native connectée au modèle canonique",
./SUPRA/ContentView.swift:2608:                let connection = try baseModel.connectingSemanticProductFeeds()
./SUPRA/ContentView.swift:2609:                model = connection.model
./SUPRA/ContentView.swift:2610:                monetizableOpportunities = connection.opportunities
./SUPRA/ContentView.swift:2864:    func connectingSemanticProductFeeds() throws -> SUPRASemanticFacadeConnection {
./SUPRA/ContentView.swift:2889:        let connectedProjects = projectsFeed.projects.map { item in
./SUPRA/ContentView.swift:2919:        let connectedMetrics = SUPRAMetrics(
./SUPRA/ContentView.swift:2920:            projects: connectedProjects.count,
./SUPRA/ContentView.swift:2929:        let connectedSections = sections.map { section in
./SUPRA/ContentView.swift:2935:                count: section.id == "products" ? productRecords.count : (section.id == "projects" ? connectedProjects.count : section.count),
./SUPRA/ContentView.swift:2939:        let connectedSources = sources.map { source in
./SUPRA/ContentView.swift:2949:        let connectedAlerts = alerts.filter {
./SUPRA/ContentView.swift:2952:        let connectedModel = SUPRAExecutiveModel(
./SUPRA/ContentView.swift:2960:            metrics: connectedMetrics,
./SUPRA/ContentView.swift:2961:            sections: connectedSections,
./SUPRA/ContentView.swift:2962:            projects: connectedProjects,
./SUPRA/ContentView.swift:2965:            sources: connectedSources,
./SUPRA/ContentView.swift:2966:            alerts: connectedAlerts
./SUPRA/ContentView.swift:2968:        return SUPRASemanticFacadeConnection(model: connectedModel, opportunities: opportunityRecords)
./SUPRA/ContentView.swift:3080:        case .architecture: return "point.3.connected.trianglepath.dotted"
./SUPRA/ContentView.swift:3215:                    Text(model.lastError == nil ? "CURRENT connected" : "CURRENT degraded")
./SUPRA/ContentView.swift:3404:                    subtitle: "Read-only CURRENT board connection"
./SUPRA/RuntimeEvent.swift:20:        case .dagGenerated: "point.connected"
./SUPRA/ExecutiveCockpitFoundation.swift:165:        Bridge: \(state.bridgeConnected ? "connected" : "disconnected")
./SUPRA/TwinSynchronizer.swift:36:    private let bindings: TwinBindings
./SUPRA/TwinSynchronizer.swift:41:         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
./SUPRA/TwinSynchronizer.swift:45:        self.bindings = bindings
./SUPRA/TwinSynchronizer.swift:57:            let twinBindings = bindings.bindings(for: twin.id)
./SUPRA/TwinSynchronizer.swift:58:            for binding in twinBindings {
./SUPRA/TwinSynchronizer.swift:59:                guard binding.sourceType == "workspace" else { continue }
./SUPRA/TwinSynchronizer.swift:61:                let objectExists = objects.contains { $0.id == binding.sourceId }
./SUPRA/TwinSynchronizer.swift:64:                        id: "sync_del_\(binding.id)",
./SUPRA/TwinSynchronizer.swift:67:                        objectId: binding.sourceId,
./SUPRA/TwinSynchronizer.swift:68:                        objectName: binding.sourceName,
./SUPRA/TwinSynchronizer.swift:115:                registry.register(twin)
./SUPRA/KnowledgeGraph.swift:15:    func registerProvider(_ provider: KnowledgeProvider) {
./SUPRA/RuntimeSourceProtocol.swift:10:    var connectionState: RuntimeConnectionState { get }
./SUPRA/SUPRAOSHomeView.swift:80:                statItem(value: "\(universe.state?.bindingCount ?? 0)", label: "Liaisons", color: .supraOrange)
./SUPRA/OpenCodeClient.swift:12:    @Published var connectionState: RuntimeConnectionState = .disconnected
./SUPRA/OpenCodeClient.swift:24:    func configure(dataService: RuntimeDataService) {
./SUPRA/OpenCodeClient.swift:31:        connectionState = .disconnected
./SUPRA/OpenCodeClient.swift:44:            source.$connectionState
./SUPRA/OpenCodeClient.swift:46:                .assign(to: &$connectionState)
./SUPRA/OpenCodeClient.swift:90:        source.$connectionState
./SUPRA/OpenCodeClient.swift:92:            .assign(to: &$connectionState)
./.mechanical_extract_backup_20260723_211359/ContentView.swift:78:    static func registerSUPRAAndGabriel() {
./.mechanical_extract_backup_20260723_211359/ContentView.swift:414:        case .arbo: return "point.3.connected.trianglepath.dotted"
./.mechanical_extract_backup_20260723_211359/ContentView.swift:509:            SUPRATerminalMegabusBridge.registerSUPRAAndGabriel()
./.mechanical_extract_backup_20260723_211359/ContentView.swift:651:                structureHero("ARBO", title: "Naviguer du sens vers la preuve.", subtitle: "Source → module → capacité → produit → preuve → décision → action.", symbol: "point.3.connected.trianglepath.dotted")
./.mechanical_extract_backup_20260723_211359/ContentView.swift:746:                            ? "point.3.connected.trianglepath.dotted"
./.mechanical_extract_backup_20260723_211359/ContentView.swift:1014:                subtitle: "Backend existant connecté à la façade",
./.mechanical_extract_backup_20260723_211359/ContentView.swift:1253:                        Label("Fuse", systemImage: "point.3.filled.connected.trianglepath.dotted")
./.mechanical_extract_backup_20260723_211359/ContentView.swift:1567:                        Label("Lineage", systemImage: "point.3.connected.trianglepath.dotted")
./.mechanical_extract_backup_20260723_211359/ContentView.swift:2525:                Text("connected")
./.mechanical_extract_backup_20260723_211359/ContentView.swift:2647:                icon: "point.3.connected.trianglepath.dotted"
./.mechanical_extract_backup_20260723_211359/ContentView.swift:2702:                        + "Le registre correspondant doit être reconnecté."
./.mechanical_extract_backup_20260723_211359/ContentView.swift:2801:                    subtitle: "Façade native connectée au modèle canonique",
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3219:                let connection = try baseModel.connectingSemanticProductFeeds()
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3220:                model = connection.model
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3221:                monetizableOpportunities = connection.opportunities
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3475:    func connectingSemanticProductFeeds() throws -> SUPRASemanticFacadeConnection {
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3500:        let connectedProjects = projectsFeed.projects.map { item in
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3530:        let connectedMetrics = SUPRAMetrics(
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3531:            projects: connectedProjects.count,
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3540:        let connectedSections = sections.map { section in
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3546:                count: section.id == "products" ? productRecords.count : (section.id == "projects" ? connectedProjects.count : section.count),
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3550:        let connectedSources = sources.map { source in
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3560:        let connectedAlerts = alerts.filter {
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3563:        let connectedModel = SUPRAExecutiveModel(
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3571:            metrics: connectedMetrics,
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3572:            sections: connectedSections,
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3573:            projects: connectedProjects,
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3576:            sources: connectedSources,
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3577:            alerts: connectedAlerts
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3579:        return SUPRASemanticFacadeConnection(model: connectedModel, opportunities: opportunityRecords)
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3748:        case .architecture: return "point.3.connected.trianglepath.dotted"
./.mechanical_extract_backup_20260723_211359/ContentView.swift:3883:                    Text(model.lastError == nil ? "CURRENT connected" : "CURRENT degraded")
./.mechanical_extract_backup_20260723_211359/ContentView.swift:4072:                    subtitle: "Read-only CURRENT board connection"
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:78:    static func registerSUPRAAndGabriel() {
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:414:        case .arbo: return "point.3.connected.trianglepath.dotted"
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:509:            SUPRATerminalMegabusBridge.registerSUPRAAndGabriel()
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:651:                structureHero("ARBO", title: "Naviguer du sens vers la preuve.", subtitle: "Source → module → capacité → produit → preuve → décision → action.", symbol: "point.3.connected.trianglepath.dotted")
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:746:                            ? "point.3.connected.trianglepath.dotted"
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:1014:                subtitle: "Backend existant connecté à la façade",
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:1253:                        Label("Fuse", systemImage: "point.3.filled.connected.trianglepath.dotted")
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:1567:                        Label("Lineage", systemImage: "point.3.connected.trianglepath.dotted")
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:2525:                Text("connected")
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:2647:                icon: "point.3.connected.trianglepath.dotted"
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:2702:                        + "Le registre correspondant doit être reconnecté."
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:2801:                    subtitle: "Façade native connectée au modèle canonique",
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3219:                let connection = try baseModel.connectingSemanticProductFeeds()
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3220:                model = connection.model
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3221:                monetizableOpportunities = connection.opportunities
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3475:    func connectingSemanticProductFeeds() throws -> SUPRASemanticFacadeConnection {
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3500:        let connectedProjects = projectsFeed.projects.map { item in
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3530:        let connectedMetrics = SUPRAMetrics(
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3531:            projects: connectedProjects.count,
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3540:        let connectedSections = sections.map { section in
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3546:                count: section.id == "products" ? productRecords.count : (section.id == "projects" ? connectedProjects.count : section.count),
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3550:        let connectedSources = sources.map { source in
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3560:        let connectedAlerts = alerts.filter {
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3563:        let connectedModel = SUPRAExecutiveModel(
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3571:            metrics: connectedMetrics,
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3572:            sections: connectedSections,
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3573:            projects: connectedProjects,
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3576:            sources: connectedSources,
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3577:            alerts: connectedAlerts
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3579:        return SUPRASemanticFacadeConnection(model: connectedModel, opportunities: opportunityRecords)
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3748:        case .architecture: return "point.3.connected.trianglepath.dotted"
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:3883:                    Text(model.lastError == nil ? "CURRENT connected" : "CURRENT degraded")
./_SUPRA_BACKUPS/INLINE_MODELS_20260723_143443/ContentView.swift:4072:                    subtitle: "Read-only CURRENT board connection"
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Core/Megabus/SUPRATerminalMegabusBridge.swift:72:    static func registerSUPRAAndGabriel() {
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:198:    func connectingSemanticProductFeeds() throws -> SUPRASemanticFacadeConnection {
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:223:        let connectedProjects = projectsFeed.projects.map { item in
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:253:        let connectedMetrics = SUPRAMetrics(
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:254:            projects: connectedProjects.count,
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:263:        let connectedSections = sections.map { section in
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:269:                count: section.id == "products" ? productRecords.count : (section.id == "projects" ? connectedProjects.count : section.count),
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:273:        let connectedSources = sources.map { source in
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:283:        let connectedAlerts = alerts.filter {
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:286:        let connectedModel = SUPRAExecutiveModel(
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:294:            metrics: connectedMetrics,
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:295:            sections: connectedSections,
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:296:            projects: connectedProjects,
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:299:            sources: connectedSources,
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:300:            alerts: connectedAlerts
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAExecutiveModel.swift:302:        return SUPRASemanticFacadeConnection(model: connectedModel, opportunities: opportunityRecords)
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Models/SUPRAAlert.swift:68:        case .architecture: return "point.3.connected.trianglepath.dotted"
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Store/SUPRAExecutiveStore.swift:149:                let connection = try baseModel.connectingSemanticProductFeeds()
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Store/SUPRAExecutiveStore.swift:150:                model = connection.model
./_NON_RUNTIME_ARCHITECTURE/_EXTRACTION_PLAN_20260723_143740/Store/SUPRAExecutiveStore.swift:151:                monetizableOpportunities = connection.opportunities

========================================
5. DEPENDANCES ENTRE STORES
========================================


### MissionStore (./SUPRA/MissionStore.swift)

5:final class MissionStore: ObservableObject {

### DecisionStore (./SUPRA/DecisionStore.swift)

5:final class DecisionStore: ObservableObject {

### KnowledgeGraph (./SUPRA/KnowledgeObject.swift)

38:struct KnowledgeGraphData: Codable {
42:    let statistics: KnowledgeGraphStatistics
45:struct KnowledgeGraphStatistics: Codable {

### ConversationMemoryStore (./SUPRA/ConversationMemoryStore.swift)

42:final class ConversationMemoryStore: ObservableObject {
43:    static let shared = ConversationMemoryStore()
61:    private var knowledgeGraph: KnowledgeGraph?
62:    private var decisionStore: DecisionStore?
63:    private var missionStore: MissionStore?
75:    func configure(knowledgeGraph: KnowledgeGraph, decisionStore: DecisionStore, missionStore: MissionStore) {
110:        connectToKnowledgeGraph()
133:            connectToKnowledgeGraph()
278:    private func connectToKnowledgeGraph() {

========================================
6. ENVIRONMENT OBJECTS
========================================

./SUPRA/FileSystemCardView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/DecisionAuthorityView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/CommandCenterView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/MissionView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/SUPRAOSUniverseView.swift:4:    @EnvironmentObject var universe: TwinUniverse
./SUPRA/IntelligenceView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/SUPRADecisionRoomView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/ProjectsCardView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/MissionCopilotView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/SUPRACompanionView.swift:80:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/SUPRAOperationalCoreApp.swift:12:                .environmentObject(state)
./SUPRA/SUPRAOperationalCoreApp.swift:13:                .environmentObject(TwinUniverse.shared)
./SUPRA/CockpitNavigation.swift:50:        .environmentObject(monitor)
./SUPRA/SUPRAApp.swift:17:                .environmentObject(TwinUniverse.shared)
./SUPRA/MemoryView.swift:5:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/RuntimeView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/SUPRAOperationalCoreView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/SUPRACommandCenterApp.swift:13:                .environmentObject(state)
./SUPRA/SUPRAAutonomyControlView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/HealthView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/SUPRAMemoryLensView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState
./SUPRA/SUPRAOSHomeView.swift:4:    @EnvironmentObject var universe: TwinUniverse
./SUPRA/MultiMemoryView.swift:4:    @EnvironmentObject private var state: SUPRACommandCenterState

========================================
7. GRAPHVIZ
========================================

digraph SUPRA {
"ConversationMemoryStore.swift" -> "DecisionStore";
"ConversationMemoryStore.swift" -> "KnowledgeGraph";
"ConversationMemoryStore.swift" -> "ConversationMemoryStore";
