import Foundation
import Combine

struct MissionOpportunity: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let objective: String
    let businessContext: String
    let technicalContext: String
    let expectedValue: String
    let estimatedCost: String
    let expectedDurationMinutes: Int
    let dependencies: [String]
    let constraints: [String]
    let rollbackStrategy: String
    let validationPlan: String
    let expectedProof: String
    let automationLevel: Int
    let priority: Mission.Priority
    let risk: Mission.Risk
    let roi: Double
    let confidence: Double
    let evidenceSummary: String
    let source: String
}

@MainActor
final class MissionOpportunityEngine: ObservableObject {
    static let shared = MissionOpportunityEngine()

    @Published private(set) var opportunities: [MissionOpportunity] = []
    @Published private(set) var lastUpdated: Date?

    private weak var observer: SUPRAMissionObserver?
    private let optimization = SUPRAOptimizationCopilot.shared
    private let resources = SUPRAResourceIntelligenceEngine.shared

    private init() {}

    func bind(observer: SUPRAMissionObserver) {
        self.observer = observer
    }

    func refresh(missions: [Mission]) {
        var result: [MissionOpportunity] = []
        result.append(contentsOf: (observer?.observeIfChanged() ?? []).map(opportunity(from:)))
        result.append(contentsOf: optimization.findings.map(opportunity(from:)))
        result.append(contentsOf: resources.optimizationOpportunities.map(opportunity(from:)))

        if let blocked = missions.first(where: { $0.status == .blocked }) {
            result.append(MissionOpportunity(
                id: UUID(),
                title: "Recover blocked mission: \(blocked.title)",
                objective: "Repair the blocker preventing mission completion",
                businessContext: "Blocked missions reduce reliability and automation rate.",
                technicalContext: blocked.blocker ?? blocked.executionError ?? "Mission failed with proof and needs deterministic recovery.",
                expectedValue: "Restore mission throughput and reduce human intervention.",
                estimatedCost: "Low",
                expectedDurationMinutes: 30,
                dependencies: [blocked.title],
                constraints: ["Preserve canonical execution path", "Produce proof before retry"],
                rollbackStrategy: "Keep the blocked mission record untouched and create a separate recovery mission.",
                validationPlan: "Verify blocker is removed and rerun the affected mission path.",
                expectedProof: "Updated validation, logs and successful retry evidence.",
                automationLevel: 1,
                priority: .high,
                risk: .medium,
                roi: 0.86,
                confidence: 0.9,
                evidenceSummary: blocked.blocker ?? blocked.executionError ?? "Blocked mission detected",
                source: "MISSION_HISTORY"
            ))
        }

        opportunities = result
        lastUpdated = Date()
    }

    private func opportunity(from proposal: MissionProposal) -> MissionOpportunity {
        MissionOpportunity(
            id: proposal.id,
            title: proposal.title,
            objective: proposal.suggestedAction,
            businessContext: "Observed runtime or repository condition requires one bounded corrective mission.",
            technicalContext: proposal.description,
            expectedValue: "Reduce instability and improve mission completion reliability.",
            estimatedCost: proposal.destinationQueue == .autoExecute ? "Low" : "Medium",
            expectedDurationMinutes: proposal.destinationQueue == .autoExecute ? 20 : 40,
            dependencies: [],
            constraints: ["Reuse existing runtime services", "No terminal interaction required for standard flow"],
            rollbackStrategy: "Preserve current mission data and revert only the targeted change set if validation fails.",
            validationPlan: "Validate the observed issue is resolved and evidence is published.",
            expectedProof: proposal.reason,
            automationLevel: policyLevel(for: proposal.destinationQueue),
            priority: priority(for: proposal.estimatedImpact),
            risk: risk(for: proposal.estimatedImpact),
            roi: roi(for: proposal.confidence, impact: proposal.estimatedImpact),
            confidence: proposal.confidence,
            evidenceSummary: proposal.reason,
            source: "MISSION_PROPOSAL"
        )
    }

    private func opportunity(from observation: ObservationEvent) -> MissionOpportunity {
        let impact: DecisionImpact
        switch observation.type {
        case .resourceCritical, .runtimeOffline:
            impact = .critical
        case .runtimeDegraded, .memoryDisconnected, .conflictDetected:
            impact = .high
        case .resourceHighLoad, .missionBlocked, .intelligenceAnomaly:
            impact = .medium
        case .optimizationAvailable, .snapshotStale, .memoryStale:
            impact = .low
        }

        return MissionOpportunity(
            id: observation.id,
            title: observation.title,
            objective: suggestedObjective(for: observation.type),
            businessContext: "Observed runtime evidence indicates a bounded corrective mission is needed.",
            technicalContext: observation.detail,
            expectedValue: "Improve reliability and reduce repeated operational friction.",
            estimatedCost: impact == .critical ? "Medium" : "Low",
            expectedDurationMinutes: impact == .critical ? 45 : 25,
            dependencies: [],
            constraints: ["Use the canonical mission execution path", "Publish proof for the observed condition"],
            rollbackStrategy: "Revert only the targeted correction if validation fails.",
            validationPlan: "Re-check the originating signal and validate that the observation no longer reproduces.",
            expectedProof: observation.detail,
            automationLevel: impact == .critical ? 1 : 0,
            priority: priority(for: impact),
            risk: risk(for: impact),
            roi: roi(for: observation.confidence, impact: impact),
            confidence: observation.confidence,
            evidenceSummary: observation.detail,
            source: observation.source
        )
    }

    private func opportunity(from finding: OptimizationFinding) -> MissionOpportunity {
        MissionOpportunity(
            id: finding.id,
            title: finding.title,
            objective: finding.suggestedAction,
            businessContext: "Resource and workflow efficiency directly affect mission throughput.",
            technicalContext: finding.detail,
            expectedValue: finding.impact,
            estimatedCost: finding.canAutoExecute ? "Low" : "Medium",
            expectedDurationMinutes: finding.canAutoExecute ? 15 : 35,
            dependencies: [],
            constraints: ["Only execute if measurable value exists", "Keep rollback available"],
            rollbackStrategy: "Revert the optimization if metrics or validation regress.",
            validationPlan: "Measure resource state before and after the mission.",
            expectedProof: finding.evidence,
            automationLevel: finding.canAutoExecute ? 0 : 1,
            priority: finding.impactScore > 0.7 ? .high : .medium,
            risk: finding.impactScore > 0.75 ? .high : .medium,
            roi: max(0.2, finding.impactScore * finding.confidence),
            confidence: finding.confidence,
            evidenceSummary: finding.evidence,
            source: "OPTIMIZATION_COPILOT"
        )
    }

    private func opportunity(from optimization: OptimizationOpportunity) -> MissionOpportunity {
        let confidence = optimization.confidence
        let priority: Mission.Priority = confidence > 0.8 ? .high : .medium
        return MissionOpportunity(
            id: optimization.id,
            title: optimization.title,
            objective: optimization.effort,
            businessContext: "Continuous improvement requires selecting the highest-value optimization window.",
            technicalContext: optimization.impact,
            expectedValue: optimization.impact,
            estimatedCost: optimization.autoFixable ? "Low" : "Medium",
            expectedDurationMinutes: optimization.autoFixable ? 15 : 45,
            dependencies: [],
            constraints: ["Policy must allow execution", "Proof must be measurable"],
            rollbackStrategy: "Discard the optimization if performance or build behaviour regresses.",
            validationPlan: "Re-measure the affected domain after execution.",
            expectedProof: "\(optimization.domain) optimization confidence \(Int(confidence * 100))%",
            automationLevel: optimization.autoFixable ? 0 : 1,
            priority: priority,
            risk: optimization.autoFixable ? .low : .medium,
            roi: max(0.2, confidence * (optimization.autoFixable ? 1.0 : 0.75)),
            confidence: confidence,
            evidenceSummary: optimization.impact,
            source: "RESOURCE_INTELLIGENCE"
        )
    }

    private func suggestedObjective(for type: ObservationType) -> String {
        switch type {
        case .memoryStale: return "Refresh stale mission memory"
        case .memoryDisconnected: return "Reconnect mission memory source"
        case .resourceHighLoad: return "Reduce resource load"
        case .resourceCritical: return "Stabilize critical resource pressure"
        case .runtimeOffline: return "Recover the runtime service"
        case .runtimeDegraded: return "Repair degraded runtime behaviour"
        case .intelligenceAnomaly: return "Investigate intelligence anomalies"
        case .missionBlocked: return "Resolve the blocked mission dependency"
        case .optimizationAvailable: return "Use the current optimization window"
        case .snapshotStale: return "Refresh stale snapshot evidence"
        case .conflictDetected: return "Resolve conflicting runtime evidence"
        }
    }

    private func policyLevel(for authority: DecisionAuthority) -> Int {
        switch authority {
        case .autoExecute: return 0
        case .supervised: return 1
        case .humanRequired: return 2
        case .sovereignHumanOnly: return 3
        }
    }

    private func priority(for impact: DecisionImpact) -> Mission.Priority {
        switch impact {
        case .critical: return .critical
        case .high: return .high
        case .medium: return .medium
        case .low: return .low
        }
    }

    private func risk(for impact: DecisionImpact) -> Mission.Risk {
        switch impact {
        case .critical: return .critical
        case .high: return .high
        case .medium: return .medium
        case .low: return .low
        }
    }

    private func roi(for confidence: Double, impact: DecisionImpact) -> Double {
        let impactWeight: Double
        switch impact {
        case .critical: impactWeight = 1.0
        case .high: impactWeight = 0.85
        case .medium: impactWeight = 0.65
        case .low: impactWeight = 0.4
        }
        return confidence * impactWeight
    }
}
