import Foundation
import Combine

// MARK: - Legacy Compatibility Types
//
// Provides backward compatibility with the legacy MissionProposal system
// used by the UI layer. Bridges the old Decision Authority model to the
// new Ω5.1 Mission Execution model using types from SUPRADecisionAuthority.swift.

/// Legacy Execution Status enum (from legacy SUPRAMissionExecutor)
public enum ExecutionStatus: String, Codable, Sendable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case executed = "EXECUTED"
    case failed = "FAILED"
    case rolledBack = "ROLLED_BACK"
    case rejected = "REJECTED"
}

/// Legacy Execution Record struct (from legacy SUPRAMissionExecutor)
public struct ExecutionRecord: Identifiable, Codable, Sendable {
    public let id: UUID
    public let proposalID: UUID
    public let title: String
    public let status: ExecutionStatus
    public let executedAt: Date?
    public let error: String?
    public let rollbackAvailable: Bool
    
    public init(
        id: UUID = UUID(),
        proposalID: UUID,
        title: String,
        status: ExecutionStatus,
        executedAt: Date? = nil,
        error: String? = nil,
        rollbackAvailable: Bool = false
    ) {
        self.id = id
        self.proposalID = proposalID
        self.title = title
        self.status = status
        self.executedAt = executedAt
        self.error = error
        self.rollbackAvailable = rollbackAvailable
    }
}

/// Extension to convert legacy MissionProposal to Ω5.1 SUPRAMissionPlan
extension MissionProposal {
    /// Converts a legacy MissionProposal to a SUPRAMissionPlan for execution.
    public func toMissionPlan() -> SUPRAMissionPlan {
        let task = SUPRATask(
            id: self.id.uuidString,
            name: self.title,
            description: self.description,
            dependencies: [],
            estimatedDuration: self.estimatedImpact == .critical ? 30.0 :
                             self.estimatedImpact == .high ? 15.0 :
                             self.estimatedImpact == .medium ? 10.0 : 5.0,
            priority: self.verdict.authority == .autoExecute ? .critical :
                      self.verdict.authority == .supervised ? .high : .normal,
            requiredCapabilities: [self.category.rawValue]
        )

        let constraint = SUPRAConstraint(
            type: self.isReversible ? .maxDuration : .sequentialExecution,
            description: "Legacy proposal: \(self.reason)",
            value: self.estimatedImpact.rawValue
        )

        return SUPRAMissionPlan(
            missionID: self.id.uuidString,
            objective: self.title,
            tasks: [task],
            constraints: [constraint]
        )
    }
}

//
// The Mission Execution Engine is the first operational capability built
// upon the certified Executive Runtime Foundation.
//
// This component consumes:
//   - Authority II (Runtime State) — session management, state transitions
//   - Authority III (Mission Continuity) — checkpoints, recovery
//   - Ω4.D (Orchestration Layer) — task coordination, dependency graph
//   - Ω4.D (Runtime Intelligence) — metrics, anomalies, quality
//
// This component produces:
//   - Mission execution outcomes
//   - Task completion with evidence
//   - Operational metrics
//   - Execution recommendations
//
// This component does NOT own:
//   - Runtime State (Authority II)
//   - Mission Continuity (Authority III)
//   - Orchestration (Ω4.D)
//   - Intelligence (Ω4.D)
//
// Constitutional composition:
//   Ω5.1 composes upon Ω4.D, Authority II, and Authority III
//   Ω5.1 never modifies any certified Authority

// MARK: - Mission Execution Status

/// The status of a mission execution.
public enum SUPRAMissionExecutionStatus: String, Sendable, Codable {
    case idle = "IDLE"
    case receiving = "RECEIVING"
    case preparing = "PREPARING"
    case executing = "EXECUTING"
    case completing = "COMPLETING"
    case completed = "COMPLETED"
    case failed = "FAILED"
    case recovering = "RECOVERING"

    public var isTerminal: Bool {
        self == .completed || self == .failed
    }
}

// MARK: - Task Execution Result

/// The result of executing a single task.
public struct SUPRATaskExecutionResult: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let taskID: String
    public let taskName: String
    public let success: Bool
    public let startedAt: Date
    public let completedAt: Date
    public let duration: TimeInterval
    public let evidence: [String]
    public let error: String?

    public init(
        id: UUID = UUID(),
        taskID: String,
        taskName: String,
        success: Bool,
        startedAt: Date = Date(),
        completedAt: Date = Date(),
        duration: TimeInterval = 0,
        evidence: [String] = [],
        error: String? = nil
    ) {
        self.id = id
        self.taskID = taskID
        self.taskName = taskName
        self.success = success
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.duration = duration
        self.evidence = evidence
        self.error = error
    }
}

// MARK: - Mission Execution Result

/// The result of executing a complete mission.
public struct SUPRAMissionExecutionResult: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let missionID: String
    public let success: Bool
    public let startedAt: Date
    public let completedAt: Date
    public let duration: TimeInterval
    public let taskResults: [SUPRATaskExecutionResult]
    public let totalTasks: Int
    public let completedTasks: Int
    public let failedTasks: Int
    public let evidence: [String]
    public let error: String?

    public init(
        id: UUID = UUID(),
        missionID: String,
        success: Bool,
        startedAt: Date = Date(),
        completedAt: Date = Date(),
        duration: TimeInterval = 0,
        taskResults: [SUPRATaskExecutionResult] = [],
        totalTasks: Int = 0,
        completedTasks: Int = 0,
        failedTasks: Int = 0,
        evidence: [String] = [],
        error: String? = nil
    ) {
        self.id = id
        self.missionID = missionID
        self.success = success
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.duration = duration
        self.taskResults = taskResults
        self.totalTasks = totalTasks
        self.completedTasks = completedTasks
        self.failedTasks = failedTasks
        self.evidence = evidence
        self.error = error
    }

    /// Success rate as a percentage.
    public var successRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks) * 100.0
    }
}

// MARK: - Mission Executor

/// The Mission Execution Engine — executes missions through the certified Runtime.
///
/// Ω5.1 is the first operational capability built upon the Executive Runtime Foundation.
/// It consumes Authorities II and III plus Ω4.D to execute missions autonomously.
///
/// Composition:
/// ```
/// Authority II (Runtime State) → reads session, transitions
/// Authority III (Continuity)   → reads health, creates checkpoints
/// Ω4.D (Orchestration)         → coordinates tasks, resolves dependencies
/// Ω4.D (Intelligence)          → collects metrics, detects anomalies
/// ```
///
/// Usage:
/// ```swift
/// let executor = SUPRAMissionExecutor.shared
/// let result = await executor.executeMission(plan)
/// print(result.success ? "Mission completed" : "Mission failed")
/// ```
@MainActor
public final class SUPRAMissionExecutor: ObservableObject, Sendable {

    public static let shared = SUPRAMissionExecutor()

    // MARK: - Published State

    /// The current execution status.
    @Published public private(set) var executionStatus: SUPRAMissionExecutionStatus = .idle

    /// The currently executing mission ID, if any.
    @Published public private(set) var currentMissionID: String?

    /// The most recent execution result.
    @Published public private(set) var lastExecutionResult: SUPRAMissionExecutionResult?

    /// Tasks completed during current execution.
    @Published public private(set) var tasksCompleted: Int = 0

    /// Tasks failed during current execution.
    @Published public private(set) var tasksFailed: Int = 0

    /// Total tasks in current mission.
    @Published public private(set) var totalTasks: Int = 0

    /// Execution start time.
    @Published public private(set) var executionStartedAt: Date?

    /// Total missions executed.
    @Published public private(set) var missionsExecuted: Int = 0

    /// Total successful missions.
    @Published public private(set) var missionsSucceeded: Int = 0

    /// Legacy compatibility: returns missions executed (for legacy UI).
    public var autoExecutedCount: Int {
        missionsExecuted
    }

    /// Legacy compatibility: returns missions failed (for legacy UI).
    public var pendingCount: Int {
        missionsExecuted - missionsSucceeded
    }

    /// Legacy compatibility: returns execution history for legacy UI (SUPRAIntelligenceGraph).
    public var executionHistory: [ExecutionRecord] {
        taskResults.map { result in
            ExecutionRecord(
                id: result.id,
                proposalID: UUID(), // legacy compatibility
                title: result.taskName,
                status: result.success ? .executed : .failed,
                executedAt: result.completedAt,
                error: result.error,
                rollbackAvailable: false
            )
        }
    }

    // MARK: - Composition Surface

    /// The Runtime State Authority — the single source of truth.
    private let stateAuthority = SUPRAExecutionStateManager.shared

    /// The Mission Continuity Authority — health and checkpoints.
    private let continuityEngine = SUPRASessionContinuityEngine.shared

    /// The Orchestration Engine — task coordination.
    private let orchestrationEngine = SUPRAOrchestrationEngine.shared

    /// The Runtime Intelligence — metrics and anomalies.
    private let intelligence = SUPRARuntimeIntelligence.shared

    // MARK: - Internal

    private let eventBus = ExecutiveEventBus.shared
    private let logger = SUPRARuntimeLogger.shared
    private let runtimeEvents = SUPRARuntimeEvents.shared
    private var executionTask: Task<SUPRAMissionExecutionResult, Never>?
    private var taskResults: [SUPRATaskExecutionResult] = []

    private init() {}

    // MARK: - Mission Execution Lifecycle

    /// Executes a mission plan through the certified Runtime.
    ///
    /// This is the primary execution entry point. It:
    /// 1. Receives the mission plan
    /// 2. Prepares execution via Orchestration Engine
    /// 3. Creates a session via Authority II
    /// 4. Executes tasks through the Orchestration Engine
    /// 5. Creates checkpoints via Authority III
    /// 6. Produces completion evidence
    ///
    /// - Parameter plan: The mission plan to execute.
    /// - Returns: The execution result with evidence.
    public func executeMission(_ plan: SUPRAMissionPlan) async -> SUPRAMissionExecutionResult {
        let startTime = Date()
        executionStartedAt = startTime
        currentMissionID = plan.missionID
        taskResults = []
        tasksCompleted = 0
        tasksFailed = 0
        totalTasks = plan.tasks.count

        // Phase 1: Receiving
        executionStatus = .receiving
        logger.log(.mission, "Mission executor: receiving plan \(plan.missionID)")
        runtimeEvents.emit(
            .executionStarted,
            "Mission receiving: \(plan.missionID)",
            source: "SUPRAMissionExecutor",
            metadata: ["missionID": plan.missionID, "taskCount": "\(plan.tasks.count)"]
        )

        // Phase 2: Preparing
        executionStatus = .preparing
        await prepareExecution(plan: plan)

        // Phase 3: Executing
        executionStatus = .executing
        let executionSuccess = await executeTasks(plan: plan)

        // Phase 4: Completing
        executionStatus = .completing
        let result = await completeExecution(
            plan: plan,
            success: executionSuccess,
            startTime: startTime
        )

        // Phase 5: Terminal
        executionStatus = result.success ? .completed : .failed
        lastExecutionResult = result
        missionsExecuted += 1
        if result.success { missionsSucceeded += 1 }

        // Emit completion
        runtimeEvents.emit(
            result.success ? .executionCompleted : .executionFailed,
            "Mission \(result.success ? "completed" : "failed"): \(plan.missionID)",
            source: "SUPRAMissionExecutor",
            metadata: [
                "missionID": plan.missionID,
                "success": "\(result.success)",
                "duration": "\(Int(result.duration))",
                "completedTasks": "\(result.completedTasks)",
                "failedTasks": "\(result.failedTasks)"
            ]
        )

        eventBus.emit(
            result.success ? .contextUpdated : .engineFailed,
            source: "SUPRAMissionExecutor",
            detail: "Mission \(result.success ? "completed" : "failed"): \(plan.missionID)",
            metadata: [
                "missionID": plan.missionID,
                "success": "\(result.success)",
                "duration": "\(Int(result.duration))"
            ]
        )

        logger.log(.mission, "Mission executor: \(result.success ? "completed" : "failed") \(plan.missionID) in \(Int(result.duration))s")

        // Reset status after completion
        executionStatus = .idle
        currentMissionID = nil

        return result
    }

    // MARK: - Preparation

    /// Prepares the execution environment.
    private func prepareExecution(plan: SUPRAMissionPlan) async {
        // Load plan into Orchestration Engine
        orchestrationEngine.loadPlan(plan)

        // Start Orchestration Engine
        orchestrationEngine.startOrchestration()

        // Start Continuity Engine monitoring
        continuityEngine.startMonitoring()

        // Create session via Authority II
        _ = stateAuthority.startSession(missionID: plan.missionID)

        // Create initial checkpoint
        _ = try? await continuityEngine.createCheckpoint()

        logger.log(.executor, "Mission executor: prepared \(plan.missionID)")
    }

    // MARK: - Task Execution

    /// Executes all tasks in the mission plan.
    private func executeTasks(plan: SUPRAMissionPlan) async -> Bool {
        var allSucceeded = true

        while !orchestrationEngine.dependencyGraph.isComplete {
            // Get next ready tasks
            let readyTasks = orchestrationEngine.nextReadyTasks()

            if readyTasks.isEmpty {
                // Check if we're stuck (all remaining tasks are blocked)
                let blockers = orchestrationEngine.currentBlockers()
                if !blockers.isEmpty {
                    logger.log(.error, "Mission executor: blocked by \(blockers.count) tasks")
                    // Mark blocked tasks as failed
                    for blocker in blockers {
                        orchestrationEngine.markTaskFailed(blocker.id, reason: "Dependency blocked")
                        allSucceeded = false
                    }
                }
                break
            }

            // Execute each ready task
            for task in readyTasks {
                let result = await executeTask(task)
                taskResults.append(result)

                if result.success {
                    tasksCompleted += 1
                    orchestrationEngine.markTaskCompleted(task.id)
                } else {
                    tasksFailed += 1
                    allSucceeded = false
                    orchestrationEngine.markTaskFailed(task.id, reason: result.error)
                }

                // Create checkpoint after each task
                _ = try? await continuityEngine.createCheckpoint()
            }
        }

        return allSucceeded
    }

    /// Executes a single task.
    private func executeTask(_ task: SUPRATask) async -> SUPRATaskExecutionResult {
        let startTime = Date()

        // Mark task as executing
        orchestrationEngine.markTaskExecuting(task.id)

        // Transition Authority II to executing state
        _ = stateAuthority.transition(to: .executing, reason: "Executing task: \(task.name)")

        logger.log(.executor, "Mission executor: executing task \(task.name)")

        // Simulate task execution
        // In production, this would invoke the actual execution provider
        let success = await performTaskExecution(task)
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        let result = SUPRATaskExecutionResult(
            taskID: task.id,
            taskName: task.name,
            success: success,
            startedAt: startTime,
            completedAt: endTime,
            duration: duration,
            evidence: ["task_\(task.id)_\(success ? "completed" : "failed")"],
            error: success ? nil : "Task execution failed"
        )

        // Transition Authority II back to ready
        _ = stateAuthority.transition(to: .ready, reason: "Task completed: \(task.name)")

        return result
    }

    /// Performs the actual task execution.
    ///
    /// This is a placeholder for actual execution logic.
    /// In production, this would invoke the IAL or execution providers.
    private func performTaskExecution(_ task: SUPRATask) async -> Bool {
        // Simulate execution delay based on estimated duration
        let duration = task.estimatedDuration ?? 1.0
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

        // For demonstration, all tasks succeed
        // In production, this would call the actual execution provider
        return true
    }

    // MARK: - Completion

    /// Completes the mission execution.
    private func completeExecution(
        plan: SUPRAMissionPlan,
        success: Bool,
        startTime: Date
    ) async -> SUPRAMissionExecutionResult {
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        // Transition Authority II to terminal state
        let terminalState: SUPRAExecutionState = success ? .completed : .failed
        _ = stateAuthority.transition(
            to: terminalState,
            reason: "Mission \(success ? "completed" : "failed")"
        )

        // End session via Authority II
        if let session = stateAuthority.activeSession {
            stateAuthority.endSession(
                sessionID: session.id,
                terminalState: terminalState,
                reason: "Mission execution \(success ? "completed" : "failed")"
            )
        }

        // Stop Orchestration Engine
        orchestrationEngine.stopOrchestration()

        // Collect final metrics
        let quality = intelligence.evaluateQuality()

        // Create final checkpoint
        _ = try? await continuityEngine.createCheckpoint()

        // Build evidence
        var evidence: [String] = []
        evidence.append("mission_\(plan.missionID)_\(success ? "completed" : "failed")")
        evidence.append("tasks_\(tasksCompleted)_of_\(totalTasks)")
        evidence.append("duration_\(Int(duration))s")
        evidence.append("quality_\(quality.rating)")

        let result = SUPRAMissionExecutionResult(
            missionID: plan.missionID,
            success: success,
            startedAt: startTime,
            completedAt: endTime,
            duration: duration,
            taskResults: taskResults,
            totalTasks: totalTasks,
            completedTasks: tasksCompleted,
            failedTasks: tasksFailed,
            evidence: evidence,
            error: success ? nil : "Mission execution failed"
        )

        return result
    }

    // MARK: - Queries

    /// Returns the execution summary.
    public func summary() -> String {
        """
        ══════════════════════════════════════════════
        MISSION EXECUTOR STATUS
        ══════════════════════════════════════════════
        Status: \(executionStatus.rawValue)
        Current Mission: \(currentMissionID ?? "none")
        Tasks: \(tasksCompleted)/\(totalTasks) completed, \(tasksFailed) failed
        Missions Executed: \(missionsExecuted)
        Missions Succeeded: \(missionsSucceeded)
        Success Rate: \(missionsExecuted > 0 ? Int(Double(missionsSucceeded) / Double(missionsExecuted) * 100) : 0)%
        ══════════════════════════════════════════════
        """
    }

    /// Returns the last execution result.
    public var lastResult: SUPRAMissionExecutionResult? {
        lastExecutionResult
    }

    // MARK: - Runtime Integration

    /// Integrates with the PHOENIX Runtime.
    public func integrate(with runtime: PhoenixRuntime) {
        logger.log(.boot, "Mission Executor: integrated with PhoenixRuntime")
    }

    // MARK: - Legacy Compatibility

    /// Clears the execution history.
    ///
    /// Provides backward compatibility with the legacy UI layer that
    /// expects this method on the Mission Executor.
    public func clearHistory() {
        lastExecutionResult = nil
        tasksCompleted = 0
        tasksFailed = 0
        totalTasks = 0
        missionsExecuted = 0
        missionsSucceeded = 0
        executionStartedAt = nil
        currentMissionID = nil
        executionStatus = .idle
        taskResults = []

        logger.log(.mission, "Mission executor: history cleared (legacy compatibility)")
        runtimeEvents.emit(
            .executionCompleted,
            "Mission executor history cleared",
            source: "SUPRAMissionExecutor",
            metadata: ["compatibility": "legacy"]
        )
    }

    /// Executes a mission proposal from the legacy Decision Authority system.
    ///
    /// Provides backward compatibility with the legacy UI layer that uses
    /// MissionProposal from the Decision Authority system. Converts the proposal
    /// to a SUPRAMissionPlan and executes it through the standard pipeline.
    ///
    /// - Parameter proposal: The legacy mission proposal to execute.
    /// - Returns: The execution result.
    func execute(_ proposal: MissionProposal) async -> SUPRAMissionExecutionResult {
        // Convert legacy MissionProposal to SUPRAMissionPlan
        let plan = proposal.toMissionPlan()

        logger.log(.mission, "Mission executor: executing legacy proposal \(proposal.title)")
        return await executeMission(plan)
    }
}
