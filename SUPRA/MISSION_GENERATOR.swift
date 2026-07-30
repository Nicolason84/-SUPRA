import Foundation

struct GeneratedMissionDraft: Identifiable, Hashable, Sendable {
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
    let authority: DecisionAuthority
    let priority: Mission.Priority
    let risk: Mission.Risk
    let priorityScore: Double
    let roi: Double
    let confidence: Double
    let source: String

    var summary: String {
        [
            "Objective: \(objective)",
            "Business Context: \(businessContext)",
            "Technical Context: \(technicalContext)",
            "Expected Value: \(expectedValue)",
            "Estimated Cost: \(estimatedCost)",
            "Expected Duration: \(expectedDurationMinutes) minutes",
            "Rollback Strategy: \(rollbackStrategy)",
            "Validation Plan: \(validationPlan)",
            "Expected Proof: \(expectedProof)",
            "Priority Score: \(priorityScore.formatted(.number.precision(.fractionLength(2))))",
            "ROI: \(roi.formatted(.number.precision(.fractionLength(2))))",
            "Confidence: \(confidence.formatted(.percent.precision(.fractionLength(0))))"
        ].joined(separator: "\n")
    }
}

enum MissionGenerator {
    static func generate(from opportunity: MissionOpportunity) -> GeneratedMissionDraft {
        let score = MissionScoringEngine.score(opportunity)
        let policy = AutonomyPolicyEngine.assess(opportunity)

        return GeneratedMissionDraft(
            id: UUID(),
            title: opportunity.title,
            objective: opportunity.objective,
            businessContext: opportunity.businessContext,
            technicalContext: opportunity.technicalContext,
            expectedValue: opportunity.expectedValue,
            estimatedCost: opportunity.estimatedCost,
            expectedDurationMinutes: opportunity.expectedDurationMinutes,
            dependencies: opportunity.dependencies,
            constraints: opportunity.constraints,
            rollbackStrategy: opportunity.rollbackStrategy,
            validationPlan: opportunity.validationPlan,
            expectedProof: opportunity.expectedProof,
            automationLevel: policy.level,
            authority: policy.authority,
            priority: opportunity.priority,
            risk: opportunity.risk,
            priorityScore: score.opportunityScore,
            roi: score.roi,
            confidence: score.confidence,
            source: opportunity.source
        )
    }
}
