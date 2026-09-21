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
    @Published var query = "" {
        didSet { applyPresentation() }
    }
    @Published var activeFilter: Filter = .all {
        didSet { applyPresentation() }
    }
    @Published var activeSort: Sort = .dueDate {
        didSet { applyPresentation() }
    }

    func load() {
        guard missions.isEmpty else {
            applyPresentation()
            return
        }
        isLoading = true
        errorMessage = nil

        let snapshot = SUPRAGabrielConductorRuntime.load()
        conductorStatus = snapshot.status
        missionSlots = snapshot.missionSlots
        workerProcesses = snapshot.workerProcesses
        finalAuthority = snapshot.finalAuthority ?? "SUPRA"
        outputMode = snapshot.outputMode

        guard snapshot.status.uppercased() != "NOT RUN" else {
            missions = []
            errorMessage = "Gabriel est disponible mais aucune exécution réelle n’est matérialisée."
            isLoading = false
            applyPresentation()
            return
        }

        missions = snapshot.workers.map { worker in
            mission(from: worker, conductor: snapshot.visibleConductor ?? "GABRIEL")
        }

        if missions.isEmpty {
            errorMessage = "Aucune branche réelle matérialisée dans le snapshot Gabriel."
        }

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

    private func mission(
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

        let objective = Mission.Objective(
            id: UUID(),
            title: "Produire un résultat isolé, vérifiable et consolidable",
            isCompleted: status == .completed
        )

        let task = Mission.Task(
            id: UUID(),
            title: worker.mission,
            status: taskStatus
        )

        let dependency = Mission.Dependency(
            id: UUID(),
            title: worker.source,
            status: "SOURCE"
        )

        let summaryParts = [
            worker.analysis,
            worker.outputDir.map { "Output: \($0)" }
        ].compactMap { $0 }

        let summary = summaryParts.isEmpty
            ? worker.mission
            : summaryParts.joined(separator: "\n")

        return Mission(
            id: stableUUID("mission:\(worker.id)"),
            title: worker.title,
            status: status,
            priority: priority,
            category: "Gabriel Parallel",
            owner: conductor,
            dueDate: nil,
            progress: progress,
            summary: summary,
            objectives: [objective],
            tasks: [task],
            dependencies: [dependency],
            timeline: [
                Mission.TimelineEntry(
                    id: UUID(),
                    date: Date(),
                    title: worker.status,
                    detail: worker.analysis
                )
            ],
            currentStatus: worker.status
        )
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
