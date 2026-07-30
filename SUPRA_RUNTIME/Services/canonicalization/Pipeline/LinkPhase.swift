import Foundation

public final class LinkPhase: Sendable {
    public init() {}

    public func execute(entities: [CanonicalEntity], graph: CanonicalKnowledgeGraph) -> [CGNode] {
        var updatedNodes = graph.nodes
        var updatedEdges = graph.edges

        for entity in entities {
            let node = buildCGNode(from: entity)
            if let existingIndex = updatedNodes.firstIndex(where: { $0.id == node.id }) {
                updatedNodes[existingIndex] = node
            } else {
                updatedNodes.append(node)
            }

            for relation in entity.canRelations {
                let edge = CGEdge(
                    source: entity.canId,
                    target: relation.target,
                    relationType: relation.relationType,
                    weight: relation.weight,
                    evidence: relation.evidence,
                    tick: NAMBROCAHORA.advance()
                )
                updatedEdges.append(edge)
            }
        }

        for i in 0..<updatedNodes.count {
            for j in (i + 1)..<updatedNodes.count {
                let nodeA = updatedNodes[i]
                let nodeB = updatedNodes[j]

                if let relationType = findRelationBetween(nodeA, nodeB) {
                    let existingEdge = updatedEdges.first {
                        ($0.source == nodeA.id && $0.target == nodeB.id) ||
                        ($0.source == nodeB.id && $0.target == nodeA.id)
                    }

                    if existingEdge == nil {
                        let edge = CGEdge(
                            source: nodeA.id,
                            target: nodeB.id,
                            relationType: relationType,
                            weight: computeRelationWeight(nodeA, nodeB),
                            evidence: [],
                            tick: NAMBROCAHORA.advance()
                        )
                        updatedEdges.append(edge)
                    }
                }
            }
        }

        return updatedNodes
    }

    private func buildCGNode(from entity: CanonicalEntity) -> CGNode {
        return CGNode(
            id: entity.canId,
            label: entity.canName,
            type: entity.canType,
            primitive: canonicalPrimitive(for: entity.canType),
            responsibility: entity.canResponsibilities.first,
            capability: entity.canCapabilities.first,
            proof: entity.canEvidence,
            nambrohoraRef: entity.canTick,
            properties: entity.canSemantics,
            relations: entity.canRelations
        )
    }

    private func canonicalPrimitive(for type: CAN_TYPE) -> String {
        switch type {
        case .agent: return "P1 CAN_ID + P2 CAN_TYPE"
        case .knowledge: return "P5 CAN_KNOWLEDGE + P6 CAN_RELATION"
        case .event: return "P9 CAN_EVENT + P10 CAN_TIME"
        case .decision: return "P12 CAN_DECISION"
        case .constraint: return "P8 CAN_CONSTRAINT"
        case .relation: return "P6 CAN_RELATION"
        case .capability: return "P7 CAN_CAPABILITY"
        case .projection: return "Projection reference"
        case .memory: return "P5 CAN_KNOWLEDGE (persistent)"
        case .runtime: return "P1 + P5 + P9"
        case .workflow: return "P1 + P2 + P6"
        case .service: return "P1 + P3 + P5"
        case .connector, .manifest: return "P1 + P6"
        case .registry: return "P1 + P6 + P8"
        case .model: return "P5 + P6"
        case .document: return "P5 (documentation knowledge)"
        case .script: return "P9 (execution event)"
        case .structure, .config: return "P1 + P2"
        }
    }

    private func findRelationBetween(_ nodeA: CGNode, _ nodeB: CGNode) -> RELATION_TYPE? {
        let labelA = nodeA.label.lowercased()
        let labelB = nodeB.label.lowercased()

        if labelA.contains("memory") && labelB.contains("state") {
            return .references
        }
        if labelA.contains("decision") && labelB.contains("knowledge") {
            return .references
        }
        if labelA.contains("runtime") && labelB.contains("service") {
            return .uses
        }
        if labelA.contains("capability") && labelB.contains("constraint") {
            return .constrains
        }
        if labelA.contains("event") && labelB.contains("state") {
            return .causes
        }
        if labelA.contains("workflow") && labelB.contains("task") {
            return .contains
        }
        if labelA.contains("orchestrator") && labelB.contains("workflow") {
            return .controls
        }
        if labelA.contains("projection") && labelB.contains("swift") {
            return .projectsTo
        }
        if labelA.contains("manifest") && labelB.contains("config") {
            return .references
        }
        if labelA.contains("registry") && labelB.contains("agent") {
            return .references
        }
        if labelA.contains("model") && labelB.contains("capability") {
            return .hasCapability
        }
        if labelA.components(separatedBy: CharacterSet.alphanumerics.inverted).map({ $0.lowercased() }).filter({ ["snapshot", "state", "event", "decision", "knowledge", "memory", "runtime", "workflow", "service", "connector", "manifest", "registry", "model", "document", "config", "source", "provider", "executor", "orchestrator", "monitor", "validator", "projection", "compiler", "kernel", "core", "broker", "manager", "controller", "handler", "processor", "engine", "bridge", "adapter", "pipeline", "gate", "authority", "constraint", "policy", "rule"].contains($0) }).count > 0 {
            return referencesRelation(nodeA, nodeB)
        }

        return nil
    }

    private func referencesRelation(_ nodeA: CGNode, _ nodeB: CGNode) -> RELATION_TYPE? {
        if nodeA.type == .structure && nodeB.type == .structure {
            return .references
        }
        if nodeA.type == .config && nodeB.type == .structure {
            return .references
        }
        if nodeA.type == .document && nodeB.type == .knowledge {
            return .references
        }
        if nodeA.type == .runtime && nodeB.type == .service {
            return .uses
        }
        return .references
    }

    private func computeRelationWeight(_ nodeA: CGNode, _ nodeB: CGNode) -> Double {
        let sharedTypes = Set(nodeA.type.rawValue + nodeB.type.rawValue)
        return 0.5 + (Double(sharedTypes.count % 3) * 0.15)
    }
}