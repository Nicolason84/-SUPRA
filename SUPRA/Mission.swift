import Foundation

struct Mission: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let status: Status
    let priority: Priority
    let category: String
    let owner: String
    let dueDate: Date?
    let progress: Double
    let summary: String
    let objectives: [Objective]
    let tasks: [Task]
    let dependencies: [Dependency]
    let timeline: [TimelineEntry]
    let currentStatus: String

    enum Status: String, CaseIterable, Hashable, Sendable {
        case planned = "Planned"
        case active = "Active"
        case blocked = "Blocked"
        case completed = "Completed"
    }

    enum Priority: String, CaseIterable, Hashable, Sendable {
        case critical = "Critical"
        case high = "High"
        case medium = "Medium"
        case low = "Low"
    }

    struct Objective: Identifiable, Hashable, Sendable {
        let id: UUID
        let title: String
        let isCompleted: Bool
    }

    struct Task: Identifiable, Hashable, Sendable {
        let id: UUID
        let title: String
        let status: Status

        enum Status: String, Hashable, Sendable {
            case pending = "Pending"
            case inProgress = "In Progress"
            case completed = "Completed"
            case blocked = "Blocked"
        }
    }

    struct Dependency: Identifiable, Hashable, Sendable {
        let id: UUID
        let title: String
        let status: String
    }

    struct TimelineEntry: Identifiable, Hashable, Sendable {
        let id: UUID
        let date: Date
        let title: String
        let detail: String?
    }
}
