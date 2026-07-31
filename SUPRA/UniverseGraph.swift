import Foundation
import Combine

@MainActor
final class UniverseGraph: ObservableObject {
    @Published var nodes: [UniverseGraphNode] = []
    @Published var edges: [UniverseGraphEdge] = []
    @Published var isBuilt = false

    private let kernel: NOVAKnowledgeKernel
    private let registry: TwinRegistry
    private let bindings: TwinBindings
    private let lifecycles: TwinLifecycleManager

    nonisolated init(kernel: NOVAKnowledgeKernel = MainActor.assumeIsolated { NOVAKnowledgeKernel.shared },
         registry: TwinRegistry = MainActor.assumeIsolated { TwinRegistry.shared },
         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
         lifecycles: TwinLifecycleManager = MainActor.assumeIsolated { TwinLifecycleManager() }) {
        self.kernel = kernel
        self.registry = registry
        self.bindings = bindings
        self.lifecycles = lifecycles
    }

    func build() {
        nodes = []
        edges = []
        var edgeCounter = 0

        let universeNode = UniverseGraphNode(
            id: "universe_root",
            name: "NOVA Universe",
            type: "universe",
            group: "universe",
            size: 80,
            color: "#2C3E50",
            description: "NOVA Universe Engine",
            childCount: registry.count()
        )
        nodes.append(universeNode)

        for twin in registry.twins {
            let twinBindings = bindings.bindings(for: twin.id)

            let node = UniverseGraphNode(
                id: twin.id,
                name: twin.name,
                type: twin.type.rawValue,
                group: "twin",
                size: 40 + Double(twinBindings.count) * 2,
                color: twinColor(for: twin.type),
                description: twin.description,
                childCount: twinBindings.count
            )
            nodes.append(node)
            edgeCounter += 1
            edges.append(UniverseGraphEdge(
                id: "edge_univ_\(edgeCounter)",
                sourceId: "universe_root",
                targetId: twin.id,
                type: "contains",
                weight: 1.0
            ))

            for binding in twinBindings.prefix(5) {
                let bindingNode = UniverseGraphNode(
                    id: binding.id,
                    name: binding.sourceName,
                    type: "binding",
                    group: "binding",
                    size: 20,
                    color: "#95A5A6",
                    description: "Binding: \(binding.bindingType)",
                    childCount: 0
                )
                if !nodes.contains(where: { $0.id == binding.id }) {
                    nodes.append(bindingNode)
                }
                edgeCounter += 1
                edges.append(UniverseGraphEdge(
                    id: "edge_bind_\(edgeCounter)",
                    sourceId: twin.id,
                    targetId: binding.id,
                    type: "binds",
                    weight: binding.strength
                ))
            }
        }

        let objects = kernel.allObjectsSnapshot()
        let typeGroups = Dictionary(grouping: objects, by: { $0.source.rawValue })
        for (source, group) in typeGroups {
            let sourceNodeId = "source_\(source)"
            if !nodes.contains(where: { $0.id == sourceNodeId }) {
                nodes.append(UniverseGraphNode(
                    id: sourceNodeId,
                    name: source.capitalized,
                    type: "source",
                    group: "source",
                    size: Double(group.count) * 0.5 + 10,
                    color: sourceColor(for: source),
                    description: "\(group.count) objets",
                    childCount: 0
                ))
            }
        }

        isBuilt = true
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
        case .knowledge: return "#34495E"
        case .product: return "#E74C3C"
        case .capital: return "#F1C40F"
        case .environment: return "#27AE60"
        case .digitalLife: return "#8E44AD"
        default: return "#BDC3C7"
        }
    }

    private func sourceColor(for source: String) -> String {
        switch source {
        case "git": return "#4A90D9"
        case "workspace": return "#7B68EE"
        case "report": return "#2ECC71"
        case "artifact": return "#F39C12"
        case "freeze": return "#3498DB"
        case "decision": return "#E74C3C"
        default: return "#95A5A6"
        }
    }

    func summary() -> String {
        return "Universe Graph: \(nodes.count) nœuds, \(edges.count) arêtes"
    }
}

struct UniverseGraphNode: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let type: String
    let group: String
    let size: Double
    let color: String
    let description: String?
    let childCount: Int

    static func == (lhs: UniverseGraphNode, rhs: UniverseGraphNode) -> Bool {
        lhs.id == rhs.id
    }
}

struct UniverseGraphEdge: Identifiable, Codable, Equatable {
    let id: String
    let sourceId: String
    let targetId: String
    let type: String
    let weight: Double

    static func == (lhs: UniverseGraphEdge, rhs: UniverseGraphEdge) -> Bool {
        lhs.id == rhs.id
    }
}
