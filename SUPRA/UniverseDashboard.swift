import Foundation
import Combine

struct DashboardWidget: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let type: DashboardWidgetType
    let space: SUPRAOSSpace
    let configuration: [String: String]
    let order: Int
    let enabled: Bool

    static func == (lhs: DashboardWidget, rhs: DashboardWidget) -> Bool {
        lhs.id == rhs.id
    }
}

enum DashboardWidgetType: String, Codable, CaseIterable, Identifiable {
    case stats, timeline, graph, list, search, status, map, feed

    var id: String { rawValue }
}

struct UniverseDashboardSnapshot: Identifiable, Codable, Equatable {
    let id: String
    let timestamp: String
    let twinCount: Int
    let objectCount: Int
    let relationCount: Int
    let activeMissions: Int
    let activeTwins: Int
    let governanceIssues: Int
    let bridgeConnected: Bool
    let healthScore: Double

    static func == (lhs: UniverseDashboardSnapshot, rhs: UniverseDashboardSnapshot) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class UniverseDashboard: ObservableObject {
    @Published var widgets: [DashboardWidget] = []
    @Published var snapshot: UniverseDashboardSnapshot?

    private let kernel: NOVAKnowledgeKernel
    private let registry: TwinRegistry
    private let lifecycles: TwinLifecycleManager
    private let bridge: OpenCodeBridge

    nonisolated init(kernel: NOVAKnowledgeKernel = MainActor.assumeIsolated { NOVAKnowledgeKernel.shared },
         registry: TwinRegistry = MainActor.assumeIsolated { TwinRegistry.shared },
         lifecycles: TwinLifecycleManager = MainActor.assumeIsolated { TwinLifecycleManager() },
         bridge: OpenCodeBridge = MainActor.assumeIsolated { OpenCodeBridge.shared }) {
        self.kernel = kernel
        self.registry = registry
        self.lifecycles = lifecycles
        self.bridge = bridge
    }

    func configure() {
        widgets = [
            DashboardWidget(id: "dw_universe_stats", title: "Universe Statistics",
                            type: .stats, space: .universe, configuration: ["detail": "full"], order: 1, enabled: true),
            DashboardWidget(id: "dw_twin_overview", title: "Twin Overview",
                            type: .graph, space: .twins, configuration: ["type": "all"], order: 2, enabled: true),
            DashboardWidget(id: "dw_recent_timeline", title: "Recent Events",
                            type: .timeline, space: .timeline, configuration: ["count": "10"], order: 3, enabled: true),
            DashboardWidget(id: "dw_active_missions", title: "Active Missions",
                            type: .list, space: .missions, configuration: ["status": "active"], order: 4, enabled: true),
            DashboardWidget(id: "dw_governance", title: "Governance",
                            type: .status, space: .explorer, configuration: ["severity": "all"], order: 5, enabled: true),
            DashboardWidget(id: "dw_knowledge_graph", title: "Knowledge Graph",
                            type: .graph, space: .knowledge, configuration: ["layout": "force"], order: 6, enabled: true),
            DashboardWidget(id: "dw_bridge_status", title: "Bridge Status",
                            type: .status, space: .runtime, configuration: [:], order: 7, enabled: true),
        ]
    }

    func refresh() {
        let activeTwins = lifecycles.activeTwins().count
        let allObjects = kernel.allObjectsSnapshot()
        let allRelations = kernel.allRelationsSnapshot()
        let missions = kernel.allObjectsSnapshot().filter { $0.type == .mission }

        snapshot = UniverseDashboardSnapshot(
            id: "dash_\(ISO8601DateFormatter().string(from: Date()))",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            twinCount: registry.count(),
            objectCount: allObjects.count,
            relationCount: allRelations.count,
            activeMissions: missions.count,
            activeTwins: activeTwins,
            governanceIssues: kernel.governance.issues.count,
            bridgeConnected: bridge.isConnected,
            healthScore: 9.0
        )
    }

    func summary() -> String {
        guard let s = snapshot else { return "Dashboard non initialisé" }
        return """
        Dashboard: \(s.twinCount) twins, \(s.objectCount) objets, \(s.relationCount) relations
        Missions: \(s.activeMissions) | Twins actifs: \(s.activeTwins)
        Santé: \(s.healthScore)/10 | Bridge: \(s.bridgeConnected ? "OK" : "NOK")
        """
    }
}
