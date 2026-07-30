import Foundation

struct KnowledgeLineage: Codable, Equatable {
    let parentId: String?
    let rootId: String?
    let depth: Int
    let createdBy: String?
    let createdReason: String?
    let missionId: String?
    let decisionId: String?
    let commitId: String?
    let evidenceId: String?
    let reportId: String?
    let conversationId: String?
    let freezeId: String?
}

struct KnowledgeLineageGraph: Identifiable, Codable, Equatable {
    let id: String
    let rootId: String
    let nodes: [String]
    let edges: [[String: String]]
    let depth: Int
    let objectCount: Int

    static func == (lhs: KnowledgeLineageGraph, rhs: KnowledgeLineageGraph) -> Bool {
        lhs.id == rhs.id
    }
}
