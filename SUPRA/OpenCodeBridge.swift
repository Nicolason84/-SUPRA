import Foundation
import Combine

enum BridgeCommand: String, Codable, CaseIterable, Identifiable {
    case startMission, cancelMission, getMissionStatus
    case dispatchAgent, getAgentStatus
    case executeTask, getExecutionState
    case queryKnowledge, updateKnowledge
    case getWorkspaceIndex, scanWorkspace
    case getRuntimeStatus
    case getProviderStatus
    case getEventStream
    case ping

    var id: String { rawValue }
}

enum BridgeResponseStatus: String, Codable {
    case success, error, pending, timeout
}

struct BridgeRequest: Codable {
    let id: String
    let command: BridgeCommand
    let payload: [String: String]
    let timestamp: String
}

struct BridgeResponse: Identifiable, Codable, Equatable {
    let id: String
    let requestId: String
    let status: BridgeResponseStatus
    let data: [String: String]?
    let error: String?
    let duration: Double
    let timestamp: String

    static func == (lhs: BridgeResponse, rhs: BridgeResponse) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class OpenCodeBridge: ObservableObject {
    static let shared = OpenCodeBridge()

    @Published var isConnected = false
    @Published var lastPing: Date?
    @Published var commandHistory: [BridgeRequest] = []
    @Published var responseHistory: [BridgeResponse] = []

    private let gateway = RuntimeGateway()
    private var pendingRequests: [String: (BridgeRequest) -> Void] = [:]
    private var requestCounter = 0

    func connect() {
        isConnected = true
        lastPing = Date()
    }

    func disconnect() {
        isConnected = false
    }

    func send(_ command: BridgeCommand, payload: [String: String] = [:]) async -> BridgeResponse {
        requestCounter += 1
        let requestId = "br_\(requestCounter)"
        let request = BridgeRequest(
            id: requestId,
            command: command,
            payload: payload,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )

        await MainActor.run {
            commandHistory.append(request)
        }

        let response = await gateway.execute(request)

        await MainActor.run {
            responseHistory.append(response)
        }

        return response
    }

    func startMission(_ missionId: String, description: String) async -> BridgeResponse {
        await send(.startMission, payload: [
            "missionId": missionId,
            "description": description
        ])
    }

    func dispatchAgent(_ agentName: String, task: String) async -> BridgeResponse {
        await send(.dispatchAgent, payload: [
            "agent": agentName,
            "task": task
        ])
    }

    func queryKnowledge(_ query: String) async -> BridgeResponse {
        await send(.queryKnowledge, payload: ["query": query])
    }

    func getRuntimeStatus() async -> BridgeResponse {
        await send(.getRuntimeStatus)
    }

    func getEventStream() async -> BridgeResponse {
        await send(.getEventStream)
    }

    func ping() async -> BridgeResponse {
        let response = await send(.ping)
        if response.status == .success {
            await MainActor.run { lastPing = Date() }
        }
        return response
    }
}
