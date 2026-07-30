import Foundation
import Combine

@MainActor
final class SUPRAEnvironmentAutoMissions: ObservableObject {
    static let shared = SUPRAEnvironmentAutoMissions()

    @Published private(set) var missionProposals: [MissionProposal] = []
    @Published private(set) var lastSync: Date?

    private let copilot = SUPRAOptimizationCopilot.shared
    private let proposalEngine = SUPRAMissionProposalEngine.shared

    private init() {}

    func sync() {
        guard !copilot.findings.isEmpty else { return }
        var proposals: [MissionProposal] = []

        for finding in copilot.findings {
            guard let proposal = buildProposal(from: finding) else { continue }
            proposals.append(proposal)
        }

        missionProposals = proposals

        for proposal in proposals {
            if !proposalEngine.proposals.contains(where: { $0.title == proposal.title }) {
                proposalEngine.refresh()
            }
        }

        lastSync = Date()
    }

    private func buildProposal(from finding: OptimizationFinding) -> MissionProposal? {
        let category: DecisionCategory
        switch finding.category {
        case "performance", "thermal", "power": category = .resource
        case "memory": category = .memory
        case "storage", "data": category = .config
        case "developer": category = .system
        default: category = .system
        }

        let impact: DecisionImpact
        if finding.impactScore > 0.7 { impact = .high }
        else if finding.impactScore > 0.4 { impact = .medium }
        else { impact = .low }

        let isReversible = finding.isReversible

        let evidence = DecisionEvidence(
            confidenceScore: finding.confidence,
            evidenceScore: finding.confidence * 0.9,
            impact: impact,
            isReversible: isReversible,
            category: category,
            permissionsAvailable: true
        )

        let verdict = SUPRADecisionEngine.evaluate(evidence)

        return MissionProposal(
            title: finding.title,
            description: finding.detail,
            category: category,
            reason: finding.evidence,
            evidence: evidence,
            estimatedImpact: impact,
            suggestedAction: finding.suggestedAction,
            verdict: verdict,
            observationType: nil
        )
    }
}
