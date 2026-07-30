import Foundation
import Combine

@MainActor
final class WorkspaceStatisticsService: ObservableObject {
    @Published var stats: WorkspaceStatistics?
    @Published var isComputing = false

    func compute(from index: WorkspaceIndex) -> WorkspaceStatistics {
        isComputing = true

        let objects = index.objects
        let projectCount = objects.filter { $0.type == .project }.count
        let moduleCount = objects.filter { $0.type == .module }.count
        let fileCount = objects.filter { $0.type != .directory && $0.type != .gitRepository }.count
        let gitRepoCount = objects.filter { $0.type == .gitRepository }.count
        let xcodeProjectCount = objects.filter { $0.type == .xcodeProject }.count
        let pdfCount = objects.filter { $0.type == .pdf }.count
        let scriptCount = objects.filter { $0.type == .script }.count
        let databaseCount = objects.filter { $0.type == .database }.count
        let decisionCount = objects.filter { $0.type == .decision }.count
        let evidenceCount = objects.filter { $0.type == .evidence }.count
        let conversationCount = objects.filter { $0.type == .conversation }.count
        let missionCount = objects.filter { $0.type == .mission }.count
        let archiveCount = objects.filter { $0.type == .archive }.count
        let documentCount = objects.filter { $0.type == .document }.count

        let totalSize = objects.reduce(0) { $0 + $1.sizeBytes }

        var languages: [String: Int] = [:]
        for obj in objects {
            if let lang = obj.language {
                languages[lang, default: 0] += 1
            }
        }

        var topDirs: [String: Int] = [:]
        for obj in objects {
            let dir = URL(fileURLWithPath: obj.path).deletingLastPathComponent().path
            let components = dir.split(separator: "/").suffix(2).joined(separator: "/")
            topDirs[components, default: 0] += 1
        }

        var typeBreakdown: [String: Int] = [:]
        for obj in objects {
            typeBreakdown[obj.type.rawValue, default: 0] += 1
        }

        let successRate: Double = {
            let total = decisionCount + evidenceCount + missionCount
            guard total > 0 else { return 1.0 }
            return min(Double(decisionCount + evidenceCount) / Double(total), 1.0)
        }()

        let coverage = min(Double(objects.count) / 1000.0, 1.0)
        let healthScore = (successRate * 0.4 + coverage * 0.3 + 0.3) * 10.0

        stats = WorkspaceStatistics(
            version: "1.0.0",
            timestamp: Date(),
            projectCount: projectCount,
            moduleCount: moduleCount,
            fileCount: fileCount,
            gitRepoCount: gitRepoCount,
            xcodeProjectCount: xcodeProjectCount,
            pdfCount: pdfCount,
            scriptCount: scriptCount,
            databaseCount: databaseCount,
            decisionCount: decisionCount,
            evidenceCount: evidenceCount,
            conversationCount: conversationCount,
            missionCount: missionCount,
            archiveCount: archiveCount,
            documentCount: documentCount,
            totalSizeBytes: totalSize,
            lastIndexed: index.timestamp,
            healthScore: healthScore,
            languages: languages,
            topDirectories: topDirs.sorted(by: { $0.value > $1.value }).prefix(10).reduce(into: [:]) { $0[$1.key] = $1.value },
            typeBreakdown: typeBreakdown
        )

        isComputing = false
        saveToDisk()
        return stats!
    }

    private func saveToDisk() {
        guard let stats = stats else { return }
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("workspace_statistics.json")
        guard let data = try? JSONEncoder.workspace.encode(stats) else { return }
        try? data.write(to: url)
    }
}
