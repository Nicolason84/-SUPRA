import Foundation
import Combine

struct ExecutiveGraphNode: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let type: String
    let source: String
    let group: String
    let size: Double
    let color: String
    let authority: Int
    let children: [String]

    static func == (lhs: ExecutiveGraphNode, rhs: ExecutiveGraphNode) -> Bool {
        lhs.id == rhs.id
    }
}

struct ExecutiveGraphEdge: Identifiable, Codable, Equatable {
    let id: String
    let sourceId: String
    let targetId: String
    let type: String
    let weight: Double

    static func == (lhs: ExecutiveGraphEdge, rhs: ExecutiveGraphEdge) -> Bool {
        lhs.id == rhs.id
    }
}

struct ExecutiveGraphLayout: Codable {
    let nodes: [ExecutiveGraphNode]
    let edges: [ExecutiveGraphEdge]
}

@MainActor
final class ExecutiveGraph: ObservableObject {
    @Published var layout: ExecutiveGraphLayout?
    @Published var isBuilt = false

    func build(from kernel: NOVAKnowledgeKernel) {
        let objects = kernel.allObjectsSnapshot()
        let relations = kernel.allRelationsSnapshot()

        let groups = Dictionary(grouping: objects, by: { $0.source.rawValue })

        var nodes: [ExecutiveGraphNode] = []
        var nodeIds = Set<String>()

        for (source, group) in groups {
            let groupNodeId = "group_\(source)"
            nodes.append(ExecutiveGraphNode(
                id: groupNodeId,
                name: source.capitalized,
                type: "group",
                source: source,
                group: source,
                size: Double(group.count),
                color: groupColor(for: source),
                authority: 0,
                children: group.map(\.id)
            ))
            nodeIds.insert(groupNodeId)

            for obj in group {
                nodes.append(ExecutiveGraphNode(
                    id: obj.id,
                    name: obj.name,
                    type: obj.type.rawValue,
                    source: obj.source.rawValue,
                    group: source,
                    size: obj.authority.map { Double($0.rank) / 10.0 } ?? 3.0,
                    color: typeColor(for: obj.type),
                    authority: obj.authority?.rank ?? 0,
                    children: []
                ))
                nodeIds.insert(obj.id)
            }
        }

        var edges: [ExecutiveGraphEdge] = []
        var edgeCounter = 0

        for rel in relations {
            edgeCounter += 1
            if nodeIds.contains(rel.sourceId) && nodeIds.contains(rel.targetId) {
                edges.append(ExecutiveGraphEdge(
                    id: "edge_\(edgeCounter)",
                    sourceId: rel.sourceId,
                    targetId: rel.targetId,
                    type: rel.type,
                    weight: rel.weight
                ))
            }
        }

        for (source, group) in groups {
            let groupNodeId = "group_\(source)"
            for obj in group {
                edgeCounter += 1
                edges.append(ExecutiveGraphEdge(
                    id: "edge_group_\(edgeCounter)",
                    sourceId: groupNodeId,
                    targetId: obj.id,
                    type: "contains",
                    weight: 0.5
                ))
            }
        }

        layout = ExecutiveGraphLayout(nodes: nodes, edges: edges)
        isBuilt = true
    }

    private func groupColor(for source: String) -> String {
        switch source {
        case "git": return "#4A90D9"
        case "workspace": return "#7B68EE"
        case "report": return "#2ECC71"
        case "artifact": return "#F39C12"
        case "freeze": return "#3498DB"
        case "decision": return "#E74C3C"
        case "conversation": return "#9B59B6"
        case "pdf": return "#1ABC9C"
        default: return "#95A5A6"
        }
    }

    private func typeColor(for type: CAnnoNicoType) -> String {
        switch type {
        case .mission, .decision, .evidence: return "#E74C3C"
        case .gitCommit, .gitBranch, .gitRepository, .gitTag: return "#4A90D9"
        case .report, .audit, .validation: return "#2ECC71"
        case .freeze, .freezeManifest: return "#3498DB"
        case .script, .swift, .python, .javascript: return "#F39C12"
        case .pdf, .document, .markdown: return "#1ABC9C"
        case .conversation: return "#9B59B6"
        case .application, .plugin, .api: return "#E67E22"
        default: return "#95A5A6"
        }
    }

    func summary() -> String {
        guard let layout = layout else { return "Graph not built" }
        return "Executive Graph: \(layout.nodes.count) nodes, \(layout.edges.count) edges"
    }

    func clear() {
        layout = nil
        isBuilt = false
    }
}
