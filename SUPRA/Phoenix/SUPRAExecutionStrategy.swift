import Foundation
import Combine

// MARK: - Ω5.1 — Execution Strategy
//
// The Execution Strategy component selects and adapts execution strategies
// based on mission constraints, Runtime state, and Intelligence data.
//
// This component consumes:
//   - Authority II (Runtime State) — current session state
//   - Authority III (Mission Continuity) — health status, checkpoints
//   - Ω4.D (Orchestration Layer) — dependency graph, task status
//   - Ω4.D (Runtime Intelligence) — metrics, anomalies, quality
//
// This component produces:
//   - Execution strategy recommendations
//   - Strategy adaptation based on Runtime conditions
//
// This component does NOT own:
//   - Any Authority or Ω4.D responsibility

// MARK: - Execution Strategy Type

/// The type of execution strategy to employ.
public enum SUPRAExecutionStrategyType: String, Sendable, Codable {
    /// Execute tasks sequentially, one at a time.
    case sequential = "SEQUENTIAL"

    /// Execute independent tasks in parallel.
    case parallel = "PARALLEL"

    /// Execute critical path tasks first, then parallelize remaining.
    case criticalPathFirst = "CRITICAL_PATH_FIRST"

    /// Execute based on priority ordering.
    case priorityBased = "PRIORITY_BASED"

    /// Adaptive strategy that changes based on Runtime conditions.
    case adaptive = "ADAPTIVE"
}

// MARK: - Strategy Conditions

/// Conditions that influence strategy selection.
public struct SUPRAStrategyConditions: Sendable {
    public let currentState: SUPRAExecutionState
    public let sessionHealth: SUPRASessionHealth
    public let taskCount: Int
    public let parallelizableCount: Int
    public let blockedCount: Int
    public let failureRate: Double
    public let throughput: Double
    public let recoveryCount: Int

    public init(
        currentState: SUPRAExecutionState = .idle,
        sessionHealth: SUPRASessionHealth = .healthy,
        taskCount: Int = 0,
        parallelizableCount: Int = 0,
        blockedCount: Int = 0,
        failureRate: Double = 0,
        throughput: Double = 0,
        recoveryCount: Int = 0
    ) {
        self.currentState = currentState
        self.sessionHealth = sessionHealth
        self.taskCount = taskCount
        self.parallelizableCount = parallelizableCount
        self.blockedCount = blockedCount
        self.failureRate = failureRate
        self.throughput = throughput
        self.recoveryCount = recoveryCount
    }
}

// MARK: - Strategy Recommendation

/// A recommendation for execution strategy.
public struct SUPRAStrategyRecommendation: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let strategy: SUPRAExecutionStrategyType
    public let confidence: Double
    public let reason: String
    public let expectedImpact: String
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        strategy: SUPRAExecutionStrategyType,
        confidence: Double = 1.0,
        reason: String,
        expectedImpact: String = "",
        timestamp: Date = Date()
    ) {
        self.id = id
        self.strategy = strategy
        self.confidence = confidence
        self.reason = reason
        self.expectedImpact = expectedImpact
        self.timestamp = timestamp
    }
}

// MARK: - Execution Strategy

/// Selects and adapts execution strategies based on Runtime conditions.
///
/// The Strategy component analyzes the current Runtime state and recommends
/// the optimal execution strategy for a given mission.
///
/// Usage:
/// ```swift
/// let strategy = SUPRAExecutionStrategy.shared
/// let recommendation = strategy.recommendStrategy(for: conditions)
/// ```
@MainActor
public final class SUPRAExecutionStrategy: ObservableObject, Sendable {

    public static let shared = SUPRAExecutionStrategy()

    // MARK: - Published State

    /// The current recommended strategy.
    @Published public private(set) var currentStrategy: SUPRAExecutionStrategyType = .sequential

    /// Strategy recommendations history.
    @Published public private(set) var recommendations: [SUPRAStrategyRecommendation] = []

    /// Total strategy evaluations.
    @Published public private(set) var evaluationsCount: Int = 0

    // MARK: - Composition Surface

    private let stateAuthority = SUPRAExecutionStateManager.shared
    private let continuityEngine = SUPRASessionContinuityEngine.shared
    private let orchestrationEngine = SUPRAOrchestrationEngine.shared
    private let intelligence = SUPRARuntimeIntelligence.shared

    // MARK: - Internal

    private let logger = SUPRARuntimeLogger.shared
    private let runtimeEvents = SUPRARuntimeEvents.shared

    private init() {}

    // MARK: - Strategy Selection

    /// Recommends an execution strategy based on current conditions.
    ///
    /// - Parameter conditions: The current Runtime conditions.
    /// - Returns: A strategy recommendation with confidence and reasoning.
    public func recommendStrategy(for conditions: SUPRAStrategyConditions) -> SUPRAStrategyRecommendation {
        evaluationsCount += 1

        // Analyze conditions and select strategy
        let (strategy, confidence, reason) = analyzeConditions(conditions)

        let recommendation = SUPRAStrategyRecommendation(
            strategy: strategy,
            confidence: confidence,
            reason: reason,
            expectedImpact: expectedImpact(for: strategy, conditions: conditions)
        )

        currentStrategy = strategy
        recommendations.append(recommendation)

        // Keep only last 100 recommendations
        if recommendations.count > 100 {
            recommendations = Array(recommendations.suffix(100))
        }

        logger.log(.decision, "Strategy recommendation: \(strategy.rawValue) (confidence: \(Int(confidence * 100))%)")
        runtimeEvents.emit(
            .decisionCreated,
            "Strategy recommended: \(strategy.rawValue)",
            source: "SUPRAExecutionStrategy",
            metadata: [
                "strategy": strategy.rawValue,
                "confidence": String(format: "%.2f", confidence),
                "reason": reason
            ]
        )

        return recommendation
    }

    /// Recommends a strategy based on current Runtime state.
    public func recommendStrategyFromRuntime() -> SUPRAStrategyRecommendation {
        let conditions = collectConditions()
        return recommendStrategy(for: conditions)
    }

    // MARK: - Condition Analysis

    /// Analyzes conditions and selects the optimal strategy.
    private func analyzeConditions(_ conditions: SUPRAStrategyConditions) -> (SUPRAExecutionStrategyType, Double, String) {
        // Rule 1: If health is critical/unresponsive, use sequential for stability
        if conditions.sessionHealth == .critical || conditions.sessionHealth == .unresponsive {
            return (.sequential, 0.9, "Session health degraded — sequential for stability")
        }

        // Rule 2: If many tasks are blocked, use critical path first
        if conditions.blockedCount > conditions.taskCount / 2 {
            return (.criticalPathFirst, 0.85, "\(conditions.blockedCount) tasks blocked — prioritize critical path")
        }

        // Rule 3: If high failure rate, use sequential with checkpoints
        if conditions.failureRate > 0.3 {
            return (.sequential, 0.8, "High failure rate (\(Int(conditions.failureRate * 100))%) — sequential for reliability")
        }

        // Rule 4: If many parallelizable tasks, use parallel
        if conditions.parallelizableCount > conditions.taskCount / 3 {
            return (.parallel, 0.85, "\(conditions.parallelizableCount) parallelizable tasks — maximize throughput")
        }

        // Rule 5: If recovery loop detected, use sequential
        if conditions.recoveryCount > 3 {
            return (.sequential, 0.75, "Recovery loop detected (\(conditions.recoveryCount)) — sequential for stability")
        }

        // Rule 6: If low throughput, try parallel
        if conditions.throughput < 0.01 && conditions.parallelizableCount > 2 {
            return (.parallel, 0.7, "Low throughput — parallelize for performance")
        }

        // Default: adaptive strategy
        return (.adaptive, 0.6, "Default adaptive strategy based on Runtime conditions")
    }

    /// Calculates expected impact for a strategy.
    private func expectedImpact(for strategy: SUPRAExecutionStrategyType, conditions: SUPRAStrategyConditions) -> String {
        switch strategy {
        case .sequential:
            return "Stable execution with checkpoints between tasks"
        case .parallel:
            return "Up to \(conditions.parallelizableCount)x throughput improvement"
        case .criticalPathFirst:
            return "Reduce mission duration by prioritizing blocking tasks"
        case .priorityBased:
            return "Critical tasks execute first"
        case .adaptive:
            return "Strategy adapts based on Runtime conditions"
        }
    }

    // MARK: - Condition Collection

    /// Collects current Runtime conditions from all sources.
    private func collectConditions() -> SUPRAStrategyConditions {
        // Read from Authority II
        let session = stateAuthority.activeSession
        let currentState = session?.currentState ?? .idle

        // Read from Authority III
        let healthStatus = continuityEngine.healthStatus
        let recoveryCount = continuityEngine.recoveryCount

        // Read from Orchestration Engine
        let graph = orchestrationEngine.dependencyGraph
        let parallelGroups = orchestrationEngine.parallelizableGroups()
        let parallelCount = parallelGroups.dropFirst().reduce(0) { $0 + $1.count }

        // Read from Intelligence
        let metrics = intelligence.latestMetrics
        let failureRate = metrics?.taskFailureRate ?? 0
        let throughput = metrics?.throughput ?? 0

        return SUPRAStrategyConditions(
            currentState: currentState,
            sessionHealth: healthStatus,
            taskCount: graph.taskCount,
            parallelizableCount: parallelCount,
            blockedCount: graph.blockedCount,
            failureRate: failureRate,
            throughput: throughput,
            recoveryCount: recoveryCount
        )
    }

    // MARK: - Queries

    /// Returns the strategy summary.
    public func summary() -> String {
        """
        Execution Strategy:
        Current: \(currentStrategy.rawValue)
        Evaluations: \(evaluationsCount)
        Last Recommendation: \(recommendations.last?.strategy.rawValue ?? "none")
        """
    }

    // MARK: - Runtime Integration

    /// Integrates with the PHOENIX Runtime.
    public func integrate(with runtime: PhoenixRuntime) {
        logger.log(.boot, "Execution Strategy: integrated with PhoenixRuntime")
    }
}
