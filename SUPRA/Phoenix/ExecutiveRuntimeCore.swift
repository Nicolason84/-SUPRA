import Foundation
import Combine

// MARK: - Ω1 — Executive Runtime Core
//
// The central nervous system of SUPRA's living runtime.
// Boots the system, manages lifecycle, coordinates engines,
// maintains health, and produces the executive heartbeat.
//
// This is NOT a service locator. It is an organism coordinator.
// No view ever accesses this directly — only via ExecutiveContextSnapshot.

public enum ExecutiveRuntimeState: String, Sendable, Codable, CaseIterable {
    case dormant       /// System files exist but runtime has not been activated
    case booting       /// Bootstrap sequence in progress
    case initializing  /// Engines being initialized
    case active        /// All engines operational, runtime is live
    case degrading     /// One or more engines reporting issues
    case regenerating  /// Runtime is self-repairing
    case syncing       /// Digital twin synchronization in progress
    case reconnecting  /// Reconnecting after disconnection
    case sleeping      /// Low-power observation mode
    case halting       /// Shutdown sequence
}

public enum ExecutiveEngineStatus: String, Sendable, Codable, CaseIterable {
    case uninitialized
    case initializing
    case active
    case degraded
    case failed
    case recovering
}

public struct ExecutiveEngineReport: Sendable, Codable, Equatable {
    public let engineID: String
    public let name: String
    public let status: ExecutiveEngineStatus
    public let uptime: TimeInterval
    public let lastHeartbeat: Date
    public let message: String
    public let version: String

    public init(engineID: String, name: String, status: ExecutiveEngineStatus, uptime: TimeInterval, lastHeartbeat: Date, message: String, version: String) {
        self.engineID = engineID
        self.name = name
        self.status = status
        self.uptime = uptime
        self.lastHeartbeat = lastHeartbeat
        self.message = message
        self.version = version
    }
}

public struct ExecutiveHealthSummary: Sendable, Codable, Equatable {
    public let overallStatus: ExecutiveRuntimeState
    public let engineCount: Int
    public let activeEngineCount: Int
    public let degradedEngineCount: Int
    public let failedEngineCount: Int
    public let uptime: TimeInterval
    public let memoryUsage: UInt64
    public let cpuUsage: Double
    public let lastHealthCheck: Date
    public let warnings: [String]

    public init(overallStatus: ExecutiveRuntimeState, engineCount: Int, activeEngineCount: Int, degradedEngineCount: Int, failedEngineCount: Int, uptime: TimeInterval, memoryUsage: UInt64, cpuUsage: Double, lastHealthCheck: Date, warnings: [String]) {
        self.overallStatus = overallStatus
        self.engineCount = engineCount
        self.activeEngineCount = activeEngineCount
        self.degradedEngineCount = degradedEngineCount
        self.failedEngineCount = failedEngineCount
        self.uptime = uptime
        self.memoryUsage = memoryUsage
        self.cpuUsage = cpuUsage
        self.lastHealthCheck = lastHealthCheck
        self.warnings = warnings
    }
}

// MARK: - Engine Protocol

public protocol ExecutiveEngine: AnyObject, Sendable {
    var engineID: String { get }
    var engineName: String { get }
    var status: ExecutiveEngineStatus { get }
    var statusPublisher: Published<ExecutiveEngineStatus>.Publisher { get }

    func boot() async throws
    func shutdown() async throws
    func healthCheck() async -> ExecutiveEngineStatus
    func reset() async throws
}

// MARK: - Executive Runtime Core

@MainActor
public final class ExecutiveRuntimeCore: ObservableObject {
    public static let shared = ExecutiveRuntimeCore()

    // MARK: - Published State

    @Published public private(set) var state: ExecutiveRuntimeState = .dormant
    @Published public private(set) var healthSummary: ExecutiveHealthSummary?
    @Published public private(set) var engineReports: [String: ExecutiveEngineReport] = [:]
    @Published public private(set) var bootDate: Date?
    @Published public private(set) var lastStateChange: Date = Date()
    @Published public private(set) var warnings: [String] = []

    // MARK: - Internal Registry

    private var engines: [String: any ExecutiveEngine] = [:]
    private var heartbeatTimer: Timer?
    private var healthCheckTask: Task<Void, Never>?
    private let eventBus = ExecutiveEventBus.shared

    private init() {
        registerCoreEngine()
    }

    // MARK: - Engine Registration

    public func registerEngine(_ engine: any ExecutiveEngine) {
        let report = ExecutiveEngineReport(
            engineID: engine.engineID,
            name: engine.engineName,
            status: .uninitialized,
            uptime: 0,
            lastHeartbeat: Date(),
            message: "Registered and awaiting boot",
            version: "1.0.0"
        )
        engineReports[engine.engineID] = report
        engines[engine.engineID] = engine
        eventBus.emit(ExecutiveEvent(
            type: .engineRegistered,
            source: "ExecutiveRuntimeCore",
            detail: "Engine registered: \(engine.engineName) (\(engine.engineID))",
            metadata: ["engineID": engine.engineID, "name": engine.engineName]
        ))
    }

    // MARK: - Boot Sequence

    public func boot() async {
        guard state == .dormant else {
            warnings.append("Boot requested but state is \(state.rawValue)")
            return
        }

        state = .booting
        bootDate = Date()
        lastStateChange = Date()

        eventBus.emit(ExecutiveEvent(
            type: .runtimeBooting,
            source: "ExecutiveRuntimeCore",
            detail: "Executive Runtime boot sequence started",
            metadata: ["bootDate": "\(Date())"]
        ))

        // Phase 1: Initialize all registered engines
        state = .initializing
        await initializeEngines()

        // Phase 2: Start heartbeat
        startHeartbeat()

        // Phase 3: Final state
        state = .active
        lastStateChange = Date()

        updateHealthSummary()

        eventBus.emit(ExecutiveEvent(
            type: .runtimeActive,
            source: "ExecutiveRuntimeCore",
            detail: "Executive Runtime is now active",
            metadata: ["engineCount": "\(engines.count)", "activeCount": "\(activeEngineCount())"]
        ))
    }

    public func shutdown() async {
        state = .halting
        lastStateChange = Date()

        eventBus.emit(ExecutiveEvent(
            type: .runtimeHalting,
            source: "ExecutiveRuntimeCore",
            detail: "Executive Runtime shutdown sequence initiated"
        ))

        healthCheckTask?.cancel()
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil

        for (id, engine) in engines {
            do {
                try await engine.shutdown()
                engineReports[id]?.status = .uninitialized
            } catch {
                warnings.append("Engine \(id) shutdown failed: \(error.localizedDescription)")
            }
        }

        state = .dormant
        lastStateChange = Date()
    }

    public func regenerate() async {
        let previousState = state
        state = .regenerating
        lastStateChange = Date()

        eventBus.emit(ExecutiveEvent(
            type: .runtimeRegenerating,
            source: "ExecutiveRuntimeCore",
            detail: "Runtime regeneration initiated"
        ))

        // Re-boot failed or degraded engines
        for (id, engine) in engines {
            if engineReports[id]?.status == .failed || engineReports[id]?.status == .degraded {
                do {
                    try await engine.reset()
                    try await engine.boot()
                    engineReports[id]?.status = .active
                    engineReports[id]?.message = "Regenerated successfully"
                } catch {
                    warnings.append("Engine \(id) regeneration failed: \(error.localizedDescription)")
                }
            }
        }

        state = previousState == .degrading ? .active : previousState
        lastStateChange = Date()
        updateHealthSummary()

        eventBus.emit(ExecutiveEvent(
            type: .runtimeActive,
            source: "ExecutiveRuntimeCore",
            detail: "Runtime regeneration complete"
        ))
    }

    // MARK: - Health

    public func performHealthCheck() async {
        var degradedCount = 0
        var failedCount = 0
        var activeCount = 0

        for (id, engine) in engines {
            let engineStatus = await engine.healthCheck()
            engineReports[id]?.status = engineStatus
            engineReports[id]?.lastHeartbeat = Date()
            engineReports[id]?.uptime = bootDate.map { Date().timeIntervalSince($0) } ?? 0

            switch engineStatus {
            case .active: activeCount += 1
            case .degraded: degradedCount += 1
            case .failed: failedCount += 1
            default: break
            }
        }

        let totalEngines = engines.count
        var newWarnings: [String] = []

        if failedCount > 0 {
            newWarnings.append("\(failedCount) engine(s) have failed")
        }
        if degradedCount > 0 {
            newWarnings.append("\(degradedCount) engine(s) are degraded")
        }

        let newState: ExecutiveRuntimeState = {
            if failedCount == totalEngines && totalEngines > 0 { return .halting }
            if failedCount > 0 { return .degrading }
            if degradedCount > 0 { return .degrading }
            return .active
        }()

        if newState != state {
            state = newState
            lastStateChange = Date()
        }

        warnings = newWarnings
        updateHealthSummary()
    }

    // MARK: - Queries

    public func engineReport(for id: String) -> ExecutiveEngineReport? {
        engineReports[id]
    }

    public func engine<T: ExecutiveEngine>(ofType type: T.Type) -> T? {
        engines.values.first(where: { $0 is T }) as? T
    }

    public var isActive: Bool { state == .active }
    public var isBooting: Bool { state == .booting }
    public var isDormant: Bool { state == .dormant }

    // MARK: - Private

    private func registerCoreEngine() {
        let report = ExecutiveEngineReport(
            engineID: "executive-runtime-core",
            name: "Executive Runtime Core",
            status: .active,
            uptime: 0,
            lastHeartbeat: Date(),
            message: "Core runtime engine",
            version: "1.0.0"
        )
        engineReports["executive-runtime-core"] = report
    }

    private func initializeEngines() async {
        for (id, engine) in engines {
            do {
                engineReports[id]?.status = .initializing
                engineReports[id]?.message = "Initializing..."
                try await engine.boot()
                engineReports[id]?.status = .active
                engineReports[id]?.message = "Engine operational"
                engineReports[id]?.uptime = 0
                engineReports[id]?.lastHeartbeat = Date()

                eventBus.emit(ExecutiveEvent(
                    type: .engineBooted,
                    source: "ExecutiveRuntimeCore",
                    detail: "Engine booted: \(engine.engineName)",
                    metadata: ["engineID": id]
                ))
            } catch {
                engineReports[id]?.status = .failed
                engineReports[id]?.message = "Boot failed: \(error.localizedDescription)"
                warnings.append("Engine \(id) failed to boot: \(error.localizedDescription)")

                eventBus.emit(ExecutiveEvent(
                    type: .engineFailed,
                    source: "ExecutiveRuntimeCore",
                    detail: "Engine boot failed: \(engine.engineName): \(error.localizedDescription)",
                    metadata: ["engineID": id, "error": error.localizedDescription]
                ))
            }
        }
    }

    private func startHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.performHealthCheck()
            }
        }
    }

    private func activeEngineCount() -> Int {
        engineReports.values.filter { $0.status == .active }.count
    }

    private func updateHealthSummary() {
        let active = engineReports.values.filter { $0.status == .active }.count
        let degraded = engineReports.values.filter { $0.status == .degraded }.count
        let failed = engineReports.values.filter { $0.status == .failed }.count

        healthSummary = ExecutiveHealthSummary(
            overallStatus: state,
            engineCount: engines.count + 1,
            activeEngineCount: active,
            degradedEngineCount: degraded,
            failedEngineCount: failed,
            uptime: bootDate.map { Date().timeIntervalSince($0) } ?? 0,
            memoryUsage: 0,
            cpuUsage: 0,
            lastHealthCheck: Date(),
            warnings: warnings
        )
    }
}
