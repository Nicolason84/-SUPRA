import Foundation

public final class CanonicalKnowledgeGraphManager: Sendable {
    public static let shared = CanonicalKnowledgeGraphManager()

    private var graph: CanonicalKnowledgeGraph
    private var nodeIndex: [String: CGNode]
    private var edgeIndex: [String: CGEdge]

    private init() {
        self.graph = CanonicalKnowledgeGraph(nodes: [], edges: [], compiledAt: 0, tick: 0)
        self.nodeIndex = [:]
        self.edgeIndex = [:]
    }

    public func addNode(_ node: CGNode) {
        if let existingIndex = graph.nodes.firstIndex(where: { $0.id == node.id }) {
            graph.nodes[existingIndex] = node
        } else {
            graph.nodes.append(node)
        }
        nodeIndex[node.id.value] = node
    }

    public func addEdge(_ edge: CGEdge) {
        let edgeKey = "\(edge.source.value)->\(edge.target.value)"
        edgeIndex[edgeKey] = edge
        graph.edges.append(edge)
    }

    public func node(for canId: CAN_ID) -> CGNode? {
        nodeIndex[canId.value]
    }

    public func edge(from source: CAN_ID, to target: CAN_ID) -> CGEdge? {
        let edgeKey = "\(source.value)->\(target.value)"
        edgeIndex[edgeKey]
    }

    public func edges(from canId: CAN_ID) -> [CGEdge] {
        graph.edges.filter { $0.source == canId }
    }

    public func edges(to canId: CAN_ID) -> [CGEdge] {
        graph.edges.filter { $0.target == canId }
    }

    public func relatedNodes(for canId: CAN_ID) -> [CGNode] {
        let outgoing = graph.edges.filter { $0.source == canId }.compactMap { target in
            graph.nodes.first { $0.id == target.target }
        }
        let incoming = graph.edges.filter { $0.target == canId }.compactMap { source in
            graph.nodes.first { $0.id == source.source }
        }
        return Array(Set(outgoing + incoming))
    }

    public func queryByPrimitive(_ primitive: String) -> [CGNode] {
        graph.nodes.filter { $0.primitive.contains(primitive) }
    }

    public func queryByType(_ type: CAN_TYPE) -> [CGNode] {
        graph.nodes.filter { $0.type == type }
    }

    public func queryByResponsibility(_ responsibility: String) -> [CGNode] {
        graph.nodes.filter { $0.responsibility?.lowercased().contains(responsibility.lowercased()) ?? false }
    }

    public func queryByCapability(_ capabilityId: CAN_ID) -> [CGNode] {
        graph.nodes.filter { $0.capability == capabilityId }
    }

    public func queryByProof(_ proofId: CAN_ID) -> [CGNode] {
        graph.nodes.filter { $0.proof.contains(proofId) }
    }

    public func queryByNambrohoraRef(_ tick: Int64) -> [CGNode] {
        graph.nodes.filter { $0.nambrohoraRef == tick }
    }

    public func findDuplicates() -> [[CGNode]] {
        var groups: [[CGNode]] = []
        var visited = Set<String>()

        for node in graph.nodes {
            if visited.contains(node.id.value) { continue }

            let related = relatedNodes(for: node.id)
            let duplicateGroup = [node] + related.filter { relatedNode in
                areSemanticallyEquivalent(node, relatedNode)
            }

            if duplicateGroup.count > 1 {
                groups.append(duplicateGroup)
            }
            visited.formUnion(duplicateGroup.map { $0.id.value })
        }

        return groups
    }

    public func findEquivalentConcepts(concept: String) -> [CGNode] {
        let lowercased = concept.lowercased()
        return graph.nodes.filter { node in
            node.label.lowercased().contains(lowercased) ||
            node.responsibility?.lowercased().contains(lowercased) ?? false ||
            node.properties.values.contains { $0.lowercased().contains(lowercased) }
        }
    }

    public func findProjections(for canId: CAN_ID) -> [String] {
        guard let node = node(for: canId) else { return [] }
        return node.properties.filter { key, _ in key.hasPrefix("projection:") }.map { $0.value }
    }

    public func findMigrationImpact(for canId: CAN_ID) -> [String] {
        let relatedEdges = edges(from: canId) + edges(to: canId)
        return relatedEdges.map { edge in
            "\(edge.source.value) -> \(edge.target.value) [\(edge.relationType.rawValue)]"
        }
    }

    public func generateReport() -> String {
        let report = """
        Canonical Knowledge Graph Report
        =================================
        Total Nodes: \(graph.nodes.count)
        Total Edges: \(graph.edges.count)
        Compiled At Tick: \(graph.compiledAt)
        Version: \(graph.version)

        Nodes by Type:
        \(graph.nodes.reduce(into: [:]) { counts, node in
            counts[node.type.rawValue, default: 0] += 1
        }.map { "\($0.key): \($0.value)" }.joined(separator: "\n"))

        Nodes by Primitive:
        \(graph.nodes.reduce(into: [:]) { counts, node in
            counts[node.primitive, default: 0] += 1
        }.map { "\($0.key): \($0.value)" }.joined(separator: "\n"))
        """
        return report
    }

    private func areSemanticallyEquivalent(_ a: CGNode, _ b: CGNode) -> Bool {
        let labelSim = a.label.lowercased() == b.label.lowercased()
        let typeMatch = a.type == b.type
        let primitiveMatch = a.primitive == b.primitive

        if labelSim && typeMatch { return true }
        if primitiveMatch && typeMatch { return true }

        let aResponsibility = a.responsibility?.lowercased() ?? ""
        let bResponsibility = b.responsibility?.lowercased() ?? ""
        if !aResponsibility.isEmpty && !bResponsibility.isEmpty && aResponsibility == bResponsibility {
            return true
        }

        return false
    }
}