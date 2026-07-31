import Foundation
import Combine

// MARK: - Ω8 — Digital Twin Runtime
//
// The reflective layer of SUPRA's living runtime.
// The Digital Twin Runtime maintains a real-time twin of:
// - SUPRA's own system state
// - The project workspace
// - Connected services and their health
// - Current missions and decisions
// - System resources
//
// The twin syncs continuously, detects desyncs, and
// reports accuracy metrics.

public enum TwinSyncState: String, Sendable, Codable, CaseIterable {
    case uninitialized
    case syncing
    case synced
    case desynced
    case recovering
}

@MainActor
public final class DigitalTwinRuntime: ObservableObject, ExecutiveEngine {
    public static let shared = DigitalTwinRuntime()

    // MARK: - Executive Engine Conformance

    public let engineID = "digital-twin-runtime"
    public let engineName = "Digital Twin Runtime"
    @Published public private(set) var status: ExecutiveEngineStatus = .uninitialized
    public var statusPublisher: Published<ExecutiveEngineStatus>.Publisher { $status }

    // MARK: - Twin State

    @Published public private(set) var state: TwinSyncState = .uninitialized
    @Published public private(set) var isSynced: Bool = false
    @Published public private(set) var lastSync: Date?
    @Published public private(set) var desyncCount: Int = 0
    @Published public private(set) var syncAccuracy: Double = 0.0
    @Published public private(set) var twinAge: TimeInterval = 0

    /// Mirror of connected services
    @Published public private(set) var serviceMirror: [String: ServiceTwin] = [:]

    /// Mirror of system resources
    @Published public private(set) var resourceMirror: ResourceTwin

    /// Mirror of current missions
    @Published public private(set) var missionMirror: [String: MissionTwin] = [:]

    // MARK: - Twin Models

    public struct ServiceTwin: Sendable, Codable, Equatable {
        public let name: String
        public let isConnected: Bool
        public let version: String
        public let lastContact: Date?
        public let health: String

        public init(name: String, isConnected: Bool, version: String, lastContact: Date?, health: String) {
            self.name = name
            self.isConnected = isConnected
            self.version = version
            self.lastContact = lastContact
            self.health = health
        }
    }

    public struct ResourceTwin: Sendable, Codable, Equatable {
        public let cpuUsage: Double
        public let memoryUsed: UInt64
        public let memoryTotal: UInt64
        public let diskFree: Int64
        public let processCount: Int
        public let uptime: TimeInterval

        public static let initial = ResourceTwin(
            cpuUsage: 0,
            memoryUsed: 0,
            memoryTotal: 0,
            diskFree: 0,
            processCount: 0,
            uptime: 0
        )
    }

    public struct MissionTwin: Sendable, Codable, Equatable, Identifiable {
        public let id: String
        public let title: String
        public let status: String
        public let progress: Double
        public let startedAt: Date?

        public init(id: String, title: String, status: String, progress: Double, startedAt: Date?) {
            self.id = id
            self.title = title
            self.status = status
            self.progress = progress
            self.startedAt = startedAt
        }
    }

    // MARK: - Internal

    private var syncTimer: Timer?
    private let eventBus = ExecutiveEventBus.shared
    private let snapshotBus = ExecutiveSnapshotBus.shared
    private let fileManager = FileManager.default
    private var twinStartTime: Date?

    private init() {
        self.resourceMirror = .initial
    }

    // MARK: - Executive Engine Boot

    public func boot() async throws {
        status = .initializing
        state = .syncing
        twinStartTime = Date()

        eventBus.emit(.twinSyncing, source: engineID, detail: "Digital Twin sync started")

        // Initial sync
        await performSync()

        // Start periodic sync
        syncTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.performSync()
            }
        }

        state = .synced
        isSynced = true
        lastSync = Date()
        status = .active

        eventBus.emit(.twinSynced, source: engineID, detail: "Digital Twin is now synced")
    }

    public func shutdown() async throws {
        syncTimer?.invalidate()
        syncTimer = nil
        state = .uninitialized
        isSynced = false
        status = .uninitialized
    }

    public func healthCheck() async -> ExecutiveEngineStatus {
        guard syncTimer?.isValid ?? false else {
            status = .degraded
            return .degraded
        }

        let timeSinceLastSync = lastSync.map { Date().timeIntervalSince($0) } ?? 999
        if timeSinceLastSync > 30 {
            status = .degraded
            return .degraded
        }

        twinAge = twinStartTime.map { Date().timeIntervalSince($0) } ?? 0
        status = .active
        return .active
    }

    public func reset() async throws {
        try await shutdown()
        try await boot()
    }

    // MARK: - Sync

    public func performSync() async {
        let syncStart = Date()

        // Sync services
        await syncServices()

        // Sync resources
        syncResources()

        // Calculate accuracy
        let syncDuration = Date().timeIntervalSince(syncStart)
        syncAccuracy = max(0, min(1.0, 1.0 - (syncDuration / 10.0)))

        lastSync = Date()
        state = .synced
        isSynced = true

        if syncDuration > 2.0 {
            eventBus.emit(.twinDesyncDetected, source: engineID, detail: "Sync took \(String(format: "%.2f", syncDuration))s")
        }
    }

    private func syncServices() async {
        // Run all service probes OFF the main thread, in parallel.
        // Runtime Hang Investigation: the previous implementation spawned
        // synchronous subprocesses on the main thread every sync (boot + every
        // 10s), freezing the UI. Probes are now async, bounded, and concurrent.
        async let gitProbe = probeService("git --version 2>/dev/null || echo \"not found\"")
        async let xcodeProbe = probeService("xcode-select -p 2>/dev/null || echo \"not found\"")
        async let ollamaProbe = probeService("ollama --version 2>/dev/null || echo \"not found\"")
        async let openCodeProbe = probeService("opencode --version 2>/dev/null || echo \"not found\"")

        let (gitVersion, xcodePath, ollamaVersion, openCodeVersion) =
            await (gitProbe, xcodeProbe, ollamaProbe, openCodeProbe)

        // Git
        serviceMirror["git"] = ServiceTwin(
            name: "Git",
            isConnected: !gitVersion.contains("not found"),
            version: gitVersion.replacingOccurrences(of: "git version ", with: ""),
            lastContact: Date(),
            health: gitVersion.contains("not found") ? "unavailable" : "available"
        )

        // Xcode
        serviceMirror["xcode"] = ServiceTwin(
            name: "Xcode",
            isConnected: !xcodePath.contains("not found"),
            version: xcodePath,
            lastContact: Date(),
            health: xcodePath.contains("not found") ? "unavailable" : "available"
        )

        // Ollama
        serviceMirror["ollama"] = ServiceTwin(
            name: "Ollama",
            isConnected: !ollamaVersion.contains("not found"),
            version: ollamaVersion,
            lastContact: Date(),
            health: ollamaVersion.contains("not found") ? "unavailable" : "available"
        )

        // OpenCode
        serviceMirror["opencode"] = ServiceTwin(
            name: "OpenCode",
            isConnected: !openCodeVersion.contains("not found"),
            version: openCodeVersion,
            lastContact: Date(),
            health: openCodeVersion.contains("not found") ? "unavailable" : "available"
        )

        // Filesystem Kernel
        let kernelExists = fileManager.fileExists(atPath: fileManager.currentDirectoryPath + "/.kernel")
        serviceMirror["kernel"] = ServiceTwin(
            name: "Executive Kernel",
            isConnected: kernelExists,
            version: kernelExists ? "1.0.0" : "N/A",
            lastContact: Date(),
            health: kernelExists ? "available" : "missing"
        )
    }

    private func syncResources() {
        let processInfo = ProcessInfo.processInfo

        // Memory
        let memoryUsed = processInfo.physicalMemory / 2 // rough estimate
        let memoryTotal = processInfo.physicalMemory

        // Disk
        let homeDir = NSHomeDirectory()
        if let attrs = try? fileManager.attributesOfFileSystem(forPath: homeDir) {
            let freeSize = (attrs[.systemFreeSize] as? NSNumber)?.int64Value ?? 0

            resourceMirror = ResourceTwin(
                cpuUsage: 0, // Would need host_info for accurate CPU
                memoryUsed: memoryUsed,
                memoryTotal: memoryTotal,
                diskFree: freeSize,
                processCount: processInfo.processIdentifier > 0 ? 1 : 0,
                uptime: processInfo.systemUptime
            )
        }
    }

    // MARK: - Service Probe Helper

    /// Runs a shell probe OFF the main thread with a hard time bound.
    /// Never blocks the UI, even if a probed command misbehaves.
    private func probeService(_ command: String) async -> String {
        await Task.detached(priority: .utility) { () -> String in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-c", command]

            let output = Pipe()
            process.standardOutput = output
            process.standardError = output

            do {
                try process.run()
            } catch {
                return ""
            }

            // Bounded wait (max 3s) — terminate a hung probe.
            let deadline = ContinuousClock.now + .seconds(3)
            while process.isRunning && ContinuousClock.now < deadline {
                try? await Task.sleep(for: .milliseconds(50))
            }
            if process.isRunning {
                process.terminate()
            }

            let data = output.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }.value
    }
}
