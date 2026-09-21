import Foundation
import Combine

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
    @Published private(set) var conductorStatus = "NOT RUN"
    @Published private(set) var missionSlots = 3
    @Published private(set) var workerProcesses = 0
    @Published private(set) var finalAuthority = "SUPRA"
    @Published private(set) var outputMode = "ISOLATED_RUNS"
    @Published private(set) var opportunityCount = 0
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

        var loaded: [Mission] = []
        var errors: [String] = []

        do {
            let opportunities = try loadOpportunityMissions()
            opportunityCount = opportunities.count
            loaded.append(contentsOf: opportunities)
        } catch {
            opportunityCount = 0
            errors.append("Opportunités: \(error.localizedDescription)")
        }

        let snapshot = SUPRAGabrielConductorRuntime.load()
        conductorStatus = snapshot.status
        missionSlots = snapshot.missionSlots
        workerProcesses = snapshot.workerProcesses
        finalAuthority = snapshot.finalAuthority ?? "SUPRA"
        outputMode = snapshot.outputMode

        if snapshot.status.uppercased() != "NOT RUN" || snapshot.run != nil {
            loaded.append(contentsOf: snapshot.workers.map {
                gabrielMission(from: $0, conductor: snapshot.visibleConductor ?? "GABRIEL")
            })
        }

        missions = loaded
        if missions.isEmpty {
            errors.append("Aucune opportunité ni branche réelle matérialisée.")
        }
        errorMessage = errors.isEmpty ? nil : errors.joined(separator: " · ")
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
                    "horizon dérivé: \(horizon)" +
                    (candidate.notALaunchedProduct ? " · produit non lancé" : ""),
                objectives: [
                    Mission.Objective(
                        id: stableUUID("objective:\(candidate.candidateID)"),
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

    private func gabrielMission(
        from worker: SUPRAGabrielWorkerSnapshot,
        conductor: String
    ) -> Mission {
        let normalized = worker.status.uppercased()
        let status: Mission.Status
        let priority: Mission.Priority
        let progress: Double
        let taskStatus: Mission.Task.Status

        if normalized.contains("FAIL") || normalized.contains("BLOCK") {
            status = .blocked
            priority = .critical
            progress = 0
            taskStatus = .blocked
        } else if normalized.contains("RUN") || normalized.contains("ACTIVE") {
            status = .active
            priority = .high
            progress = 0.55
            taskStatus = .inProgress
        } else if normalized.contains("PASS")
                    || normalized.contains("SUCCESS")
                    || normalized.contains("DONE")
                    || normalized.contains("COMPLETE") {
            status = .completed
            priority = .low
            progress = 1
            taskStatus = .completed
        } else {
            status = .planned
            priority = .medium
            progress = 0.10
            taskStatus = .pending
        }

        return Mission(
            id: stableUUID("gabriel:\(worker.id)"),
            title: worker.title,
            status: status,
            priority: priority,
            category: "Branche concurrente",
            owner: conductor,
            dueDate: nil,
            progress: progress,
            summary: worker.analysis ?? worker.mission,
            objectives: [
                Mission.Objective(
                    id: stableUUID("gabriel-objective:\(worker.id)"),
                    title: "Produire un résultat isolé, vérifiable et consolidable",
                    isCompleted: status == .completed
                )
            ],
            tasks: [
                Mission.Task(
                    id: stableUUID("gabriel-task:\(worker.id)"),
                    title: worker.mission,
                    status: taskStatus
                )
            ],
            dependencies: [
                Mission.Dependency(
                    id: stableUUID("gabriel-source:\(worker.id)"),
                    title: worker.source,
                    status: "SOURCE"
                )
            ],
            timeline: [],
            currentStatus: worker.status
        )
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

    private func stableUUID(_ input: String) -> UUID {
        var hash = UInt64(1469598103934665603)
        for byte in input.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        let hex = String(format: "%016llx", hash)
        let padded = hex + hex
        let uuidString =
            String(padded.prefix(8)) + "-" +
            String(padded.dropFirst(8).prefix(4)) + "-" +
            String(padded.dropFirst(12).prefix(4)) + "-" +
            String(padded.dropFirst(16).prefix(4)) + "-" +
            String(padded.dropFirst(20).prefix(12))
        return UUID(uuidString: uuidString) ?? UUID()
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
