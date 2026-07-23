import Foundation
import Combine

@MainActor
final class MissionStore: ObservableObject {
    private static var sourceURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("NOVA_OS/SUPRA_TERMINAL_MEGABUS_V1/INBOX", isDirectory: true)
    }

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

    func load() {
        guard missions.isEmpty else {
            applyPresentation()
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            let urls = try FileManager.default.contentsOfDirectory(
                at: Self.sourceURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
            missions = try urls
                .filter { $0.pathExtension.lowercased() == "json" }
                .map(readMission)
        } catch {
            missions = []
            errorMessage = error.localizedDescription
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

    private func readMission(at url: URL) throws -> Mission {
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let idValue = object["id"] as? String,
              let id = UUID(uuidString: idValue),
              let intent = object["intent"] as? String,
              let state = object["state"] as? String
        else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let title = intent.split(separator: "\n")
            .map(String.init)
            .first { $0.hasPrefix("MISSION_ID=") }?
            .replacingOccurrences(of: "MISSION_ID=", with: "") ?? url.deletingPathExtension().lastPathComponent
        let createdAt = (object["createdAt"] as? String).flatMap(ISO8601DateFormatter().date)
        let normalizedState = state.uppercased()
        let status: Mission.Status = switch normalizedState {
        case "COMPLETED", "PASS": .completed
        case "BLOCKED", "FAILED": .blocked
        case "RUNNING", "ACTIVE", "PROCESSING": .active
        default: .planned
        }

        return Mission(
            id: id,
            title: title,
            status: status,
            priority: .medium,
            category: state,
            owner: Self.sourceURL.lastPathComponent,
            dueDate: nil,
            progress: status == .completed ? 1 : 0,
            summary: intent,
            objectives: [],
            tasks: [],
            dependencies: [],
            timeline: createdAt.map { [Mission.TimelineEntry(id: id, date: $0, title: state, detail: url.path)] } ?? [],
            currentStatus: state
        )
    }
}
