import Foundation

enum RuntimeEventType: String, Codable, CaseIterable {
    case missionCreated = "mission_created"
    case dagGenerated = "dag_generated"
    case schedulerAction = "scheduler_action"
    case agentSelected = "agent_selected"
    case providerAssigned = "provider_assigned"
    case executionStarted = "execution_started"
    case executionCompleted = "execution_completed"
    case validationPassed = "validation_passed"
    case validationFailed = "validation_failed"
    case missionCompleted = "mission_completed"
    case error = "error"
    case info = "info"

    var icon: String {
        switch self {
        case .missionCreated: "flag"
        case .dagGenerated: "point.connected"
        case .schedulerAction: "clock.arrow.2.circlepath"
        case .agentSelected: "person.badge.plus"
        case .providerAssigned: "network"
        case .executionStarted: "play"
        case .executionCompleted: "checkmark.circle"
        case .validationPassed: "shield.checkered"
        case .validationFailed: "exclamationmark.triangle"
        case .missionCompleted: "star"
        case .error: "xmark.octagon"
        case .info: "info.circle"
        }
    }
}

struct RuntimeEvent: Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let type: RuntimeEventType
    let title: String
    let detail: String
    let sourceFile: String?
    let missionId: String?

    init(type: RuntimeEventType, title: String, detail: String = "", sourceFile: String? = nil, missionId: String? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.type = type
        self.title = title
        self.detail = detail
        self.sourceFile = sourceFile
        self.missionId = missionId
    }

    static func == (lhs: RuntimeEvent, rhs: RuntimeEvent) -> Bool {
        lhs.id == rhs.id
    }
}
