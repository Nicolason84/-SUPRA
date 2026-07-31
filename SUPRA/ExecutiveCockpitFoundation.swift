import Foundation
import Combine

enum CockpitTab: String, Codable, CaseIterable, Identifiable {
    case dashboard, missions, runtime, knowledge, memory
    case timeline, search, governance, settings

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .missions: return "Missions"
        case .runtime: return "Runtime"
        case .knowledge: return "Knowledge"
        case .memory: return "Memory"
        case .timeline: return "Timeline"
        case .search: return "Search"
        case .governance: return "Governance"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .missions: return "flag"
        case .runtime: return "gear"
        case .knowledge: return "brain.head.profile"
        case .memory: return "memorychip"
        case .timeline: return "clock"
        case .search: return "magnifyingglass"
        case .governance: return "shield"
        case .settings: return "wrench"
        }
    }
}

struct CockpitState: Codable {
    let kernelInitialized: Bool
    let objectCount: Int
    let sourceCount: Int
    let relationshipCount: Int
    let governanceIssueCount: Int
    let memoryEntryCount: Int
    let timelineEventCount: Int
    let graphNodeCount: Int
    let graphEdgeCount: Int
    let bridgeConnected: Bool
    let lastBuildDate: String?
    let uptime: String
}

struct CockpitWidget: Identifiable, Codable, Equatable {
    let id: String
    let tab: CockpitTab
    let title: String
    let type: String
    let configuration: [String: String]
    let enabled: Bool
    let order: Int

    static func == (lhs: CockpitWidget, rhs: CockpitWidget) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class ExecutiveCockpitFoundation: ObservableObject {
    @Published var activeTab: CockpitTab = .dashboard
    @Published var state: CockpitState?
    @Published var isInitialized = false
    @Published var widgets: [CockpitWidget] = []

    private let kernel: NOVAKnowledgeKernel
    private let memory: ExecutiveMemory
    private let timeline: ExecutiveTimeline
    private let graph: ExecutiveGraph

    init(kernel: NOVAKnowledgeKernel? = nil,
         memory: ExecutiveMemory,
         timeline: ExecutiveTimeline,
         graph: ExecutiveGraph) {
        self.kernel = kernel ?? .shared
        self.memory = memory
        self.timeline = timeline
        self.graph = graph
    }

    func initialize() {
        configureWidgets()
        refreshState()

        isInitialized = true
    }

    func selectTab(_ tab: CockpitTab) {
        activeTab = tab
    }

    func refreshState() {
        state = CockpitState(
            kernelInitialized: kernel.isInitialized,
            objectCount: kernel.objectCount,
            sourceCount: kernel.sourceCount,
            relationshipCount: kernel.relationshipCount,
            governanceIssueCount: kernel.governance.issues.count,
            memoryEntryCount: memory.entries.count,
            timelineEventCount: timeline.events.count,
            graphNodeCount: graph.layout?.nodes.count ?? 0,
            graphEdgeCount: graph.layout?.edges.count ?? 0,
            bridgeConnected: kernel.bridge.isConnected,
            lastBuildDate: kernel.lastBuildDate?.ISO8601Format(),
            uptime: formattedUptime(from: kernel.lastBuildDate ?? Date())
        )
    }

    private func configureWidgets() {
        widgets = [
            CockpitWidget(id: "w_dashboard_stats", tab: .dashboard, title: "Statistics",
                          type: "stats", configuration: [:], enabled: true, order: 1),
            CockpitWidget(id: "w_dashboard_recent", tab: .dashboard, title: "Recent Activity",
                          type: "timeline", configuration: ["count": "10"], enabled: true, order: 2),
            CockpitWidget(id: "w_knowledge_graph", tab: .knowledge, title: "Knowledge Graph",
                          type: "graph", configuration: [:], enabled: true, order: 1),
            CockpitWidget(id: "w_knowledge_search", tab: .knowledge, title: "Search",
                          type: "search", configuration: [:], enabled: true, order: 2),
            CockpitWidget(id: "w_memory_browser", tab: .memory, title: "Memory Browser",
                          type: "list", configuration: [:], enabled: true, order: 1),
            CockpitWidget(id: "w_timeline_all", tab: .timeline, title: "Full Timeline",
                          type: "timeline", configuration: ["count": "100"], enabled: true, order: 1),
            CockpitWidget(id: "w_search_bar", tab: .search, title: "Global Search",
                          type: "search", configuration: [:], enabled: true, order: 1),
            CockpitWidget(id: "w_governance_issues", tab: .governance, title: "Issues",
                          type: "list", configuration: ["severity": "all"], enabled: true, order: 1),
            CockpitWidget(id: "w_runtime_status", tab: .runtime, title: "Runtime Status",
                          type: "status", configuration: [:], enabled: true, order: 1),
            CockpitWidget(id: "w_missions_active", tab: .missions, title: "Active Missions",
                          type: "list", configuration: ["status": "active"], enabled: true, order: 1)
        ]
    }

    private func formattedUptime(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    func summary() -> String {
        guard let state = state else { return "Cockpit not initialized" }
        return """
        Executive Cockpit Foundation
        Tab: \(activeTab.label)
        State: \(state.objectCount) objects, \(state.relationshipCount) relations
        Memory: \(state.memoryEntryCount) entries
        Timeline: \(state.timelineEventCount) events
        Graph: \(state.graphNodeCount) nodes, \(state.graphEdgeCount) edges
        Governance: \(state.governanceIssueCount) issues
        Bridge: \(state.bridgeConnected ? "connected" : "disconnected")
        """
    }
}
