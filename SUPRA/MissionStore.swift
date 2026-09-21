import Foundation
import Combine
import CryptoKit

@MainActor
final class MissionStore: ObservableObject {
    enum Filter: String, CaseIterable, Identifiable {
        case all = "Toutes"
        case planned = "Planifiées"
        case active = "Actives"
        case blocked = "Bloquées"
        case completed = "Terminées"

        var id: Self { self }
    }

    enum Sort: String, CaseIterable, Identifiable {
        case dueDate = "Échéance"
        case priority = "Priorité"
        case progress = "Progression"
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
        isLoading = true
        errorMessage = nil

        let snapshot = SUPRAGabrielConductorRuntime.load()
        guard snapshot.status.uppercased() != "NOT RUN" else {
            missions = []
            isLoading = false
            errorMessage = "Gabriel n’a pas encore matérialisé de mission active."
            applyPresentation()
            return
        }

        missions = snapshot.workers.map { mission(from: $0, snapshot: snapshot) }
        isLoading = false
        applyPresentation()
    }

    func refresh() {
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
        snapshot: SUPRAGabrielConductorSnapshot
    ) -> Mission {
        let status = missionStatus(worker.status)
        let priority = missionPriority(status)
        let progress = missionProgress(status)
        let completed = status == .completed

        let objective = Mission.Objective(
            id: stableUUID(worker.id + ":objective"),
            title: worker.mission,
            isCompleted: completed
        )

        let task = Mission.Task(
            id: stableUUID(worker.id + ":task"),
            title: worker.analysis ?? "Exécuter la branche isolée et matérialiser une preuve.",
            status: taskStatus(status)
        )

        let dependency = Mission.Dependency(
            id: stableUUID(worker.id + ":source"),
            title: worker.source,
            status: "READ_ONLY"
        )

        let generatedAt = parseISO8601(snapshot.generatedAt) ?? Date()
        let timeline = [
            Mission.TimelineEntry(
                id: stableUUID(worker.id + ":timeline"),
                date: generatedAt,
                title: "Snapshot Gabriel",
                detail: "Conductor: \(snapshot.visibleConductor ?? "GABRIEL") · final authority: \(snapshot.finalAuthority ?? "SUPRA")"
            )
        ]

        return Mission(
            id: stableUUID(worker.id),
            title: worker.title,
            status: status,
            priority: priority,
            category: "Branche concurrente",
            owner: snapshot.visibleConductor ?? "GABRIEL",
            dueDate: nil,
            progress: progress,
            summary: worker.analysis ?? worker.mission,
            objectives: [objective],
            tasks: [task],
            dependencies: [dependency],
            timeline: timeline,
            currentStatus: worker.status
        )
    }

    private func missionStatus(_ raw: String) -> Mission.Status {
        let value = raw.uppercased()
        if value.contains("PASS") || value.contains("SUCCESS") || value.contains("COMPLETE") || value.contains("DONE") {
            return .completed
        }
        if value.contains("BLOCK") || value.contains("FAIL") || value.contains("ERROR") {
            return .blocked
        }
        if value.contains("RUN") || value.contains("ACTIVE") || value.contains("IN_PROGRESS") || value.contains("EXECUT") {
            return .active
        }
        return .planned
    }

    private func missionPriority(_ status: Mission.Status) -> Mission.Priority {
        switch status {
        case .blocked: return .critical
        case .active: return .high
        case .planned: return .medium
        case .completed: return .low
        }
    }

    private func missionProgress(_ status: Mission.Status) -> Double {
        switch status {
        case .planned: return 0
        case .active: return 0.5
        case .blocked: return 0.25
        case .completed: return 1
        }
    }

    private func taskStatus(_ status: Mission.Status) -> Mission.Task.Status {
        switch status {
        case .planned: return .pending
        case .active: return .inProgress
        case .blocked: return .blocked
        case .completed: return .completed
        }
    }

    private func parseISO8601(_ value: String?) -> Date? {
        guard let value else { return nil }
        return ISO8601DateFormatter().date(from: value)
    }

    private func stableUUID(_ value: String) -> UUID {
        let digest = SHA256.hash(data: Data(value.utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        let raw = String(hex.prefix(32))
        guard raw.count == 32 else { return UUID() }

        let i8 = raw.index(raw.startIndex, offsetBy: 8)
        let i12 = raw.index(raw.startIndex, offsetBy: 12)
        let i16 = raw.index(raw.startIndex, offsetBy: 16)
        let i20 = raw.index(raw.startIndex, offsetBy: 20)

        let a = String(raw[..<i8])
        let b = String(raw[i8..<i12])
        let c = String(raw[i12..<i16])
        let d = String(raw[i16..<i20])
        let e = String(raw[i20...])
        let uuidString = a + "-" + b + "-" + c + "-" + d + "-" + e
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
