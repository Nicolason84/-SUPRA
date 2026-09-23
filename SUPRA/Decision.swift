import Foundation

struct Decision: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let status: Status
    let priority: Priority
    let category: String
    let date: Date
    let humanGate: HumanGate
    let confidence: Double?
    let summary: String
    let evidence: [Evidence]
    let nextActions: [NextAction]
    let history: [HistoryEntry]

    enum Status: String, CaseIterable, Hashable, Sendable {
        case pending = "Pending"
        case inReview = "In Review"
        case approved = "Approved"
        case rejected = "Rejected"
        case deferred = "Deferred"
        case historical = "Historical"
    }

    enum Priority: String, CaseIterable, Hashable, Sendable {
        case critical = "Critical"
        case high = "High"
        case medium = "Medium"
        case low = "Low"
    }

    enum HumanGate: String, CaseIterable, Hashable, Sendable {
        case required = "Required"
        case completed = "Completed"
        case notRequired = "Not Required"
    }

    struct Evidence: Identifiable, Hashable, Sendable {
        let id: UUID
        let title: String
        let detail: String
        let source: String?
    }

    struct NextAction: Identifiable, Hashable, Sendable {
        let id: UUID
        let title: String
        let owner: String?
        let dueDate: Date?
    }

    struct HistoryEntry: Identifiable, Hashable, Sendable {
        let id: UUID
        let date: Date
        let title: String
        let detail: String?
    }
}
