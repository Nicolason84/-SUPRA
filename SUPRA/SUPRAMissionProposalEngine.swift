import Foundation
import Combine

@MainActor
final class SUPRAMissionProposalEngine: ObservableObject {
    static let shared = SUPRAMissionProposalEngine()

    @Published private(set) var proposals: [MissionProposal] = []
    @Published private(set) var autoQueue: [MissionProposal] = []
    @Published private(set) var supervisionQueue: [MissionProposal] = []
    @Published private(set) var humanQueue: [MissionProposal] = []

    private let observer = SUPRAMissionObserver.shared
    private var lastHash = 0

    private init() {}

    func refresh() {
        let observations = observer.observeIfChanged()
        let hash = observations.reduce(0) { $0 ^ $1.id.hashValue }
        guard hash != lastHash else { return }
        lastHash = hash

        var newProposals: [MissionProposal] = []
        for obs in observations {
            if let proposal = proposal(from: obs) {
                if !proposals.contains(where: { $0.title == proposal.title }) {
                    newProposals.append(proposal)
                }
            }
        }
        proposals = newProposals + proposals
        if proposals.count > 50 { proposals = Array(proposals.prefix(50)) }
        classify()
    }

    func clear() {
        proposals = []
        autoQueue = []
        supervisionQueue = []
        humanQueue = []
        lastHash = 0
    }

    private func classify() {
        var auto: [MissionProposal] = []
        var supervision: [MissionProposal] = []
        var human: [MissionProposal] = []

        for p in proposals {
            switch p.verdict.authority {
            case .autoExecute: auto.append(p)
            case .supervised: supervision.append(p)
            case .humanRequired, .sovereignHumanOnly: human.append(p)
            }
        }

        autoQueue = auto
        supervisionQueue = supervision
        humanQueue = human
    }

    private func proposal(from observation: ObservationEvent) -> MissionProposal? {
        let (category, impact, reversible, confidence): (DecisionCategory, DecisionImpact, Bool, Double)

        switch observation.type {
        case .memoryDisconnected:
            category = .memory; impact = .high; reversible = true; confidence = observation.confidence
        case .memoryStale:
            category = .memory; impact = .medium; reversible = true; confidence = observation.confidence
        case .resourceHighLoad:
            category = .resource; impact = .medium; reversible = true; confidence = observation.confidence
        case .resourceCritical:
            category = .resource; impact = .critical; reversible = false; confidence = observation.confidence
        case .runtimeOffline:
            category = .runtime; impact = .critical; reversible = true; confidence = observation.confidence
        case .runtimeDegraded:
            category = .runtime; impact = .high; reversible = true; confidence = observation.confidence
        case .intelligenceAnomaly:
            category = .system; impact = .medium; reversible = true; confidence = observation.confidence
        case .missionBlocked:
            category = .mission; impact = .medium; reversible = true; confidence = observation.confidence
        case .optimizationAvailable:
            category = .config; impact = .low; reversible = true; confidence = observation.confidence
        case .snapshotStale:
            category = .memory; impact = .low; reversible = true; confidence = observation.confidence
        case .conflictDetected:
            category = .system; impact = .high; reversible = true; confidence = observation.confidence
        }

        let evidence = DecisionEvidence(
            confidenceScore: confidence,
            evidenceScore: 0.85,
            impact: impact,
            isReversible: reversible,
            category: category,
            permissionsAvailable: true
        )
        let verdict = SUPRADecisionEngine.evaluate(evidence)
        let action = suggestedAction(for: observation.type)

        return MissionProposal(
            title: observation.title,
            description: observation.detail,
            category: category,
            reason: "Observation: \(observation.type.rawValue)",
            evidence: evidence,
            estimatedImpact: impact,
            suggestedAction: action,
            verdict: verdict,
            observationType: observation.type
        )
    }

    private func suggestedAction(for type: ObservationType) -> String {
        switch type {
        case .memoryDisconnected: "Reconnect memory source"
        case .memoryStale: "Refresh snapshot"
        case .resourceHighLoad: "Reduce background tasks"
        case .resourceCritical: "Pause non-essential operations"
        case .runtimeOffline: "Restart runtime monitor"
        case .runtimeDegraded: "Stabilize runtime"
        case .intelligenceAnomaly: "Investigate anomalies"
        case .missionBlocked: "Resolve dependencies"
        case .optimizationAvailable: "Run optimization"
        case .snapshotStale: "Refresh CAnnoNico cache"
        case .conflictDetected: "Resolve conflict"
        }
    }
}
