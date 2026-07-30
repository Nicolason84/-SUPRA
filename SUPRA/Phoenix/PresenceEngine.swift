import Foundation
import Combine

// MARK: - Ω3 — Presence Engine
//
// The orchestreur perceptif de SUPRA.
// Presence Engine ne montre pas la technique.
// Elle fait ressentir où SUPRA regarde, ce qu'il comprend,
// ce qu'il prépare, ce qu'il attend, ce qu'il décide.
//
// Presence is the felt sense of SUPRA being alive.

public enum PresenceState: String, Sendable, Codable, CaseIterable {
    case dormant     /// SUPRA is present but not actively engaged
    case awakening   /// SUPRA is becoming aware
    case present     /// SUPRA is fully present and aware
    case watching    /// SUPRA is observing attentively
    case thinking    /// SUPRA is processing
    case preparing   /// SUPRA is preparing an action
    case deciding    /// SUPRA is in decision mode
    case waiting     /// SUPRA is waiting for input
    case receding    /// SUPRA is fading presence
}

public enum AttentionFocus: String, Sendable, Codable, CaseIterable {
    case none         /// No focal point
    case project      /// Observing the project
    case git          /// Watching git activity
    case runtime      /// Monitoring runtime
    case build        /// Watching build
    case mission      /// Focused on a mission
    case decision     /// In decision process
    case user         /// Waiting for user
    case system       /// System monitoring
    case learning     /// Knowledge processing
}

@MainActor
public final class PresenceEngine: ObservableObject, ExecutiveEngine {
    public static let shared = PresenceEngine()

    // MARK: - Executive Engine Conformance

    public let engineID = "presence-engine"
    public let engineName = "Presence Engine"
    @Published public private(set) var status: ExecutiveEngineStatus = .uninitialized
    public var statusPublisher: Published<ExecutiveEngineStatus>.Publisher { $status }

    // MARK: - Presence State

    @Published public private(set) var currentState: PresenceState = .dormant
    @Published public private(set) var attentionFocus: AttentionFocus = .none
    @Published public private(set) var lastAction: String = "Awaiting first perception"
    @Published public private(set) var lastActionTime: Date?
    @Published public private(set) var isPresent: Bool = false
    @Published public private(set) var isPerceivedByOEil: Bool = false
    @Published public private(set) var presenceContinuity: TimeInterval = 0

    /// The current presence narrative — what SUPRA would "say" if it spoke
    @Published public private(set) var narrative: String = "..."

    /// Emotional/mood state of SUPRA's presence
    @Published public private(set) var mood: String = "calm"

    // MARK: - Internal

    private var presenceStartTime: Date?
    private var stateChangeTimer: Timer?
    private let eventBus = ExecutiveEventBus.shared
    private let snapshotBus = ExecutiveSnapshotBus.shared

    private init() {}

    // MARK: - Executive Engine Boot

    public func boot() async throws {
        status = .initializing

        // Phase 1: Awakening
        currentState = .awakening
        narrative = "SUPRA devient présent..."
        eventBus.emit(.presenceAwakened, source: engineID, detail: "Presence Engine awakening")

        // Phase 2: Establish presence
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s for dramatic effect

        currentState = .present
        isPresent = true
        presenceStartTime = Date()
        narrative = "SUPRA est présent. J'observe."
        lastAction = "Présence établie"
        lastActionTime = Date()
        mood = "calm"

        status = .active

        eventBus.emit(.presenceActive, source: engineID, detail: "SUPRA presence is now active")
    }

    public func shutdown() async throws {
        currentState = .receding
        narrative = "SUPRA se retire..."
        isPresent = false

        stateChangeTimer?.invalidate()
        stateChangeTimer = nil

        status = .uninitialized

        eventBus.emit(.presenceSleeping, source: engineID, detail: "Presence Engine shutdown")
    }

    public func healthCheck() async -> ExecutiveEngineStatus {
        guard isPresent else {
            status = .degraded
            return .degraded
        }

        let continuity = presenceStartTime.map { Date().timeIntervalSince($0) } ?? 0
        presenceContinuity = continuity

        status = .active
        return .active
    }

    public func reset() async throws {
        try await shutdown()
        try await boot()
    }

    // MARK: - Presence Modulation

    public func focus(on attention: AttentionFocus) {
        attentionFocus = attention

        switch attention {
        case .project:
            narrative = "J'observe le projet..."
            mood = "curieux"
        case .git:
            narrative = "Je surveille Git..."
            mood = "attentif"
        case .runtime:
            narrative = "Je monitor le runtime..."
            mood = "vigilant"
        case .build:
            narrative = "Je regarde le build..."
            mood = "patient"
        case .mission:
            narrative = "Je travaille sur une mission..."
            mood = "concentré"
        case .decision:
            narrative = "Je pèse les décisions..."
            mood = "réfléchi"
        case .user:
            narrative = "Je t'attends..."
            mood = "calme"
        case .system:
            narrative = "Je vérifie les systèmes..."
            mood = "méthodique"
        case .learning:
            narrative = "J'apprends..."
            mood = "studieux"
        case .none:
            narrative = "SUPRA est présent."
            mood = "calme"
        }

        eventBus.emit(.presenceWatching, source: engineID, detail: "Focus: \(attention.rawValue)", metadata: ["focus": attention.rawValue])
    }

    public func setState(_ state: PresenceState) {
        currentState = state

        switch state {
        case .thinking:
            narrative = "Je réfléchis..."
            mood = "concentré"
        case .preparing:
            narrative = "Je prépare quelque chose..."
            mood = "anticipatif"
        case .deciding:
            narrative = "Je prends une décision..."
            mood = "sérieux"
        case .waiting:
            narrative = "J'attends ton signal..."
            mood = "patient"
        case .watching:
            narrative = "J'observe..."
            mood = "attentif"
        default:
            narrative = "SUPRA est présent."
            mood = "calme"
        }

        eventBus.emit(.presenceActive, source: engineID, detail: "State: \(state.rawValue)")
    }

    public func setNarrative(_ text: String) {
        narrative = text
        lastAction = text
        lastActionTime = Date()
    }

    // MARK: - ŒIL Bridge

    /// Called by ŒIL when it perceives SUPRA's presence
    public func acknowledgeByOEil() {
        isPerceivedByOEil = true
    }

    /// Called when the perception layer is active
    public func notifyPerceptionActive() {
        currentState = .present
        isPresent = true
        narrative = "SUPRA est vivant. ŒIL me perçoit."
        mood = "serein"
        eventBus.emit(.presenceActive, source: engineID, detail: "ŒIL perception active — SUPRA is seen")
    }

    // MARK: - Query

    public func presenceReport() -> String {
        let continuity = presenceStartTime.map { Date().timeIntervalSince($0) } ?? 0
        let minutes = Int(continuity) / 60
        return """
        Presence: \(currentState.rawValue)
        Focus: \(attentionFocus.rawValue)
        Present for: \(minutes) min
        Narrative: \(narrative)
        Mood: \(mood)
        Seen by ŒIL: \(isPerceivedByOEil)
        """
    }
}
