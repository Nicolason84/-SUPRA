import Foundation

struct AutonomyPolicyAssessment: Hashable, Sendable {
    let level: Int
    let authority: DecisionAuthority
    let executionAllowed: Bool
    let reason: String
}

enum AutonomyPolicyEngine {
    static func assess(_ opportunity: MissionOpportunity) -> AutonomyPolicyAssessment {
        let authority: DecisionAuthority
        let level = max(0, min(3, opportunity.automationLevel))

        switch level {
        case 0:
            authority = .autoExecute
        case 1:
            authority = .supervised
        case 2:
            authority = .humanRequired
        default:
            authority = .sovereignHumanOnly
        }

        let isStrategic = opportunity.risk == .critical && opportunity.priority == .critical
        let executionAllowed = !isStrategic && authority != .sovereignHumanOnly
        let reason: String

        if authority == .sovereignHumanOnly {
            reason = "Mission falls under Level 3 human-only governance."
        } else if authority == .humanRequired {
            reason = "Mission requires approval before execution."
        } else if executionAllowed {
            reason = "Mission is reversible and can proceed on the canonical path."
        } else {
            reason = "Mission is blocked by policy."
        }

        return AutonomyPolicyAssessment(
            level: level,
            authority: authority,
            executionAllowed: executionAllowed,
            reason: reason
        )
    }
}
