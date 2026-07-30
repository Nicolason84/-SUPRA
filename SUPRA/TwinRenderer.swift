import Foundation
import Combine

struct TwinVisualConfig: Codable {
    let showBindings: Bool
    let showNeighbours: Bool
    let showLifecycle: Bool
    let showHistory: Bool
    let maxNeighbours: Int
    let colorScheme: String
    let nodeSize: Double
    let edgeThickness: Double
}

struct TwinRenderedNode: Identifiable, Codable, Equatable {
    let id: String
    let label: String
    let type: String
    let status: String
    let size: Double
    let color: String
    let authority: Int
    let confidence: Double
    let children: [String]

    static func == (lhs: TwinRenderedNode, rhs: TwinRenderedNode) -> Bool {
        lhs.id == rhs.id
    }
}

struct TwinRenderedEdge: Identifiable, Codable, Equatable {
    let id: String
    let sourceId: String
    let targetId: String
    let label: String
    let weight: Double
    let bidirectional: Bool

    static func == (lhs: TwinRenderedEdge, rhs: TwinRenderedEdge) -> Bool {
        lhs.id == rhs.id
    }
}

struct TwinRenderLayout: Codable {
    let nodes: [TwinRenderedNode]
    let edges: [TwinRenderedEdge]
}

@MainActor
final class TwinRenderer: ObservableObject {
    @Published var layout: TwinRenderLayout?
    @Published var config = TwinVisualConfig(
        showBindings: true, showNeighbours: true, showLifecycle: true,
        showHistory: false, maxNeighbours: 10, colorScheme: "twins",
        nodeSize: 40.0, edgeThickness: 2.0
    )

    private let registry: TwinRegistry
    private let bindings: TwinBindings
    private let lifecycles: TwinLifecycleManager

    nonisolated init(registry: TwinRegistry = MainActor.assumeIsolated { TwinRegistry.shared },
         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
         lifecycles: TwinLifecycleManager = MainActor.assumeIsolated { TwinLifecycleManager() }) {
        self.registry = registry
        self.bindings = bindings
        self.lifecycles = lifecycles
    }

    func render() {
        let twins = registry.twins
        var nodes: [TwinRenderedNode] = []
        var edges: [TwinRenderedEdge] = []

        for twin in twins {
            let lc = lifecycles.lifecycle(for: twin.id)
            let twinBindings = bindings.bindings(for: twin.id)
            let childIds = twinBindings.map(\.id)

            nodes.append(TwinRenderedNode(
                id: twin.id,
                label: twin.name,
                type: twin.type.rawValue,
                status: lc?.status.rawValue ?? "unknown",
                size: config.nodeSize + (Double(twinBindings.count) * 2.0),
                color: twinColor(for: twin.type),
                authority: twin.authority?.rank ?? 0,
                confidence: twin.confidence,
                children: childIds
            ))

            if config.showBindings {
                for binding in twinBindings.prefix(config.maxNeighbours) {
                    nodes.append(TwinRenderedNode(
                        id: binding.id,
                        label: binding.sourceName,
                        type: "binding",
                        status: "active",
                        size: config.nodeSize * 0.5,
                        color: "#95A5A6",
                        authority: 0,
                        confidence: binding.strength,
                        children: []
                    ))

                    edges.append(TwinRenderedEdge(
                        id: "edge_\(twin.id)_\(binding.id)",
                        sourceId: twin.id,
                        targetId: binding.id,
                        label: binding.bindingType,
                        weight: binding.strength,
                        bidirectional: binding.bidirectional
                    ))
                }
            }
        }

        layout = TwinRenderLayout(nodes: nodes, edges: edges)
    }

    private func twinColor(for type: TwinType) -> String {
        switch type {
        case .workspace: return "#7B68EE"
        case .project: return "#4A90D9"
        case .mission: return "#E74C3C"
        case .decision: return "#F39C12"
        case .evidence: return "#E67E22"
        case .company: return "#2ECC71"
        case .person: return "#1ABC9C"
        case .team: return "#3498DB"
        case .organization: return "#9B59B6"
        case .runtime: return "#95A5A6"
        case .knowledge: return "#2C3E50"
        case .product: return "#E74C3C"
        case .capital: return "#F1C40F"
        case .environment: return "#27AE60"
        case .digitalLife: return "#8E44AD"
        case .document: return "#2980B9"
        case .media: return "#E91E63"
        case .repository: return "#34495E"
        case .conversation: return "#00BCD4"
        case .application: return "#FF5722"
        case .system: return "#607D8B"
        case .component: return "#795548"
        case .capability: return "#009688"
        case .unknown: return "#BDC3C7"
        }
    }

    func summary() -> String {
        guard let layout = layout else { return "Non rendu" }
        return "TwinRenderer: \(layout.nodes.count) nœuds, \(layout.edges.count) arêtes"
    }
}
