// MARK: - Executive Snapshot Builder
//
// Builds ExecutiveContextSnapshot from all runtime engines.
// This is the only way snapshots are created.

import Foundation

@MainActor
public final class ExecutiveSnapshotBuilder {
    public init() {}

    public func build(
        runtimeCore: ExecutiveRuntimeCore,
        vision: VisionEngine,
        presence: PresenceEngine,
        context: ExecutiveContextEngine,
        digitalTwin: DigitalTwinRuntime,
        identity: IdentityRuntime,
        distance: SUPRAExecutiveDistanceEngine
    ) -> ExecutiveContextSnapshot {
        let now = Date()

        return ExecutiveContextSnapshot(
            timestamp: now,
            phase: context.currentMission.map { "mission_\($0)" } ?? "monitoring",
            missionId: context.currentMission ?? "",
            executiveMode: "autonomous",
            buildStatus: distance.dashboard.currentMaturity.rawValue,
            runtimeStatus: runtimeCore.state.rawValue,
            missionMaturity: distance.dashboard.currentMaturity,
            healthStatus: runtimeCore.healthSummary?.overallStatus.rawValue ?? "unknown",
            progressionStatus: "active",
            nextAction: nil,
            loadedAt: now,
            sequenceNumber: UInt64(now.timeIntervalSince1970),
            context: ExecutiveContextSnapshot.ContextSnapshot(
                currentMission: context.currentMission,
                currentDecision: context.currentDecision,
                activeProviders: context.activeProviders,
                systemLoad: context.systemLoad,
                memoryPressure: context.memoryPressure,
                networkStatus: context.networkStatus,
                missionsSummary: context.missionsSummary,
                dashboard: context.dashboard
            ),
            vision: ExecutionVision(
                isWatching: vision.isWatching,
                readingMode: .automatic,
                gitChangeCount: vision.gitChangeCount,
                fileChangeCount: vision.fileChangeCount,
                activeBranches: vision.activeBranches,
                lastChangeDetected: vision.lastFileChange
            ),
            presence: presence.currentState,
            digitalTwin: ExecutiveContextSnapshot.DigitalTwinSnapshot(
                isSynced: digitalTwin.isSynced,
                lastSyncAt: digitalTwin.lastSync
            ),
            runtimeHealthSummary: runtimeCore.healthSummary.map { summary in
                ExecutiveContextSnapshot.RuntimeHealthSummary(
                    overallStatus: summary.overallStatus.rawValue,
                    engineCount: summary.engineCount,
                    activeEngineCount: summary.activeEngineCount
                )
            },
            missionsSummary: context.missionsSummary,
            dashboard: context.dashboard
        )
    }
}
