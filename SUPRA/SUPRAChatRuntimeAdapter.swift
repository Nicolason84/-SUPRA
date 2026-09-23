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
    private let healthURLs: [URL]
    private let healthSession: URLSession

    private static let defaultHealthURLs: [URL] = [
        URL(string: "http://127.0.0.1:18765/health")!,
        URL(string: "http://127.0.0.1:18765/v1/health")!
    ]

    init() {
        runtimeStore = SUPRAExecutiveStore()
        healthURLs = Self.defaultHealthURLs
        healthSession = Self.makeHealthSession()
    }

    init(runtimeStore: SUPRAExecutiveStore) {
        self.runtimeStore = runtimeStore
        healthURLs = Self.defaultHealthURLs
        healthSession = Self.makeHealthSession()
    }

    init(runtimeStore: SUPRAExecutiveStore, healthURL: URL) {
        self.runtimeStore = runtimeStore
        healthURLs = [healthURL]
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
        var failures: [String] = []

        for healthURL in healthURLs {
            do {
                try await performHealthCheck(at: healthURL)
                return
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                failures.append("\(healthURL.path): \(error.localizedDescription)")
            }
        }

        throw SUPRAChatRuntimeError.bridgeUnavailable(
            "Bridge local indisponible sur 127.0.0.1:18765. Health probes: "
            + failures.joined(separator: " | ")
        )
    }

    private func performHealthCheck(at healthURL: URL) async throws {
        var request = URLRequest(url: healthURL)
        request.timeoutInterval = 2.5

        let (data, response) = try await healthSession.data(for: request)
        try Task.checkCancellation()

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SUPRAChatRuntimeError.invalidHealthResponse
        }

        if let health = try? JSONDecoder().decode(HealthResponse.self, from: data),
           health.status.uppercased() == "PASS" {
            return
        }

        if let raw = String(data: data, encoding: .utf8),
           raw.uppercased().contains("PASS") {
            return
        }

        throw SUPRAChatRuntimeError.invalidHealthResponse
    }

    private func restartExistingBridge() async throws {
        let uid = getuid()
        let label = "com.novaera.supra.bridge-watcher"
        let domain = "gui/\(uid)"

        func runLaunchctl(_ arguments: [String]) -> Int32 {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
            process.arguments = arguments
            let output = Pipe()
            process.standardOutput = output
            process.standardError = output

            do {
                try process.run()
                process.waitUntilExit()
                return process.terminationStatus
            } catch {
                return -1
            }
        }

        if runLaunchctl(["kickstart", "-k", "\(domain)/\(label)"]) != 0 {
            let userHome = NSHomeDirectoryForUser(NSUserName())
                ?? "/Users/\(NSUserName())"
            let plist = URL(fileURLWithPath: userHome, isDirectory: true)
                .appendingPathComponent("Library/LaunchAgents/\(label).plist")

            _ = runLaunchctl(["bootstrap", domain, plist.path])
            _ = runLaunchctl(["kickstart", "-k", "\(domain)/\(label)"])
        }

        try? await Task.sleep(nanoseconds: 1_200_000_000)
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
        configuration.timeoutIntervalForRequest = 3
        configuration.timeoutIntervalForResource = 3
        return URLSession(configuration: configuration)
    }

    private struct HealthResponse: Decodable {
        let status: String
    }
}
