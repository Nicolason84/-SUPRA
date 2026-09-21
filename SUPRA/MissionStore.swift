import Foundation
import Combine
import CryptoKit

@MainActor
final class MissionStore: ObservableObject {
    enum Filter: String, CaseIterable, Identifiable {
        case all = "All"
        case planned = "Planned"
        case active = "Active"
        case blocked = "Blocked"
        case completed = "Completed"

        var id: Self { self }
    }

    enum Sort: String, CaseIterable, Identifiable {
        case dueDate = "Due Date"
        case priority = "Priority"
        case progress = "Progress"
        case title = "Mission"

        var id: Self { self }
    }

    @Published private(set) var missions: [Mission] = []
    @Published private(set) var visibleMissions: [Mission] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var query = "" {
        didSet { applyPresentation() }
    }
    @Published var activeFilter: Filter = .all {
        didSet { applyPresentation() }
    }
    @Published var activeSort: Sort = .priority {
        didSet { applyPresentation() }
    }

    func load() {
        guard missions.isEmpty else {
            applyPresentation()
            return
        }

        isLoading = true
        errorMessage = nil

        let result = loadRealMissions()
        missions = result.missions
        errorMessage = result.errors.isEmpty ? nil : result.errors.joined(separator: " · ")
        isLoading = false
        applyPresentation()
    }

    func refresh() {
        missions = []
        load()
    }

    func search(_ text: String) {
        query = text
    }

    func filter(_ filter: Filter) {
        activeFilter = filter
    }

    func sort(_ sort: Sort) {
        activeSort = sort
    }

    private func loadRealMissions() -> (missions: [Mission], errors: [String]) {
        var loaded: [Mission] = []
        var errors: [String] = []

        do {
            loaded.append(contentsOf: try loadOpportunityMissions())
        } catch {
            errors.append("Opportunités: \(error.localizedDescription)")
        }

        let gabriel = SUPRAGabrielConductorRuntime.load()
        if gabriel.status.uppercased() != "NOT RUN" || gabriel.run != nil {
            loaded.append(contentsOf: gabrielMissions(gabriel))
        } else if loaded.isEmpty {
            errors.append("Gabriel: aucun run matérialisé")
        }

        return (loaded, errors)
    }

    private func loadOpportunityMissions() throws -> [Mission] {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(
                "NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/CURRENT/04_PRODUCTS_SEMANTIC_V4.json"
            )

        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        let feed = try JSONDecoder().decode(OpportunityFeed.self, from: data)

        guard feed.capabilityOpportunities.count == 20 else {
            throw NSError(
                domain: "SUPRA.MissionStore",
                code: 20,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Flux opportunités refusé: \(feed.capabilityOpportunities.count), attendu: 20."
                ]
            )
        }

        return feed.capabilityOpportunities.map { candidate in
            let horizon = derivedHorizon(for: candidate.declaredRank)
            let progress = normalizedProgress(candidate.maturityScoreDeclared)

            return Mission(
                id: stableUUID("opportunity:\(candidate.candidateID)"),
                title: candidate.name,
                status: .planned,
                priority: priority(for: candidate.declaredRank),
                category: horizon,
                owner: "SUPRA Opportunity Engine",
                dueDate: nil,
                progress: progress,
                summary:
                    "\(candidate.declaredAction) · rang déclaré \(candidate.declaredRank) · " +
                    "\(candidate.matchedReconciledProjectCount) projets liés · " +
                    "horizon dérivé du rang: \(horizon)" +
                    (candidate.notALaunchedProduct ? " · produit non lancé" : ""),
                objectives: [
                    Mission.Objective(
                        id: stableUUID("objective:\(candidate.candidateID):action"),
                        title: candidate.declaredAction,
                        isCompleted: false
                    )
                ],
                tasks: [],
                dependencies: [],
                timeline: [],
                currentStatus: candidate.status
            )
        }
    }

    private func gabrielMissions(_ snapshot: SUPRAGabrielConductorSnapshot) -> [Mission] {
        snapshot.workers.map { worker in
            let status = missionStatus(worker.status)
            return Mission(
                id: stableUUID("gabriel:\(worker.id)"),
                title: worker.title,
                status: status,
                priority: status == .blocked ? .high : .medium,
                category: "Branche concurrente",
                owner: snapshot.visibleConductor ?? "GABRIEL",
                dueDate: nil,
                progress: missionProgress(worker.status),
                summary: worker.analysis ?? worker.mission,
                objectives: [
                    Mission.Objective(
                        id: stableUUID("gabriel-objective:\(worker.id)"),
                        title: worker.mission,
                        isCompleted: status == .completed
                    )
                ],
                tasks: [],
                dependencies: [],
                timeline: [],
                currentStatus: worker.status
            )
        }
    }

    private func derivedHorizon(for rank: Int) -> String {
        switch rank {
        case ...5: return "Très court terme"
        case 6...10: return "Court terme"
        case 11...15: return "Moyen terme"
        default: return "Long terme"
        }
    }

    private func priority(for rank: Int) -> Mission.Priority {
        switch rank {
        case ...5: return .critical
        case 6...10: return .high
        case 11...15: return .medium
        default: return .low
        }
    }

    private func normalizedProgress(_ raw: Double) -> Double {
        let value = raw > 1 ? raw / 100 : raw
        return min(max(value, 0), 1)
    }

    private func missionStatus(_ raw: String) -> Mission.Status {
        let value = raw.uppercased()
        if value.contains("PASS") || value.contains("SUCCESS") || value.contains("COMPLETE") {
            return .completed
        }
        if value.contains("BLOCK") || value.contains("FAIL") || value.contains("ERROR") {
            return .blocked
        }
        if value.contains("RUN") || value.contains("ACTIVE") || value.contains("WORK") {
            return .active
        }
        return .planned
    }

    private func missionProgress(_ raw: String) -> Double {
        switch missionStatus(raw) {
        case .completed: return 1
        case .active: return 0.5
        case .blocked: return 0.35
        case .planned: return 0
        }
    }

    private func stableUUID(_ value: String) -> UUID {
        let digest = SHA256.hash(data: Data(value.utf8))
        var bytes = Array(digest.prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }

    private func applyPresentation() {
        let filtered = missions.filter { mission in
            let matchesQuery = query.isEmpty
                || mission.title.localizedStandardContains(query)
                || mission.category.localizedStandardContains(query)
                || mission.owner.localizedStandardContains(query)
                || mission.summary.localizedStandardContains(query)

            let matchesFilter: Bool = switch activeFilter {
            case .all: true
            case .planned: mission.status == .planned
            case .active: mission.status == .active
            case .blocked: mission.status == .blocked
            case .completed: mission.status == .completed
            }
            return matchesQuery && matchesFilter
        }

        visibleMissions = filtered.sorted { lhs, rhs in
            switch activeSort {
            case .dueDate:
                (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
            case .priority:
                priorityRank(lhs.priority) < priorityRank(rhs.priority)
            case .progress:
                lhs.progress > rhs.progress
            case .title:
                lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
            }
        }
    }

    private func priorityRank(_ priority: Mission.Priority) -> Int {
        switch priority {
        case .critical: 0
        case .high: 1
        case .medium: 2
        case .low: 3
        }
    }
}

private struct OpportunityFeed: Decodable {
    let capabilityOpportunities: [OpportunityCandidate]

    enum CodingKeys: String, CodingKey {
        case capabilityOpportunities = "capability_opportunities"
    }
}

private struct OpportunityCandidate: Decodable {
    let candidateID: String
    let name: String
    let status: String
    let declaredAction: String
    let declaredRank: Int
    let matchedReconciledProjectCount: Int
    let maturityScoreDeclared: Double
    let notALaunchedProduct: Bool

    enum CodingKeys: String, CodingKey {
        case candidateID = "candidate_id"
        case name, status
        case declaredAction = "declared_action"
        case declaredRank = "declared_rank"
        case matchedReconciledProjectCount = "matched_reconciled_project_count"
        case maturityScoreDeclared = "maturity_score_declared"
        case notALaunchedProduct = "not_a_launched_product"
    }
}
