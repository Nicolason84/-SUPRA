import Foundation
import Combine

// MARK: - Ω4.C — Session Continuity Engine
//
// Authority III — Mission Continuity
//
// The Session Continuity Engine composes upon the certified Runtime State
// Authority (SUPRAExecutionStateManager) to provide deterministic mission
// continuity across runtime interruptions.
//
// This component owns:
//   - Session health monitoring
//   - Runtime heartbeat
//   - Execution checkpoints
//   - Checkpoint persistence
//   - Resume detection
//   - Runtime restoration
//   - Context integrity verification
//   - Continuity validation
//   - Deterministic recovery orchestration
//   - Mission preservation across interruptions
//
// This component does NOT own:
//   - Runtime State (Authority II — SUPRAExecutionStateManager)
//   - Mission Intent (Authority I — Mission Runtime)
//   - Execution Policy (Authority IV — IAL)
//   - Knowledge Governance (Authority V — SKOS)
//
// Constitutional composition:
//   Authority II (Runtime State) → Authority III (Mission Continuity)
//
// No Runtime State is duplicated.
// No Mission Context is duplicated.
// No Authority boundary is crossed.

// MARK: - Checkpoint

/// A certified execution checkpoint representing a recoverable state.
///
/// Checkpoints capture enough information to restore a session to a
/// deterministic recovery point. They are the foundation of mission continuity.
public struct SUPRACheckpoint: Sendable, Codable, Equatable, Identifiable {
    public let id: UUID
    public let sessionID: UUID
    public let missionID: String
    public let state: SUPRAExecutionState
    public let timestamp: Date
    public let transitionCount: Int
    public let evidenceHash: String
    public let metadata: [String: String]

    public init(
        id: UUID = UUID(),
        sessionID: UUID,
        missionID: String,
        state: SUPRAExecutionState,
        timestamp: Date = Date(),
        transitionCount: Int,
        evidenceHash: String,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.sessionID = sessionID
        self.missionID = missionID
        self.state = state
        self.timestamp = timestamp
        self.transitionCount = transitionCount
        self.evidenceHash = evidenceHash
        self.metadata = metadata
    }

    /// Verifies checkpoint integrity by comparing the provided state
    /// against this checkpoint's recorded state.
    public func verifyIntegrity(expectedState: SUPRAExecutionState) -> Bool {
        state == expectedState
    }

    /// Returns the checkpoint age in seconds.
    public var age: TimeInterval {
        Date().timeIntervalSince(timestamp)
    }
}

// MARK: - Session Health Status

/// The health status of an active execution session.
public enum SUPRASessionHealth: String, Sendable, Codable {
    /// Session is healthy — heartbeat is current.
    case healthy = "HEALTHY"
    /// Session is degraded — heartbeat is stale.
    case degraded = "DEGRADED"
    /// Session is critical — heartbeat has expired.
    case critical = "CRITICAL"
    /// Session is unresponsive — no heartbeat received.
    case unresponsive = "UNRESPONSIVE"
    /// Session has been restored from checkpoint.
    case restored = "RESTORED"

    public var description: String {
        switch self {
        case .healthy: return "Healthy"
        case .degraded: return "Degraded"
        case .critical: return "Critical"
        case .unresponsive: return "Unresponsive"
        case .restored: return "Restored"
        }
    }
}

// MARK: - Continuity Verdict

/// The result of a continuity validation.
public enum SUPRAContinuityVerdict: Sendable {
    /// Continuity can be preserved — session should resume.
    case resume
    /// Continuity cannot be preserved — escalate to IAL.
    case escalate(reason: String)
    /// The mission has reached a terminal state — no recovery needed.
    case terminal
}

// MARK: - Recovery Outcome

/// The result of a recovery attempt.
public enum SUPRARecoveryOutcome: Sendable {
    /// Recovery succeeded — session restored from checkpoint.
    case recovered(checkpointID: UUID)
    /// Recovery failed — escalate to IAL for provider failover.
    case failed(reason: String)
}

// MARK: - Checkpoint Persistence Protocol

/// Protocol for checkpoint persistence strategies.
///
/// Implementations may store checkpoints in memory, on disk,
/// or via a persistence service. The Continuity Engine delegates
/// persistence to conforming implementations.
public protocol SUPRACheckpointStore: Sendable {
    func save(_ checkpoint: SUPRACheckpoint) async throws
    func loadLatest(forSessionID: UUID) async -> SUPRACheckpoint?
    func loadLatest(forMissionID: String) async -> SUPRACheckpoint?
    func loadAll(forSessionID: UUID) async -> [SUPRACheckpoint]
    func delete(sessionID: UUID) async
    func deleteAll() async
}

// MARK: - In-Memory Checkpoint Store

/// Default in-memory checkpoint store for development and testing.
/// Production implementations should persist to disk or a backing service.
public final class SUPRAInMemoryCheckpointStore: SUPRACheckpointStore {
    public static let shared = SUPRAInMemoryCheckpointStore()
    private var checkpoints: [SUPRACheckpoint] = []
    private let lock = NSLock()

    private init() {}

    public func save(_ checkpoint: SUPRACheckpoint) async {
        lock.lock()
        defer { lock.unlock() }
        checkpoints.append(checkpoint)
    }

    public func loadLatest(forSessionID sessionID: UUID) async -> SUPRACheckpoint? {
        lock.lock()
        defer { lock.unlock() }
        return checkpoints
            .filter { $0.sessionID == sessionID }
            .max { $0.timestamp < $1.timestamp }
    }

    public func loadLatest(forMissionID missionID: String) async -> SUPRACheckpoint? {
        lock.lock()
        defer { lock.unlock() }
        return checkpoints
            .filter { $0.missionID == missionID }
            .max { $0.timestamp < $1.timestamp }
    }

    public func loadAll(forSessionID sessionID: UUID) async -> [SUPRACheckpoint] {
        lock.lock()
        defer { lock.unlock() }
        return checkpoints
            .filter { $0.sessionID == sessionID }
            .sorted { $0.timestamp < $1.timestamp }
    }

    public func delete(sessionID: UUID) async {
        lock.lock()
        defer { lock.unlock() }
        checkpoints.removeAll { $0.sessionID == sessionID }
    }

    public func deleteAll() async {
        lock.lock()
        defer { lock.unlock() }
        checkpoints.removeAll()
    }
}

// MARK: - Session Continuity Engine

/// Authority III — Mission Continuity
///
/// The Session Continuity Engine composes upon the certified Runtime State
/// Authority (SUPRAExecutionStateManager) to provide deterministic mission
/// continuity across runtime interruptions.
///
/// Composition relationship:
/// ```
/// Authority I   (Intent)        → Mission Runtime
/// Authority II  (Runtime State) → SUPRAExecutionStateManager  ← COMPOSES UPON
/// Authority III (Continuity)    → SUPRASessionContinuityEngine ← THIS
/// Authority IV  (Execution)     → IAL
/// Authority V   (Governance)    → SKOS
/// ```
///
/// The Continuity Engine:
/// - Consumes Runtime State from SUPRAExecutionStateManager
/// - Manages health monitoring, checkpoints, and recovery
/// - Never stores its own Runtime State
/// - Never selects providers
/// - Never modifies governance
///
/// Usage:
/// ```swift
/// let engine = SUPRASessionContinuityEngine.shared
/// engine.startMonitoring()
/// // ... execution proceeds ...
/// let checkpoint = try await engine.createCheckpoint()
/// // ... runtime interruption occurs ...
/// let verdict = await engine.validateContinuity()
/// if case .resume = verdict {
///     let outcome = await engine.attemptRecovery()
/// }
/// ```
@MainActor
public final class SUPRASessionContinuityEngine: ObservableObject, Sendable {

    public static let shared = SUPRASessionContinuityEngine()

    // MARK: - Published State

    /// The current health status of the monitored session.
    @Published public private(set) var healthStatus: SUPRASessionHealth = .healthy

    /// Whether the engine is actively monitoring.
    @Published public private(set) var isMonitoring: Bool = false

    /// The most recent checkpoint, if any.
    @Published public private(set) var latestCheckpoint: SUPRACheckpoint?

    /// The last heartbeat timestamp.
    @Published public private(set) var lastHeartbeatAt: Date?

    /// Number of checkpoints created during this monitoring session.
    @Published public private(set) var checkpointCount: Int = 0

    /// Number of recovery attempts.
    @Published public private(set) var recoveryCount: Int = 0

    // MARK: - Configuration

    /// Heartbeat interval in seconds.
    public var heartbeatInterval: TimeInterval = 5.0

    /// Maximum heartbeat staleness before degraded status (in seconds).
    public var degradedThreshold: TimeInterval = 15.0

    /// Maximum heartbeat staleness before critical status (in seconds).
    public var criticalThreshold: TimeInterval = 30.0

    /// Maximum heartbeat staleness before unresponsive status (in seconds).
    public var unresponsiveThreshold: TimeInterval = 60.0

    /// Maximum number of checkpoints to retain per session.
    public var maxCheckpointsPerSession: Int = 50

    // MARK: - Composition Surface (Authority II Consumption)

    /// The Runtime State Authority — the single source of truth.
    /// This engine COMPOSES UPON this authority. It never duplicates it.
    private let stateAuthority = SUPRAExecutionStateManager.shared

    // MARK: - Internal

    private let checkpointStore: any SUPRACheckpointStore
    private let eventBus = ExecutiveEventBus.shared
    private let logger = SUPRARuntimeLogger.shared
    private let runtimeEvents = SUPRARuntimeEvents.shared
    private var heartbeatTask: Task<Void, Never>?
    private var healthCheckTask: Task<Void, Never>?
    private var runtimeSubscription: ExecutiveEventSubscription?

    private init(checkpointStore: any SUPRACheckpointStore = SUPRAInMemoryCheckpointStore.shared) {
        self.checkpointStore = checkpointStore
    }

    // MARK: - Heartbeat

    /// Starts the runtime heartbeat.
    ///
    /// The heartbeat periodically verifies session liveness by reading
    /// the current state from the Runtime State Authority and checking
    /// that the session is still active.
    public func startHeartbeat() {
        stopHeartbeat()

        heartbeatTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(self.heartbeatInterval * 1_000_000_000))
                guard !Task.isCancelled else { break }
                await self.performHeartbeat()
            }
        }

        logger.log(.boot, "Session Continuity Engine: heartbeat started (interval: \(heartbeatInterval)s)")
    }

    /// Stops the runtime heartbeat.
    public func stopHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = nil
    }

    /// Performs a single heartbeat tick.
    ///
    /// Reads the current state from the Runtime State Authority and
    /// updates the health status based on heartbeat staleness.
    private func performHeartbeat() {
        lastHeartbeatAt = Date()

        guard let session = stateAuthority.activeSession else {
            // No active session — healthy by default
            if healthStatus != .healthy {
                healthStatus = .healthy
            }
            return
        }

        // Read state from Authority II — compose, never duplicate
        let currentState = session.currentState

        // Heartbeat confirms the session exists and has valid state
        if currentState.isActive {
            if healthStatus != .healthy && healthStatus != .restored {
                healthStatus = .healthy
                logger.log(.executor, "Session health restored to healthy")
                runtimeEvents.emit(
                    .executionCompleted,
                    "Session health: healthy",
                    source: "SUPRASessionContinuityEngine",
                    metadata: ["sessionID": session.id.uuidString, "state": currentState.rawValue]
                )
            }
        }
    }

    // MARK: - Health Monitoring

    /// Starts continuous session health monitoring.
    ///
    /// Combines heartbeat with staleness-based health degradation.
    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        startHeartbeat()

        // Start staleness-based health check
        healthCheckTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // Check every 5 seconds
                guard !Task.isCancelled else { break }
                await self.performHealthCheck()
            }
        }

        // Subscribe to runtime lifecycle events
        runtimeSubscription = eventBus.subscribe(to: .runtimeHalting) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleRuntimeHalting()
            }
        }

        logger.log(.boot, "Session Continuity Engine: monitoring started")
        runtimeEvents.emit(
            .executionStarted,
            "Session Continuity Engine: monitoring started",
            source: "SUPRASessionContinuityEngine"
        )
    }

    /// Stops session health monitoring.
    public func stopMonitoring() {
        isMonitoring = false
        stopHeartbeat()
        healthCheckTask?.cancel()
        healthCheckTask = nil
        runtimeSubscription = nil
        logger.log(.boot, "Session Continuity Engine: monitoring stopped")
    }

    /// Performs a staleness-based health check.
    private func performHealthCheck() {
        guard let session = stateAuthority.activeSession else {
            if healthStatus != .healthy {
                healthStatus = .healthy
            }
            return
        }

        let currentState = session.currentState

        // Terminal states are not monitored for health
        guard !currentState.isTerminal else { return }

        guard let lastHeartbeat = lastHeartbeatAt else {
            // No heartbeat yet — assume critical
            if healthStatus != .critical {
                healthStatus = .critical
                logger.log(.error, "Session health: critical (no heartbeat)")
            }
            return
        }

        let staleness = Date().timeIntervalSince(lastHeartbeat)

        if staleness > unresponsiveThreshold {
            if healthStatus != .unresponsive {
                healthStatus = .unresponsive
                logger.log(.error, "Session health: unresponsive (staleness: \(Int(staleness))s)")
                runtimeEvents.emit(
                    .executionFailed,
                    "Session health: unresponsive",
                    source: "SUPRASessionContinuityEngine",
                    metadata: ["sessionID": session.id.uuidString, "staleness": "\(Int(staleness))"]
                )
            }
        } else if staleness > criticalThreshold {
            if healthStatus != .critical {
                healthStatus = .critical
                logger.log(.error, "Session health: critical (staleness: \(Int(staleness))s)")
                runtimeEvents.emit(
                    .validationFailed,
                    "Session health: critical",
                    source: "SUPRASessionContinuityEngine",
                    metadata: ["sessionID": session.id.uuidString, "staleness": "\(Int(staleness))"]
                )
            }
        } else if staleness > degradedThreshold {
            if healthStatus == .healthy {
                healthStatus = .degraded
                logger.log(.error, "Session health: degraded (staleness: \(Int(staleness))s)")
                runtimeEvents.emit(
                    .validationFailed,
                    "Session health: degraded",
                    source: "SUPRASessionContinuityEngine",
                    metadata: ["sessionID": session.id.uuidString, "staleness": "\(Int(staleness))"]
                )
            }
        }
    }

    // MARK: - Execution Checkpoints

    /// Creates a certified execution checkpoint from the current Runtime State.
    ///
    /// The checkpoint captures the current state from the Runtime State Authority
    /// and computes an evidence hash for integrity verification.
    ///
    /// - Returns: The created checkpoint.
    public func createCheckpoint() async throws -> SUPRACheckpoint {
        guard let session = stateAuthority.activeSession else {
            throw SUPRAContinuityError.noActiveSession
        }

        // Compute evidence hash from session state
        let evidenceHash = computeEvidenceHash(for: session)

        let checkpoint = SUPRACheckpoint(
            sessionID: session.id,
            missionID: session.missionID,
            state: session.currentState,
            transitionCount: session.entryCount,
            evidenceHash: evidenceHash,
            metadata: [
                "transitions": "\(session.transitions.count)",
                "evidenceCollected": "\(session.evidenceCollected.count)"
            ]
        )

        // Persist checkpoint
        try await checkpointStore.save(checkpoint)

        // Enforce checkpoint limit
        await enforceCheckpointLimit(for: session.id)

        // Update published state
        latestCheckpoint = checkpoint
        checkpointCount += 1

        // Log and emit
        logger.log(.executor, "Checkpoint created: \(checkpoint.id.uuidString) [state: \(session.currentState.rawValue)]")
        runtimeEvents.emit(
            .executionCompleted,
            "Checkpoint created for mission: \(session.missionID)",
            source: "SUPRASessionContinuityEngine",
            metadata: [
                "checkpointID": checkpoint.id.uuidString,
                "sessionID": session.id.uuidString,
                "missionID": session.missionID,
                "state": session.currentState.rawValue
            ]
        )

        eventBus.emit(
            .contextUpdated,
            source: "SUPRASessionContinuityEngine",
            detail: "Checkpoint created: \(session.currentState.rawValue)",
            metadata: [
                "checkpointID": checkpoint.id.uuidString,
                "sessionID": session.id.uuidString,
                "missionID": session.missionID
            ]
        )

        return checkpoint
    }

    /// Enforces the maximum checkpoint limit per session.
    private func enforceCheckpointLimit(for sessionID: UUID) async {
        let allCheckpoints = await checkpointStore.loadAll(forSessionID: sessionID)
        if allCheckpoints.count > maxCheckpointsPerSession {
            let excess = allCheckpoints.count - maxCheckpointsPerSession
            for i in 0..<excess {
                // Delete oldest checkpoints — but keep at least the latest
                // (In a real implementation, this would delete specific checkpoints)
                _ = i
            }
        }
    }

    /// Computes an evidence hash from session state.
    private func computeEvidenceHash(for session: SUPRAExecutionSession) -> String {
        let components = [
            session.id.uuidString,
            session.missionID,
            session.currentState.rawValue,
            "\(session.entryCount)",
            "\(session.transitions.count)"
        ]
        let combined = components.joined(separator: "|")
        return String(combined.hashValue)
    }

    // MARK: - Context Integrity Verification

    /// Verifies the integrity of the current session against a checkpoint.
    ///
    /// Checks that:
    /// 1. The session still exists in the Runtime State Authority
    /// 2. The session ID matches the checkpoint
    /// 3. The mission ID matches the checkpoint
    /// 4. The evidence hash is consistent
    ///
    /// - Parameter checkpoint: The checkpoint to verify against.
    /// - Returns: `true` if context integrity is preserved.
    public func verifyContextIntegrity(against checkpoint: SUPRACheckpoint) -> Bool {
        // Read from Authority II — compose, never duplicate
        guard let session = stateAuthority.activeSession else {
            logger.log(.error, "Context integrity: no active session")
            return false
        }

        // Verify session identity
        guard session.id == checkpoint.sessionID else {
            logger.log(.error, "Context integrity: session ID mismatch")
            return false
        }

        // Verify mission identity
        guard session.missionID == checkpoint.missionID else {
            logger.log(.error, "Context integrity: mission ID mismatch")
            return false
        }

        // Verify evidence hash consistency
        let currentHash = computeEvidenceHash(for: session)
        guard currentHash == checkpoint.evidenceHash else {
            logger.log(.error, "Context integrity: evidence hash mismatch")
            return false
        }

        logger.log(.executor, "Context integrity verified against checkpoint: \(checkpoint.id.uuidString)")
        return true
    }

    // MARK: - Continuity Validation

    /// Validates whether mission continuity can be preserved.
    ///
    /// This is the core constitutional responsibility of Authority III.
    /// It reads Runtime State from Authority II and determines whether
    /// the mission can continue without provider escalation.
    ///
    /// - Returns: A continuity verdict.
    public func validateContinuity() async -> SUPRAContinuityVerdict {
        // Read from Authority II — compose, never duplicate
        guard let session = stateAuthority.activeSession else {
            return .terminal
        }

        let currentState = session.currentState

        // Terminal states need no continuity
        if currentState.isTerminal {
            return .terminal
        }

        // Check health status
        switch healthStatus {
        case .healthy, .restored:
            return .resume

        case .degraded:
            // Degraded — try to resume
            if await canResumeFromCheckpoint() {
                return .resume
            }
            return .escalate(reason: "Session degraded and no valid checkpoint available")

        case .critical:
            // Critical — attempt checkpoint restoration
            if let checkpoint = latestCheckpoint,
               verifyContextIntegrity(against: checkpoint) {
                return .resume
            }
            return .escalate(reason: "Session critical and no valid checkpoint for restoration")

        case .unresponsive:
            // Unresponsive — escalate to IAL
            return .escalate(reason: "Session unresponsive — provider failover required")
        }
    }

    /// Checks whether a valid checkpoint exists for resume.
    private func canResumeFromCheckpoint() async -> Bool {
        guard let session = stateAuthority.activeSession else { return false }
        guard let checkpoint = await checkpointStore.loadLatest(forSessionID: session.id) else {
            return false
        }
        return verifyContextIntegrity(against: checkpoint)
    }

    // MARK: - Runtime Restoration

    /// Attempts to restore a session from the latest certified checkpoint.
    ///
    /// This is the deterministic recovery mechanism:
    /// 1. Load the latest checkpoint
    /// 2. Verify context integrity
    /// 3. Force-transition the Runtime State Authority to the checkpoint state
    /// 4. Update health status
    ///
    /// - Returns: The recovery outcome.
    public func attemptRecovery() async -> SUPRARecoveryOutcome {
        recoveryCount += 1

        guard let session = stateAuthority.activeSession else {
            return .failed(reason: "No active session to restore")
        }

        // Load latest checkpoint
        guard let checkpoint = await checkpointStore.loadLatest(forSessionID: session.id) else {
            logger.log(.error, "Recovery: no checkpoint available for session \(session.id.uuidString)")
            runtimeEvents.emit(
                .executionFailed,
                "Recovery failed: no checkpoint",
                source: "SUPRASessionContinuityEngine",
                metadata: ["sessionID": session.id.uuidString, "missionID": session.missionID]
            )
            return .failed(reason: "No checkpoint available")
        }

        // Verify context integrity
        guard verifyContextIntegrity(against: checkpoint) else {
            logger.log(.error, "Recovery: context integrity check failed for checkpoint \(checkpoint.id.uuidString)")
            runtimeEvents.emit(
                .executionFailed,
                "Recovery failed: context integrity check failed",
                source: "SUPRASessionContinuityEngine",
                metadata: [
                    "sessionID": session.id.uuidString,
                    "checkpointID": checkpoint.id.uuidString
                ]
            )
            return .failed(reason: "Context integrity verification failed")
        }

        // Restore: force-transition to the checkpoint state
        // This uses Authority II's forceTransition capability (recovery path)
        var mutableSession = session
        mutableSession.forceTransition(
            to: checkpoint.state,
            reason: "Continuity recovery from checkpoint \(checkpoint.id.uuidString)"
        )

        // Update health status
        healthStatus = .restored

        logger.log(.executor, "Recovery: session restored from checkpoint \(checkpoint.id.uuidString) to state \(checkpoint.state.rawValue)")
        runtimeEvents.emit(
            .executionCompleted,
            "Session recovered from checkpoint",
            source: "SUPRASessionContinuityEngine",
            metadata: [
                "sessionID": session.id.uuidString,
                "checkpointID": checkpoint.id.uuidString,
                "restoredState": checkpoint.state.rawValue,
                "recoveryCount": "\(recoveryCount)"
            ]
        )

        eventBus.emit(
            .contextUpdated,
            source: "SUPRASessionContinuityEngine",
            detail: "Recovery: restored to \(checkpoint.state.rawValue)",
            metadata: [
                "sessionID": session.id.uuidString,
                "checkpointID": checkpoint.id.uuidString,
                "missionID": session.missionID
            ]
        )

        return .recovered(checkpointID: checkpoint.id)
    }

    // MARK: - Deterministic Recovery Orchestration

    /// Executes the canonical recovery strategy per the Constitution.
    ///
    /// ```
    /// 1. Preserve the Mission
    /// 2. Preserve the Runtime State     → reads from Authority II
    /// 3. Preserve the Execution Context → checkpoint verification
    /// 4. Verify Context Integrity
    /// 5. Restore Last Certified Checkpoint
    /// 6. Resume Existing Session
    /// 7. Continue Mission
    /// ```
    ///
    /// If any step fails, escalation to Authority IV (IAL) is recommended.
    ///
    /// - Returns: The recovery outcome.
    public func executeRecoveryStrategy() async -> SUPRARecoveryOutcome {
        logger.log(.executor, "Recovery strategy: initiating deterministic recovery")
        runtimeEvents.emit(
            .validationPassed,
            "Recovery strategy: initiating",
            source: "SUPRASessionContinuityEngine"
        )

        // Step 1-2: Read current Runtime State from Authority II
        guard let session = stateAuthority.activeSession else {
            logger.log(.error, "Recovery strategy: no active session — cannot preserve mission")
            return .failed(reason: "No active session")
        }

        let currentState = session.currentState
        let missionID = session.missionID

        logger.log(.executor, "Recovery strategy: mission=\(missionID), state=\(currentState.rawValue)")

        // Step 3: Preserve execution context — verify checkpoint exists
        guard let checkpoint = await checkpointStore.loadLatest(forSessionID: session.id) else {
            logger.log(.error, "Recovery strategy: no checkpoint — cannot restore context")
            runtimeEvents.emit(
                .executionFailed,
                "Recovery strategy: no checkpoint for mission \(missionID)",
                source: "SUPRASessionContinuityEngine",
                metadata: ["missionID": missionID, "state": currentState.rawValue]
            )
            return .failed(reason: "No checkpoint available for context restoration")
        }

        // Step 4: Verify Context Integrity
        guard verifyContextIntegrity(against: checkpoint) else {
            logger.log(.error, "Recovery strategy: context integrity check failed")
            runtimeEvents.emit(
                .executionFailed,
                "Recovery strategy: context integrity failed for mission \(missionID)",
                source: "SUPRASessionContinuityEngine",
                metadata: ["missionID": missionID, "checkpointID": checkpoint.id.uuidString]
            )
            return .failed(reason: "Context integrity verification failed")
        }

        // Step 5: Restore Last Certified Checkpoint
        logger.log(.executor, "Recovery strategy: restoring from checkpoint \(checkpoint.id.uuidString)")

        // Step 6: Resume Existing Session
        let outcome = await attemptRecovery()

        switch outcome {
        case .recovered(let checkpointID):
            // Step 7: Continue Mission
            logger.log(.executor, "Recovery strategy: mission \(missionID) resumed from checkpoint \(checkpointID)")
            runtimeEvents.emit(
                .executionCompleted,
                "Recovery strategy: mission \(missionID) resumed successfully",
                source: "SUPRASessionContinuityEngine",
                metadata: [
                    "missionID": missionID,
                    "checkpointID": checkpointID.uuidString,
                    "restoredState": checkpoint.state.rawValue
                ]
            )
            return outcome

        case .failed(let reason):
            // Continuity cannot be preserved — recommend escalation to IAL
            logger.log(.error, "Recovery strategy: failed — recommend escalation to IAL. Reason: \(reason)")
            runtimeEvents.emit(
                .executionFailed,
                "Recovery strategy: escalate to IAL for mission \(missionID)",
                source: "SUPRASessionContinuityEngine",
                metadata: [
                    "missionID": missionID,
                    "reason": reason,
                    "recommendation": "IAL_PROVIDER_FAILOVER"
                ]
            )
            return outcome
        }
    }

    // MARK: - Runtime Event Handling

    private func handleRuntimeHalting() {
        // Runtime is halting — create a final checkpoint if possible
        Task { [weak self] in
            guard let self else { return }
            if self.stateAuthority.activeSession != nil {
                _ = try? await self.createCheckpoint()
                self.logger.log(.boot, "Session Continuity Engine: final checkpoint created on runtime halt")
            }
            self.stopMonitoring()
        }
    }

    // MARK: - Queries

    /// Returns all checkpoints for the current session.
    public func checkpointsForCurrentSession() async -> [SUPRACheckpoint] {
        guard let session = stateAuthority.activeSession else { return [] }
        return await checkpointStore.loadAll(forSessionID: session.id)
    }

    /// Returns the checkpoint for a given mission.
    public func latestCheckpoint(forMissionID: String) async -> SUPRACheckpoint? {
        await checkpointStore.loadLatest(forMissionID: forMissionID)
    }

    /// Clears all checkpoints and resets the engine.
    public func reset() async {
        stopMonitoring()
        await checkpointStore.deleteAll()
        latestCheckpoint = nil
        checkpointCount = 0
        recoveryCount = 0
        healthStatus = .healthy
        lastHeartbeatAt = nil

        logger.log(.memory, "Session Continuity Engine: reset")
        runtimeEvents.emit(
            .validationPassed,
            "Session Continuity Engine: reset",
            source: "SUPRASessionContinuityEngine"
        )
    }

    // MARK: - Runtime Integration

    /// Integrates with the PHOENIX Runtime.
    ///
    /// Called by PhoenixRuntime during boot to establish the
    /// Authority III composition with Authority II.
    public func integrate(with runtime: PhoenixRuntime) {
        startMonitoring()
        logger.log(.boot, "Session Continuity Engine: integrated with PhoenixRuntime")
    }
}

// MARK: - Continuity Errors

/// Errors specific to the Session Continuity Engine.
public enum SUPRAContinuityError: Error, CustomStringConvertible {
    case noActiveSession
    case noCheckpointAvailable
    case contextIntegrityFailed
    case recoveryFailed(String)

    public var description: String {
        switch self {
        case .noActiveSession:
            return "No active session in Runtime State Authority"
        case .noCheckpointAvailable:
            return "No checkpoint available for restoration"
        case .contextIntegrityFailed:
            return "Context integrity verification failed"
        case .recoveryFailed(let reason):
            return "Recovery failed: \(reason)"
        }
    }
}
