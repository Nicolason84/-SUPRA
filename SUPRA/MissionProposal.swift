import Foundation

struct MissionProposal: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let category: DecisionCategory
    let reason: String
    let evidence: DecisionEvidence
    let confidence: Double
    let estimatedImpact: DecisionImpact
    let isReversible: Bool
    let suggestedAction: String
    let verdict: DecisionVerdict
    let observationType: ObservationType?
    let proposedAt: Date

    var destinationQueue: DecisionAuthority { verdict.authority }

    init(
        title: String,
        description: String,
        category: DecisionCategory,
        reason: String,
        evidence: DecisionEvidence,
        estimatedImpact: DecisionImpact,
        suggestedAction: String,
        verdict: DecisionVerdict,
        observationType: ObservationType?
    ) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.reason = reason
        self.evidence = evidence
        self.confidence = evidence.confidenceScore
        self.estimatedImpact = estimatedImpact
        self.isReversible = evidence.isReversible
        self.suggestedAction = suggestedAction
        self.verdict = verdict
        self.observationType = observationType
        self.proposedAt = Date()
    }
}
