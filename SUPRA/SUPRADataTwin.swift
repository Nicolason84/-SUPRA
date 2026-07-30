import Foundation
import Combine

struct DataSnapshot {
    let projectCount: Int
    let documentCount: Int
    let archiveCount: Int
    let totalSizeGB: Double
    let duplicateCount: Int
    let largeFileCount: Int
    let activeFolderCount: Int
    let largestDirectories: [String]
    let timestamp: Date
}

@MainActor
final class SUPRADataTwin: ObservableObject {
    static let shared = SUPRADataTwin()

    @Published private(set) var snapshot: DataSnapshot?
    @Published private(set) var isCollecting = false
    @Published private(set) var lastError: String?

    private var cached: DataSnapshot?
    private var lastHash = 0
    private let ttl: TimeInterval = 120

    private let coordinator = ProtectedFolderAccessCoordinator.shared

    private init() {}

    func refresh() {
        isCollecting = true
        let h = collectHash()
        guard h != lastHash || snapshot == nil else { isCollecting = false; return }
        lastHash = h
        let s = gather(from: coordinator.snapshot)
        cached = s
        snapshot = s
        lastError = coordinator.lastError
        isCollecting = false
    }

    private func collectHash() -> Int {
        var h = Hasher()
        h.combine(Int(Date().timeIntervalSince1970 / 120))
        return h.finalize()
    }

    private func gather(from protectedSnapshot: ProtectedFolderSnapshot) -> DataSnapshot {
        let entries = protectedSnapshot.entries
        let projectIndicators = Set(["package.swift", "cargo.toml", "go.mod", "podfile"])
        let projectRoots = Set(entries.compactMap { entry -> String? in
            let lower = entry.name.lowercased()
            guard lower == ".git" || lower.hasSuffix(".xcodeproj") || projectIndicators.contains(lower) else { return nil }
            return URL(fileURLWithPath: entry.path).deletingLastPathComponent().path
        })
        let documentExtensions = Set(["pdf", "doc", "docx", "txt", "md", "rtf", "pages", "key", "numbers", "csv", "json", "xml"])
        let archiveExtensions = Set(["zip", "tar", "gz", "bz2", "7z", "rar", "dmg", "iso"])
        let documents = entries.filter { !$0.isDirectory && documentExtensions.contains($0.pathExtension) }
        let archives = entries.filter { !$0.isDirectory && archiveExtensions.contains($0.pathExtension) }
        let largeFiles = entries.filter { !$0.isDirectory && $0.sizeBytes > 100 * 1_048_576 }
        let duplicateGroups = Dictionary(grouping: entries.filter { !$0.isDirectory }) {
            "\($0.name)_\($0.sizeBytes)"
        }.values.filter { $0.count > 1 }.count
        let recentFolders = entries.filter(\.isDirectory)
            .sorted { ($0.modifiedAt ?? .distantPast) > ($1.modifiedAt ?? .distantPast) }

        return DataSnapshot(
            projectCount: projectRoots.count,
            documentCount: documents.count,
            archiveCount: archives.count,
            totalSizeGB: Double(entries.reduce(Int64(0)) { $0 + $1.sizeBytes }) / 1_073_741_824,
            duplicateCount: duplicateGroups,
            largeFileCount: largeFiles.count,
            activeFolderCount: recentFolders.count,
            largestDirectories: Array(recentFolders.prefix(10).map(\.path)),
            timestamp: protectedSnapshot.generatedAt
        )
    }
}
