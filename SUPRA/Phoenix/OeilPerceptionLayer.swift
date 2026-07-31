import Foundation
import Combine

// MARK: - Ω10 — ŒIL (Executive Perception Layer)
//
// The first visible manifestation of SUPRA's living runtime.
// ŒIL is not an icon, not an animation, not a widget.
// ŒIL is the living representation of the Vision Engine.
//
// ŒIL observes:
// - The project filesystem
// - Git repository state
// - Xcode build state
// - Runtime health
// - Provider status
// - Memory state
// - Mission progress
// - Build and test results
// - System health
//
// Then transforms raw perception into PRESENCE.
//
// ŒIL does not show engines. ŒIL does not show technology.
// ŒIL makes you FEEL where SUPRA is looking,
// what it understands, what it prepares, what it awaits, what it decides.

public enum OeilMood: String, Sendable, Codable, CaseIterable {
    case dormant     /// ŒIL is closed / not activated
    case observing   /// ŒIL is watching calmly
    case attentive   /// ŒIL has detected something
    case curious     /// ŒIL is exploring
    case focused     /// ŒIL is locked on a target
    case processing  /// ŒIL is thinking
    case waiting     /// ŒIL awaits user input
    case alert       /// ŒIL detected an anomaly
    case serene      /// ŒIL is at peace (all systems nominal)
}

public enum OeilGaze: String, Sendable, Codable, CaseIterable {
    case project     /// Looking at the project
    case git         /// Watching Git
    case files       /// Observing file changes
    case runtime     /// Monitoring runtime
    case build       /// Watching build
    case mission     /// Focused on mission
    case memory      /// Consulting memory
    case system      /// Checking system health
    case providers   /// Watching providers
    case user        /// Looking at user
    case horizon     /// Looking ahead
}

@MainActor
public final class OeilPerceptionLayer: ObservableObject, ExecutiveEngine {
    public static let shared = OeilPerceptionLayer()

    // MARK: - Executive Engine Conformance

    public let engineID = "oeil-perception-layer"
    public let engineName = "ŒIL Perception Layer"
    @Published public private(set) var status: ExecutiveEngineStatus = .uninitialized
    public var statusPublisher: Published<ExecutiveEngineStatus>.Publisher { $status }

    // MARK: - ŒIL State

    /// Current mood of ŒIL
    @Published public private(set) var mood: OeilMood = .dormant

    /// Where ŒIL is looking
    @Published public private(set) var gaze: OeilGaze = .horizon

    /// What ŒIL sees right now
    @Published public private(set) var perception: String = "..."

    /// What ŒIL understands
    @Published public private(set) var understanding: String = "..."

    /// What ŒIL is preparing
    @Published public private(set) var preparation: String = "..."

    /// What ŒIL is waiting for
    @Published public private(set) var awaiting: String = "..."

    /// ŒIL's current attention vector (0.0 = fully dispersed, 1.0 = fully locked)
    @Published public private(set) var attentionIntensity: Double = 0.0

    /// Whether ŒIL is active and perceiving
    @Published public private(set) var isAlive: Bool = false

    /// The last perception timestamp
    @Published public private(set) var lastPerception: Date?

    /// Perception log
    @Published public private(set) var perceptionLog: [PerceptionEntry] = []

    // MARK: - Perception Entry

    public struct PerceptionEntry: Sendable, Identifiable, Codable, Equatable {
        public let id: UUID
        public let timestamp: Date
        public let gaze: OeilGaze
        public let perception: String
        public let mood: OeilMood

        public init(gaze: OeilGaze, perception: String, mood: OeilMood) {
            self.id = UUID()
            self.timestamp = Date()
            self.gaze = gaze
            self.perception = perception
            self.mood = mood
        }

        public static func == (lhs: PerceptionEntry, rhs: PerceptionEntry) -> Bool {
            lhs.id == rhs.id
        }
    }

    // MARK: - Internal

    private var perceptionTimer: Timer?
    private let eventBus = ExecutiveEventBus.shared
    private let snapshotBus = ExecutiveSnapshotBus.shared
    private let vision = VisionEngine.shared
    private let presence = PresenceEngine.shared
    private let context = ExecutiveContextEngine.shared

    private var perceptionSequence: UInt64 = 0
    private let maxPerceptionLog: Int = 50

    private init() {}

    // MARK: - Executive Engine Boot

    public func boot() async throws {
        status = .initializing

        // Awaken ŒIL
        mood = .observing
        gaze = .horizon
        perception = "ŒIL s'éveille..."
        understanding = "Analyse de l'environnement..."
        preparation = "Connexion des perceptions..."
        awaiting = "Première observation"
        isAlive = true
        lastPerception = Date()

        // Register with Presence Engine
        presence.acknowledgeByOEil()
        presence.notifyPerceptionActive()

        eventBus.emit(.visionStarted, source: engineID, detail: "ŒIL s'éveille — perception layer active")

        // Start perception cycle
        perceptionTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.perceptionCycle()
            }
        }

        status = .active
        logPerception(gaze: .horizon, perception: "ŒIL est vivant. Perception active.", mood: .serene)
    }

    public func shutdown() async throws {
        mood = .dormant
        isAlive = false
        perceptionTimer?.invalidate()
        perceptionTimer = nil
        status = .uninitialized
        logPerception(gaze: .horizon, perception: "ŒIL se ferme.", mood: .dormant)
    }

    public func healthCheck() async -> ExecutiveEngineStatus {
        guard isAlive else {
            status = .degraded
            return .degraded
        }
        status = .active
        return .active
    }

    public func reset() async throws {
        try await shutdown()
        try await boot()
    }

    // MARK: - Perception Cycle

    private func perceptionCycle() {
        perceptionSequence += 1

        // Read the latest snapshot for context
        let snapshot = snapshotBus.latestSnapshot

        // Determine gaze based on what's happening
        updateGaze(from: snapshot)

        // Update mood based on system state
        updateMood(from: snapshot)

        // Update perception narrative
        updatePerception(from: snapshot)

        // Update understanding
        updateUnderstanding(from: snapshot)

        // Log perception
        logPerception(gaze: gaze, perception: perception, mood: mood)

        lastPerception = Date()

        // Update presence engine
        updatePresence()
    }

    // MARK: - Gaze Control

    private func updateGaze(from snapshot: ExecutiveContextSnapshot) {
        // Priority-based gaze determination
        if snapshot.runtimeState == "degrading" || snapshot.runtimeState == "regenerating" {
            gaze = .runtime
            attentionIntensity = 0.9
            return
        }

        if snapshot.vision.gitChangeCount > 0 {
            gaze = .git
            attentionIntensity = 0.7
            return
        }

        if snapshot.vision.fileChangeCount > 0 {
            gaze = .files
            attentionIntensity = 0.6
            return
        }

        if snapshot.digitalTwin.isSynced == false {
            gaze = .system
            attentionIntensity = 0.5
            return
        }

        if snapshot.context.currentMission != nil {
            gaze = .mission
            attentionIntensity = 0.6
            return
        }

        // Default: serene observation
        gaze = .project
        attentionIntensity = 0.3
    }

    // MARK: - Mood Control

    private func updateMood(from snapshot: ExecutiveContextSnapshot) {
        switch snapshot.runtimeState {
        case "dormant", "booting":
            mood = .observing
        case "degrading", "regenerating":
            mood = .alert
        case "active":
            if snapshot.vision.fileChangeCount > 0 || snapshot.vision.gitChangeCount > 0 {
                mood = .attentive
            } else if snapshot.presence.rawValue == "thinking" || snapshot.presence.rawValue == "deciding" {
                mood = .processing
            } else if snapshot.presence.rawValue == "waiting" {
                mood = .waiting
            } else {
                mood = .serene
            }
        default:
            mood = .observing
        }
    }

    // MARK: - Perception Narrative

    private func updatePerception(from snapshot: ExecutiveContextSnapshot) {
        switch gaze {
        case .project:
            let fileActivity = snapshot.vision.fileChangeCount > 0 ? "Activité détectée" : "Calme"
            perception = "Je perçois le projet. \(fileActivity)."
        case .git:
            perception = "Je vois \(snapshot.vision.gitChangeCount) changement(s) Git. Branche active: \(snapshot.vision.activeBranches.first ?? "inconnue")"
        case .files:
            perception = "\(snapshot.vision.fileChangeCount) fichier(s) modifié(s). Dernier changement: \(snapshot.vision.lastChangeDetected?.ISO8601Format() ?? "récent")"
        case .runtime:
            perception = "Runtime: \(snapshot.runtimeState). Moteurs: \(snapshot.runtimeHealthSummary?.activeEngineCount ?? 0)/\(snapshot.runtimeHealthSummary?.engineCount ?? 0) actifs."
        case .build:
            perception = "Surveillance du build..."
        case .mission:
            perception = "Mission active: \(snapshot.context.currentMission ?? "aucune")"
        case .memory:
            perception = "Consultation de la mémoire..."
        case .system:
            perception = "Santé système: \(snapshot.runtimeHealthSummary?.overallStatus ?? "inconnue")"
        case .providers:
            perception = "Fournisseurs: \(snapshot.context.activeProviders.joined(separator: ", "))"
        case .user:
            perception = "J'attends ton signal..."
        case .horizon:
            perception = "Tout est calme. J'observe l'horizon."
        }
    }

    // MARK: - Understanding

    private func updateUnderstanding(from snapshot: ExecutiveContextSnapshot) {
        let runtimeStatus = snapshot.runtimeState
        let presenceState = snapshot.presence.rawValue
        let visionActive = snapshot.vision.isWatching

        if snapshot.runtimeState == "active" && visionActive {
            understanding = "SUPRA est pleinement opérationnel. Tous les capteurs sont actifs."
        } else if snapshot.runtimeState == "degrading" {
            understanding = "Un ou plusieurs composants nécessitent mon attention."
        } else {
            understanding = "Analyse en cours..."
        }
    }

    // MARK: - Presence Update

    private func updatePresence() {
        switch gaze {
        case .project, .horizon:
            presence.focus(on: .project)
        case .git:
            presence.focus(on: .git)
        case .runtime:
            presence.focus(on: .runtime)
        case .build:
            presence.focus(on: .build)
        case .mission:
            presence.focus(on: .mission)
        case .system:
            presence.focus(on: .system)
        case .user:
            presence.focus(on: .user)
        default:
            presence.focus(on: .none)
        }

        switch mood {
        case .processing:
            presence.setState(.thinking)
        case .attentive, .curious, .focused:
            presence.setState(.watching)
        case .waiting:
            presence.setState(.waiting)
        case .alert:
            presence.setState(.watching)
        default:
            presence.setState(.present)
        }

        presence.setNarrative(perception)
    }

    // MARK: - Perception Logging

    private func logPerception(gaze: OeilGaze, perception: String, mood: OeilMood) {
        let entry = PerceptionEntry(gaze: gaze, perception: perception, mood: mood)
        perceptionLog.insert(entry, at: 0)
        if perceptionLog.count > maxPerceptionLog {
            perceptionLog = Array(perceptionLog.prefix(maxPerceptionLog))
        }
    }

    // MARK: - Manual Override

    public func directGaze(_ target: OeilGaze) {
        gaze = target
        logPerception(gaze: target, perception: "ŒIL regarde vers \(target.rawValue)", mood: .focused)
    }

    public func setMood(_ newMood: OeilMood) {
        mood = newMood
    }

    // MARK: - ŒIL Status Report

    public func statusReport() -> String {
        """
        ╔══════════════════════════════╗
        ║        ŒIL — STATUS          ║
        ╠══════════════════════════════╣
        ║ Alive:    \(isAlive ? "✓ YES" : "✗ NO")                 ║
        ║ Mood:     \(mood.rawValue.padding(toLength: 16, withPad: " ", startingAt: 0))║
        ║ Gaze:     \(gaze.rawValue.padding(toLength: 16, withPad: " ", startingAt: 0))║
        ║ Attention: \(String(format: "%.0f", attentionIntensity * 100).padding(toLength: 3, withPad: " ", startingAt: 0))%                 ║
        ║ Sequence: \(String(perceptionSequence).padding(toLength: 16, withPad: " ", startingAt: 0))║
        ╚══════════════════════════════╝
        Perception: \(perception)
        Understanding: \(understanding)
        """
    }
}
