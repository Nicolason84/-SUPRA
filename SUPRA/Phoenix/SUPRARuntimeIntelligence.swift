import Foundation
import Combine

// MARK: - Ω4.D — Runtime Intelligence Layer
//
// The Runtime Intelligence Layer provides operational telemetry,
// anomaly detection, quality evaluation, and optimization suggestions.
//
// This component consumes data from Authority II (Runtime State) and
// Authority III (Mission Continuity) to produce intelligence without
// owning any constitutional responsibility.
//
// Composition:
//   Authority II (Runtime State) → Ω4.D (reads metrics, never modifies)
//   Authority III (Continuity)   → Ω4.D (reads health, never modifies)

// MARK: - Metric Point

/// A single data point in the runtime intelligence telemetry stream.
public struct SUPRAIntelligenceMetricPoint: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let name: String
    public let value: Double
    public let unit: String
    public let timestamp: Date
    public let source: String
    public let metadata: [String: String]

    public init(
        id: UUID = UUID(),
        name: String,
        value: Double,
        unit: String = "",
        timestamp: Date = Date(),
        source: String = "",
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.unit = unit
        self.timestamp = timestamp
        self.source = source
        self.metadata = metadata
    }
}

// MARK: - Execution Metrics

/// Aggregated runtime execution metrics.
public struct SUPRAExecutionMetrics: Sendable {
    public let totalTasks: Int
    public let completedTasks: Int
    public let failedTasks: Int
    public let blockedTasks: Int
    public let averageTaskDuration: TimeInterval
    public let totalExecutionTime: TimeInterval
    public let taskCompletionRate: Double
    public let taskFailureRate: Double
    public let throughput: Double
    public let timestamp: Date

    public init(
        totalTasks: Int = 0,
        completedTasks: Int = 0,
        failedTasks: Int = 0,
        blockedTasks: Int = 0,
        averageTaskDuration: TimeInterval = 0,
        totalExecutionTime: TimeInterval = 0,
        timestamp: Date = Date()
    ) {
        self.totalTasks = totalTasks
        self.completedTasks = completedTasks
        self.failedTasks = failedTasks
        self.blockedTasks = blockedTasks
        self.averageTaskDuration = averageTaskDuration
        self.totalExecutionTime = totalExecutionTime
        self.timestamp = timestamp

        self.taskCompletionRate = totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0
        self.taskFailureRate = totalTasks > 0 ? Double(failedTasks) / Double(totalTasks) : 0
        self.throughput = totalExecutionTime > 0 ? Double(completedTasks) / totalExecutionTime : 0
    }
}

// MARK: - Anomaly Severity

/// Severity levels for detected anomalies.
public enum SUPRAAnomalySeverity: String, Sendable, Codable, Comparable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case critical = "CRITICAL"

    public static func < (lhs: SUPRAAnomalySeverity, rhs: SUPRAAnomalySeverity) -> Bool {
        let order: [SUPRAAnomalySeverity] = [.low, .medium, .high, .critical]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

// MARK: - Anomaly Report

/// A detected anomaly in runtime behavior.
public struct SUPRAAnomalyReport: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let type: SUPRAAnomalyType
    public let severity: SUPRAAnomalySeverity
    public let description: String
    public let detectedAt: Date
    public let source: String
    public let metadata: [String: String]

    public init(
        id: UUID = UUID(),
        type: SUPRAAnomalyType,
        severity: SUPRAAnomalySeverity,
        description: String,
        detectedAt: Date = Date(),
        source: String = "",
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.severity = severity
        self.description = description
        self.detectedAt = detectedAt
        self.source = source
        self.metadata = metadata
    }
}

/// Types of anomalies that can be detected.
public enum SUPRAAnomalyType: String, Sendable, Codable {
    case taskStall = "TASK_STALL"
    case highFailureRate = "HIGH_FAILURE_RATE"
    case slowExecution = "SLOW_EXECUTION"
    case dependencyDeadlock = "DEPENDENCY_DEADLOCK"
    case healthDegradation = "HEALTH_DEGRADATION"
    case checkpointFailure = "CHECKPOINT_FAILURE"
    case recoveryLoop = "RECOVERY_LOOP"
    case resourceExhaustion = "RESOURCE_EXHAUSTION"
}

// MARK: - Quality Evaluation

/// Quality assessment of the current execution.
public struct SUPRAQualityEvaluation: Sendable {
    public let overallScore: Double
    public let executionEfficiency: Double
    public let dependencyHealth: Double
    public let taskQuality: Double
    public let recoveryReadiness: Double
    public let timestamp: Date

    public init(
        overallScore: Double = 0,
        executionEfficiency: Double = 0,
        dependencyHealth: Double = 0,
        taskQuality: Double = 0,
        recoveryReadiness: Double = 0,
        timestamp: Date = Date()
    ) {
        self.overallScore = overallScore
        self.executionEfficiency = executionEfficiency
        self.dependencyHealth = dependencyHealth
        self.taskQuality = taskQuality
        self.recoveryReadiness = recoveryReadiness
        self.timestamp = timestamp
    }

    /// Quality rating based on overall score.
    public var rating: String {
        switch overallScore {
        case 0.9...1.0: return "EXCELLENT"
        case 0.7..<0.9: return "GOOD"
        case 0.5..<0.7: return "FAIR"
        case 0.3..<0.5: return "POOR"
        default: return "CRITICAL"
        }
    }
}

// MARK: - Optimization Suggestion

/// A suggestion for runtime optimization.
public struct SUPRAOptimizationSuggestion: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let type: SUPRAOptimizationType
    public let priority: SUPRATaskPriority
    public let description: String
    public let expectedImpact: String
    public let suggestedAt: Date
    public let metadata: [String: String]

    public init(
        id: UUID = UUID(),
        type: SUPRAOptimizationType,
        priority: SUPRATaskPriority = .normal,
        description: String,
        expectedImpact: String = "",
        suggestedAt: Date = Date(),
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.priority = priority
        self.description = description
        self.expectedImpact = expectedImpact
        self.suggestedAt = suggestedAt
        self.metadata = metadata
    }
}

/// Types of optimization suggestions.
public enum SUPRAOptimizationType: String, Sendable, Codable {
    case parallelizeTasks = "PARALLELIZE_TASKS"
    case prioritizeCriticalPath = "PRIORITIZE_CRITICAL_PATH"
    case reduceDependencies = "REDUCE_DEPENDENCIES"
    case increaseConcurrency = "INCREASE_CONCURRENCY"
    case optimizeCheckpointFrequency = "OPTIMIZE_CHECKPOINT_FREQUENCY"
    case reduceRecoveryOverhead = "REDUCE_RECOVERY_OVERHEAD"
    case rebalanceWorkload = "REBALANCE_WORKLOAD"
}

// MARK: - Runtime Intelligence

/// The Runtime Intelligence Layer — produces operational telemetry.
///
/// Ω4.D Intelligence Layer consumes data from Authorities II and III
/// to produce actionable intelligence without owning state.
///
/// Capabilities:
/// - Collects runtime metrics
/// - Detects anomalies
/// - Evaluates execution quality
/// - Suggests runtime optimizations
/// - Produces operational telemetry
///
/// Usage:
/// ```swift
/// let intelligence = SUPRARuntimeIntelligence.shared
/// let metrics = intelligence.collectMetrics()
/// let anomalies = intelligence.detectAnomalies()
/// let quality = intelligence.evaluateQuality()
/// let suggestions = intelligence.suggestOptimizations()
/// ```
@MainActor
public final class SUPRARuntimeIntelligence: ObservableObject, Sendable {

    public static let shared = SUPRARuntimeIntelligence()

    // MARK: - Published State

    /// The most recent execution metrics.
    @Published public private(set) var latestMetrics: SUPRAExecutionMetrics?

    /// Detected anomalies.
    @Published public private(set) var activeAnomalies: [SUPRAAnomalyReport] = []

    /// Most recent quality evaluation.
    @Published public private(set) var latestQuality: SUPRAQualityEvaluation?

    /// Pending optimization suggestions.
    @Published public private(set) var suggestions: [SUPRAOptimizationSuggestion] = []

    /// Total metrics collected.
    @Published public private(set) var metricsCollected: Int = 0

    /// Total anomalies detected.
    @Published public private(set) var anomaliesDetected: Int = 0

    // MARK: - Composition Surface (Authority II + III)

    /// The Runtime State Authority — the single source of truth.
    /// Ω4.D reads from this authority. It never modifies it.
    private let stateAuthority = SUPRAExecutionStateManager.shared

    /// The Mission Continuity Authority — health and checkpoints.
    /// Ω4.D reads from this authority. It never modifies it.
    private let continuityEngine = SUPRASessionContinuityEngine.shared

    /// The Orchestration Engine — task coordination.
    /// Ω4.D reads from this engine. It never modifies it.
    private let orchestrationEngine = SUPRAOrchestrationEngine.shared

    // MARK: - Internal

    private let eventBus = ExecutiveEventBus.shared
    private let logger = SUPRARuntimeLogger.shared
    private let runtimeEvents = SUPRARuntimeEvents.shared
    private var metricHistory: [SUPRAIntelligenceMetricPoint] = []
    private let maxMetricHistory = 1000

    private init() {}

    // MARK: - Metrics Collection

    /// Collects current runtime metrics from Authorities II, III, and Orchestration.
    ///
    /// This method reads state from all authorities without modifying any.
    public func collectMetrics() -> SUPRAExecutionMetrics {
        // Read from Orchestration Engine
        let totalTasks = orchestrationEngine.dependencyGraph.taskCount
        let completedTasks = orchestrationEngine.dependencyGraph.completedCount
        let failedTasks = orchestrationEngine.failedTaskCount
        let blockedTasks = orchestrationEngine.dependencyGraph.blockedCount

        // Read from Authority II
        let session = stateAuthority.activeSession
        let executionTime = orchestrationEngine.orchestrationDuration

        // Calculate metrics
        let avgDuration = completedTasks > 0 ? executionTime / Double(completedTasks) : 0

        let metrics = SUPRAExecutionMetrics(
            totalTasks: totalTasks,
            completedTasks: completedTasks,
            failedTasks: failedTasks,
            blockedTasks: blockedTasks,
            averageTaskDuration: avgDuration,
            totalExecutionTime: executionTime
        )

        latestMetrics = metrics
        metricsCollected += 1

        // Store metric points for history
        recordMetricPoint(name: "tasks.total", value: Double(totalTasks))
        recordMetricPoint(name: "tasks.completed", value: Double(completedTasks))
        recordMetricPoint(name: "tasks.failed", value: Double(failedTasks))
        recordMetricPoint(name: "tasks.blocked", value: Double(blockedTasks))
        recordMetricPoint(name: "execution.time", value: executionTime, unit: "seconds")
        recordMetricPoint(name: "completion.rate", value: metrics.taskCompletionRate)
        recordMetricPoint(name: "failure.rate", value: metrics.taskFailureRate)
        recordMetricPoint(name: "throughput", value: metrics.throughput, unit: "tasks/s")

        logger.log(.performance, "Metrics collected: \(completedTasks)/\(totalTasks) tasks, \(Int(executionTime))s")
        runtimeEvents.emit(
            .executionCompleted,
            "Runtime metrics collected",
            source: "SUPRARuntimeIntelligence",
            metadata: [
                "totalTasks": "\(totalTasks)",
                "completedTasks": "\(completedTasks)",
                "failedTasks": "\(failedTasks)",
                "throughput": String(format: "%.4f", metrics.throughput)
            ]
        )

        return metrics
    }

    /// Records a single metric point in the history.
    private func recordMetricPoint(name: String, value: Double, unit: String = "") {
        let point = SUPRAIntelligenceMetricPoint(
            name: name,
            value: value,
            unit: unit,
            source: "SUPRARuntimeIntelligence"
        )
        metricHistory.append(point)
        if metricHistory.count > maxMetricHistory {
            metricHistory = Array(metricHistory.suffix(maxMetricHistory / 2))
        }
    }

    // MARK: - Anomaly Detection

    /// Detects anomalies in current runtime behavior.
    ///
    /// Analyzes metrics, health status, and execution patterns to identify
    /// deviations from expected behavior.
    public func detectAnomalies() -> [SUPRAAnomalyReport] {
        var anomalies: [SUPRAAnomalyReport] = []

        // Read from Authority II + III
        let session = stateAuthority.activeSession
        let healthStatus = continuityEngine.healthStatus
        let recoveryCount = continuityEngine.recoveryCount

        // Read from Orchestration
        let graph = orchestrationEngine.dependencyGraph
        let metrics = latestMetrics

        // Detect: Health degradation
        if healthStatus == .critical || healthStatus == .unresponsive {
            anomalies.append(SUPRAAnomalyReport(
                type: .healthDegradation,
                severity: healthStatus == .unresponsive ? .critical : .high,
                description: "Session health is \(healthStatus.rawValue)",
                source: "SUPRARuntimeIntelligence",
                metadata: ["health": healthStatus.rawValue]
            ))
        }

        // Detect: High failure rate
        if let metrics = metrics, metrics.taskFailureRate > 0.3 {
            anomalies.append(SUPRAAnomalyReport(
                type: .highFailureRate,
                severity: metrics.taskFailureRate > 0.5 ? .critical : .high,
                description: "Task failure rate is \(Int(metrics.taskFailureRate * 100))%",
                source: "SUPRARuntimeIntelligence",
                metadata: ["failureRate": String(format: "%.2f", metrics.taskFailureRate)]
            ))
        }

        // Detect: Task stall (many blocked tasks)
        if graph.blockedCount > 0 && graph.blockedCount == graph.taskCount - graph.completedCount {
            anomalies.append(SUPRAAnomalyReport(
                type: .dependencyDeadlock,
                severity: .high,
                description: "All remaining tasks are blocked — possible dependency deadlock",
                source: "SUPRARuntimeIntelligence",
                metadata: ["blockedCount": "\(graph.blockedCount)"]
            ))
        }

        // Detect: Recovery loop
        if recoveryCount > 3 {
            anomalies.append(SUPRAAnomalyReport(
                type: .recoveryLoop,
                severity: recoveryCount > 5 ? .critical : .medium,
                description: "Recovery count is \(recoveryCount) — possible recovery loop",
                source: "SUPRARuntimeIntelligence",
                metadata: ["recoveryCount": "\(recoveryCount)"]
            ))
        }

        // Detect: Slow execution
        if let metrics = metrics, metrics.totalExecutionTime > 0 && metrics.throughput < 0.01 {
            anomalies.append(SUPRAAnomalyReport(
                type: .slowExecution,
                severity: .medium,
                description: "Execution throughput is very low: \(String(format: "%.4f", metrics.throughput)) tasks/s",
                source: "SUPRARuntimeIntelligence",
                metadata: ["throughput": String(format: "%.4f", metrics.throughput)]
            ))
        }

        activeAnomalies = anomalies
        anomaliesDetected += anomalies.count

        if !anomalies.isEmpty {
            logger.log(.error, "Anomalies detected: \(anomalies.count)")
            for anomaly in anomalies {
                runtimeEvents.emit(
                    .validationFailed,
                    "Anomaly: \(anomaly.type.rawValue) — \(anomaly.description)",
                    source: "SUPRARuntimeIntelligence",
                    metadata: [
                        "type": anomaly.type.rawValue,
                        "severity": anomaly.severity.rawValue,
                        "description": anomaly.description
                    ]
                )
            }
        }

        return anomalies
    }

    // MARK: - Quality Evaluation

    /// Evaluates the quality of the current execution.
    ///
    /// Produces a composite quality score based on multiple factors.
    public func evaluateQuality() -> SUPRAQualityEvaluation {
        let metrics = latestMetrics ?? collectMetrics()
        let graph = orchestrationEngine.dependencyGraph
        let healthStatus = continuityEngine.healthStatus

        // Execution efficiency: completion rate weighted by throughput
        let executionEfficiency: Double = {
            let baseRate = metrics.taskCompletionRate
            let throughputBonus = min(metrics.throughput * 10, 0.2)
            return min(baseRate + throughputBonus, 1.0)
        }()

        // Dependency health: ratio of non-blocked to total
        let dependencyHealth: Double = {
            guard graph.taskCount > 0 else { return 1.0 }
            let nonBlocked = graph.taskCount - graph.blockedCount
            return Double(nonBlocked) / Double(graph.taskCount)
        }()

        // Task quality: based on failure rate
        let taskQuality: Double = {
            1.0 - metrics.taskFailureRate
        }()

        // Recovery readiness: based on checkpoints and health
        let recoveryReadiness: Double = {
            var score = 0.0
            if continuityEngine.latestCheckpoint != nil { score += 0.5 }
            if healthStatus == .healthy || healthStatus == .restored { score += 0.5 }
            return score
        }()

        // Overall score: weighted average
        let overallScore = (
            executionEfficiency * 0.3 +
            dependencyHealth * 0.25 +
            taskQuality * 0.25 +
            recoveryReadiness * 0.2
        )

        let evaluation = SUPRAQualityEvaluation(
            overallScore: overallScore,
            executionEfficiency: executionEfficiency,
            dependencyHealth: dependencyHealth,
            taskQuality: taskQuality,
            recoveryReadiness: recoveryReadiness
        )

        latestQuality = evaluation

        logger.log(.performance, "Quality evaluated: \(evaluation.rating) (\(Int(overallScore * 100))%)")
        runtimeEvents.emit(
            .validationPassed,
            "Quality evaluation: \(evaluation.rating)",
            source: "SUPRARuntimeIntelligence",
            metadata: [
                "overallScore": String(format: "%.2f", overallScore),
                "rating": evaluation.rating,
                "executionEfficiency": String(format: "%.2f", executionEfficiency),
                "dependencyHealth": String(format: "%.2f", dependencyHealth),
                "taskQuality": String(format: "%.2f", taskQuality),
                "recoveryReadiness": String(format: "%.2f", recoveryReadiness)
            ]
        )

        return evaluation
    }

    // MARK: - Optimization Suggestions

    /// Analyzes current state and suggests runtime optimizations.
    public func suggestOptimizations() -> [SUPRAOptimizationSuggestion] {
        var newSuggestions: [SUPRAOptimizationSuggestion] = []
        let graph = orchestrationEngine.dependencyGraph
        let metrics = latestMetrics
        let healthStatus = continuityEngine.healthStatus

        // Suggest: Parallelize tasks
        let parallelGroups = orchestrationEngine.parallelizableGroups()
        if parallelGroups.count > 1 {
            let parallelCount = parallelGroups.dropFirst().reduce(0) { $0 + $1.count }
            if parallelCount > 0 {
                newSuggestions.append(SUPRAOptimizationSuggestion(
                    type: .parallelizeTasks,
                    priority: .normal,
                    description: "\(parallelCount) tasks could execute in parallel across \(parallelGroups.count) groups",
                    expectedImpact: "Reduce execution time by up to \(Int(Double(parallelCount) * 0.3))%"
                ))
            }
        }

        // Suggest: Prioritize critical path
        let chains = orchestrationEngine.blockingChains()
        if let longestChain = chains.max(by: { $0.count < $1.count }), longestChain.count > 3 {
            newSuggestions.append(SUPRAOptimizationSuggestion(
                type: .prioritizeCriticalPath,
                priority: .high,
                description: "Critical path has \(longestChain.count) sequential tasks — consider prioritizing",
                expectedImpact: "Reduce mission duration"
            ))
        }

        // Suggest: Reduce dependencies
        let highDepTasks = graph.allTasks.filter { $0.dependencies.count > 3 }
        if !highDepTasks.isEmpty {
            newSuggestions.append(SUPRAOptimizationSuggestion(
                type: .reduceDependencies,
                priority: .normal,
                description: "\(highDepTasks.count) tasks have more than 3 dependencies",
                expectedImpact: "Improve dependency health and reduce blocking"
            ))
        }

        // Suggest: Optimize checkpoint frequency
        let checkpointCount = continuityEngine.checkpointCount
        let executionTime = orchestrationEngine.orchestrationDuration
        if executionTime > 0 && checkpointCount > 0 {
            let checkpointRate = Double(checkpointCount) / executionTime
            if checkpointRate > 0.1 { // More than 1 checkpoint per 10 seconds
                newSuggestions.append(SUPRAOptimizationSuggestion(
                    type: .optimizeCheckpointFrequency,
                    priority: .low,
                    description: "Checkpoint rate is high: \(String(format: "%.2f", checkpointRate)) per second",
                    expectedImpact: "Reduce overhead"
                ))
            }
        }

        // Suggest: Reduce recovery overhead
        let recoveryCount = continuityEngine.recoveryCount
        if recoveryCount > 2 {
            newSuggestions.append(SUPRAOptimizationSuggestion(
                type: .reduceRecoveryOverhead,
                priority: .high,
                description: "Recovery count is \(recoveryCount) — investigate root cause",
                expectedImpact: "Improve execution stability"
            ))
        }

        suggestions = newSuggestions

        if !newSuggestions.isEmpty {
            logger.log(.decision, "Optimization suggestions: \(newSuggestions.count)")
            for suggestion in newSuggestions {
                runtimeEvents.emit(
                    .decisionCreated,
                    "Optimization: \(suggestion.type.rawValue) — \(suggestion.description)",
                    source: "SUPRARuntimeIntelligence",
                    metadata: [
                        "type": suggestion.type.rawValue,
                        "priority": suggestion.priority.rawValue,
                        "description": suggestion.description
                    ]
                )
            }
        }

        return newSuggestions
    }

    // MARK: - Telemetry Report

    /// Generates a comprehensive telemetry report.
    public func generateTelemetryReport() -> SUPRATelemetryReport {
        let metrics = collectMetrics()
        let anomalies = detectAnomalies()
        let quality = evaluateQuality()
        let suggestions = suggestOptimizations()

        return SUPRATelemetryReport(
            metrics: metrics,
            anomalies: anomalies,
            quality: quality,
            suggestions: suggestions,
            metricsCollected: metricsCollected,
            anomaliesDetected: anomaliesDetected,
            timestamp: Date()
        )
    }

    // MARK: - Metric History Queries

    /// Returns metric history for a given metric name.
    public func metricHistory(for name: String) -> [SUPRAIntelligenceMetricPoint] {
        metricHistory.filter { $0.name == name }
    }

    /// Returns the average value for a metric over the last N points.
    public func averageMetric(for name: String, last points: Int = 10) -> Double {
        let history = metricHistory(for: name).suffix(points)
        guard !history.isEmpty else { return 0 }
        return history.reduce(0) { $0 + $1.value } / Double(history.count)
    }

    /// Returns the trend for a metric (positive = improving, negative = degrading).
    public func metricTrend(for name: String) -> Double {
        let history = metricHistory(for: name)
        guard history.count >= 2 else { return 0 }
        let recent = history.suffix(5).reduce(0) { $0 + $1.value } / Double(min(history.count, 5))
        let older = history.prefix(5).reduce(0) { $0 + $1.value } / Double(min(history.count, 5))
        return recent - older
    }

    // MARK: - Reset

    /// Clears all intelligence state.
    public func reset() {
        latestMetrics = nil
        activeAnomalies = []
        latestQuality = nil
        suggestions = []
        metricHistory = []
        metricsCollected = 0
        anomaliesDetected = 0

        logger.log(.memory, "Runtime Intelligence: reset")
        runtimeEvents.emit(
            .validationPassed,
            "Runtime Intelligence: reset",
            source: "SUPRARuntimeIntelligence"
        )
    }

    // MARK: - Runtime Integration

    /// Integrates with the PHOENIX Runtime.
    public func integrate(with runtime: PhoenixRuntime) {
        logger.log(.boot, "Runtime Intelligence: integrated with PhoenixRuntime")
    }
}

// MARK: - Telemetry Report

/// A comprehensive telemetry report combining all intelligence data.
public struct SUPRATelemetryReport: Sendable {
    public let metrics: SUPRAExecutionMetrics
    public let anomalies: [SUPRAAnomalyReport]
    public let quality: SUPRAQualityEvaluation
    public let suggestions: [SUPRAOptimizationSuggestion]
    public let metricsCollected: Int
    public let anomaliesDetected: Int
    public let timestamp: Date

    /// Whether the runtime is in a good state.
    public var isHealthy: Bool {
        anomalies.isEmpty || anomalies.allSatisfy { $0.severity < .high }
    }

    /// Human-readable summary.
    public var summary: String {
        """
        ══════════════════════════════════════════════
        RUNTIME INTELLIGENCE REPORT
        ══════════════════════════════════════════════
        Metrics Collected: \(metricsCollected)
        Anomalies Detected: \(anomaliesDetected)
        Quality Rating: \(quality.rating) (\(Int(quality.overallScore * 100))%)
        Active Anomalies: \(anomalies.count)
        Suggestions: \(suggestions.count)
        ──────────────────────────────────────────────
        Tasks: \(metrics.completedTasks)/\(metrics.totalTasks) completed
        Failure Rate: \(Int(metrics.taskFailureRate * 100))%
        Throughput: \(String(format: "%.4f", metrics.throughput)) tasks/s
        Execution Time: \(Int(metrics.totalExecutionTime))s
        ══════════════════════════════════════════════
        """
    }
}
