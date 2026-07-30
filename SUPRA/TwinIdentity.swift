import Foundation

enum TwinType: String, Codable, CaseIterable, Identifiable {
    case workspace, project, mission, decision, evidence
    case company, person, team, organization
    case runtime, knowledge, product, capital
    case environment, digitalLife = "digital_life"
    case document, media, repository, conversation
    case application, system, component, capability
    case unknown

    var id: String { rawValue }
}

enum TwinStatus: String, Codable, CaseIterable, Identifiable {
    case creating, active, syncing, outdated, frozen
    case archived, deleted, error, unknown

    var id: String { rawValue }
}

struct TwinIdentity: Identifiable, Codable, Equatable {
    let id: String
    let type: TwinType
    let name: String
    let description: String
    let sourceId: String
    let sourceType: String
    let createdAt: String
    let updatedAt: String
    let version: Int
    let hash: String?
    let authority: KnowledgeAuthority?
    let confidence: Double

    static func == (lhs: TwinIdentity, rhs: TwinIdentity) -> Bool {
        lhs.id == rhs.id
    }
}
