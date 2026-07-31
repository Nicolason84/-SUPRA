import Foundation

final class ConversationKnowledgeProvider: KnowledgeProvider {
    let sourceType: KnowledgeSourceType = .conversation
    let displayName = "Conversation Knowledge"

    private let workspacePath: String

    init(workspacePath: String = FileManager.default.currentDirectoryPath) {
        self.workspacePath = workspacePath
    }

    func discover() async -> [KnowledgeObject] {
        var objects: [KnowledgeObject] = []
        let projectName = URL(fileURLWithPath: workspacePath).lastPathComponent

        let chatPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/com.openai.chat")

        if FileManager.default.fileExists(atPath: chatPath.path) {
            let convId = ensureId("chatgpt:library")
            objects.append(KnowledgeObject(
                id: convId, source: sourceType.rawValue, type: .conversation,
                title: "ChatGPT Conversation Store", summary: "ChatGPT conversation data available at ~/Library",
                path: chatPath.path, project: nil, module: nil,
                created: nil, updated: nil,
                tags: ["chatgpt", "conversation", "openai"],
                relations: [], authority: 0.5, confidence: 0.6,
                status: "available", metadata: ["note": "Metadata only - content not loaded"]
            ))
        }

        let missionFiles = [
            "SUPRA_EXECUTIVE_COCKPIT_V1_REPORT.md",
            "SUPRA_EXECUTIVE_COCKPIT_V2_REPORT.md",
            "SUPRA_EXECUTIVE_COCKPIT_V3_REPORT.md",
            "SUPRA_WORKSPACE_INTELLIGENCE_V1_REPORT.md"
        ]

        let baseURL = URL(fileURLWithPath: workspacePath)
        for file in missionFiles {
            let url = baseURL.appendingPathComponent("SUPRA").appendingPathComponent(file)
            guard FileManager.default.fileExists(atPath: url.path),
                  let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                  let modDate = attrs[.modificationDate] as? Date
            else { continue }

            let reportId = ensureId("report:\(file)")
            let name = file.replacingOccurrences(of: "SUPRA_", with: "").replacingOccurrences(of: "_REPORT.md", with: "").replacingOccurrences(of: "_", with: " ")

            objects.append(KnowledgeObject(
                id: reportId, source: "report", type: .report,
                title: file, summary: "SUPRA Mission Report: \(name)", path: url.path,
                project: projectName, module: "Cockpit",
                created: nil, updated: modDate,
                tags: ["report", "mission", "supra"],
                relations: [], authority: 0.9, confidence: 1.0,
                status: "active", metadata: ["format": "markdown", "lines": "\((try? String(contentsOf: url, encoding: .utf8))?.components(separatedBy: .newlines).count ?? 0)"]
            ))
        }

        let conversationFiles = scanConversationFiles(in: baseURL)
        objects.append(contentsOf: conversationFiles)

        return objects
    }

    func relations() -> [KnowledgeRelation] { [] }

    private func scanConversationFiles(in baseURL: URL) -> [KnowledgeObject] {
        var objects: [KnowledgeObject] = []
        let fm = FileManager.default

        let chatMarkers = ["CHAT", "chat", "conversation", "Conversation", "message", "Message"]
        if let files = try? fm.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) {
            for file in files where chatMarkers.contains(where: { file.lastPathComponent.contains($0) }) {
                guard let attrs = try? fm.attributesOfItem(atPath: file.path),
                      let modDate = attrs[.modificationDate] as? Date
                else { continue }

                let convId = ensureId("conversation:\(file.lastPathComponent)")
                objects.append(KnowledgeObject(
                    id: convId, source: sourceType.rawValue, type: .conversation,
                    title: file.lastPathComponent, summary: "Conversation artifact: \(file.lastPathComponent)", path: file.path,
                    project: URL(fileURLWithPath: workspacePath).lastPathComponent, module: nil,
                    created: attrs[.creationDate] as? Date, updated: modDate,
                    tags: ["conversation", "artifact"],
                    relations: [], authority: 0.6, confidence: 0.7,
                    status: "found", metadata: ["format": file.pathExtension]
                ))
            }
        }

        return objects
    }
}
