import Foundation
import Combine

struct DeveloperSnapshot {
    let xcodeDetected: Bool
    let xcodeVersion: String?
    let xcodePath: String?
    let derivedDataSizeMB: Int
    let swiftPackageCount: Int
    let gitRepositoryCount: Int
    let totalBranches: Int
    let uncommittedRepos: Int
    let swiftFileCount: Int
    let projectCount: Int
    let recentProjects: [String]
    let timestamp: Date
}

@MainActor
final class SUPRADeveloperTwin: ObservableObject {
    static let shared = SUPRADeveloperTwin()

    @Published private(set) var snapshot: DeveloperSnapshot?
    @Published private(set) var isCollecting = false
    @Published private(set) var lastError: String?

    private var cached: DeveloperSnapshot?
    private var lastHash = 0
    private let ttl: TimeInterval = 120
    private let coordinator = ProtectedFolderAccessCoordinator.shared

    private init() {}

    func refresh() {
        isCollecting = true
        let h = collectHash()
        guard h != lastHash || snapshot == nil else { isCollecting = false; return }
        lastHash = h
        do {
            let s = try gather()
            cached = s
            snapshot = s
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
        isCollecting = false
    }

    private func collectHash() -> Int {
        var h = Hasher()
        h.combine(Int(Date().timeIntervalSince1970 / 120))
        return h.finalize()
    }

    private func gather() throws -> DeveloperSnapshot {
        let fm = FileManager.default

        let xcodePath = "/Applications/Xcode.app"
        let xcodeDetected = fm.fileExists(atPath: xcodePath)
        let xcodeVersion = try? shell("/usr/bin/xcodebuild -version 2>/dev/null | head -1")

        let entries = coordinator.snapshot.entries
        let repos = Set(entries.filter { $0.isDirectory && $0.name == ".git" }
            .map { URL(fileURLWithPath: $0.path).deletingLastPathComponent().path })
        let packages = entries.filter { !$0.isDirectory && $0.name == "Package.swift" }
        let swiftFiles = entries.filter { !$0.isDirectory && $0.pathExtension == "swift" }
        let projects = entries.filter { $0.name.hasSuffix(".xcodeproj") }

        return DeveloperSnapshot(
            xcodeDetected: xcodeDetected,
            xcodeVersion: xcodeVersion?.trimmingCharacters(in: .whitespacesAndNewlines),
            xcodePath: xcodeDetected ? xcodePath : nil,
            derivedDataSizeMB: 0,
            swiftPackageCount: packages.count,
            gitRepositoryCount: repos.count,
            totalBranches: 0,
            uncommittedRepos: 0,
            swiftFileCount: swiftFiles.count,
            projectCount: projects.count,
            recentProjects: Array(projects.prefix(10).map(\.path)),
            timestamp: coordinator.snapshot.generatedAt
        )
    }

    private func shell(_ cmd: String) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", cmd]
        let output = Pipe()
        process.standardOutput = output
        try process.run()
        process.waitUntilExit()
        return String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }
}
