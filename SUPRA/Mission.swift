import Foundation

struct Mission: Identifiable, Hashable, Sendable {
    let id: UUID
    let identity: Identity
    let title: String
    let objective: String
    let businessContext: String
    let technicalContext: String
    let status: Status
    let lifecycle: Lifecycle
    let priority: Priority
    let risk: Risk
    let health: Health
    let category: String
    let owner: String
    let dueDate: Date?
    let progress: Double
    let summary: String
    let constraints: [String]
    let objectives: [Objective]
    let tasks: [Task]
    let dependencies: [Dependency]
    let timeline: [TimelineEntry]
    let executionStrategy: String
    let planner: String
    let executor: String
    let providers: [String]
    let models: [String]
    let currentStatus: String
    let currentStep: String
    let currentProvider: String?
    let currentModel: String?
    let estimatedRemainingMinutes: Int?
    let expectedOutcome: String?
    let executiveDecision: String?
    let nextMission: String?
    let blocker: String?
    let report: String?
    let executionError: String?
    let evidence: [EvidenceItem]
    let artifacts: [ArtifactItem]
    let logs: [LogEntry]
    let memoryLinks: [String]
    let lessonsLearned: [String]
    let validation: Validation
    let confidence: Double
    let score: Double
    let value: Double
    let impact: String
    let authority: DecisionAuthority
    let autonomyLevel: Int

    enum Status: String, CaseIterable, Hashable, Sendable {
        case planned = "Planned"
        case active = "Active"
        case blocked = "Blocked"
        case completed = "Completed"
    }

    enum Lifecycle: String, CaseIterable, Hashable, Sendable, Comparable {
        case created = "MISSION_CREATED"
        case analysed = "MISSION_ANALYSED"
        case understood = "MISSION_UNDERSTOOD"
        case planned = "MISSION_PLANNED"
        case validated = "MISSION_VALIDATED"
        case executed = "MISSION_EXECUTED"
        case verified = "MISSION_VERIFIED"
        case learned = "MISSION_LEARNED"
        case archived = "MISSION_ARCHIVED"
        case nextPrepared = "NEXT_MISSION_PREPARED"

        private static let orderedCases: [Lifecycle] = [
            .created,
            .analysed,
            .understood,
            .planned,
            .validated,
            .executed,
            .verified,
            .learned,
            .archived,
            .nextPrepared
        ]

        static func < (lhs: Lifecycle, rhs: Lifecycle) -> Bool {
            let lhsIndex = orderedCases.firstIndex(of: lhs) ?? 0
            let rhsIndex = orderedCases.firstIndex(of: rhs) ?? 0
            return lhsIndex < rhsIndex
        }
    }

    enum Priority: String, CaseIterable, Hashable, Sendable {
        case critical = "Critical"
        case high = "High"
        case medium = "Medium"
        case low = "Low"
    }

    enum Risk: String, CaseIterable, Hashable, Sendable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
    }

    enum Health: String, CaseIterable, Hashable, Sendable {
        case ready = "Ready"
        case healthy = "Healthy"
        case warning = "Warning"
        case blocked = "Blocked"
        case failed = "Failed"
    }

    struct Identity: Hashable, Sendable {
        let missionID: String
        let slug: String
        let createdAt: Date?
        let updatedAt: Date?
        let createdBy: String
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

    struct EvidenceItem: Identifiable, Hashable, Sendable {
        let id: UUID
        let title: String
        let detail: String
        let kind: String
    }

    struct ArtifactItem: Identifiable, Hashable, Sendable {
        let id: UUID
        let title: String
        let path: String
        let kind: String
    }

    struct LogEntry: Identifiable, Hashable, Sendable {
        let id: UUID
        let date: Date
        let level: String
        let message: String
    }

    struct Validation: Hashable, Sendable {
        let summary: String
        let buildStatus: String
        let testStatus: String
        let evidenceStatus: String
    }
}
