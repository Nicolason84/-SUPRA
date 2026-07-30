import Foundation

enum KnowledgeAuthority: String, Codable, CaseIterable, Identifiable {
    case founder, executive, architect, builder, auditor
    case system, user, external, inferred, unknown

    var id: String { rawValue }

    var rank: Int {
        switch self {
        case .founder: return 100
        case .executive: return 90
        case .architect: return 80
        case .builder: return 70
        case .auditor: return 60
        case .system: return 50
        case .user: return 40
        case .external: return 30
        case .inferred: return 20
        case .unknown: return 0
        }
    }

    var label: String {
        switch self {
        case .founder: return "Founder"
        case .executive: return "Executive"
        case .architect: return "Architect"
        case .builder: return "Builder"
        case .auditor: return "Auditor"
        case .system: return "System"
        case .user: return "User"
        case .external: return "External"
        case .inferred: return "Inferred"
        case .unknown: return "Unknown"
        }
    }
}

struct KnowledgeAuthorityRecord: Identifiable, Codable, Equatable {
    let id: String
    let authority: KnowledgeAuthority
    let objectId: String
    let grantedBy: String?
    let grantedAt: String?
    let reason: String?
    let expiresAt: String?

    static func == (lhs: KnowledgeAuthorityRecord, rhs: KnowledgeAuthorityRecord) -> Bool {
        lhs.id == rhs.id
    }
}
