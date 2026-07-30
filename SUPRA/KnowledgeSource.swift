import Foundation

enum KnowledgeSourceType: String, Codable, CaseIterable, Identifiable {
    case workspace, git, report, artifact, freeze, decision
    case conversation, pdf, image, video, audio
    case system, external, unknown

    var id: String { rawValue }
}

struct KnowledgeSource: Identifiable, Codable, Equatable {
    let id: String
    let type: KnowledgeSourceType
    let name: String
    let path: String?
    let version: String?
    let lastAccessed: String?
    let objectCount: Int
    let reliability: Double

    static func == (lhs: KnowledgeSource, rhs: KnowledgeSource) -> Bool {
        lhs.id == rhs.id
    }
}
