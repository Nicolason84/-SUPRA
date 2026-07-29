import Foundation
import Combine

enum RuntimeGatewayEvent: Codable {
    case missionStarted(missionId: String)
    case missionUpdated(missionId: String, status: String)
    case workerCreated(workerId: String)
    case workerFinished(workerId: String)
    case contextReady(contextId: String)
    case decisionGenerated(decisionId: String)
    case knowledgeUpdated(source: String, count: Int)
    case workspaceChanged(change: String)
    case buildFinished(result: String)
    case gitUpdated(branch: String)
    case error(message: String)

    var type: String {
        switch self {
        case .missionStarted: return "mission_started"
        case .missionUpdated: return "mission_updated"
        case .workerCreated: return "worker_created"
        case .workerFinished: return "worker_finished"
        case .contextReady: return "context_ready"
        case .decisionGenerated: return "decision_generated"
        case .knowledgeUpdated: return "knowledge_updated"
        case .workspaceChanged: return "workspace_changed"
        case .buildFinished: return "build_finished"
        case .gitUpdated: return "git_updated"
        case .error: return "error"
        }
    }
}

struct RuntimeStatus: Codable {
    let isRunning: Bool
    let activeMissions: Int
    let activeWorkers: Int
    let availableProviders: Int
    let uptime: String?
    let version: String
}

@MainActor
final class RuntimeGateway: ObservableObject {
    static let shared = RuntimeGateway()

    @Published var status: RuntimeStatus?
    @Published var events: [RuntimeGatewayEvent] = []
    @Published var isConnected = false

    private var eventTask: Task<Void, Never>?
    private var baseURL = URL(string: "http://localhost:8080")!

    private static func readRuntimeVersion() -> String {
        let path = "\(SUPRAEnvironmentResolver.shared.projectRoot)/version.json"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let version = obj["runtime_version"] as? String
        else { return "—" }
        return version
    }

    func setBaseURL(_ url: URL) { baseURL = url }

    func connect() {
        isConnected = true
        startEventPolling()
    }

    func disconnect() {
        isConnected = false
        eventTask?.cancel()
        eventTask = nil
    }

    func execute(_ request: BridgeRequest) async -> BridgeResponse {
        let start = Date()

        let response: BridgeResponse

        switch request.command {
        case .ping:
            response = BridgeResponse(
                id: "resp_\(request.id)",
                requestId: request.id,
                status: .success,
                data: ["pong": ISO8601DateFormatter().string(from: Date())],
                error: nil,
                duration: Date().timeIntervalSince(start),
                timestamp: ISO8601DateFormatter().string(from: Date())
            )

        case .getRuntimeStatus:
            response = BridgeResponse(
                id: "resp_\(request.id)",
                requestId: request.id,
                status: .success,
                data: ["status": "running", "version": Self.readRuntimeVersion()],
                error: nil,
                duration: Date().timeIntervalSince(start),
                timestamp: ISO8601DateFormatter().string(from: Date())
            )

        case .startMission:
            recordEvent(.missionStarted(missionId: request.payload["missionId"] ?? "unknown"))

            response = BridgeResponse(
                id: "resp_\(request.id)",
                requestId: request.id,
                status: .success,
                data: ["missionId": request.payload["missionId"] ?? ""],
                error: nil,
                duration: Date().timeIntervalSince(start),
                timestamp: ISO8601DateFormatter().string(from: Date())
            )

        case .dispatchAgent:
            response = BridgeResponse(
                id: "resp_\(request.id)",
                requestId: request.id,
                status: .success,
                data: ["agent": request.payload["agent"] ?? "", "status": "dispatched"],
                error: nil,
                duration: Date().timeIntervalSince(start),
                timestamp: ISO8601DateFormatter().string(from: Date())
            )

        case .getEventStream:
            response = BridgeResponse(
                id: "resp_\(request.id)",
                requestId: request.id,
                status: .success,
                data: ["eventCount": "\(events.count)"],
                error: nil,
                duration: Date().timeIntervalSince(start),
                timestamp: ISO8601DateFormatter().string(from: Date())
            )

        default:
            response = BridgeResponse(
                id: "resp_\(request.id)",
                requestId: request.id,
                status: .success,
                data: ["acknowledged": "true"],
                error: nil,
                duration: Date().timeIntervalSince(start),
                timestamp: ISO8601DateFormatter().string(from: Date())
            )
        }

        return response
    }

    private func startEventPolling() {
        eventTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                await self?.pollEvents()
            }
        }
    }

    private func pollEvents() async {
        // Stub: actual SSE integration will be added in Phase 8
    }

    private func recordEvent(_ event: RuntimeGatewayEvent) {
        events.append(event)
    }

    deinit {
        eventTask?.cancel()
    }
}
