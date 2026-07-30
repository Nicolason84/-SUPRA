import Foundation

struct MissionScore: Hashable, Sendable {
    let opportunityID: UUID
    let opportunityScore: Double
    let roi: Double
    let confidence: Double
    let riskPenalty: Double
}

enum MissionScoringEngine {
    static func score(_ opportunity: MissionOpportunity) -> MissionScore {
        let priorityWeight: Double = switch opportunity.priority {
        case .critical: 1.0
        case .high: 0.85
        case .medium: 0.65
        case .low: 0.4
        }

        let riskPenalty: Double = switch opportunity.risk {
        case .critical: 0.4
        case .high: 0.25
        case .medium: 0.1
        case .low: 0.0
        }

        let automationBonus = max(0, 0.2 - (Double(opportunity.automationLevel) * 0.05))
        let speedBonus = opportunity.expectedDurationMinutes <= 30 ? 0.1 : 0.0
        let score = max(
            0,
            (opportunity.confidence * 0.35)
            + (opportunity.roi * 0.3)
            + (priorityWeight * 0.25)
            + automationBonus
            + speedBonus
            - riskPenalty
        )

        return MissionScore(
            opportunityID: opportunity.id,
            opportunityScore: min(score, 1.0),
            roi: opportunity.roi,
            confidence: opportunity.confidence,
            riskPenalty: riskPenalty
        )
    }
}
