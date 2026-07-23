import Foundation

@MainActor
protocol SUPRAChatRuntimeProtocol {
    func checkHealth() async throws
    func execute(prompt: String, mode: ChatMode) async throws -> String
}

enum SUPRAChatRuntimeError: LocalizedError {
    case emptyResponse
    case bridgeUnavailable(String)
    case invalidHealthResponse

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "Le runtime n’a retourné aucune réponse."
        case .bridgeUnavailable(let detail):
            return detail
        case .invalidHealthResponse:
            return "Le bridge a répondu, mais son état n’est pas valide."
        }
    }
}

@MainActor
final class SUPRAChatRuntimeAdapter: SUPRAChatRuntimeProtocol {
    private let runtimeStore: SUPRAExecutiveStore
    private let healthURL: URL
    private let healthSession: URLSession

    private static let defaultHealthURL = URL(string: "http://127.0.0.1:18765/v1/health")!

    init() {
        runtimeStore = SUPRAExecutiveStore()
        healthURL = Self.defaultHealthURL
        healthSession = Self.makeHealthSession()
    }

    init(runtimeStore: SUPRAExecutiveStore) {
        self.runtimeStore = runtimeStore
        healthURL = Self.defaultHealthURL
        healthSession = Self.makeHealthSession()
    }

    init(runtimeStore: SUPRAExecutiveStore, healthURL: URL) {
        self.runtimeStore = runtimeStore
        self.healthURL = healthURL
        healthSession = Self.makeHealthSession()
    }

    func checkHealth() async throws {
        var request = URLRequest(url: healthURL)
        request.timeoutInterval = 4

        do {
            let (data, response) = try await healthSession.data(for: request)
            try Task.checkCancellation()

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw SUPRAChatRuntimeError.invalidHealthResponse
            }

            let health = try JSONDecoder().decode(HealthResponse.self, from: data)
            guard health.status.uppercased() == "PASS" else {
                throw SUPRAChatRuntimeError.invalidHealthResponse
            }
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as SUPRAChatRuntimeError {
            throw error
        } catch {
            throw SUPRAChatRuntimeError.bridgeUnavailable(
                "Bridge indisponible. Vérifiez qu’il écoute sur 127.0.0.1:18765."
            )
        }
    }

    func execute(prompt: String, mode: ChatMode) async throws -> String {
        let runtimePrompt = """
        SUPRA_CHAT_MODE=\(mode.rawValue)

        \(prompt)
        """

        await runtimeStore.sendChat(runtimePrompt)
        try Task.checkCancellation()

        guard let response = runtimeStore.chatMessages.last(where: {
            $0.role == "assistant"
        })?.text, !response.isEmpty else {
            throw SUPRAChatRuntimeError.emptyResponse
        }

        guard runtimeStore.chatConnected else {
            throw SUPRAChatRuntimeError.bridgeUnavailable(response)
        }

        return response
    }

    private static func makeHealthSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 4
        configuration.timeoutIntervalForResource = 4
        return URLSession(configuration: configuration)
    }

    private struct HealthResponse: Decodable {
        let status: String
    }
}
