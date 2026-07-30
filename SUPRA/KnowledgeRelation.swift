import Foundation

enum RelationType: String, Codable, CaseIterable, Identifiable {
    case contains, belongsTo = "belongs_to", dependsOn = "depends_on"
    case implements, documents, triggers, validates
    case references, relatesTo = "relates_to", supersedes
    case causedBy = "caused_by", inspiredBy = "inspired_by"
    case resolves, archives, freezes, commits
    case introduces, removes, renames
    case partOf = "part_of", versionOf = "version_of"
    case conversationAbout = "conversation_about"
    case decisionFor = "decision_for"
    case evidenceFor = "evidence_for"
    case commitFor = "commit_for"
    case reportFor = "report_for"
    case pdfFor = "pdf_for"
    case freezeOf = "freeze_of"
    case archiveOf = "archive_of"
    case artifactOf = "artifact_of"

    var id: String { rawValue }

    var inverse: RelationType {
        switch self {
        case .contains: .belongsTo
        case .belongsTo: .contains
        case .dependsOn: .dependsOn
        case .implements: .implements
        case .documents: .documents
        case .triggers: .causedBy
        case .validates: .validates
        case .references: .references
        case .relatesTo: .relatesTo
        case .supersedes: .supersedes
        case .causedBy: .triggers
        case .inspiredBy: .inspiredBy
        case .resolves: .resolves
        case .archives: .archiveOf
        case .freezes: .freezeOf
        case .commits: .commitFor
        case .introduces: .introduces
        case .removes: .removes
        case .renames: .renames
        case .partOf: .contains
        case .versionOf: .versionOf
        case .conversationAbout: .conversationAbout
        case .decisionFor: .decisionFor
        case .evidenceFor: .evidenceFor
        case .commitFor: .commits
        case .reportFor: .reportFor
        case .pdfFor: .pdfFor
        case .freezeOf: .freezes
        case .archiveOf: .archives
        case .artifactOf: .artifactOf
        }
    }
}

struct KnowledgeRelation: Codable, Equatable, Identifiable {
    let id: String
    let sourceId: String
    let targetId: String
    let type: RelationType
    let weight: Double
    let bidirectional: Bool
    let description: String?

    init(sourceId: String, targetId: String, type: RelationType, weight: Double = 1.0, bidirectional: Bool = true, description: String? = nil) {
        self.id = "\(sourceId)->\(targetId)[\(type.rawValue)]"
        self.sourceId = sourceId
        self.targetId = targetId
        self.type = type
        self.weight = weight
        self.bidirectional = bidirectional
        self.description = description
    }
}
