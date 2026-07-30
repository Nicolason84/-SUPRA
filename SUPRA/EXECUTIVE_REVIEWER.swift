import Foundation

struct ExecutiveReview: Hashable, Sendable {
    let passed: Bool
    let findings: [String]
}

enum ExecutiveReviewer {
    static func review(_ draft: GeneratedMissionDraft) -> ExecutiveReview {
        var findings: [String] = []

        if draft.objective.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            findings.append("Missing objective.")
        }
        if draft.expectedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            findings.append("Missing measurable value.")
        }
        if draft.rollbackStrategy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            findings.append("Missing rollback strategy.")
        }
        if draft.validationPlan.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            findings.append("Missing validation plan.")
        }
        if draft.expectedProof.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            findings.append("Missing expected proof.")
        }
        if draft.confidence < 0.4 {
            findings.append("Confidence below minimum threshold.")
        }

        return ExecutiveReview(passed: findings.isEmpty, findings: findings)
    }
}
