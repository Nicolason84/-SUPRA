import Foundation
import Combine

// MARK: - Ω5.2 — Executive Telemetry
//
// The Executive Telemetry subsystem collects, stores, and exposes
// runtime metrics, performance data, and operational telemetry
// from the certified Executive Runtime.
//
// Composition:
//   Authority II (Runtime State) → reads session state, transitions
//   Authority III (Continuity)   → reads health, checkpoints
//   Ω4.D (Orchestration)         → reads dependency graph, task status
//   Ω4.D (Intelligence)          → reads metrics, anomalies
//   Ω5.1 (Mission Executor)      → reads execution results
//
// Ω5.2 does NOT own any Authority responsibility.
// It aggregates and exposes telemetry data.

// MARK: - Telemetry Metric

/// A single telemetry metric data point.
public struct SUPRATelemetryMetric: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let name: String
    public let value: Double
    public let unit: String
    public let timestamp: Date
    public let source: String
    public let tags: [String: String]

    public init(
        id: UUID = UUID(),
        name: String,
        value: Double,
        unit: String = "",
        timestamp: Date = Date(),
        source: String = "",
        tags: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.unit = unit
        self.timestamp = timestamp
        self.source = source
        self.tags = tags
    }
}

// MARK: - Metric Category

/// Categories of telemetry metrics.
public enum SUPRAMetricCategory: String, Sendable, Codable, CaseIterable {
    case execution = "EXECUTION"
    case performance = "PERFORMANCE"
    case health = "HEALTH"
    case continuity = "CONTINUITY"
    case orchestration = "ORCHESTRATION"
    case intelligence = "INTELLIGENCE"
}

// MARK: - Telemetry Snapshot

/// A point-in-time snapshot of all telemetry data.
public struct SUPRATelemetrySnapshot: Sendable {
    public let timestamp: Date
    public let metrics: [SUPRATelemetryMetric]
    public let sessionState: SUPRAExecutionState
    public let healthStatus: SUPRASessionHealth
    public let checkpointCount: Int
    public let recoveryCount: Int
    public let completedTasks: Int
    public let failedTasks: Int
    public let totalTasks: Int
    public let completionPercentage: Double

    public init(
        timestamp: Date = Date(),
        metrics: [SUPRATelemetryMetric] = [],
        sessionState: SUPRAExecutionState = .idle,
        healthStatus: SUPRASessionHealth = .healthy,
        checkpointCount: Int = 0,
        recoveryCount: Int = 0,
        completedTasks: Int = 0,
        failedTasks: Int = 0,
        totalTasks: Int = 0,
        completionPercentage: Double = 0
    ) {
        self.timestamp = timestamp
        self.metrics = metrics
        self.sessionState = sessionState
        self.healthStatus = healthStatus
        self.checkpointCount = checkpointCount
        self.recoveryCount = recoveryCount
        self.completedTasks = completedTasks
        self.failedTasks = failedTasks
        self.totalTasks = totalTasks
        self.completionPercentage = completionPercentage
    }
}

// MARK: - Telemetry Aggregate

/// Aggregated telemetry statistics over a time window.
public struct SUPRATelemetryAggregate: Sendable {
    public let name: String
    public let count: Int
    public let sum: Double
    public let average: Double
    public let min: Double
    public let max: Double
    public let windowStart: Date
    public let windowEnd: Date

    public init(
        name: String,
        count: Int,
        sum: Double,
        average: Double,
        min: Double,
        max: Double,
        windowStart: Date,
        windowEnd: Date
    ) {
        self.name = name
        self.count = count
        self.sum = sum
        self.average = average
        self.min = min
        self.max = max
        self.windowStart = windowStart
        self.windowEnd = windowEnd
    }
}

// MARK: - Runtime Telemetry

/// The Executive Telemetry subsystem — collects and exposes runtime metrics.
///
/// Ω5.2 aggregates telemetry from all certified Authorities and Ω4.D components
/// without owning any constitutional responsibility.
///
/// Usage:
/// ```swift
/// let telemetry = SUPRARuntimeTelemetry.shared
/// let snapshot = telemetry.captureSnapshot()
/// let aggregate = telemetry.aggregateMetrics(named: "tasks.completed")
/// ```
@MainActor
public final class SUPRARuntimeTelemetry: ObservableObject, Sendable {

    public static let shared = SUPRARuntimeTelemetry()

    // MARK: - Published State

    /// The most recent telemetry snapshot.
    @Published public private(set) var latestSnapshot: SUPRATelemetrySnapshot?

    /// All collected metrics.
    @Published public private(set) var allMetrics: [SUPRATelemetryMetric] = []

    /// Total metrics collected.
    @Published public private(set) var metricsCollected: Int = 0

    /// Whether telemetry collection is active.
    @Published public private(set) var isCollecting: Bool = false

    /// Collection start time.
    @Published public private(set) var collectionStartedAt: Date?

    // MARK: - Composition Surface

    private let stateAuthority = SUPRAExecutionStateManager.shared
    private let continuityEngine = SUPRASessionContinuityEngine.shared
    private let orchestrationEngine = SUPRAOrchestrationEngine.shared
    private let intelligence = SUPRARuntimeIntelligence.shared
    private let missionExecutor = SUPRAMissionExecutor.shared

    // MARK: - Internal

    private let eventBus = ExecutiveEventBus.shared
    private let logger = SUPRARuntimeLogger.shared
    private let runtimeEvents = SUPRARuntimeEvents.shared
    private var collectionTask: Task<Void, Never>?
    private var metricBuffer: [SUPRATelemetryMetric] = []
    private let maxBufferSize = 5000

    private init() {}

    // MARK: - Collection Lifecycle

    /// Starts telemetry collection.
    public func startCollection() {
        guard !isCollecting else { return }

        isCollecting = true
        collectionStartedAt = Date()

        // Collect initial snapshot
        captureSnapshot()

        // Start periodic collection
        collectionTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 10_000_000_000)
                guard !Task.isCancelled else { break }
                await self.performCollectionCycle()
            }
        }

        logger.log(.performance, "Telemetry collection started")
        runtimeEvents.emit(
            .executionStarted,
            "Telemetry collection started",
            source: "SUPRARuntimeTelemetry"
        )
    }

    /// Stops telemetry collection.
    public func stopCollection() {
        isCollecting = false
        collectionTask?.cancel()
        collectionTask = nil

        // Flush remaining buffer
        flushBuffer()

        logger.log(.performance, "Telemetry collection stopped")
        runtimeEvents.emit(
            .executionCompleted,
            "Telemetry collection stopped",
            source: "SUPRARuntimeTelemetry",
            metadata: ["metricsCollected": "\(metricsCollected)"]
        )
    }

    // MARK: - Snapshot Capture

    /// Captures a point-in-time snapshot of all telemetry data.
    public func captureSnapshot() -> SUPRATelemetrySnapshot {
        // Read from Authority II
        let session = stateAuthority.activeSession
        let sessionState = session?.currentState ?? .idle

        // Read from Authority III
        let healthStatus = continuityEngine.healthStatus
        let checkpointCount = continuityEngine.checkpointCount
        let recoveryCount = continuityEngine.recoveryCount

        // Read from Ω4.D Orchestration
        let graph = orchestrationEngine.dependencyGraph
        let completedTasks = graph.completedCount
        let failedTasks = graph.failedCount
        let totalTasks = graph.taskCount
        let completionPercentage = graph.completionPercentage

        // Read from Ω5.1 Mission Executor
        let executorResult = missionExecutor.lastResult
        let executorCompleted = missionExecutor.tasksCompleted
        let executorFailed = missionExecutor.tasksFailed

        // Merge task counts (prefer orchestration engine)
        let finalCompleted = max(completedTasks, executorCompleted)
        let finalFailed = max(failedTasks, executorFailed)
        let finalTotal = max(totalTasks, executorCompleted + executorFailed)
        let finalPercentage = finalTotal > 0
            ? Double(finalCompleted) / Double(finalTotal) * 100.0
            : 0

        let snapshot = SUPRATelemetrySnapshot(
            timestamp: Date(),
            metrics: allMetrics.suffix(100),
            sessionState: sessionState,
            healthStatus: healthStatus,
            checkpointCount: checkpointCount,
            recoveryCount: recoveryCount,
            completedTasks: finalCompleted,
            failedTasks: finalFailed,
            totalTasks: finalTotal,
            completionPercentage: finalPercentage
        )

        latestSnapshot = snapshot
        return snapshot
    }

    // MARK: - Metric Collection

    /// Collects a single telemetry metric.
    public func recordMetric(
        name: String,
        value: Double,
        unit: String = "",
        category: SUPRAMetricCategory = .execution,
        tags: [String: String] = [:]
    ) {
        let metric = SUPRATelemetryMetric(
            name: name,
            value: value,
            unit: unit,
            timestamp: Date(),
            source: "SUPRARuntimeTelemetry",
            tags: ["category": category.rawValue, "source": "SUPRARuntimeTelemetry"]
        )

        metricBuffer.append(metric)
        metricsCollected += 1

        // Flush buffer if it exceeds max size
        if metricBuffer.count >= maxBufferSize {
            flushBuffer()
        }
    }

    /// Flushes the metric buffer into allMetrics.
    private func flushBuffer() {
        allMetrics.append(contentsOf: metricBuffer)
        metricBuffer = []

        // Trim to max history
        if allMetrics.count > maxBufferSize {
            allMetrics = Array(allMetrics.suffix(maxBufferSize / 2))
        }
    }

    // MARK: - Collection Cycle

    /// Performs a single telemetry collection cycle.
    private func performCollectionCycle() {
        let snapshot = captureSnapshot()

        // Record key metrics
        recordMetric(name: "session.state", value: Double(snapshot.sessionState.rawValue.hashValue))
        recordMetric(name: "session.health", value: Double(snapshot.healthStatus.rawValue.hashValue))
        recordMetric(name: "tasks.completed", value: Double(snapshot.completedTasks))
        recordMetric(name: "tasks.failed", value: Double(snapshot.failedTasks))
        recordMetric(name: "tasks.total", value: Double(snapshot.totalTasks))
        recordMetric(name: "tasks.completion_percentage", value: snapshot.completionPercentage)
        recordMetric(name: "checkpoints.count", value: Double(snapshot.checkpointCount))
        recordMetric(name: "recoveries.count", value: Double(snapshot.recoveryCount))

        // Flush buffer periodically
        flushBuffer()
    }

    // MARK: - Aggregation

    /// Aggregates metrics by name over the last N entries.
    public func aggregateMetrics(named name: String, last entries: Int = 100) -> SUPRATelemetryAggregate? {
        let relevant = allMetrics.filter { $0.name == name }.suffix(entries)
        guard !relevant.isEmpty else { return nil }

        let values = relevant.map { $0.value }
        let sum = values.reduce(0, +)
        let avg = sum / Double(values.count)
        let min = values.min() ?? 0
        let max = values.max() ?? 0

        return SUPRATelemetryAggregate(
            name: name,
            count: relevant.count,
            sum: sum,
            average: avg,
            min: min,
            max: max,
            windowStart: relevant.first?.timestamp ?? Date(),
            windowEnd: relevant.last?.timestamp ?? Date()
        )
    }

    /// Returns all available metric names.
    public var metricNames: [String] {
        Array(Set(allMetrics.map { $0.name })).sorted()
    }

    // MARK: - Queries

    /// Returns the telemetry summary.
    public func summary() -> String {
        """
        ══════════════════════════════════════════════
        EXECUTIVE TELEMETRY
        ══════════════════════════════════════════════
        Collection: \(isCollecting ? "ACTIVE" : "IDLE")
        Metrics Collected: \(metricsCollected)
        Buffer Size: \(metricBuffer.count)
        History Size: \(allMetrics.count)
        Latest Snapshot: \(latestSnapshot != nil ? "AVAILABLE" : "NONE")
        ──────────────────────────────────────────────
        Session State: \(latestSnapshot?.sessionState.rawValue ?? "N/A")
        Health: \(latestSnapshot?.healthStatus.rawValue ?? "N/A")
        Tasks: \(latestSnapshot?.completedTasks ?? 0)/\((latestSnapshot?.totalTasks ?? 0)) completed
        Checkpoints: \(latestSnapshot?.checkpointCount ?? 0)
        Recoveries: \(latestSnapshot?.recoveryCount ?? 0)
        ══════════════════════════════════════════════
        """
    }

    // MARK: - Reset

    /// Clears all telemetry data.
    public func reset() {
        allMetrics = []
        metricBuffer = []
        metricsCollected = 0
        latestSnapshot = nil
        isCollecting = false
        collectionStartedAt = nil

        logger.log(.memory, "Telemetry: reset")
    }

    // MARK: - Runtime Integration

    /// Integrates with the PHOENIX Runtime.
    public func integrate(with runtime: PhoenixRuntime) {
        logger.log(.boot, "Runtime Telemetry: integrated with PhoenixRuntime")
    }
}
