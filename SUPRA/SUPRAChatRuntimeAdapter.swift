import Foundation

@MainActor
protocol SUPRAChatRuntimeProtocol {
    func execute(prompt: String, mode: ChatMode) async throws -> String
}

enum SUPRAChatRuntimeError: LocalizedError {
    case emptyResponse
    case bridgeUnavailable(String)

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "Le runtime n’a retourné aucune réponse."
        case .bridgeUnavailable(let detail):
            return detail
        }
    }
}

@MainActor
final class SUPRAChatRuntimeAdapter: SUPRAChatRuntimeProtocol {
    private let runtimeStore: SUPRAExecutiveStore

    init() {
        runtimeStore = SUPRAExecutiveStore()
    }

    init(runtimeStore: SUPRAExecutiveStore) {
        self.runtimeStore = runtimeStore
    }

    func execute(prompt: String, mode: ChatMode) async throws -> String {
        let runtimePrompt = """
        SUPRA_CHAT_MODE=\(mode.rawValue)

        \(prompt)
        """

        await runtimeStore.sendChat(runtimePrompt)

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
}
