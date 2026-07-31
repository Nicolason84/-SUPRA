import Foundation
import Combine

enum GraphNodeType: String, Codable {
    case observation = "OBSERVATION"
    case cause = "CAUSE"
    case impact = "IMPACT"
    case decision = "DECISION"
    case mission = "MISSION"
    case result = "RESULT"
}

struct IntelligenceGraphNode: Identifiable {
    let id: UUID
    let type: GraphNodeType
    let title: String
    let detail: String
    let weight: Double
    let timestamp: Date
}

struct IntelligenceGraphEdge: Identifiable {
    let id: UUID
    let source: UUID
    let target: UUID
    let relationship: String
    let weight: Double
}

@MainActor
final class SUPRAIntelligenceGraph: ObservableObject {
    static let shared = SUPRAIntelligenceGraph()

    @Published private(set) var nodes: [IntelligenceGraphNode] = []
    @Published private(set) var edges: [IntelligenceGraphEdge] = []
    @Published private(set) var lastUpdated: Date?

    private let observer = SUPRAMissionObserver.shared
    private let proposalEngine = SUPRAMissionProposalEngine.shared
    private let executor = SUPRAMissionExecutor.shared
    private var lastNodeCount = 0

    private init() {}

    func refresh() {
        let observations = observer.observations
        let proposals = proposalEngine.proposals
        let history = executor.executionHistory

        var newNodes: [IntelligenceGraphNode] = []
        var newEdges: [IntelligenceGraphEdge] = []
        var nodeMap: [String: UUID] = [:]

        for obs in observations {
            let nodeID = UUID()
            nodeMap["obs_\(obs.id)"] = nodeID
            newNodes.append(IntelligenceGraphNode(
                id: nodeID, type: .observation,
                title: obs.title, detail: obs.detail,
                weight: obs.confidence, timestamp: obs.observedAt
            ))

            let causeID = UUID()
            newNodes.append(IntelligenceGraphNode(
                id: causeID, type: .cause,
                title: "Root: \(obs.type.rawValue)", detail: obs.source,
                weight: 0.8, timestamp: obs.observedAt
            ))
            newEdges.append(IntelligenceGraphEdge(id: UUID(), source: nodeID, target: causeID, relationship: "caused_by", weight: 0.9))
        }

        for proposal in proposals {
            let nodeID = UUID()
            nodeMap["prop_\(proposal.id)"] = nodeID
            newNodes.append(IntelligenceGraphNode(
                id: nodeID, type: .decision,
                title: proposal.title, detail: proposal.verdict.authority.rawValue,
                weight: proposal.confidence, timestamp: proposal.proposedAt
            ))

            let impactID = UUID()
            newNodes.append(IntelligenceGraphNode(
                id: impactID, type: .impact,
                title: "Impact: \(proposal.estimatedImpact.rawValue)", detail: proposal.reason,
                weight: proposal.confidence, timestamp: proposal.proposedAt
            ))
            newEdges.append(IntelligenceGraphEdge(id: UUID(), source: nodeID, target: impactID, relationship: "impacts", weight: proposal.confidence))
        }

        for record in history where record.status == .executed {
            let nodeID = UUID()
            newNodes.append(IntelligenceGraphNode(
                id: nodeID, type: .result,
                title: "Executed: \(record.title)", detail: "Rollback: \(record.rollbackAvailable)",
                weight: 1.0, timestamp: record.executedAt ?? Date()
            ))
            if let prev = newNodes.last(where: { $0.type == .decision }) {
                newEdges.append(IntelligenceGraphEdge(id: UUID(), source: prev.id, target: nodeID, relationship: "produced", weight: 0.95))
            }
        }

        nodes = newNodes
        edges = newEdges
        lastUpdated = Date()
    }

    func query(type: GraphNodeType) -> [IntelligenceGraphNode] {
        nodes.filter { $0.type == type }
    }

    func path(from sourceID: UUID, to targetID: UUID) -> [IntelligenceGraphEdge] {
        var visited = Set<UUID>()
        var queue: [(UUID, [IntelligenceGraphEdge])] = [(sourceID, [])]

        while !queue.isEmpty {
            let (current, path) = queue.removeFirst()
            if current == targetID { return path }
            guard visited.insert(current).inserted else { continue }
            for edge in edges where edge.source == current {
                queue.append((edge.target, path + [edge]))
            }
        }
        return []
    }

    var nodeCount: Int { nodes.count }
    var edgeCount: Int { edges.count }
}
