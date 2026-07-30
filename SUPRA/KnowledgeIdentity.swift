import Foundation

struct KnowledgeIdentity: Codable, Equatable {
    let id: String
    let name: String
    let type: String
    let source: String
    let hash: String?
    let signature: String?
}

struct KnowledgeIdentityRegistry: Identifiable, Codable, Equatable {
    let id: String
    let identity: KnowledgeIdentity
    let registeredAt: String
    let verified: Bool
    let verificationMethod: String?

    static func == (lhs: KnowledgeIdentityRegistry, rhs: KnowledgeIdentityRegistry) -> Bool {
        lhs.id == rhs.id
    }
}
