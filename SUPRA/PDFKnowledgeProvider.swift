import Foundation

final class PDFKnowledgeProvider: KnowledgeProvider {
    let sourceType: KnowledgeSourceType = .pdf
    let displayName = "PDF Knowledge"

    private let workspacePath: String

    init(workspacePath: String = FileManager.default.currentDirectoryPath) {
        self.workspacePath = workspacePath
    }

    func discover() async -> [KnowledgeObject] {
        var objects: [KnowledgeObject] = []
        let projectName = URL(fileURLWithPath: workspacePath).lastPathComponent

        if let workspaceIndex = loadWorkspaceIndex() {
            let pdfObjects = workspaceIndex.objects.filter { $0.type == .pdf }

            for pdfObj in pdfObjects {
                let pdfId = ensureId("pdf:\(pdfObj.id)")
                let url = URL(fileURLWithPath: pdfObj.path)

                let metadata = extractPDFMetadata(at: url)

                objects.append(KnowledgeObject(
                    id: pdfId, source: sourceType.rawValue, type: .pdf,
                    title: pdfObj.name,
                    summary: metadata["author"].flatMap { "PDF by \($0)" } ?? "PDF: \(pdfObj.name)",
                    path: pdfObj.path,
                    project: projectName,
                    module: inferModule(from: pdfObj.path),
                    created: pdfObj.dateCreated,
                    updated: pdfObj.dateModified,
                    tags: ["pdf", "document"] + (metadata["author"].map { ["author:\($0)"] } ?? []),
                    relations: [], authority: 0.7, confidence: 0.8,
                    status: "indexed",
                    metadata: metadata
                ))
            }
        }

        return objects
    }

    func relations() -> [KnowledgeRelation] { [] }

    private func loadWorkspaceIndex() -> WorkspaceIndex? {
        let url = URL(fileURLWithPath: workspacePath).appendingPathComponent("workspace_index.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder.workspace.decode(WorkspaceIndex.self, from: data)
    }

    private func extractPDFMetadata(at url: URL) -> [String: String] {
        var meta: [String: String] = [:]
        meta["format"] = "pdf"

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/mdls")
        task.arguments = ["-name", "kMDItemAuthors", "-name", "kMDItemTitle",
                          "-name", "kMDItemHeadline", "-name", "kMDItemNumberOfPages",
                          url.path]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilTimeout(3)

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        for line in output.components(separatedBy: "\n") {
            if line.contains("kMDItemAuthors") {
                meta["author"] = line.components(separatedBy: "=").last?.trimmingCharacters(in: .whitespaces) ?? "unknown"
            } else if line.contains("kMDItemTitle") {
                meta["pdf_title"] = line.components(separatedBy: "=").last?.trimmingCharacters(in: .whitespaces) ?? "unknown"
            } else if line.contains("kMDItemNumberOfPages") {
                meta["pages"] = line.components(separatedBy: "=").last?.trimmingCharacters(in: .whitespaces) ?? "?"
            }
        }

        return meta
    }

    private func inferModule(from path: String) -> String? {
        let p = path.lowercased()
        if p.contains("supra_video_swap") { return "Video Swap" }
        if p.contains("nova_os") || p.contains("supra/") { return "SUPRA" }
        if p.contains("desktop_clean_archive") { return "Archive" }
        if p.contains("documents") { return "Documents" }
        return nil
    }
}
