import Foundation

struct KnowledgeRelationshipType: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let inverse: String?
    let weight: Double
    let bidirectional: Bool
    let description: String

    static func == (lhs: KnowledgeRelationshipType, rhs: KnowledgeRelationshipType) -> Bool {
        lhs.id == rhs.id
    }
}

struct KnowledgeRelationship: Identifiable, Codable, Equatable {
    let id: String
    let sourceId: String
    let targetId: String
    let type: String
    let weight: Double
    let bidirectional: Bool
    let description: String?
    let authority: KnowledgeAuthority?
    let created: String?

    static func == (lhs: KnowledgeRelationship, rhs: KnowledgeRelationship) -> Bool {
        lhs.id == rhs.id
    }
}
