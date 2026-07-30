import Foundation
import Combine

// MARK: - Ω2 — Vision Engine
//
// The perceptual faculty of SUPRA's living runtime.
// The Vision Engine observes the external world:
// - The project filesystem
// - Git repository state
// - Xcode build state
// - Runtime providers
// - Memory state
// - Mission state
// - Build and test state
// - System health
//
// It transforms raw observation into structured perception
// that feeds the Executive Context Snapshot.

public enum VisionEngineStatus: String, Sendable, Codable, CaseIterable {
    case uninitialized
    case starting
    case watching
    case paused
    case degraded
    case failed
}

@MainActor
public final class VisionEngine: ObservableObject, ExecutiveEngine {
    public static let shared = VisionEngine()

    // MARK: - Executive Engine Conformance

    public let engineID = "vision-engine"
    public let engineName = "Vision Engine"
    @Published public private(set) var status: ExecutiveEngineStatus = .uninitialized
    public var statusPublisher: Published<ExecutiveEngineStatus>.Publisher { $status }

    // MARK: - Vision State

    @Published public private(set) var isWatching: Bool = false
    @Published public private(set) var observedPaths: [String] = []
    @Published public private(set) var lastFileChange: Date?
    @Published public private(set) var lastGitChange: Date?
    @Published public private(set) var fileChangeCount: Int = 0
    @Published public private(set) var gitChangeCount: Int = 0
    @Published public private(set) var activeBranches: [String] = []
    @Published public private(set) var recentCommits: [String] = []
    @Published public private(set) var projectHealth: String = "unknown"
    @Published public private(set) var watcherStatus: String = "uninitialized"

    /// File watcher health
    @Published public private(set) var watcherHealthy: Bool = false

    // MARK: - Watcher Timers

    private var fileWatcherTimer: Timer?
    private var gitWatcherTimer: Timer?
    private var healthTimer: Timer?
    private let eventBus = ExecutiveEventBus.shared
    private let fileManager = FileManager.default

    // MARK: - Observed State Snapshots

    private var lastFileState: [String: Date] = [:]
    private var lastGitState: String = ""
    private var lastBuildState: String = ""

    private init() {}

    // MARK: - Executive Engine Boot

    public func boot() async throws {
        status = .initializing
        watcherStatus = "starting"

        eventBus.emit(.visionStarted, source: engineID, detail: "Vision Engine boot sequence started")

        // Configure observation paths
        let projectRoot = FileManager.default.currentDirectoryPath
        observedPaths = [
            projectRoot,
            projectRoot + "/SUPRA",
            projectRoot + "/.kernel",
            projectRoot + "/FACTORIES",
            projectRoot + "/Artifacts",
            projectRoot + "/SUPRA.xcodeproj"
        ]

        // Start watchers
        startFileWatcher()
        startGitWatcher()
        startHealthMonitor()

        isWatching = true
        watcherHealthy = true
        watcherStatus = "watching"
        status = .active

        eventBus.emit(.visionObserving, source: engineID, detail: "Vision Engine is now observing \(observedPaths.count) paths", metadata: ["paths": observedPaths.joined(separator: ",")])
    }

    public func shutdown() async throws {
        fileWatcherTimer?.invalidate()
        gitWatcherTimer?.invalidate()
        healthTimer?.invalidate()
        fileWatcherTimer = nil
        gitWatcherTimer = nil
        healthTimer = nil

        isWatching = false
        watcherHealthy = false
        watcherStatus = "shutdown"
        status = .uninitialized

        eventBus.emit(.visionDegraded, source: engineID, detail: "Vision Engine shutdown")
    }

    public func healthCheck() async -> ExecutiveEngineStatus {
        let fileWatcherRunning = fileWatcherTimer?.isValid ?? false
        let gitWatcherRunning = gitWatcherTimer?.isValid ?? false

        if !fileWatcherRunning || !gitWatcherRunning {
            watcherHealthy = false
            watcherStatus = "degraded"
            status = .degraded
            eventBus.emit(.visionDegraded, source: engineID, detail: "One or more watchers are not running")
            return .degraded
        }

        watcherHealthy = true
        watcherStatus = "watching"
        status = .active
        return .active
    }

    public func reset() async throws {
        await shutdown()
        try await boot()
    }

    // MARK: - Observation Control

    public func pause() {
        guard isWatching else { return }
        fileWatcherTimer?.invalidate()
        gitWatcherTimer?.invalidate()
        isWatching = false
        watcherStatus = "paused"
        status = .degraded
        eventBus.emit(.visionDegraded, source: engineID, detail: "Vision Engine paused")
    }

    public func resume() {
        guard !isWatching else { return }
        startFileWatcher()
        startGitWatcher()
        isWatching = true
        watcherStatus = "watching"
        status = .active
        eventBus.emit(.visionRecovered, source: engineID, detail: "Vision Engine resumed")
    }

    // MARK: - Manual Observation Triggers

    public func observeNow() {
        scanFileChanges()
        scanGitChanges()
    }

    // MARK: - File Watcher

    private func startFileWatcher() {
        fileWatcherTimer?.invalidate()
        fileWatcherTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.scanFileChanges()
            }
        }
    }

    private func scanFileChanges() {
        let swiftFiles = findSwiftFiles()
        var changedCount = 0

        for filePath in swiftFiles {
            let url = URL(fileURLWithPath: filePath)
            guard let attrs = try? fileManager.attributesOfItem(atPath: filePath),
                  let modDate = attrs[.modificationDate] as? Date else { continue }

            if let lastMod = lastFileState[filePath] {
                if modDate != lastMod {
                    changedCount += 1
                    lastFileState[filePath] = modDate
                    lastFileChange = modDate
                    eventBus.emit(.visionFileChanged, source: engineID, detail: "File changed: \(url.lastPathComponent)", metadata: ["file": url.lastPathComponent, "path": filePath])
                }
            } else {
                lastFileState[filePath] = modDate
            }
        }

        if changedCount > 0 {
            fileChangeCount += changedCount
            eventBus.emit(.visionDetectedChange, source: engineID, detail: "\(changedCount) file(s) changed")
        }
    }

    private func findSwiftFiles() -> [String] {
        let projectDir = FileManager.default.currentDirectoryPath + "/SUPRA"
        guard let enumerator = fileManager.enumerator(atPath: projectDir) else { return [] }
        var files: [String] = []
        for case let path as String in enumerator {
            if path.hasSuffix(".swift") {
                files.append(projectDir + "/" + path)
            }
        }
        return files
    }

    // MARK: - Git Watcher

    private func startGitWatcher() {
        gitWatcherTimer?.invalidate()
        gitWatcherTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.scanGitChanges()
            }
        }
    }

    private func scanGitChanges() {
        let projectDir = FileManager.default.currentDirectoryPath

        // Check branch
        let branch = shell("cd \"\(projectDir)\" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo \"unknown\"")
        if !branch.isEmpty {
            let branches = branch.split(separator: "\n").map(String.init)
            activeBranches = branches
        }

        // Check recent commits
        let log = shell("cd \"\(projectDir)\" && git log --oneline -5 2>/dev/null || echo \"\"")
        if !log.isEmpty {
            let commits = log.split(separator: "\n").map(String.init)
            recentCommits = commits
        }

        // Check for changes
        let status = shell("cd \"\(projectDir)\" && git status --porcelain 2>/dev/null || echo \"\"")

        if status != lastGitState {
            let changedCount = status.split(separator: "\n").count
            if changedCount > 0 {
                gitChangeCount += changedCount
                lastGitChange = Date()
                eventBus.emit(.visionGitChanged, source: engineID, detail: "Git state changed: \(changedCount) file(s)", metadata: ["count": "\(changedCount)"])
            }
            lastGitState = status
        }
    }

    // MARK: - Health Monitor

    private func startHealthMonitor() {
        healthTimer?.invalidate()
        healthTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.checkProjectHealth()
            }
        }
    }

    private func checkProjectHealth() async {
        let projectDir = FileManager.default.currentDirectoryPath

        // Check Xcode project exists
        let xcodeExists = fileManager.fileExists(atPath: projectDir + "/SUPRA.xcodeproj")
        // Check Packages
        let packagesExist = fileManager.fileExists(atPath: projectDir + "/Packages")
        // Check kernel
        let kernelExists = fileManager.fileExists(atPath: projectDir + "/.kernel")

        let healthComponents = [xcodeExists, packagesExist, kernelExists]
        let healthyCount = healthComponents.filter { $0 }.count

        switch healthyCount {
        case 3: projectHealth = "healthy"
        case 2: projectHealth = "degraded"
        case 1: projectHealth = "unhealthy"
        default: projectHealth = "critical"
        }

        eventBus.emit(.visionHealthChanged, source: engineID, detail: "Project health: \(projectHealth)")
    }

    // MARK: - Shell Helper

    private func shell(_ command: String) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]

        let output = Pipe()
        process.standardOutput = output

        do {
            try process.run()
            process.waitUntilExit()
            let data = output.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        } catch {
            return ""
        }
    }
}
