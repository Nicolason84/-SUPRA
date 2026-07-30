import Foundation

// MARK: - Ω5 — Executive Context Snapshot
//
// The SINGLE source of truth for SwiftUI and all consumers.
// No view accesses services directly. Every view reads this snapshot.
// The snapshot is published by the Snapshot Bus (Ω6) whenever context changes.
//
// This is an immutable value type — once captured, it represents
// a point-in-time view of the entire executive context.

public struct ExecutiveContextSnapshot: Sendable, Codable, Equatable {
    // MARK: - Snapshot Identity

    public let snapshotID: UUID
    public let timestamp: Date
    public let sequenceNumber: UInt64

    // MARK: - Runtime State

    public let runtimeState: ExecutiveRuntimeState
    public let runtimeUptime: TimeInterval
    public let runtimeBootDate: Date?
    public let runtimeHealthSummary: ExecutiveHealthSummary?

    // MARK: - Vision (Ω2)

    public let vision: VisionSnapshot

    public struct VisionSnapshot: Sendable, Codable, Equatable {
        public let isWatching: Bool
        public let observedPaths: [String]
        public let lastChangeDetected: Date?
        public let lastGitChange: Date?
        public let fileChangeCount: Int
        public let gitChangeCount: Int
        public let activeBranches: [String]
        public let recentCommits: [String]
        public let projectHealth: String
        public let watcherStatus: String

        public static let initial = VisionSnapshot(
            isWatching: false,
            observedPaths: [],
            lastChangeDetected: nil,
            lastGitChange: nil,
            fileChangeCount: 0,
            gitChangeCount: 0,
            activeBranches: [],
            recentCommits: [],
            projectHealth: "unknown",
            watcherStatus: "uninitialized"
        )
    }

    // MARK: - Presence (Ω3)

    public let presence: PresenceSnapshot

    public struct PresenceSnapshot: Sendable, Codable, Equatable {
        public let state: String
        public let attention: String
        public let lastAction: String
        public let lastActionTime: Date?
        public let isPresent: Bool
        public let perceivedByOEil: Bool

        public static let initial = PresenceSnapshot(
            state: "dormant",
            attention: "none",
            lastAction: "Awaiting first mission",
            lastActionTime: nil,
            isPresent: false,
            perceivedByOEil: false
        )
    }

    // MARK: - Context (Ω4)

    public let context: ContextSnapshot

    public struct ContextSnapshot: Sendable, Codable, Equatable {
        public let currentMission: String?
        public let currentDecision: String?
        public let activeProviders: [String]
        public let systemLoad: Double
        public let memoryPressure: String
        public let networkStatus: String

        // MARK: - Mission Summary (Bridge to Mission Center)

        public let missionsSummary: MissionsSummary

        public static let initial = ContextSnapshot(
            currentMission: nil,
            currentDecision: nil,
            activeProviders: [],
            systemLoad: 0,
            memoryPressure: "unknown",
            networkStatus: "unknown",
            missionsSummary: .initial
        )
    }

    // MARK: - Missions Summary

    /// Lightweight, Codable mission data for views — populated by the
    /// Context Engine from MissionStore, distributed via the Snapshot Bus.
    /// Views read this instead of accessing MissionStore directly.
    public struct MissionsSummary: Sendable, Codable, Equatable {
        // Aggregates
        public let totalCount: Int
        public let activeCount: Int
        public let plannedCount: Int
        public let completedCount: Int
        public let blockedCount: Int
        public let autoCount: Int
        public let supervisionCount: Int
        public let humanCount: Int

        // Current / active mission (full detail for the grid)
        public let current: MissionSummaryItem?

        // Queue lists
        public let autoMissions: [MissionSummaryItem]
        public let supervisionMissions: [MissionSummaryItem]
        public let humanMissions: [MissionSummaryItem]
        public let visibleMissions: [MissionSummaryItem]

        public static let initial = MissionsSummary(
            totalCount: 0,
            activeCount: 0,
            plannedCount: 0,
            completedCount: 0,
            blockedCount: 0,
            autoCount: 0,
            supervisionCount: 0,
            humanCount: 0,
            current: nil,
            autoMissions: [],
            supervisionMissions: [],
            humanMissions: [],
            visibleMissions: []
        )
    }

    /// Individual mission item carried in the snapshot.
    /// Covers all fields used by MissionSurfaceView's stat cards and queue lists.
    public struct MissionSummaryItem: Sendable, Codable, Equatable, Identifiable {
        public let id: String
        public let title: String
        public let objective: String
        public let phase: String
        public let status: String
        public let lifecycle: String
        public let authority: String
        public let priority: String
        public let risk: String
        public let health: String
        public let progress: Double
        public let currentStep: String
        public let currentStatus: String
        public let currentProvider: String?
        public let currentModel: String?
        public let estimatedRemainingMinutes: Int?
        public let expectedOutcome: String?
        public let executiveDecision: String?
        public let nextMission: String?
        public let blocker: String?
        public let evidenceCount: Int
        public let updatedAt: Date?

        static func from(mission: Mission) -> MissionSummaryItem {
            MissionSummaryItem(
                id: mission.id.uuidString,
                title: mission.title,
                objective: mission.objective,
                phase: mission.currentStep,
                status: mission.status.rawValue,
                lifecycle: mission.lifecycle.rawValue,
                authority: mission.authority.rawValue,
                priority: mission.priority.rawValue,
                risk: mission.risk.rawValue,
                health: mission.health.rawValue,
                progress: mission.progress,
                currentStep: mission.currentStep,
                currentStatus: mission.currentStatus,
                currentProvider: mission.currentProvider,
                currentModel: mission.currentModel,
                estimatedRemainingMinutes: mission.estimatedRemainingMinutes,
                expectedOutcome: mission.expectedOutcome,
                executiveDecision: mission.executiveDecision,
                nextMission: mission.nextMission,
                blocker: mission.blocker,
                evidenceCount: mission.evidence.count,
                updatedAt: mission.identity.updatedAt
            )
        }
    }

    // MARK: - Digital Twin (Ω8)

    public let digitalTwin: DigitalTwinSnapshot

    public struct DigitalTwinSnapshot: Sendable, Codable, Equatable {
        public let isSynced: Bool
        public let lastSync: Date?
        public let twinState: String
        public let desyncCount: Int
        public let syncAccuracy: Double

        public static let initial = DigitalTwinSnapshot(
            isSynced: false,
            lastSync: nil,
            twinState: "uninitialized",
            desyncCount: 0,
            syncAccuracy: 0
        )
    }

    // MARK: - Identity (Ω9)

    public let identity: IdentitySnapshot

    public struct IdentitySnapshot: Sendable, Codable, Equatable {
        public let nodeID: String
        public let hostname: String
        public let kernelVersion: String
        public let sessionID: String
        public let bootCount: Int

        public static let initial = IdentitySnapshot(
            nodeID: "supra-node-unknown",
            hostname: Host.current().localizedName ?? "unknown",
            kernelVersion: "1.0.0",
            sessionID: UUID().uuidString,
            bootCount: 0
        )
    }

    // MARK: - System

    public let system: SystemSnapshot

    public struct SystemSnapshot: Sendable, Codable, Equatable {
        public let cpuUsage: Double
        public let memoryUsage: UInt64
        public let memoryTotal: UInt64
        public let diskFree: Int64
        public let diskTotal: Int64
        public let batteryLevel: Float?
        public let isCharging: Bool?

        public static let current = SystemSnapshot(
            cpuUsage: 0,
            memoryUsage: 0,
            memoryTotal: 0,
            diskFree: 0,
            diskTotal: 0,
            batteryLevel: nil,
            isCharging: nil
        )
    }

    // MARK: - Initial Snapshot

    public static let initial = ExecutiveContextSnapshot(
        snapshotID: UUID(),
        timestamp: Date(),
        sequenceNumber: 0,
        runtimeState: .dormant,
        runtimeUptime: 0,
        runtimeBootDate: nil,
        runtimeHealthSummary: nil,
        vision: .initial,
        presence: .initial,
        context: .initial,
        digitalTwin: .initial,
        identity: .initial,
        system: .current
    )

    // MARK: - Init

    public init(snapshotID: UUID, timestamp: Date, sequenceNumber: UInt64, runtimeState: ExecutiveRuntimeState, runtimeUptime: TimeInterval, runtimeBootDate: Date?, runtimeHealthSummary: ExecutiveHealthSummary?, vision: VisionSnapshot, presence: PresenceSnapshot, context: ContextSnapshot, digitalTwin: DigitalTwinSnapshot, identity: IdentitySnapshot, system: SystemSnapshot) {
        self.snapshotID = snapshotID
        self.timestamp = timestamp
        self.sequenceNumber = sequenceNumber
        self.runtimeState = runtimeState
        self.runtimeUptime = runtimeUptime
        self.runtimeBootDate = runtimeBootDate
        self.runtimeHealthSummary = runtimeHealthSummary
        self.vision = vision
        self.presence = presence
        self.context = context
        self.digitalTwin = digitalTwin
        self.identity = identity
        self.system = system
    }
}

// MARK: - Snapshot Builder

public final class ExecutiveSnapshotBuilder: Sendable {
    private var sequenceNumber: UInt64 = 0

    public init() {}

    public func build(
        runtimeCore: ExecutiveRuntimeCore,
        vision: VisionEngine?,
        presence: PresenceEngine?,
        context: ExecutiveContextEngine?,
        digitalTwin: DigitalTwinRuntime?,
        identity: IdentityRuntime?
    ) -> ExecutiveContextSnapshot {
        sequenceNumber += 1

        return ExecutiveContextSnapshot(
            snapshotID: UUID(),
            timestamp: Date(),
            sequenceNumber: sequenceNumber,
            runtimeState: runtimeCore.state,
            runtimeUptime: runtimeCore.bootDate.map { Date().timeIntervalSince($0) } ?? 0,
            runtimeBootDate: runtimeCore.bootDate,
            runtimeHealthSummary: runtimeCore.healthSummary,
            vision: buildVisionSnapshot(vision),
            presence: buildPresenceSnapshot(presence),
            context: buildContextSnapshot(context),
            digitalTwin: buildDigitalTwinSnapshot(digitalTwin),
            identity: buildIdentitySnapshot(identity),
            system: .current
        )
    }

    private func buildVisionSnapshot(_ vision: VisionEngine?) -> ExecutiveContextSnapshot.VisionSnapshot {
        guard let vision else { return .initial }
        return ExecutiveContextSnapshot.VisionSnapshot(
            isWatching: vision.isWatching,
            observedPaths: vision.observedPaths,
            lastChangeDetected: vision.lastFileChange,
            lastGitChange: vision.lastGitChange,
            fileChangeCount: vision.fileChangeCount,
            gitChangeCount: vision.gitChangeCount,
            activeBranches: vision.activeBranches,
            recentCommits: vision.recentCommits,
            projectHealth: vision.projectHealth,
            watcherStatus: vision.status.rawValue
        )
    }

    private func buildPresenceSnapshot(_ presence: PresenceEngine?) -> ExecutiveContextSnapshot.PresenceSnapshot {
        guard let presence else { return .initial }
        return ExecutiveContextSnapshot.PresenceSnapshot(
            state: presence.currentState.rawValue,
            attention: presence.attentionFocus.rawValue,
            lastAction: presence.lastAction,
            lastActionTime: presence.lastActionTime,
            isPresent: presence.isPresent,
            perceivedByOEil: presence.isPerceivedByOEil
        )
    }

    private func buildContextSnapshot(_ context: ExecutiveContextEngine?) -> ExecutiveContextSnapshot.ContextSnapshot {
        guard let context else { return .initial }
        return ExecutiveContextSnapshot.ContextSnapshot(
            currentMission: context.currentMission,
            currentDecision: context.currentDecision,
            activeProviders: context.activeProviders,
            systemLoad: context.systemLoad,
            memoryPressure: context.memoryPressure,
            networkStatus: context.networkStatus,
            missionsSummary: context.missionsSummary
        )
    }

    private func buildDigitalTwinSnapshot(_ twin: DigitalTwinRuntime?) -> ExecutiveContextSnapshot.DigitalTwinSnapshot {
        guard let twin else { return .initial }
        return ExecutiveContextSnapshot.DigitalTwinSnapshot(
            isSynced: twin.isSynced,
            lastSync: twin.lastSync,
            twinState: twin.state.rawValue,
            desyncCount: twin.desyncCount,
            syncAccuracy: twin.syncAccuracy
        )
    }

    private func buildIdentitySnapshot(_ identity: IdentityRuntime?) -> ExecutiveContextSnapshot.IdentitySnapshot {
        guard let identity else { return .initial }
        return ExecutiveContextSnapshot.IdentitySnapshot(
            nodeID: identity.nodeID,
            hostname: identity.hostname,
            kernelVersion: identity.kernelVersion,
            sessionID: identity.sessionID,
            bootCount: identity.bootCount
        )
    }
}
