import Foundation

enum WorkspaceObjectType: String, Codable, CaseIterable, Identifiable {
    case project, module, `class`, view, script, mission
    case document, decision, evidence, conversation, archive
    case gitRepository = "git_repository"
    case xcodeProject = "xcode_project"
    case database, log, file, directory, pdf, image, unknown

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .project: "folder"
        case .module: "square.stack.3d.up"
        case .class: "c.square"
        case .view: "rectangle.3.group"
        case .script: "terminal"
        case .mission: "flag"
        case .document: "doc.text"
        case .decision: "list.bullet.clipboard"
        case .evidence: "doc.badge.plus"
        case .conversation: "message"
        case .archive: "archivebox"
        case .gitRepository: "arrow.triangle.branch"
        case .xcodeProject: "hammer"
        case .database: "cylinder"
        case .log: "doc.text.magnifyingglass"
        case .file: "doc"
        case .directory: "folder"
        case .pdf: "pdf"
        case .image: "photo"
        case .unknown: "questionmark"
        }
    }
}

struct WorkspaceRelation: Codable, Equatable {
    let type: String
    let targetId: String
    let weight: Double

    static func contains(_ targetId: String) -> WorkspaceRelation {
        WorkspaceRelation(type: "contains", targetId: targetId, weight: 1.0)
    }

    static func belongsTo(_ targetId: String) -> WorkspaceRelation {
        WorkspaceRelation(type: "belongs_to", targetId: targetId, weight: 1.0)
    }

    static func references(_ targetId: String, weight: Double = 0.8) -> WorkspaceRelation {
        WorkspaceRelation(type: "references", targetId: targetId, weight: weight)
    }

    static func related(_ targetId: String, weight: Double = 0.5) -> WorkspaceRelation {
        WorkspaceRelation(type: "related", targetId: targetId, weight: weight)
    }
}

struct WorkspaceObject: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let path: String
    let type: WorkspaceObjectType
    let language: String?
    let dateCreated: Date?
    let dateModified: Date?
    let sizeBytes: Int64
    let hash: String
    var relations: [WorkspaceRelation]
    var tags: [String]
    var importance: Double
    var projectName: String?
    var moduleName: String?
    var lineCount: Int?

    static func == (lhs: WorkspaceObject, rhs: WorkspaceObject) -> Bool { lhs.id == rhs.id }
}

struct WorkspaceIndex: Codable {
    let version: String
    let timestamp: Date
    let objects: [WorkspaceObject]
    let metadata: WorkspaceMetadata

    static let initial = WorkspaceIndex(
        version: "1.0.0",
        timestamp: Date(),
        objects: [],
        metadata: WorkspaceMetadata(scanDuration: 0, directoriesScanned: 0, filesScanned: 0, errors: [])
    )
}

struct WorkspaceMetadata: Codable {
    let scanDuration: TimeInterval
    let directoriesScanned: Int
    let filesScanned: Int
    let errors: [String]
}

struct GraphNode: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let type: WorkspaceObjectType
    let importance: Double
    let projectName: String?
}

struct GraphEdge: Identifiable, Codable, Equatable {
    var id: String { "\(source) -> \(target) [\(type)]" }
    let source: String
    let target: String
    let type: String
    let weight: Double

    static func contains(_ source: String, _ target: String) -> GraphEdge {
        GraphEdge(source: source, target: target, type: "contains", weight: 1.0)
    }

    static func references(_ source: String, _ target: String, weight: Double = 0.8) -> GraphEdge {
        GraphEdge(source: source, target: target, type: "references", weight: weight)
    }
}

struct WorkspaceGraph: Codable {
    let version: String
    let timestamp: Date
    let nodes: [GraphNode]
    let edges: [GraphEdge]
    let metadata: WorkspaceMetadata
}

struct ContextQuery: Codable {
    let query: String
    let keywords: [String]
    let projectFilter: String?
    let typeFilter: WorkspaceObjectType?
    let maxResults: Int
}

struct ContextResultItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let path: String
    let type: WorkspaceObjectType
    let relevance: Double
    let reason: String
    let matchedKeywords: [String]
}

struct ContextResult: Codable {
    let query: String
    let timestamp: Date
    let items: [ContextResultItem]
    let totalMatches: Int
    let totalWeight: Double
    let responseTimeMs: Int
}

struct WorkspaceMemoryEntry: Identifiable, Codable {
    let id: String
    let timestamp: Date
    let version: String
    let eventType: String
    let objectId: String?
    let objectName: String?
    let objectType: WorkspaceObjectType?
    let changeDescription: String
    let previousHash: String?
    let newHash: String?
}

struct WorkspaceMemory: Codable {
    let version: String
    var entries: [WorkspaceMemoryEntry]
    var lastIndexed: Date?
    var totalSnapshots: Int
}

struct WorkspaceStatistics: Codable {
    let version: String
    let timestamp: Date
    let projectCount: Int
    let moduleCount: Int
    let fileCount: Int
    let gitRepoCount: Int
    let xcodeProjectCount: Int
    let pdfCount: Int
    let scriptCount: Int
    let databaseCount: Int
    let decisionCount: Int
    let evidenceCount: Int
    let conversationCount: Int
    let missionCount: Int
    let archiveCount: Int
    let documentCount: Int
    let totalSizeBytes: Int64
    let lastIndexed: Date?
    let healthScore: Double
    let languages: [String: Int]
    let topDirectories: [String: Int]
    let typeBreakdown: [String: Int]
}
