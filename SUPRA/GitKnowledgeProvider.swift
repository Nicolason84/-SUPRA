import Foundation

final class GitKnowledgeProvider: KnowledgeProvider {
    let sourceType: KnowledgeSourceType = .git
    let displayName = "Git Knowledge"

    private let repoPath: String

    init(repoPath: String = FileManager.default.currentDirectoryPath) {
        self.repoPath = repoPath
    }

    func discover() async -> [KnowledgeObject] {
        var objects: [KnowledgeObject] = []

        let repoName = URL(fileURLWithPath: repoPath).lastPathComponent

        let repoId = ensureId("repo:\(repoName)")
        objects.append(KnowledgeObject(
            id: repoId, source: sourceType.rawValue, type: .gitRepository,
            title: repoName, summary: "Git repository: \(repoName)", path: repoPath,
            project: repoName, module: nil,
            created: nil, updated: nil,
            tags: ["git", "repository", repoName],
            relations: [], authority: 1.0, confidence: 1.0,
            status: "active", metadata: ["branch_count": "0", "commit_count": "0"]
        ))

        let branches = runGit(["branch", "-a"])
        for branch in branches.components(separatedBy: "\n").map({ $0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "* ", with: "") }).filter({ !$0.isEmpty }) {
            let branchId = ensureId("branch:\(branch)")
            objects.append(KnowledgeObject(
                id: branchId, source: sourceType.rawValue, type: .gitBranch,
                title: branch, summary: "Git branch: \(branch)", path: repoPath,
                project: repoName, module: nil,
                created: nil, updated: nil,
                tags: ["git", "branch", branch],
                relations: [KnowledgeRelation(sourceId: branchId, targetId: repoId, type: .belongsTo, weight: 1.0)],
                authority: 0.9, confidence: 1.0,
                status: branch == "develop" ? "active" : branch == "main" || branch == "master" ? "active" : "inactive",
                metadata: [:]
            ))
        }

        let logOutput = runGit(["log", "--all", "--oneline", "--format=%H|%an|%ai|%s", "-50"])
        for line in logOutput.components(separatedBy: "\n").filter({ !$0.isEmpty }) {
            let parts = line.components(separatedBy: "|")
            guard parts.count >= 4 else { continue }
            let hash = parts[0], author = parts[1], dateStr = parts[2], message = parts[3]
            let commitId = ensureId("commit:\(hash.prefix(8))")
            let shortHash = String(hash.prefix(8))

            let commitFileOutput = runGit(["diff-tree", "--no-commit-id", "--name-only", "-r", hash])
            let files = commitFileOutput.components(separatedBy: "\n").filter({ !$0.isEmpty })

            objects.append(KnowledgeObject(
                id: commitId, source: sourceType.rawValue, type: .gitCommit,
                title: "\(shortHash): \(message)", summary: "Commit by \(author): \(message)", path: repoPath,
                project: repoName, module: nil,
                created: date(from: dateStr), updated: nil,
                tags: ["git", "commit", shortHash, author.components(separatedBy: "@").first ?? author] + files.prefix(3).map { "file:\($0)" },
                relations: [KnowledgeRelation(sourceId: commitId, targetId: repoId, type: .belongsTo, weight: 1.0)],
                authority: 0.95, confidence: 1.0,
                status: "applied",
                metadata: ["hash": hash, "author": author, "files_changed": "\(files.count)"]
            ))
        }

        let tagOutput = runGit(["tag"])
        for tag in tagOutput.components(separatedBy: "\n").filter({ !$0.isEmpty }) {
            let tagId = ensureId("tag:\(tag)")
            objects.append(KnowledgeObject(
                id: tagId, source: sourceType.rawValue, type: .gitTag,
                title: tag, summary: "Git tag: \(tag)", path: repoPath,
                project: repoName, module: nil,
                created: nil, updated: nil,
                tags: ["git", "tag", tag],
                relations: [KnowledgeRelation(sourceId: tagId, targetId: repoId, type: .belongsTo, weight: 1.0)],
                authority: 0.9, confidence: 1.0,
                status: "active", metadata: [:]
            ))
        }

        return objects
    }

    func relations() -> [KnowledgeRelation] { [] }

    private func runGit(_ args: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: repoPath)
        let pipe = Pipe()
        process.standardOutput = pipe
        try? process.run()
        process.waitUntilTimeout(5)
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension Process {
    func waitUntilTimeout(_ seconds: TimeInterval) {
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
            if self.isRunning { self.terminate() }
            group.leave()
        }
        waitUntilExit()
    }
}
