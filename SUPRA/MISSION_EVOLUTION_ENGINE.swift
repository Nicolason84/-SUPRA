import Foundation
import Combine

@MainActor
final class MissionEvolutionEngine: ObservableObject {
    static let shared = MissionEvolutionEngine()

    @Published private(set) var selectedOpportunity: MissionOpportunity?
    @Published private(set) var generatedMission: GeneratedMissionDraft?
    @Published private(set) var review: ExecutiveReview?
    @Published private(set) var policy: AutonomyPolicyAssessment?
    @Published private(set) var lastUpdated: Date?

    private weak var opportunityEngine: MissionOpportunityEngine?

    private init() {}

    func bind(opportunityEngine: MissionOpportunityEngine) {
        self.opportunityEngine = opportunityEngine
    }

    func refresh(missions: [Mission]) {
        opportunityEngine?.refresh(missions: missions)
        let ranked = (opportunityEngine?.opportunities ?? [])
            .map { ($0, MissionScoringEngine.score($0)) }
            .sorted { lhs, rhs in
                if lhs.1.opportunityScore == rhs.1.opportunityScore {
                    return lhs.0.confidence > rhs.0.confidence
                }
                return lhs.1.opportunityScore > rhs.1.opportunityScore
            }

        guard let best = ranked.first?.0 else {
            selectedOpportunity = nil
            generatedMission = nil
            review = nil
            policy = nil
            lastUpdated = Date()
            return
        }

        let draft = MissionGenerator.generate(from: best)
        let policy = AutonomyPolicyEngine.assess(best)
        let review = ExecutiveReviewer.review(draft)

        selectedOpportunity = best
        generatedMission = draft
        self.policy = policy
        self.review = review
        lastUpdated = Date()
    }
}
