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
        do {
            try await performHealthCheck()
            return
        } catch {
            try? await restartExistingBridge()
            try await performHealthCheck()
        }
    }

    private func performHealthCheck() async throws {
        var request = URLRequest(url: healthURL)
        request.timeoutInterval = 4

        do {
            let (data, response) = try await healthSession.data(for: request)
            try Task.checkCancellation()

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw SUPRAChatRuntimeError.invalidHealthResponse
            }

            if let health = try? JSONDecoder().decode(HealthResponse.self, from: data) {
                let accepted = ["PASS", "OK", "READY", "CONNECTED", "HEALTHY"]
                if accepted.contains(health.status.uppercased()) {
                    return
                }
            }

            // Some historical C1 bridge builds answer 2xx with a different
            // health payload shape. A successful local HTTP response proves
            // liveness; the first /v1/chat request remains the execution proof.
            guard !data.isEmpty else {
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

    private func restartExistingBridge() async throws {
        let fileManager = FileManager.default
        let plist = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/com.novaera.sol-github-bridge.plist")

        guard fileManager.fileExists(atPath: plist.path) else {
            throw SUPRAChatRuntimeError.bridgeUnavailable(
                "Bridge local existant introuvable."
            )
        }

        let uid = getuid()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = [
            "kickstart",
            "-k",
            "gui/\(uid)/com.novaera.sol-github-bridge"
        ]

        let output = Pipe()
        process.standardOutput = output
        process.standardError = output

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            throw SUPRAChatRuntimeError.bridgeUnavailable(
                "Impossible de relancer le bridge local existant."
            )
        }

        guard process.terminationStatus == 0 else {
            throw SUPRAChatRuntimeError.bridgeUnavailable(
                "Le bridge local n’a pas pu être relancé."
            )
        }

        try? await Task.sleep(nanoseconds: 1_500_000_000)
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
        let status: String?
    }
}
