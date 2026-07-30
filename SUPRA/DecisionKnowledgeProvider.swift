import Foundation

final class DecisionKnowledgeProvider: KnowledgeProvider {
    let sourceType: KnowledgeSourceType = .decision
    let displayName = "Decision Knowledge"

    private let workspacePath: String

    init(workspacePath: String = FileManager.default.currentDirectoryPath) {
        self.workspacePath = workspacePath
    }

    func discover() async -> [KnowledgeObject] {
        var objects: [KnowledgeObject] = []
        let projectName = URL(fileURLWithPath: workspacePath).lastPathComponent
        let baseURL = URL(fileURLWithPath: workspacePath)

        if let workspaceIndex = loadWorkspaceIndex() {
            let decisionObjects = workspaceIndex.objects.filter { $0.type == .decision || $0.type == .evidence || $0.type == .mission }

            for decision in decisionObjects {
                let decisionId: String
                let objType: KnowledgeObjectType
                switch decision.type {
                case .decision: decisionId = ensureId("decision:\(decision.id)"); objType = .decision
                case .evidence: decisionId = ensureId("evidence:\(decision.id)"); objType = .evidence
                case .mission: decisionId = ensureId("mission:\(decision.id)"); objType = .mission
                default: continue
                }

                let status: String?
                if decision.name.contains("SUCCESS") || decision.name.contains("passed") { status = "validated" }
                else if decision.name.contains("FAIL") || decision.name.contains("failed") { status = "rejected" }
                else { status = "pending" }

                objects.append(KnowledgeObject(
                    id: decisionId, source: sourceType.rawValue, type: objType,
                    title: decision.name,
                    summary: "\(objType.rawValue): \(decision.name) — \(status ?? "unknown")",
                    path: decision.path, project: projectName,
                    module: decision.projectName,
                    created: decision.dateModified, updated: decision.dateModified,
                    tags: [objType.rawValue, "decision", decision.projectName ?? "supra"].compactMap { $0 },
                    relations: [], authority: 0.85, confidence: 0.9,
                    status: status,
                    metadata: ["size_bytes": "\(decision.sizeBytes)", "hash": decision.hash]
                ))
            }
        }

        let opencodeURL = baseURL.appendingPathComponent(".opencode")
        let runtimeFiles = [
            "mission_center.json", "execution_pipeline.json", "builder_guard.json",
            "agent_permissions.json", "delegation_rules.json", "priority_engine.json",
            "runtime_bindings.json"
        ]
        let fm = FileManager.default
        for file in runtimeFiles {
            let url = opencodeURL.appendingPathComponent(file)
            guard fm.fileExists(atPath: url.path),
                  let attrs = try? fm.attributesOfItem(atPath: url.path),
                  let modDate = attrs[.modificationDate] as? Date
            else { continue }

            let configId = ensureId("opencode:\(file)")
            objects.append(KnowledgeObject(
                id: configId, source: "opencode", type: .file,
                title: file, summary: "OpenCode Runtime configuration: \(file)", path: url.path,
                project: projectName, module: "Runtime",
                created: attrs[.creationDate] as? Date, updated: modDate,
                tags: ["opencode", "runtime", "configuration", "json"],
                relations: [], authority: 0.95, confidence: 1.0,
                status: "active", metadata: ["format": "json"]
            ))
        }

        let freezeDirs = scanFreezeDirectories(in: baseURL)
        objects.append(contentsOf: freezeDirs)

        return objects
    }

    func relations() -> [KnowledgeRelation] { [] }

    private func loadWorkspaceIndex() -> WorkspaceIndex? {
        let url = URL(fileURLWithPath: workspacePath).appendingPathComponent("workspace_index.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder.workspace.decode(WorkspaceIndex.self, from: data)
    }

    private func scanFreezeDirectories(in baseURL: URL) -> [KnowledgeObject] {
        var objects: [KnowledgeObject] = []
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: [.contentModificationDateKey]) else { return objects }

        for item in contents where item.lastPathComponent.hasPrefix("FREEZE_") {
            guard let attrs = try? fm.attributesOfItem(atPath: item.path),
                  let modDate = attrs[.modificationDate] as? Date
            else { continue }

            let freezeId = ensureId("freeze:\(item.lastPathComponent)")
            objects.append(KnowledgeObject(
                id: freezeId, source: "freeze", type: .freeze,
                title: item.lastPathComponent,
                summary: "SUPRA Freeze: \(item.lastPathComponent.replacingOccurrences(of: "FREEZE_", with: ""))",
                path: item.path,
                project: URL(fileURLWithPath: workspacePath).lastPathComponent, module: "Freeze",
                created: attrs[.creationDate] as? Date, updated: modDate,
                tags: ["freeze", "snapshot", "archive"],
                relations: [], authority: 0.95, confidence: 1.0,
                status: "frozen", metadata: ["type": "freeze_directory"]
            ))

            let manifestURL = item.appendingPathComponent("FREEZE_MANIFEST.json")
            if fm.fileExists(atPath: manifestURL.path),
               let manifestAttrs = try? fm.attributesOfItem(atPath: manifestURL.path) {
                let manifestId = ensureId("freeze:manifest:\(item.lastPathComponent)")
                objects.append(KnowledgeObject(
                    id: manifestId, source: "freeze", type: .freezeManifest,
                    title: "FREEZE_MANIFEST (\(item.lastPathComponent))",
                    summary: "Freeze manifest for \(item.lastPathComponent)", path: manifestURL.path,
                    project: URL(fileURLWithPath: workspacePath).lastPathComponent, module: "Freeze",
                    created: manifestAttrs[.creationDate] as? Date, updated: manifestAttrs[.modificationDate] as? Date,
                    tags: ["freeze", "manifest", "json"],
                    relations: [KnowledgeRelation(sourceId: manifestId, targetId: freezeId, type: .belongsTo, weight: 1.0)],
                    authority: 1.0, confidence: 1.0,
                    status: "frozen", metadata: ["format": "json"]
                ))
            }
        }

        return objects
    }
}
