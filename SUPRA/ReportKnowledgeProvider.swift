import Foundation

final class ReportKnowledgeProvider: KnowledgeProvider {
    let sourceType: KnowledgeSourceType = .report
    let displayName = "Report Knowledge"

    private let workspacePath: String

    init(workspacePath: String = FileManager.default.currentDirectoryPath) {
        self.workspacePath = workspacePath
    }

    func discover() async -> [KnowledgeObject] {
        var objects: [KnowledgeObject] = []
        let projectName = URL(fileURLWithPath: workspacePath).lastPathComponent
        let baseURL = URL(fileURLWithPath: workspacePath)

        let reportPatterns = ["REPORT", "AUDIT", "VALIDATION", "DIAGNOSTIC", "PROBE", "CHECK", "VERIFICATION"]

        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .creationDateKey]) else {
            return objects
        }

        for file in files {
            let name = file.lastPathComponent
            guard reportPatterns.contains(where: { name.contains($0) }),
                  file.pathExtension == "json" || file.pathExtension == "md" || file.pathExtension == "txt"
            else { continue }

            guard let attrs = try? fm.attributesOfItem(atPath: file.path),
                  let modDate = attrs[.modificationDate] as? Date,
                  let fileSize = attrs[.size] as? Int
            else { continue }

            let reportType: KnowledgeObjectType = name.contains("AUDIT") ? .audit :
                name.contains("VALIDATION") ? .validation : .report

            let reportId = ensureId("report:\(name)")
            let title = name.replacingOccurrences(of: ".json", with: "").replacingOccurrences(of: ".md", with: "").replacingOccurrences(of: "_", with: " ")

            objects.append(KnowledgeObject(
                id: reportId, source: sourceType.rawValue, type: reportType,
                title: title, summary: "\(reportType.rawValue.capitalized): \(title)", path: file.path,
                project: projectName, module: inferModule(from: name),
                created: attrs[.creationDate] as? Date, updated: modDate,
                tags: [reportType.rawValue, "report", file.pathExtension],
                relations: [], authority: 0.9, confidence: 1.0,
                status: "active", metadata: ["size_bytes": "\(fileSize)", "format": file.pathExtension]
            ))
        }

        let agentResultsURL = baseURL.appendingPathComponent("agent_results")
        if fm.fileExists(atPath: agentResultsURL.path),
           let agentFiles = try? fm.contentsOfDirectory(at: agentResultsURL, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) {
            for file in agentFiles where file.pathExtension == "json" {
                guard let attrs = try? fm.attributesOfItem(atPath: file.path),
                      let modDate = attrs[.modificationDate] as? Date
                else { continue }

                let artId = ensureId("artifact:\(file.lastPathComponent)")
                objects.append(KnowledgeObject(
                    id: artId, source: "artifact", type: .artifactResult,
                    title: file.lastPathComponent, summary: "Agent execution artifact: \(file.lastPathComponent)", path: file.path,
                    project: projectName, module: "Agents",
                    created: attrs[.creationDate] as? Date, updated: modDate,
                    tags: ["artifact", "agent", "execution", "json"],
                    relations: [], authority: 0.85, confidence: 1.0,
                    status: "archived", metadata: ["format": "json"]
                ))
            }
        }

        return objects
    }

    func relations() -> [KnowledgeRelation] { [] }

    private func inferModule(from name: String) -> String? {
        if name.contains("COCKPIT") || name.contains("Cockpit") { return "Cockpit" }
        if name.contains("WORKSPACE") || name.contains("Workspace") { return "Workspace Intelligence" }
        if name.contains("RUNTIME") || name.contains("Runtime") { return "Runtime" }
        if name.contains("MISSION") || name.contains("Mission") { return "Mission Center" }
        if name.contains("PROVIDER") || name.contains("Provider") { return "Provider Runtime" }
        if name.contains("BUILD") || name.contains("Build") { return "Build" }
        if name.contains("GRAPH") || name.contains("Graph") { return "Knowledge Graph" }
        return nil
    }
}
