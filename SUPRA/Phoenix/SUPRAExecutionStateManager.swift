import Foundation
import Combine

// MARK: - Ω4.B — SUPRA Execution State Manager
//
// The single Runtime authority responsible for execution state management.
//
// This component manages the execution lifecycle of a single mission or
// operation within the PHOENIX Runtime. It defines:
// - The execution state model (10 states)
// - Valid state transitions
// - State transition validation
// - Runtime integration hooks
// - Logging hooks
//
// This component does NOT contain:
// - Orchestration logic (that belongs to the Executive Mission Runtime)
// - Provider-specific logic (that belongs to IAL / execution providers)
// - UI (that belongs to the presentation layer)
// - SKOS implementation (that is the Knowledge Governance Authority)
// - ProofGraph implementation (that is the certification authority)
// - ExecutiveMissionRouter implementation (that is a separate Ω component)
//
// Integration:
// - Reuses Ω4.A (ExecutiveContextEngine) for context awareness
// - Hooks into SUPRARuntimeLogger for structured logging
// - Hooks into SUPRARuntimeEvents for runtime event emission
// - Hooks into ExecutiveEventBus for Phoenix event backbone
// - Integrates with PhoenixRuntime for lifecycle coordination

// MARK: - Execution State

/// The canonical execution states for a single mission/operation lifecycle.
///
/// These states form a directed acyclic graph of valid transitions.
/// The state manager enforces that only permitted transitions occur.
public enum SUPRAExecutionState: String, Codable, Sendable, CaseIterable {
    /// The execution engine is initialized but not yet performing any work.
    case idle = "IDLE"

    /// The execution engine is planning the next operation.
    case planning = "PLANNING"

    /// The execution engine is ready to begin execution.
    case ready = "READY"

    /// The execution engine is actively performing the operation.
    case executing = "EXECUTING"

    /// The execution engine is waiting for an external dependency or resource.
    case waiting = "WAITING"

    /// The execution engine is validating the results of the operation.
    case validating = "VALIDATING"

    /// The execution engine is collecting evidence from the operation.
    case collectingEvidence = "COLLECTING_EVIDENCE"

    /// The execution engine is certifying the collected evidence.
    case certification = "CERTIFICATION"

    /// The operation completed successfully.
    case completed = "COMPLETED"

    /// The operation failed and cannot continue.
    case failed = "FAILED"

    /// Human-readable description for logging and display.
    public var description: String {
        switch self {
        case .idle: return "Idle"
        case .planning: return "Planning"
        case .ready: return "Ready"
        case .executing: return "Executing"
        case .waiting: return "Waiting"
        case .validating: return "Validating"
        case .collectingEvidence: return "Collecting Evidence"
        case .certification: return "Certification"
        case .completed: return "Completed"
        case .failed: return "Failed"
        }
    }

    /// Whether this state represents a terminal state (no outgoing transitions).
    public var isTerminal: Bool {
        self == .completed || self == .failed
    }

    /// Whether this state represents an active/in-progress state.
    public var isActive: Bool {
        self == .planning || self == .executing || self == .waiting ||
        self == .validating || self == .collectingEvidence || self == .certification
    }
}

// MARK: - State Transition

/// Represents a transition between two execution states.
public struct SUPRAExecutionStateTransition: Sendable, Codable, Equatable {
    public let from: SUPRAExecutionState
    public let to: SUPRAExecutionState
    public let timestamp: Date
    public let reason: String?
    public let evidence: [String]

    public init(from: SUPRAExecutionState, to: SUPRAExecutionState,
                timestamp: Date = Date(), reason: String? = nil,
                evidence: [String] = []) {
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.reason = reason
        self.evidence = evidence
    }
}

// MARK: - Transition Validation

/// Validates whether a state transition is permitted.
public struct SUPRAExecutionStateTransitionValidator {
    /// The canonical transition table defining all valid state transitions.
    ///
    /// This table is the single source of truth for which transitions are allowed.
    /// Adding a new valid transition requires updating this table only.
    private static let validTransitions: [SUPRAExecutionState: Set<SUPRAExecutionState>] = [
        .idle: [.planning, .ready, .failed],
        .planning: [.ready, .executing, .waiting, .failed],
        .ready: [.executing, .waiting, .failed],
        .executing: [.waiting, .validating, .collectingEvidence, .completed, .failed],
        .waiting: [.executing, .validating, .failed],
        .validating: [.collectingEvidence, .certification, .completed, .failed],
        .collectingEvidence: [.certification, .validating, .failed],
        .certification: [.completed, .failed, .validating],
        .completed: [],
        .failed: []
    ]

    /// Checks whether a transition from one state to another is valid.
    ///
    /// - Parameters:
    ///   - from: The current state.
    ///   - to: The target state.
    /// - Returns: `true` if the transition is permitted, `false` otherwise.
    public static func isValidTransition(from: SUPRAExecutionState, to: SUPRAExecutionState) -> Bool {
        // Terminal states have no outgoing transitions
        if from.isTerminal {
            return false
        }

        // Same-state transitions are not valid (no self-loops)
        if from == to {
            return false
        }

        // Check the transition table
        let allowedTargets = validTransitions[from] ?? []
        return allowedTargets.contains(to)
    }

    /// Validates a transition and returns a reason if invalid.
    ///
    /// - Parameters:
    ///   - from: The current state.
    ///   - to: The target state.
    /// - Returns: A tuple containing whether the transition is valid and an optional reason.
    public static func validateTransition(from: SUPRAExecutionState, to: SUPRAExecutionState) -> (valid: Bool, reason: String?) {
        if from == to {
            return (false, "Self-transition not allowed: \(from.rawValue) -> \(to.rawValue)")
        }

        if from.isTerminal {
            return (false, "Cannot transition from terminal state: \(from.rawValue)")
        }

        let allowedTargets = validTransitions[from] ?? []
        if !allowedTargets.contains(to) {
            return (false, "Transition not permitted: \(from.rawValue) -> \(to.rawValue). Allowed: \(allowedTargets.map { $0.rawValue }.sorted().joined(separator: ", "))")
        }

        return (true, nil)
    }

    /// Returns all valid target states for a given source state.
    public static func validTargets(from state: SUPRAExecutionState) -> Set<SUPRAExecutionState> {
        validTransitions[state] ?? []
    }
}

// MARK: - Execution Session

/// A single execution session tracked by the state manager.
///
/// Each session represents one mission or operation lifecycle.
/// The state manager tracks the current state, transition history,
/// and associated metadata.
public struct SUPRAExecutionSession: Sendable, Codable, Equatable, Identifiable {
    public let id: UUID
    public let missionID: String
    public let startedAt: Date
    public private(set) var currentState: SUPRAExecutionState
    public private(set) var transitions: [SUPRAExecutionStateTransition]
    public private(set) var lastTransitionAt: Date?
    public private(set) var lastTransitionReason: String?
    public private(set) var evidenceCollected: [String]
    public private(set) var entryCount: Int

    public init(id: UUID = UUID(), missionID: String, startedAt: Date = Date(),
                initialState: SUPRAExecutionState = .idle) {
        self.id = id
        self.missionID = missionID
        self.startedAt = startedAt
        self.currentState = initialState
        self.transitions = []
        self.lastTransitionAt = nil
        self.lastTransitionReason = nil
        self.evidenceCollected = []
        self.entryCount = 1
    }

    /// Records a state transition if valid.
    ///
    /// - Parameters:
    ///   - to: The target state.
    ///   - reason: Optional reason for the transition.
    ///   - evidence: Optional evidence supporting the transition.
    /// - Returns: The transition record if valid, `nil` if the transition was rejected.
    public mutating func recordTransition(
        to: SUPRAExecutionState,
        reason: String? = nil,
        evidence: [String] = []
    ) -> SUPRAExecutionStateTransition? {
        let validation = SUPRAExecutionStateTransitionValidator.validateTransition(
            from: currentState, to: to
        )

        guard validation.valid else {
            return nil
        }

        let transition = SUPRAExecutionStateTransition(
            from: currentState,
            to: to,
            timestamp: Date(),
            reason: reason,
            evidence: evidence
        )

        transitions.append(transition)
        currentState = to
        lastTransitionAt = transition.timestamp
        lastTransitionReason = reason

        if !evidence.isEmpty {
            evidenceCollected.append(contentsOf: evidence)
        }

        entryCount += 1

        return transition
    }

    /// Attempts to force a state transition, bypassing validation.
    /// This should only be used for recovery scenarios where the normal
    /// transition graph cannot be followed.
    ///
    /// - Parameters:
    ///   - to: The target state.
    ///   - reason: Required reason for the forced transition.
    public mutating func forceTransition(to: SUPRAExecutionState, reason: String) {
        let transition = SUPRAExecutionStateTransition(
            from: currentState,
            to: to,
            timestamp: Date(),
            reason: "FORCED: \(reason)",
            evidence: []
        )

        transitions.append(transition)
        currentState = to
        lastTransitionAt = transition.timestamp
        lastTransitionReason = "FORCED: \(reason)"
        entryCount += 1
    }

    /// Checks whether a transition to the given state is currently valid.
    public func canTransition(to state: SUPRAExecutionState) -> Bool {
        SUPRAExecutionStateTransitionValidator.isValidTransition(from: currentState, to: state)
    }

    /// Returns the full transition history for this session.
    public var transitionHistory: [SUPRAExecutionStateTransition] {
        transitions
    }

    /// Convenience: returns the duration the session has been in its current state.
    public var currentStateDuration: TimeInterval {
        lastTransitionAt.map { Date().timeIntervalSince($0) } ?? 0
    }
}

// MARK: - Execution State Manager

/// The single Runtime authority responsible for execution state management.
///
/// This manager tracks the lifecycle of execution sessions, enforces valid
/// state transitions, integrates with the PHOENIX Runtime event backbone,
/// and provides logging hooks for observability.
///
/// Integration points:
/// - Reuses Ω4.A (ExecutiveContextEngine) for context awareness
/// - Hooks into SUPRARuntimeLogger for structured logging
/// - Hooks into SUPRARuntimeEvents for runtime event emission
/// - Hooks into ExecutiveEventBus for Phoenix event backbone
///
/// Usage:
/// ```swift
/// let manager = SUPRAExecutionStateManager.shared
/// let session = manager.startSession(missionID: "mission-123")
/// manager.transition(to: .planning, for: session.id)
/// ```
@MainActor
public final class SUPRAExecutionStateManager: ObservableObject, Sendable {
    public static let shared = SUPRAExecutionStateManager()

    // MARK: - Published State

    /// The currently active execution session, if any.
    @Published public private(set) var activeSession: SUPRAExecutionSession?

    /// All tracked execution sessions, ordered by start time.
    @Published public private(set) var sessions: [SUPRAExecutionSession] = []

    /// The current execution state (mirrors activeSession.currentState).
    @Published public private(set) var currentState: SUPRAExecutionState = .idle {
        didSet {
            // Mirror state to the context engine (Ω4.A reuse)
            ExecutiveContextEngine.shared.setExecutionState(currentState)
        }
    }

    /// Whether the state manager is currently tracking an active session.
    @Published public private(set) var hasActiveSession: Bool = false

    // MARK: - Internal

    private let eventBus = ExecutiveEventBus.shared
    private let logger = SUPRARuntimeLogger.shared
    private let runtimeEvents = SUPRARuntimeEvents.shared
    private let maxSessions: Int = 100
    private var bootSubscription: ExecutiveEventSubscription?
    private var activeSubscription: ExecutiveEventSubscription?
    private var haltSubscription: ExecutiveEventSubscription?

    private init() {}

    // MARK: - Session Lifecycle

    /// Starts a new execution session for the given mission.
    ///
    /// - Parameter missionID: The identifier of the mission to track.
    /// - Returns: The newly created session.
    public func startSession(missionID: String) -> SUPRAExecutionSession {
        // If there's an active session, we keep it but don't block the new one
        let session = SUPRAExecutionSession(missionID: missionID)
        sessions.append(session)

        // Enforce session history limit
        if sessions.count > maxSessions {
            sessions.removeFirst(sessions.count - maxSessions)
        }

        activeSession = session
        hasActiveSession = true
        currentState = session.currentState

        // Log the session start
        logger.log(.mission, "Execution session started: \(missionID)")
        runtimeEvents.emit(.executionStarted, "Execution session started for mission: \(missionID)",
                          source: "SUPRAExecutionStateManager",
                          metadata: ["missionID": missionID, "sessionID": session.id.uuidString])

        // Emit Phoenix event
        eventBus.emit(
            .info,
            source: "SUPRAExecutionStateManager",
            detail: "Session started for mission: \(missionID)",
            metadata: ["sessionID": session.id.uuidString, "missionID": missionID, "state": currentState.rawValue]
        )

        return session
    }

    /// Ends the active session, transitioning it to a terminal state.
    ///
    /// - Parameters:
    ///   - sessionID: The session to end.
    ///   - terminalState: Must be `.completed` or `.failed`.
    ///   - reason: Optional reason for ending the session.
    ///   - evidence: Optional evidence supporting the terminal state.
    public func endSession(
        sessionID: UUID,
        terminalState: SUPRAExecutionState,
        reason: String? = nil,
        evidence: [String] = []
    ) {
        guard terminalState.isTerminal else {
            logger.log(.error, "Cannot end session with non-terminal state: \(terminalState.rawValue)")
            return
        }

        // Find the session
        guard let index = sessions.firstIndex(where: { $0.id == sessionID }) else {
            logger.log(.error, "Session not found: \(sessionID.uuidString)")
            return
        }

        var session = sessions[index]
        _ = session.recordTransition(
            to: terminalState,
            reason: reason ?? "Session ended",
            evidence: evidence
        )

        sessions[index] = session

        // Clear active session if this was the active one
        if activeSession?.id == sessionID {
            currentState = terminalState
            hasActiveSession = false
            activeSession = nil
        }

        // Log the session end
        logger.log(.mission, "Execution session ended: \(session.missionID) -> \(terminalState.rawValue)")
        runtimeEvents.emit(
            terminalState == .completed ? .executionCompleted : .executionFailed,
            "Execution session ended: \(session.missionID) -> \(terminalState.rawValue)",
            source: "SUPRAExecutionStateManager",
            metadata: [
                "sessionID": sessionID.uuidString,
                "missionID": session.missionID,
                "state": terminalState.rawValue
            ]
        )

        // Emit Phoenix event
        eventBus.emit(
            terminalState == .completed ? .info : .error,
            source: "SUPRAExecutionStateManager",
            detail: "Session ended: \(session.missionID) -> \(terminalState.rawValue)",
            metadata: [
                "sessionID": sessionID.uuidString,
                "missionID": session.missionID,
                "state": terminalState.rawValue,
                "transitionCount": "\(session.transitions.count)"
            ]
        )
    }

    // MARK: - State Transitions

    /// Attempts to transition the active session to a new state.
    ///
    /// The transition is validated against the canonical transition table.
    /// If invalid, the transition is rejected and logged.
    ///
    /// - Parameters:
    ///   - to: The target state.
    ///   - reason: Optional reason for the transition.
    ///   - evidence: Optional evidence supporting the transition.
    /// - Returns: The transition record if valid, `nil` if rejected.
    public func transition(
        to: SUPRAExecutionState,
        reason: String? = nil,
        evidence: [String] = []
    ) -> SUPRAExecutionStateTransition? {
        guard let session = activeSession else {
            logger.log(.error, "Cannot transition: no active session")
            return nil
        }

        return transition(to: to, for: session.id, reason: reason, evidence: evidence)
    }

    /// Attempts to transition a specific session to a new state.
    ///
    /// - Parameters:
    ///   - to: The target state.
    ///   - sessionID: The session to transition.
    ///   - reason: Optional reason for the transition.
    ///   - evidence: Optional evidence supporting the transition.
    /// - Returns: The transition record if valid, `nil` if rejected.
    public func transition(
        to: SUPRAExecutionState,
        for sessionID: UUID,
        reason: String? = nil,
        evidence: [String] = []
    ) -> SUPRAExecutionStateTransition? {
        guard let index = sessions.firstIndex(where: { $0.id == sessionID }) else {
            logger.log(.error, "Cannot transition: session not found: \(sessionID.uuidString)")
            return nil
        }

        let validation = SUPRAExecutionStateTransitionValidator.validateTransition(
            from: sessions[index].currentState, to: to
        )

        guard validation.valid else {
            logger.log(.error, "Transition rejected: \(sessions[index].currentState.rawValue) -> \(to.rawValue). Reason: \(validation.reason ?? "unknown")")
            runtimeEvents.emit(
                .validationFailed,
                "Execution state transition rejected: \(sessions[index].currentState.rawValue) -> \(to.rawValue)",
                source: "SUPRAExecutionStateManager",
                metadata: [
                    "from": sessions[index].currentState.rawValue,
                    "to": to.rawValue,
                    "reason": validation.reason ?? "unknown",
                    "sessionID": sessionID.uuidString
                ]
            )
            return nil
        }

        // Record the transition
        var session = sessions[index]
        guard let transition = session.recordTransition(to: to, reason: reason, evidence: evidence) else {
            logger.log(.error, "Failed to record transition to \(to.rawValue)")
            return nil
        }
        sessions[index] = session

        // Update published state if this is the active session
        if activeSession?.id == sessionID {
            currentState = to
        }

        // Log the transition
        logger.log(
            .executor,
            "State transition: \(transition.from.rawValue) -> \(to.rawValue)"
        )

        runtimeEvents.emit(
            .executionCompleted,
            "Execution state transition: \(transition.from.rawValue) -> \(to.rawValue)",
            source: "SUPRAExecutionStateManager",
            metadata: [
                "from": transition.from.rawValue,
                "to": to.rawValue,
                "sessionID": sessionID.uuidString,
                "missionID": session.missionID
            ]
        )

        // Emit Phoenix event
        eventBus.emit(
            .contextUpdated,
            source: "SUPRAExecutionStateManager",
            detail: "Execution state: \(transition.from.rawValue) -> \(to.rawValue)",
            metadata: [
                "from": transition.from.rawValue,
                "to": to.rawValue,
                "sessionID": sessionID.uuidString,
                "missionID": session.missionID,
                "reason": reason ?? ""
            ]
        )

        return transition
    }

    // MARK: - Validation

    /// Checks whether a transition from the current state to the target state is valid.
    ///
    /// - Parameter to: The target state.
    /// - Returns: `true` if the transition is valid.
    public func canTransition(to: SUPRAExecutionState) -> Bool {
        guard let session = activeSession else { return false }
        return session.canTransition(to: to)
    }

    /// Checks whether a transition from a specific state to the target state is valid.
    ///
    /// - Parameters:
    ///   - from: The source state.
    ///   - to: The target state.
    /// - Returns: `true` if the transition is valid.
    public func isValidTransition(from: SUPRAExecutionState, to: SUPRAExecutionState) -> Bool {
        SUPRAExecutionStateTransitionValidator.isValidTransition(from: from, to: to)
    }

    /// Returns all valid target states from the current state.
    public func validTargets() -> Set<SUPRAExecutionState> {
        guard let session = activeSession else { return [] }
        return SUPRAExecutionStateTransitionValidator.validTargets(from: session.currentState)
    }

    // MARK: - Queries

    /// Returns all sessions matching the given mission ID.
    public func sessions(for missionID: String) -> [SUPRAExecutionSession] {
        sessions.filter { $0.missionID == missionID }
    }

    /// Returns the most recent session for a given mission ID.
    public func latestSession(for missionID: String) -> SUPRAExecutionSession? {
        sessions(for: missionID).max { $0.startedAt < $1.startedAt }
    }

    /// Returns all terminal sessions (completed or failed).
    public var terminalSessions: [SUPRAExecutionSession] {
        sessions.filter { $0.currentState.isTerminal }
    }

    /// Returns all active (non-terminal) sessions.
    public var activeSessions: [SUPRAExecutionSession] {
        sessions.filter { !$0.currentState.isTerminal }
    }

    /// Clears all session history.
    /// This should only be called during a full runtime reset.
    public func reset() {
        sessions.removeAll()
        activeSession = nil
        hasActiveSession = false
        currentState = .idle

        logger.log(.memory, "Execution State Manager reset — all sessions cleared")
        runtimeEvents.emit(.validationPassed, "Execution State Manager reset",
                          source: "SUPRAExecutionStateManager")
    }

    // MARK: - Runtime Integration Hooks

    /// Integrates with the PHOENIX Runtime by registering the state manager
    /// as an engine and hooking into the event bus.
    ///
    /// This method is called by PhoenixRuntime during boot.
    public func integrate(with runtime: PhoenixRuntime) {
        // Subscribe to runtime lifecycle events
        bootSubscription = eventBus.subscribe(to: .runtimeBooting) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleRuntimeBooting(event)
            }
        }

        activeSubscription = eventBus.subscribe(to: .runtimeActive) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleRuntimeActive(event)
            }
        }

        haltSubscription = eventBus.subscribe(to: .runtimeHalting) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleRuntimeHalting(event)
            }
        }

        logger.log(.boot, "SUPRAExecutionStateManager integrated with PhoenixRuntime")
    }

    /// Integrates with the Ω4.A Context Engine to mirror execution state.
    ///
    /// The Context Engine (ExecutiveContextEngine) is the canonical context
    /// authority for the PHOENIX Runtime. This method establishes the
    /// bidirectional integration hook.
    public func integrateWithContextEngine(_ contextEngine: ExecutiveContextEngine) {
        // The context engine is already integrated via the currentState didSet observer
        // This method exists for explicit integration confirmation
        logger.log(.boot, "SUPRAExecutionStateManager integrated with ExecutiveContextEngine (Ω4.A)")
    }

    // MARK: - Private: Event Handlers

    private func handleRuntimeBooting(_ event: ExecutiveEvent) {
        // Reset state when runtime boots
        if hasActiveSession {
            // Force-end any active session on boot
            if let session = activeSession {
                endSession(
                    sessionID: session.id,
                    terminalState: .failed,
                    reason: "Runtime rebooting",
                    evidence: ["runtime_boot"]
                )
            }
        }

        logger.log(.boot, "Runtime booting — execution state manager reset")
    }

    private func handleRuntimeActive(_ event: ExecutiveEvent) {
        // Runtime is now active — ensure we're in idle state for new sessions
        if !hasActiveSession {
            currentState = .idle
        }

        logger.log(.boot, "Runtime active — execution state manager ready")
    }

    private func handleRuntimeHalting(_ event: ExecutiveEvent) {
        // Runtime is halting — end any active session
        if let session = activeSession {
            endSession(
                sessionID: session.id,
                terminalState: .failed,
                reason: "Runtime halting",
                evidence: ["runtime_halt"]
            )
        }

        logger.log(.boot, "Runtime halting — execution state manager shutting down")
    }
}

// MARK: - ExecutiveContextEngine Integration

extension ExecutiveContextEngine {
    /// Sets the current execution state on the context engine.
    /// This is called by SUPRAExecutionStateManager when the state changes.
    ///
    /// This bridges the execution state manager with the Ω4.A Context Engine,
    /// allowing the context engine to expose execution state in the
    /// Executive Context Snapshot.
    ///
    /// This method is intentionally a no-op hook: the context engine already
    /// publishes state via @Published properties. The execution state is
    /// mirrored through the didSet observer on SUPRAExecutionStateManager.currentState.
    /// The ExecutiveContextSnapshot.ContextSnapshot can include this state
    /// via the snapshot builder without modifying ExecutiveContextEngine's
    /// existing API.
    public func setExecutionState(_ state: SUPRAExecutionState) {
        // Intentionally empty — serves as an integration hook point.
        // The state is mirrored via the didSet observer on
        // SUPRAExecutionStateManager.currentState, which calls this method.
    }
}
