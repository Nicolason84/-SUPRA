// MARK: - Core Executive Types - Canonical Implementation
//
// This file is the canonical source of truth for ExecutiveContextSnapshot.
// All consumers read from this snapshot via ExecutiveSnapshotBus.
// No consumer accesses services directly — only via the latest snapshot.

import Foundation

// MARK: - ExecutiveContextSnapshot - Canonical Runtime State Structure

public struct ExecutiveContextSnapshot: Codable, Sendable {
    // MARK: - Stored Properties

    public let timestamp: Date
    public let phase: String
    public let missionId: String
    public let executiveMode: String
    public let buildStatus: String
    public let runtimeStatus: String
    public let missionMaturity: MissionMaturity
    public let healthStatus: String
    public let progressionStatus: String
    public let nextAction: String?
    public let loadedAt: Date
    public let sequenceNumber: UInt64

    // MARK: - Context (bridge to ExecutiveContextEngine)

    public let context: ContextSnapshot

    // MARK: - Vision Snapshot

    public let vision: ExecutionVision
    public let presence: PresenceState
    public let digitalTwin: DigitalTwinSnapshot
    public let runtimeHealthSummary: RuntimeHealthSummary?

    // MARK: - Mission Summaries

    public let missionsSummary: MissionsSummary
    public let dashboard: DashboardSummary

    // MARK: - Initial

    public static let initial: ExecutiveContextSnapshot = ExecutiveContextSnapshot(
        timestamp: Date(),
        phase: "initial",
        missionId: "",
        executiveMode: "autonomous",
        buildStatus: "IDLE",
        runtimeStatus: "dormant",
        missionMaturity: .undefined,
        healthStatus: "HEALTHY",
        progressionStatus: "idle",
        nextAction: nil,
        loadedAt: Date(),
        sequenceNumber: 0,
        context: ContextSnapshot.initial,
        vision: ExecutionVision(),
        presence: .dormant,
        digitalTwin: DigitalTwinSnapshot(),
        runtimeHealthSummary: nil,
        missionsSummary: MissionsSummary.initial,
        dashboard: DashboardSummary.initial
    )

    public init(
        timestamp: Date,
        phase: String,
        missionId: String,
        executiveMode: String,
        buildStatus: String,
        runtimeStatus: String,
        missionMaturity: MissionMaturity,
        healthStatus: String,
        progressionStatus: String,
        nextAction: String?,
        loadedAt: Date,
        sequenceNumber: UInt64,
        context: ContextSnapshot,
        vision: ExecutionVision,
        presence: PresenceState,
        digitalTwin: DigitalTwinSnapshot,
        runtimeHealthSummary: RuntimeHealthSummary?,
        missionsSummary: MissionsSummary,
        dashboard: DashboardSummary
    ) {
        self.timestamp = timestamp
        self.phase = phase
        self.missionId = missionId
        self.executiveMode = executiveMode
        self.buildStatus = buildStatus
        self.runtimeStatus = runtimeStatus
        self.missionMaturity = missionMaturity
        self.healthStatus = healthStatus
        self.progressionStatus = progressionStatus
        self.nextAction = nextAction
        self.loadedAt = loadedAt
        self.sequenceNumber = sequenceNumber
        self.context = context
        self.vision = vision
        self.presence = presence
        self.digitalTwin = digitalTwin
        self.runtimeHealthSummary = runtimeHealthSummary
        self.missionsSummary = missionsSummary
        self.dashboard = dashboard
    }

    // MARK: - Convenience Accessors

    public func needsBoost() -> Bool {
        buildStatus != "GREEN"
    }
}

// MARK: - ContextSnapshot (Bridge from ExecutiveContextEngine)

public extension ExecutiveContextSnapshot {
    struct ContextSnapshot: Codable, Sendable {
        public let currentMission: String?
        public let currentDecision: String?
        public let activeProviders: [String]
        public let systemLoad: Double
        public let memoryPressure: String
        public let networkStatus: String
        public let missionsSummary: MissionsSummary
        public let dashboard: DashboardSummary

        public static let initial: ContextSnapshot = ContextSnapshot(
            currentMission: nil,
            currentDecision: nil,
            activeProviders: [],
            systemLoad: 0,
            memoryPressure: "unknown",
            networkStatus: "unknown",
            missionsSummary: MissionsSummary.initial,
            dashboard: DashboardSummary.initial
        )

        public init(
            currentMission: String?,
            currentDecision: String?,
            activeProviders: [String],
            systemLoad: Double,
            memoryPressure: String,
            networkStatus: String,
            missionsSummary: MissionsSummary,
            dashboard: DashboardSummary
        ) {
            self.currentMission = currentMission
            self.currentDecision = currentDecision
            self.activeProviders = activeProviders
            self.systemLoad = systemLoad
            self.memoryPressure = memoryPressure
            self.networkStatus = networkStatus
            self.missionsSummary = missionsSummary
            self.dashboard = dashboard
        }
    }
}

// MARK: - DigitalTwinSnapshot

public extension ExecutiveContextSnapshot {
    struct DigitalTwinSnapshot: Codable, Sendable {
        public let isSynced: Bool
        public let lastSyncAt: Date?

        public static let initial: DigitalTwinSnapshot = DigitalTwinSnapshot(
            isSynced: false,
            lastSyncAt: nil
        )

        public init() {
            self.isSynced = false
            self.lastSyncAt = nil
        }

        public init(isSynced: Bool, lastSyncAt: Date?) {
            self.isSynced = isSynced
            self.lastSyncAt = lastSyncAt
        }
    }
}

// MARK: - RuntimeHealthSummary

public extension ExecutiveContextSnapshot {
    struct RuntimeHealthSummary: Codable, Sendable {
        public let overallStatus: String
        public let engineCount: Int
        public let activeEngineCount: Int

        public init(overallStatus: String, engineCount: Int, activeEngineCount: Int) {
            self.overallStatus = overallStatus
            self.engineCount = engineCount
            self.activeEngineCount = activeEngineCount
        }
    }

}

// MARK: - MissionSummaryItem

public extension ExecutiveContextSnapshot {
    struct MissionSummaryItem: Codable, Sendable, Identifiable, Equatable {
        public let id: String
        public let title: String
        public let status: String
        public let priority: String
        public let risk: String
        public let maturity: MissionMaturity
        public let progress: Double
        public let executiveDecision: String?
        public let currentStep: String
        public let currentStatus: String
        public let evidenceCount: Int
        public let blocker: String?
        public let currentProvider: String?
        public let currentModel: String?
        public let estimatedRemainingMinutes: Int?
        public let expectedOutcome: String?
        public let nextMission: String?
        public let health: String

        public init(
            id: String,
            title: String,
            status: String,
            priority: String,
            risk: String,
            maturity: MissionMaturity,
            progress: Double,
            executiveDecision: String? = nil,
            currentStep: String = "",
            currentStatus: String = "",
            evidenceCount: Int = 0,
            blocker: String? = nil,
            currentProvider: String? = nil,
            currentModel: String? = nil,
            estimatedRemainingMinutes: Int? = nil,
            expectedOutcome: String? = nil,
            nextMission: String? = nil,
            health: String = "Ready"
        ) {
            self.id = id
            self.title = title
            self.status = status
            self.priority = priority
            self.risk = risk
            self.maturity = maturity
            self.progress = progress
            self.executiveDecision = executiveDecision
            self.currentStep = currentStep
            self.currentStatus = currentStatus
            self.evidenceCount = evidenceCount
            self.blocker = blocker
            self.currentProvider = currentProvider
            self.currentModel = currentModel
            self.estimatedRemainingMinutes = estimatedRemainingMinutes
            self.expectedOutcome = expectedOutcome
            self.nextMission = nextMission
            self.health = health
        }

        static func from(mission: Mission) -> MissionSummaryItem {
            MissionSummaryItem(
                id: mission.id.uuidString,
                title: mission.title,
                status: mission.status.rawValue,
                priority: mission.priority.rawValue,
                risk: mission.risk.rawValue,
                maturity: .undefined,
                progress: mission.progress,
                executiveDecision: mission.executiveDecision,
                currentStep: mission.currentStep,
                currentStatus: mission.currentStatus,
                evidenceCount: mission.evidence.count,
                blocker: mission.blocker,
                currentProvider: mission.currentProvider,
                currentModel: mission.currentModel,
                estimatedRemainingMinutes: mission.estimatedRemainingMinutes,
                expectedOutcome: mission.expectedOutcome,
                nextMission: mission.nextMission,
                health: mission.health.rawValue
            )
        }
    }
}

// MARK: - MissionsSummary

public extension ExecutiveContextSnapshot {
    struct MissionsSummary: Codable, Sendable {
        public let totalCount: Int
        public let activeCount: Int
        public let plannedCount: Int
        public let completedCount: Int
        public let blockedCount: Int
        public let autoCount: Int
        public let supervisionCount: Int
        public let humanCount: Int
        public let current: MissionSummaryItem?
        public let autoMissions: [MissionSummaryItem]
        public let supervisionMissions: [MissionSummaryItem]
        public let humanMissions: [MissionSummaryItem]
        public let visibleMissions: [MissionSummaryItem]

        public static let initial: MissionsSummary = MissionsSummary(
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

        public init(
            totalCount: Int,
            activeCount: Int,
            plannedCount: Int,
            completedCount: Int,
            blockedCount: Int,
            autoCount: Int,
            supervisionCount: Int,
            humanCount: Int,
            current: MissionSummaryItem?,
            autoMissions: [MissionSummaryItem],
            supervisionMissions: [MissionSummaryItem],
            humanMissions: [MissionSummaryItem],
            visibleMissions: [MissionSummaryItem]
        ) {
            self.totalCount = totalCount
            self.activeCount = activeCount
            self.plannedCount = plannedCount
            self.completedCount = completedCount
            self.blockedCount = blockedCount
            self.autoCount = autoCount
            self.supervisionCount = supervisionCount
            self.humanCount = humanCount
            self.current = current
            self.autoMissions = autoMissions
            self.supervisionMissions = supervisionMissions
            self.humanMissions = humanMissions
            self.visibleMissions = visibleMissions
        }
    }
}

// MARK: - DashboardSummary

public extension ExecutiveContextSnapshot {
    struct DashboardSummary: Codable, Sendable {
        public let hasRuntimeMetrics: Bool
        public let runtimeVersion: String
        public let decisionCount: Int
        public let conversationCount: Int
        public let activeRecommendationCount: Int
        public let humanRequiredRecommendationCount: Int
        public let environmentStateExists: Bool
        public let evolutionProposalCount: Int
        public let agentCount: Int
        public let alertCount: Int
        public let buildStatus: String
        public let freezeStatus: String
        public let providerCount: Int
        public let timelineEventCount: Int
        public let copilotProposalCount: Int
        public let copilotAutoQueueCount: Int
        public let copilotExecutionQueueCount: Int
        public let copilotSupervisionQueueCount: Int
        public let copilotHumanQueueCount: Int
        public let copilotExecutedCount: Int

        public static let initial: DashboardSummary = DashboardSummary(
            hasRuntimeMetrics: false,
            runtimeVersion: "0.0.0",
            decisionCount: 0,
            conversationCount: 0,
            activeRecommendationCount: 0,
            humanRequiredRecommendationCount: 0,
            environmentStateExists: false,
            evolutionProposalCount: 0,
            agentCount: 0,
            alertCount: 0,
            buildStatus: "idle",
            freezeStatus: "missing",
            providerCount: 0,
            timelineEventCount: 0,
            copilotProposalCount: 0,
            copilotAutoQueueCount: 0,
            copilotExecutionQueueCount: 0,
            copilotSupervisionQueueCount: 0,
            copilotHumanQueueCount: 0,
            copilotExecutedCount: 0
        )

        public init(
            hasRuntimeMetrics: Bool,
            runtimeVersion: String,
            decisionCount: Int,
            conversationCount: Int,
            activeRecommendationCount: Int,
            humanRequiredRecommendationCount: Int,
            environmentStateExists: Bool,
            evolutionProposalCount: Int,
            agentCount: Int,
            alertCount: Int,
            buildStatus: String,
            freezeStatus: String,
            providerCount: Int,
            timelineEventCount: Int,
            copilotProposalCount: Int,
            copilotAutoQueueCount: Int,
            copilotExecutionQueueCount: Int,
            copilotSupervisionQueueCount: Int,
            copilotHumanQueueCount: Int,
            copilotExecutedCount: Int
        ) {
            self.hasRuntimeMetrics = hasRuntimeMetrics
            self.runtimeVersion = runtimeVersion
            self.decisionCount = decisionCount
            self.conversationCount = conversationCount
            self.activeRecommendationCount = activeRecommendationCount
            self.humanRequiredRecommendationCount = humanRequiredRecommendationCount
            self.environmentStateExists = environmentStateExists
            self.evolutionProposalCount = evolutionProposalCount
            self.agentCount = agentCount
            self.alertCount = alertCount
            self.buildStatus = buildStatus
            self.freezeStatus = freezeStatus
            self.providerCount = providerCount
            self.timelineEventCount = timelineEventCount
            self.copilotProposalCount = copilotProposalCount
            self.copilotAutoQueueCount = copilotAutoQueueCount
            self.copilotExecutionQueueCount = copilotExecutionQueueCount
            self.copilotSupervisionQueueCount = copilotSupervisionQueueCount
            self.copilotHumanQueueCount = copilotHumanQueueCount
            self.copilotExecutedCount = copilotExecutedCount
        }
    }
}
