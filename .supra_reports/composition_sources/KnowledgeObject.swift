// ==================================================
// SOURCE : ./SUPRA/KnowledgeObject.swift
// ==================================================

import Foundation

enum KnowledgeObjectType: String, Codable, CaseIterable, Identifiable {
    case file, directory, gitRepository = "git_repository", gitCommit = "git_commit"
    case gitBranch = "git_branch", gitTag = "git_tag"
    case conversation, message, report, audit, validation
    case pdf, document, decision, evidence
    case freeze, freezeManifest = "freeze_manifest"
    case artifact, artifactResult = "artifact_result"
    case archive, zip, tar, gz
    case module, project, mission, script
    case image, database, log, unknown

    var id: String { rawValue }
}

struct KnowledgeObject: Identifiable, Codable, Equatable {
    let id: String
    let source: String
    let type: KnowledgeObjectType
    let title: String
    let summary: String
    let path: String
    let project: String?
    let module: String?
    let created: Date?
    let updated: Date?
    var tags: [String]
    var relations: [KnowledgeRelation]
    var authority: Double
    var confidence: Double
    var status: String?
    var metadata: [String: String]

    static func == (lhs: KnowledgeObject, rhs: KnowledgeObject) -> Bool { lhs.id == rhs.id }
}

struct KnowledgeGraphData: Codable {
    let version: String
    let generated: Date
    let objects: [KnowledgeObject]
    let statistics: KnowledgeGraphStatistics
}

struct KnowledgeGraphStatistics: Codable {
    let totalObjects: Int
    let totalRelations: Int
    let sourceBreakdown: [String: Int]
    let typeBreakdown: [String: Int]
    let authorityDistribution: [String: Int]
    let topProjects: [String: Int]
    let healthScore: Double
}
