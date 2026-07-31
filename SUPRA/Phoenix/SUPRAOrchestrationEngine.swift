import Foundation
import Combine

// MARK: - Ω4.D — Runtime Orchestration Layer
//
// The Runtime Orchestration Layer coordinates already certified Authorities
// without owning any constitutional responsibility.
//
// This component owns:
//   - Mission coordination (reads plans, resolves dependencies, schedules tasks)
//   - Dependency graph management (DAG, blocking chains, parallel opportunities)
//   - Runtime monitoring (observes Authority II + III, reports health)
//
// This component does NOT own:
//   - Runtime State (Authority II — SUPRAExecutionStateManager)
//   - Mission Continuity (Authority III — SUPRASessionContinuityEngine)
//   - Mission Intent (Authority I — Mission Runtime)
//   - Execution Policy (Authority IV — IAL)
//   - Knowledge Governance (Authority V — SKOS)
//
// Constitutional composition:
//   Authority II (Runtime State) → Ω4.D (reads state, never modifies)
//   Authority III (Continuity)   → Ω4.D (reads health, never modifies)
//
// No Runtime State is duplicated.
// No Mission Continuity is duplicated.
// No Authority boundary is crossed.

// MARK: - Mission Plan

/// A read-only mission plan consumed from Authority I (Intent).
///
/// Ω4.D reads mission plans but never creates or modifies them.
/// The plan defines the tasks, dependencies, and constraints for a mission.
public struct SUPRAMissionPlan: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let missionID: String
    public let objective: String
    public let tasks: [SUPRATask]
    public let constraints: [SUPRAConstraint]
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        missionID: String,
        objective: String,
        tasks: [SUPRATask] = [],
        constraints: [SUPRAConstraint] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.missionID = missionID
        self.objective = objective
        self.tasks = tasks
        self.constraints = constraints
        self.createdAt = createdAt
    }
}

// MARK: - Task

/// A single executable unit within a mission plan.
///
/// Tasks are the atomic units of work that the Orchestration Engine coordinates.
/// Each task has dependencies that must be satisfied before execution.
public struct SUPRATask: Sendable, Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let description: String
    public let dependencies: [String]
    public let estimatedDuration: TimeInterval?
    public let priority: SUPRATaskPriority
    public let requiredCapabilities: [String]

    public init(
        id: String,
        name: String,
        description: String = "",
        dependencies: [String] = [],
        estimatedDuration: TimeInterval? = nil,
        priority: SUPRATaskPriority = .normal,
        requiredCapabilities: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.dependencies = dependencies
        self.estimatedDuration = estimatedDuration
        self.priority = priority
        self.requiredCapabilities = requiredCapabilities
    }
}

// MARK: - Task Priority

/// Priority levels for task scheduling.
public enum SUPRATaskPriority: String, Sendable, Codable, Comparable, CaseIterable {
    case critical = "CRITICAL"
    case high = "HIGH"
    case normal = "NORMAL"
    case low = "LOW"

    public static func < (lhs: SUPRATaskPriority, rhs: SUPRATaskPriority) -> Bool {
        let order: [SUPRATaskPriority] = [.critical, .high, .normal, .low]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

// MARK: - Task Status

/// The execution status of a task within the orchestration layer.
public enum SUPRATaskStatus: String, Sendable, Codable {
    case pending = "PENDING"
    case ready = "READY"
    case executing = "EXECUTING"
    case completed = "COMPLETED"
    case failed = "FAILED"
    case blocked = "BLOCKED"
    case skipped = "SKIPPED"

    public var isTerminal: Bool {
        self == .completed || self == .failed || self == .skipped
    }

    public var isActive: Bool {
        self == .executing
    }
}

// MARK: - Constraint

/// A constraint on mission execution.
public struct SUPRAConstraint: Sendable, Codable, Equatable {
    public let type: SUPRAConstraintType
    public let description: String
    public let value: String

    public init(type: SUPRAConstraintType, description: String, value: String) {
        self.type = type
        self.description = description
        self.value = value
    }
}

/// Types of execution constraints.
public enum SUPRAConstraintType: String, Sendable, Codable {
    case maxDuration = "MAX_DURATION"
    case maxCost = "MAX_COST"
    case requiredProvider = "REQUIRED_PROVIDER"
    case excludedProvider = "EXCLUDED_PROVIDER"
    case sequentialExecution = "SEQUENTIAL_EXECUTION"
}

// MARK: - Dependency Graph

/// Maintains the execution dependency graph as a directed acyclic graph (DAG).
///
/// The dependency graph:
/// - Tracks task relationships
/// - Detects blocking chains
/// - Identifies parallel execution opportunities
/// - Preserves deterministic execution order
public struct SUPRADependencyGraph: Sendable {
    private var taskStatuses: [String: SUPRATaskStatus] = [:]
    private var taskMap: [String: SUPRATask] = [:]

    public init() {}

    // MARK: - Graph Construction

    /// Builds the dependency graph from a mission plan.
    public mutating func build(from plan: SUPRAMissionPlan) {
        taskMap.removeAll()
        taskStatuses.removeAll()

        for task in plan.tasks {
            taskMap[task.id] = task
            taskStatuses[task.id] = .pending
        }
    }

    // MARK: - Status Updates

    /// Updates the status of a task.
    public mutating func setStatus(_ status: SUPRATaskStatus, for taskID: String) {
        taskStatuses[taskID] = status
    }

    /// Returns the status of a task.
    public func status(for taskID: String) -> SUPRATaskStatus {
        taskStatuses[taskID] ?? .pending
    }

    // MARK: - Dependency Resolution

    /// Returns all tasks whose dependencies are satisfied (status = .ready).
    public func readyTasks() -> [SUPRATask] {
        taskMap.values.filter { task in
            let status = taskStatuses[task.id] ?? .pending
            guard status == .pending else { return false }

            return task.dependencies.allSatisfy { depID in
                taskStatuses[depID] == .completed
            }
        }
    }

    /// Returns all tasks that are currently blocking other tasks.
    public func blockingTasks() -> [SUPRATask] {
        let blockedIDs = Set(taskMap.values.flatMap { $0.dependencies })
        return blockedIDs.compactMap { taskMap[$0] }.filter { task in
            let status = taskStatuses[task.id] ?? .pending
            return !status.isTerminal && status != .completed
        }
    }

    /// Returns tasks blocked by a specific task.
    public func tasksBlockedBy(_ taskID: String) -> [SUPRATask] {
        taskMap.values.filter { $0.dependencies.contains(taskID) }
    }

    // MARK: - Parallel Execution

    /// Identifies groups of tasks that can execute in parallel.
    ///
    /// Tasks are parallelizable if:
    /// 1. They have no dependencies on each other
    /// 2. Their dependencies are all completed
    /// 3. They are not blocked
    public func parallelizableGroups() -> [[SUPRATask]] {
        var groups: [[SUPRATask]] = []
        var processed = Set<String>()

        let ready = readyTasks()
        guard !ready.isEmpty else { return [] }

        // Group tasks by dependency depth
        let depthGroups = Dictionary(grouping: ready) { task -> Int in
            task.dependencies.filter { taskStatuses[$0] != .completed }.count
        }

        for (_, tasks) in depthGroups.sorted(by: { $0.key < $1.key }) {
            let parallelTasks = tasks.filter { !processed.contains($0.id) }
            if !parallelTasks.isEmpty {
                groups.append(parallelTasks)
                parallelTasks.forEach { processed.insert($0.id) }
            }
        }

        return groups
    }

    // MARK: - Blocking Chain Detection

    /// Detects chains of blocking dependencies.
    ///
    /// A blocking chain is a sequence of tasks where each task depends on
    /// the completion of the previous one, creating a critical path.
    public func blockingChains() -> [[SUPRATask]] {
        var chains: [[SUPRATask]] = []

        // Find root tasks (no dependencies)
        let rootTasks = taskMap.values.filter { $0.dependencies.isEmpty }

        for root in rootTasks {
            var chain: [SUPRATask] = [root]
            var current = root

            while true {
                let dependents = tasksBlockedBy(current.id)
                guard let next = dependents.first else { break }
                chain.append(next)
                current = next
            }

            if chain.count > 1 {
                chains.append(chain)
            }
        }

        return chains
    }

    // MARK: - Completion Check

    /// Returns whether all tasks are complete.
    public var isComplete: Bool {
        taskStatuses.values.allSatisfy { $0.isTerminal }
    }

    /// Returns the completion percentage.
    public var completionPercentage: Double {
        guard !taskStatuses.isEmpty else { return 0 }
        let completed = taskStatuses.values.filter { $0.isTerminal }.count
        return Double(completed) / Double(taskStatuses.count) * 100.0
    }

    // MARK: - Queries

    /// Returns all tasks in the graph.
    public var allTasks: [SUPRATask] {
        Array(taskMap.values)
    }

    /// Returns the total number of tasks.
    public var taskCount: Int {
        taskMap.count
    }

    /// Returns the number of completed tasks.
    public var completedCount: Int {
        taskStatuses.values.filter { $0 == .completed }.count
    }

    /// Returns the number of failed tasks.
    public var failedCount: Int {
        taskStatuses.values.filter { $0 == .failed }.count
    }

    /// Returns the number of blocked tasks.
    public var blockedCount: Int {
        taskStatuses.values.filter { $0 == .blocked }.count
    }
}

// MARK: - Orchestration Status

/// The current status of the orchestration engine.
public enum SUPRAOrchestrationStatus: String, Sendable, Codable {
    case idle = "IDLE"
    case planning = "PLANNING"
    case coordinating = "COORDINATING"
    case executing = "EXECUTING"
    case monitoring = "MONITORING"
    case recovering = "RECOVERING"
}

// MARK: - Orchestration Engine

/// The Runtime Orchestration Layer — coordinates certified Authorities.
///
/// Ω4.D is NOT a Constitutional Authority. It is a composition layer that:
/// - Reads Runtime State from Authority II
/// - Reads Mission Continuity from Authority III
/// - Coordinates task execution without owning state
/// - Maintains the dependency graph
/// - Monitors runtime health
///
/// Usage:
/// ```swift
/// let engine = SUPRAOrchestrationEngine.shared
/// engine.loadPlan(plan)
/// engine.startOrchestration()
/// let ready = engine.nextReadyTasks()
/// engine.markTaskCompleted("task-1")
/// ```
@MainActor
public final class SUPRAOrchestrationEngine: ObservableObject, Sendable {

    public static let shared = SUPRAOrchestrationEngine()

    // MARK: - Published State

    /// The current orchestration status.
    @Published public private(set) var status: SUPRAOrchestrationStatus = .idle

    /// The loaded mission plan, if any.
    @Published public private(set) var currentPlan: SUPRAMissionPlan?

    /// The dependency graph for the current plan.
    @Published public private(set) var dependencyGraph: SUPRADependencyGraph = SUPRADependencyGraph()

    /// Whether orchestration is active.
    @Published public private(set) var isOrchestrating: Bool = false

    /// Tasks completed during this orchestration session.
    @Published public private(set) var completedTaskCount: Int = 0

    /// Tasks failed during this orchestration session.
    @Published public private(set) var failedTaskCount: Int = 0

    /// Orchestration start time.
    @Published public private(set) var orchestrationStartedAt: Date?

    /// Total orchestration duration.
    public var orchestrationDuration: TimeInterval {
        orchestrationStartedAt.map { Date().timeIntervalSince($0) } ?? 0
    }

    // MARK: - Composition Surface (Authority II + III)

    /// The Runtime State Authority — the single source of truth.
    /// Ω4.D reads from this authority. It never modifies it.
    private let stateAuthority = SUPRAExecutionStateManager.shared

    /// The Mission Continuity Authority — health and checkpoints.
    /// Ω4.D reads from this authority. It never modifies it.
    private let continuityEngine = SUPRASessionContinuityEngine.shared

    // MARK: - Internal

    private let eventBus = ExecutiveEventBus.shared
    private let logger = SUPRARuntimeLogger.shared
    private let runtimeEvents = SUPRARuntimeEvents.shared
    private var monitorTask: Task<Void, Never>?
    private var runtimeSubscription: ExecutiveEventSubscription?

    private init() {}

    // MARK: - Plan Management

    /// Loads a mission plan for orchestration.
    ///
    /// The plan is read from Authority I (Intent) and used to build
    /// the dependency graph. No plan data is owned by Ω4.D.
    public func loadPlan(_ plan: SUPRAMissionPlan) {
        currentPlan = plan
        dependencyGraph.build(from: plan)
        completedTaskCount = 0
        failedTaskCount = 0

        logger.log(.mission, "Orchestration: plan loaded — \(plan.tasks.count) tasks, mission=\(plan.missionID)")
        runtimeEvents.emit(
            .executionStarted,
            "Orchestration plan loaded: \(plan.missionID)",
            source: "SUPRAOrchestrationEngine",
            metadata: [
                "planID": plan.id.uuidString,
                "missionID": plan.missionID,
                "taskCount": "\(plan.tasks.count)"
            ]
        )

        eventBus.emit(
            .contextUpdated,
            source: "SUPRAOrchestrationEngine",
            detail: "Plan loaded: \(plan.objective)",
            metadata: [
                "planID": plan.id.uuidString,
                "missionID": plan.missionID,
                "taskCount": "\(plan.tasks.count)"
            ]
        )
    }

    /// Clears the current plan and resets the orchestration state.
    public func clearPlan() {
        currentPlan = nil
        dependencyGraph = SUPRADependencyGraph()
        completedTaskCount = 0
        failedTaskCount = 0
        orchestrationStartedAt = nil
        status = .idle
        logger.log(.mission, "Orchestration: plan cleared")
    }

    // MARK: - Orchestration Lifecycle

    /// Starts the orchestration engine.
    ///
    /// Begins monitoring Authority II and III, and prepares for
    /// task coordination.
    public func startOrchestration() {
        guard !isOrchestrating else { return }
        guard currentPlan != nil else {
            logger.log(.error, "Orchestration: cannot start — no plan loaded")
            return
        }

        isOrchestrating = true
        orchestrationStartedAt = Date()
        status = .coordinating

        // Subscribe to runtime events
        runtimeSubscription = eventBus.subscribe(to: .runtimeHalting) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleRuntimeHalting()
            }
        }

        // Start runtime monitoring
        startMonitoring()

        logger.log(.mission, "Orchestration: started — mission=\(currentPlan?.missionID ?? "unknown")")
        runtimeEvents.emit(
            .executionStarted,
            "Orchestration started",
            source: "SUPRAOrchestrationEngine",
            metadata: ["missionID": currentPlan?.missionID ?? "unknown"]
        )

        eventBus.emit(
            .contextUpdated,
            source: "SUPRAOrchestrationEngine",
            detail: "Orchestration started",
            metadata: ["missionID": currentPlan?.missionID ?? "unknown"]
        )
    }

    /// Stops the orchestration engine.
    public func stopOrchestration() {
        isOrchestrating = false
        stopMonitoring()
        status = .idle
        runtimeSubscription = nil

        logger.log(.mission, "Orchestration: stopped — completed=\(completedTaskCount), failed=\(failedTaskCount)")
        runtimeEvents.emit(
            .executionCompleted,
            "Orchestration stopped",
            source: "SUPRAOrchestrationEngine",
            metadata: [
                "completedTasks": "\(completedTaskCount)",
                "failedTasks": "\(failedTaskCount)",
                "duration": "\(Int(orchestrationDuration))"
            ]
        )
    }

    // MARK: - Task Coordination

    /// Returns the next ready tasks for execution.
    ///
    /// Tasks are ready when:
    /// 1. All dependencies are completed
    /// 2. The task is in pending status
    /// 3. No blocking constraints prevent execution
    public func nextReadyTasks() -> [SUPRATask] {
        let ready = dependencyGraph.readyTasks()

        // Sort by priority
        return ready.sorted { $0.priority > $1.priority }
    }

    /// Marks a task as ready for execution.
    public func markTaskReady(_ taskID: String) {
        dependencyGraph.setStatus(.ready, for: taskID)
        status = .executing

        if let task = dependencyGraph.allTasks.first(where: { $0.id == taskID }) {
            logger.log(.executor, "Orchestration: task ready — \(task.name)")
            runtimeEvents.emit(
                .executionStarted,
                "Task ready: \(task.name)",
                source: "SUPRAOrchestrationEngine",
                metadata: ["taskID": taskID, "taskName": task.name]
            )
        }
    }

    /// Marks a task as executing.
    public func markTaskExecuting(_ taskID: String) {
        dependencyGraph.setStatus(.executing, for: taskID)

        if let task = dependencyGraph.allTasks.first(where: { $0.id == taskID }) {
            logger.log(.executor, "Orchestration: task executing — \(task.name)")
        }
    }

    /// Marks a task as completed.
    public func markTaskCompleted(_ taskID: String) {
        dependencyGraph.setStatus(.completed, for: taskID)
        completedTaskCount += 1

        if let task = dependencyGraph.allTasks.first(where: { $0.id == taskID }) {
            logger.log(.executor, "Orchestration: task completed — \(task.name)")
            runtimeEvents.emit(
                .executionCompleted,
                "Task completed: \(task.name)",
                source: "SUPRAOrchestrationEngine",
                metadata: [
                    "taskID": taskID,
                    "taskName": task.name,
                    "completedCount": "\(completedTaskCount)"
                ]
            )
        }

        // Check if mission is complete
        if dependencyGraph.isComplete {
            handleMissionComplete()
        }
    }

    /// Marks a task as failed.
    public func markTaskFailed(_ taskID: String, reason: String? = nil) {
        dependencyGraph.setStatus(.failed, for: taskID)
        failedTaskCount += 1

        // Mark dependent tasks as blocked
        let blockedTasks = dependencyGraph.tasksBlockedBy(taskID)
        for blocked in blockedTasks {
            dependencyGraph.setStatus(.blocked, for: blocked.id)
        }

        if let task = dependencyGraph.allTasks.first(where: { $0.id == taskID }) {
            logger.log(.error, "Orchestration: task failed — \(task.name). Reason: \(reason ?? "unknown")")
            runtimeEvents.emit(
                .executionFailed,
                "Task failed: \(task.name)",
                source: "SUPRAOrchestrationEngine",
                metadata: [
                    "taskID": taskID,
                    "taskName": task.name,
                    "reason": reason ?? "unknown",
                    "failedCount": "\(failedTaskCount)"
                ]
            )
        }
    }

    /// Skips a task (marks as skipped).
    public func skipTask(_ taskID: String, reason: String? = nil) {
        dependencyGraph.setStatus(.skipped, for: taskID)

        if let task = dependencyGraph.allTasks.first(where: { $0.id == taskID }) {
            logger.log(.executor, "Orchestration: task skipped — \(task.name). Reason: \(reason ?? "none")")
        }
    }

    // MARK: - Dependency Analysis

    /// Returns tasks that can execute in parallel.
    public func parallelizableGroups() -> [[SUPRATask]] {
        dependencyGraph.parallelizableGroups()
    }

    /// Returns blocking chains (critical paths).
    public func blockingChains() -> [[SUPRATask]] {
        dependencyGraph.blockingChains()
    }

    /// Returns tasks currently blocking other tasks.
    public func currentBlockers() -> [SUPRATask] {
        dependencyGraph.blockingTasks()
    }

    /// Returns the mission completion percentage.
    public func completionPercentage() -> Double {
        dependencyGraph.completionPercentage
    }

    // MARK: - Runtime Monitoring

    /// Starts runtime monitoring — observes Authority II and III.
    private func startMonitoring() {
        monitorTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                guard !Task.isCancelled else { break }
                await self.performMonitoringCycle()
            }
        }

        status = .monitoring
        logger.log(.boot, "Orchestration: monitoring started")
    }

    /// Stops runtime monitoring.
    private func stopMonitoring() {
        monitorTask?.cancel()
        monitorTask = nil
    }

    /// Performs a single monitoring cycle.
    ///
    /// Reads Runtime State from Authority II and health from Authority III
    /// without modifying either authority.
    private func performMonitoringCycle() {
        // Read from Authority II — compose, never duplicate
        guard let session = stateAuthority.activeSession else { return }

        let currentState = session.currentState
        let healthStatus = continuityEngine.healthStatus

        // Detect degraded conditions
        if healthStatus == .critical || healthStatus == .unresponsive {
            handleDegradedRuntime(state: currentState, health: healthStatus)
        }

        // Log monitoring telemetry
        runtimeEvents.emit(
            .executionCompleted,
            "Orchestration monitoring: state=\(currentState.rawValue), health=\(healthStatus.rawValue)",
            source: "SUPRAOrchestrationEngine",
            metadata: [
                "state": currentState.rawValue,
                "health": healthStatus.rawValue,
                "completedTasks": "\(completedTaskCount)",
                "failedTasks": "\(failedTaskCount)"
            ]
        )
    }

    // MARK: - Runtime Health Reporting

    /// Generates a runtime health report from Authority II and III.
    public func generateHealthReport() -> SUPRARuntimeHealthReport {
        // Read from Authority II
        let session = stateAuthority.activeSession
        let currentState = session?.currentState ?? .idle
        let sessionID = session?.id
        let missionID = session?.missionID

        // Read from Authority III
        let healthStatus = continuityEngine.healthStatus
        let checkpointCount = continuityEngine.checkpointCount
        let recoveryCount = continuityEngine.recoveryCount

        return SUPRARuntimeHealthReport(
            currentState: currentState,
            sessionHealth: healthStatus,
            sessionID: sessionID,
            missionID: missionID,
            checkpointCount: checkpointCount,
            recoveryCount: recoveryCount,
            completedTasks: completedTaskCount,
            failedTasks: failedTaskCount,
            totalTasks: dependencyGraph.taskCount,
            completionPercentage: dependencyGraph.completionPercentage,
            orchestrationStatus: status,
            timestamp: Date()
        )
    }

    // MARK: - Degraded Runtime Handling

    /// Handles degraded runtime conditions detected by monitoring.
    private func handleDegradedRuntime(state: SUPRAExecutionState, health: SUPRASessionHealth) {
        logger.log(.error, "Orchestration: degraded runtime detected — state=\(state.rawValue), health=\(health.rawValue)")
        runtimeEvents.emit(
            .validationFailed,
            "Degraded runtime detected",
            source: "SUPRAOrchestrationEngine",
            metadata: [
                "state": state.rawValue,
                "health": health.rawValue,
                "recommendation": "CHECK_CONTINUITY"
            ]
        )

        eventBus.emit(
            .engineDegraded,
            source: "SUPRAOrchestrationEngine",
            detail: "Degraded runtime: state=\(state.rawValue), health=\(health.rawValue)",
            metadata: [
                "state": state.rawValue,
                "health": health.rawValue
            ]
        )
    }

    // MARK: - Mission Completion

    /// Handles mission completion when all tasks are done.
    private func handleMissionComplete() {
        status = .idle
        stopOrchestration()

        logger.log(.mission, "Orchestration: mission complete — \(currentPlan?.missionID ?? "unknown")")
        runtimeEvents.emit(
            .executionCompleted,
            "Mission complete: \(currentPlan?.missionID ?? "unknown")",
            source: "SUPRAOrchestrationEngine",
            metadata: [
                "missionID": currentPlan?.missionID ?? "unknown",
                "completedTasks": "\(completedTaskCount)",
                "failedTasks": "\(failedTaskCount)",
                "duration": "\(Int(orchestrationDuration))"
            ]
        )

        eventBus.emit(
            .contextUpdated,
            source: "SUPRAOrchestrationEngine",
            detail: "Mission complete",
            metadata: [
                "missionID": currentPlan?.missionID ?? "unknown",
                "completedTasks": "\(completedTaskCount)"
            ]
        )
    }

    // MARK: - Runtime Event Handling

    private func handleRuntimeHalting() {
        stopOrchestration()
        logger.log(.boot, "Orchestration: runtime halting — orchestration stopped")
    }

    // MARK: - Runtime Integration

    /// Integrates with the PHOENIX Runtime.
    ///
    /// Called by PhoenixRuntime during boot to establish the
    /// orchestration layer composition with Authorities II and III.
    public func integrate(with runtime: PhoenixRuntime) {
        logger.log(.boot, "Orchestration Engine: integrated with PhoenixRuntime")
    }

    // MARK: - Queries

    /// Returns the current orchestration summary.
    public func summary() -> String {
        """
        Orchestration Status: \(status.rawValue)
        Mission: \(currentPlan?.missionID ?? "none")
        Tasks: \(dependencyGraph.completedCount)/\(dependencyGraph.taskCount) completed
        Failed: \(failedTaskCount)
        Duration: \(Int(orchestrationDuration))s
        """
    }
}

// MARK: - Runtime Health Report

/// A comprehensive runtime health report combining Authority II and III data.
public struct SUPRARuntimeHealthReport: Sendable {
    public let currentState: SUPRAExecutionState
    public let sessionHealth: SUPRASessionHealth
    public let sessionID: UUID?
    public let missionID: String?
    public let checkpointCount: Int
    public let recoveryCount: Int
    public let completedTasks: Int
    public let failedTasks: Int
    public let totalTasks: Int
    public let completionPercentage: Double
    public let orchestrationStatus: SUPRAOrchestrationStatus
    public let timestamp: Date

    /// Whether the runtime is in a healthy state.
    public var isHealthy: Bool {
        currentState != .failed && sessionHealth != .unresponsive && sessionHealth != .critical
    }

    /// Human-readable health summary.
    public var summary: String {
        """
        Runtime Health: \(isHealthy ? "HEALTHY" : "DEGRADED")
        State: \(currentState.rawValue)
        Session: \(sessionHealth.rawValue)
        Progress: \(completedTasks)/\(totalTasks) (\(Int(completionPercentage))%)
        Checkpoints: \(checkpointCount)
        Recoveries: \(recoveryCount)
        """
    }
}
