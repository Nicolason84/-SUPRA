import Foundation

struct CAnnoNicoObject: Identifiable, Codable, Equatable {
    let id: String
    let type: CAnnoNicoType
    let source: CAnnoNicoSource
    let name: String
    let description: String
    let path: String?
    let project: String?
    let module: String?
    let created: String?
    let modified: String?
    let tags: [String]
    let authority: KnowledgeAuthority?
    let identity: KnowledgeIdentity?
    let lineage: KnowledgeLineage?
    let relations: [KnowledgeRelationship]
    let metadata: [String: String]

    static func == (lhs: CAnnoNicoObject, rhs: CAnnoNicoObject) -> Bool {
        lhs.id == rhs.id
    }
}

enum CAnnoNicoType: String, Codable, CaseIterable, Identifiable {
    case workspace, directory, file
    case swift, python, javascript, typescript, rust, go, cpp, c, java, kotlin
    case script, document, markdown, json, yaml, toml, xml, csv, sql
    case pdf, image, video, audio, archive
    case gitRepository = "git_repository"
    case gitBranch = "git_branch"
    case gitCommit = "git_commit"
    case gitTag = "git_tag"
    case xcodeProject = "xcode_project"
    case package, library, framework
    case database, log
    case report, audit, validation, diagnostic, probe, check, verification
    case mission, decision, evidence
    case artifactResult = "artifact_result"
    case freeze, freezeManifest = "freeze_manifest"
    case conversation
    case application, plugin, api
    case externalResource = "external_resource"
    case system, kernel, module, component
    case unknown

    var id: String { rawValue }
}

enum CAnnoNicoSource: String, Codable, CaseIterable, Identifiable {
    case workspace, git, report, artifact, freeze, decision
    case conversation, pdf, image, video, audio
    case system, external, unknown

    var id: String { rawValue }
}
