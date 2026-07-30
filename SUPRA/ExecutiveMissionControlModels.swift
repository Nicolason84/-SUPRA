import Foundation

enum ExecutiveAgentStatus: String, Codable, CaseIterable, Sendable {
    case running
    case waiting
    case blocked
    case failed
    case succeeded
    case idle
}

enum ExecutiveBuildStatus: String, Codable, Sendable {
    case idle
    case queued
    case running
    case succeeded
    case failed
}

enum ExecutiveFreezeStatus: String, Codable, Sendable {
    case current
    case missing
    case stale
    case generating
}

enum ExecutiveAlertKind: String, Codable, CaseIterable, Sendable {
    case buildFailed = "build_failed"
    case buildSucceeded = "build_succeeded"
    case agentTimeout = "agent_timeout"
    case heartbeatTimeout = "heartbeat_timeout"
    case permissionPopupDetected = "permission_popup_detected"
    case runtimeCrash = "runtime_crash"
    case duplicateWriters = "duplicate_writers"
    case mergeConflict = "merge_conflict"
    case regression = "regression"
    case missingFreeze = "missing_freeze"
}

enum ExecutiveAlertSeverity: String, Codable, Sendable {
    case info
    case warning
    case critical
}

struct ExecutiveAgentSnapshot: Identifiable, Codable, Equatable, Sendable {
    let agentID: String
    let agentName: String
    let providerID: String
    let role: String
    let currentTask: String
    let currentPhase: String
    let progress: Double
    let status: ExecutiveAgentStatus
    let lastUpdate: Date
    let currentFile: String?
    let filesModified: [String]
    let testsRunning: [String]
    let testsPassed: Int
    let testsFailed: Int
    let warnings: [String]
    let errors: [String]
    let eta: Date?
    let branch: String?
    let buildStatus: ExecutiveBuildStatus
    let freezeStatus: ExecutiveFreezeStatus
    let heartbeat: Date

    var id: String { agentID }

    enum CodingKeys: String, CodingKey {
        case agentID = "agent_id"
        case agentName = "agent_name"
        case providerID = "provider_id"
        case role
        case currentTask = "current_task"
        case currentPhase = "current_phase"
        case progress
        case status
        case lastUpdate = "last_update"
        case currentFile = "current_file"
        case filesModified = "files_modified"
        case testsRunning = "tests_running"
        case testsPassed = "tests_passed"
        case testsFailed = "tests_failed"
        case warnings
        case errors
        case eta
        case branch
        case buildStatus = "build_status"
        case freezeStatus = "freeze_status"
        case heartbeat
    }
}

struct ExecutiveProviderSnapshot: Identifiable, Codable, Equatable, Sendable {
    let providerID: String
    let providerName: String
    let status: ExecutiveAgentStatus
    let lastHeartbeat: Date
    let activeAgents: Int
    let detail: String?

    var id: String { providerID }

    enum CodingKeys: String, CodingKey {
        case providerID = "provider_id"
        case providerName = "provider_name"
        case status
        case lastHeartbeat = "last_heartbeat"
        case activeAgents = "active_agents"
        case detail
    }
}

struct ExecutiveMissionSnapshot: Identifiable, Codable, Equatable, Sendable {
    let missionID: String
    let title: String
    let objective: String
    let phase: String
    let progress: Double
    let status: ExecutiveAgentStatus
    let startedAt: Date?
    let updatedAt: Date
    let eta: Date?
    let agentIDs: [String]

    var id: String { missionID }

    enum CodingKeys: String, CodingKey {
        case missionID = "mission_id"
        case title
        case objective
        case phase
        case progress
        case status
        case startedAt = "started_at"
        case updatedAt = "updated_at"
        case eta
        case agentIDs = "agent_ids"
    }
}

struct ExecutiveRuntimeSnapshot: Codable, Equatable, Sendable {
    let runtimeID: String
    let status: ExecutiveAgentStatus
    let heartbeat: Date
    let version: String
    let writerID: String
    let writerCount: Int
    let buildStatus: ExecutiveBuildStatus
    let currentBuild: String?
    let freezeStatus: ExecutiveFreezeStatus
    let providers: [ExecutiveProviderSnapshot]

    enum CodingKeys: String, CodingKey {
        case runtimeID = "runtime_id"
        case status
        case heartbeat
        case version
        case writerID = "writer_id"
        case writerCount = "writer_count"
        case buildStatus = "build_status"
        case currentBuild = "current_build"
        case freezeStatus = "freeze_status"
        case providers
    }
}

struct ExecutiveRuntimeEvent: Identifiable, Codable, Equatable, Sendable {
    let eventID: String
    let timestamp: Date
    let type: String
    let title: String
    let detail: String?
    let missionID: String?
    let agentID: String?
    let evidence: [String]

    var id: String { eventID }

    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
        case timestamp
        case type
        case title
        case detail
        case missionID = "mission_id"
        case agentID = "agent_id"
        case evidence
    }
}

struct ExecutiveRuntimeAlert: Identifiable, Codable, Equatable, Sendable {
    let alertID: String
    let kind: ExecutiveAlertKind
    let severity: ExecutiveAlertSeverity
    let title: String
    let detail: String
    let timestamp: Date
    let sourceID: String?
    let evidence: [String]

    var id: String { alertID }

    enum CodingKeys: String, CodingKey {
        case alertID = "alert_id"
        case kind
        case severity
        case title
        case detail
        case timestamp
        case sourceID = "source_id"
        case evidence
    }
}

protocol ExecutiveAgentStatePublishing: Sendable {
    var providerID: String { get }
    func publish(snapshot: ExecutiveAgentSnapshot) async throws
    func publish(event: ExecutiveRuntimeEvent) async throws
}

protocol ExecutiveHeartbeatPublishing: Sendable {
    func publishHeartbeat(agentID: String, at timestamp: Date) async throws
}

protocol ExecutiveProviderAdapter: ExecutiveAgentStatePublishing, ExecutiveHeartbeatPublishing {
    var providerName: String { get }
}
