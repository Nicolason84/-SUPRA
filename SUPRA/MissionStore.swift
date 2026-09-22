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
    @Published var query = "" {
        didSet { applyPresentation() }
    }
    @Published var activeFilter: Filter = .all {
        didSet { applyPresentation() }
    }
    @Published var activeSort: Sort = .dueDate {
        didSet { applyPresentation() }
    }

    private let liveStore = SUPRAProcessObservatoryStore.shared

    func load() {
        isLoading = true
        errorMessage = nil

        let runner = SUPRAGrandeMissionRunner.shared
        liveStore.start()
        missions = [makeGrandeMission(from: runner)]
        runner.startIfNeeded()

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


    private func makeGrandeMission(from runner: SUPRAGrandeMissionRunner) -> Mission {
        let liveByID = Dictionary(
            uniqueKeysWithValues: liveStore.processes
                .filter { process in runner.phases.contains(where: { $0.id == process.id }) }
                .map { ($0.id, $0) }
        )

        let phaseStatuses = runner.phases.map { phase -> (SUPRAGrandeMissionRunner.Phase, String) in
            if let live = liveByID[phase.id] {
                let liveStatus: String = switch live.stage {
                case .materialized, .frozen: "PASS"
                case .inFlight: "RUNNING"
                case .blocked: "BLOCKED"
                case .failed, .anomaly: "ERROR"
                case .historical, .unknown:
                    runner.receiptStatus(for: phase.id)
                        ?? (runner.activePhaseID == phase.id ? "RUNNING" : "PENDING")
                }
                return (phase, liveStatus)
            }

            return (
                phase,
                runner.receiptStatus(for: phase.id)
                    ?? (runner.activePhaseID == phase.id ? "RUNNING" : "PENDING")
            )
        }

        let completed = phaseStatuses.filter { $0.1 == "PASS" }.count
        let blocked = phaseStatuses.first { ["BLOCKED", "UNPROVEN", "ERROR"].contains($0.1) }

        let status: Mission.Status
        if completed == runner.phases.count {
            status = .completed
        } else if blocked != nil || runner.lastError != nil {
            status = .blocked
        } else {
            status = .active
        }

        let progress = Double(completed) / Double(max(runner.phases.count, 1))

        let objectives = runner.phases.map { phase in
            Mission.Objective(
                id: stableUUID("objective-" + phase.id),
                title: phase.title,
                isCompleted: runner.receiptStatus(for: phase.id) == "PASS"
            )
        }

        let tasks = phaseStatuses.map { phase, phaseStatus in
            let taskStatus: Mission.Task.Status = switch phaseStatus {
            case "PASS": .completed
            case "RUNNING": .inProgress
            case "BLOCKED", "UNPROVEN", "ERROR": .blocked
            default: .pending
            }
            return Mission.Task(
                id: stableUUID("task-" + phase.id),
                title: phase.title,
                status: taskStatus
            )
        }

        let current: String
        if completed == runner.phases.count {
            current = "TOTAL_SYSTEM_READY candidate — all ten phases returned explicit PASS receipts."
        } else if let blocked {
            current = "Stopped fail-closed at \(blocked.0.id): \(blocked.1). \(runner.lastError ?? "")"
        } else if let active = runner.activePhaseID,
                  let phase = runner.phases.first(where: { $0.id == active }) {
            current = "Executing \(phase.id) · \(phase.title)"
        } else {
            current = "Authorized and waiting for next runtime cycle."
        }

        return Mission(
            id: stableUUID(runner.missionID),
            title: "Grande Mission · MacBook / CAnnoNico / Alonso",
            status: status,
            priority: .critical,
            category: "System Consolidation",
            owner: "SUPRA · Authority Nicolas",
            dueDate: nil,
            progress: progress,
            summary: "Memory-first, patrimony-first consolidation using the existing SUPRA Chat runtime. Every phase requires an explicit PASS receipt; missing proof stops the chain.",
            objectives: objectives,
            tasks: tasks,
            dependencies: [
                Mission.Dependency(
                    id: stableUUID("dep-runtime"),
                    title: "Existing SUPRA Chat runtime",
                    status: "REQUIRED · no replacement"
                ),
                Mission.Dependency(
                    id: stableUUID("dep-canon"),
                    title: "Existing CAnnoNico / registries / evidence",
                    status: "RECOVER + REUSE FIRST"
                )
            ],
            timeline: [
                Mission.TimelineEntry(
                    id: stableUUID("timeline-authorized"),
                    date: Date(),
                    title: "Mission authorized",
                    detail: "Mission 0 readiness passed; execution routed through existing runtime."
                )
            ],
            currentStatus: current
        )
    }

    private func stableUUID(_ seed: String) -> UUID {
        var bytes = Array(seed.utf8)
        if bytes.isEmpty { bytes = [0] }
        var hash = [UInt8](repeating: 0, count: 16)
        for (index, byte) in bytes.enumerated() {
            hash[index % 16] = hash[index % 16] &+ byte &+ UInt8(truncatingIfNeeded: index)
        }
        hash[6] = (hash[6] & 0x0F) | 0x40
        hash[8] = (hash[8] & 0x3F) | 0x80
        return UUID(uuid: (
            hash[0], hash[1], hash[2], hash[3],
            hash[4], hash[5], hash[6], hash[7],
            hash[8], hash[9], hash[10], hash[11],
            hash[12], hash[13], hash[14], hash[15]
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
