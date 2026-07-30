import Foundation
import Combine

public enum SUPRAProviderError: LocalizedError {
    case noProviderAvailable
    case providerNotRegistered(SUPRAProviderType)
    case executionFailed(SUPRAProviderType, String)
    case timeout(SUPRAProviderType)
    case modelNotFound(String)
    case allProvidersFailed

    public var errorDescription: String? {
        switch self {
        case .noProviderAvailable: return "Aucun provider IA disponible"
        case .providerNotRegistered(let t): return "Provider \(t.rawValue) non enregistré"
        case .executionFailed(let t, let e): return "Échec \(t.rawValue): \(e)"
        case .timeout(let t): return "Timeout \(t.rawValue)"
        case .modelNotFound(let m): return "Modèle \(m) non trouvé"
        case .allProvidersFailed: return "Tous les providers ont échoué"
        }
    }
}

@MainActor
public final class SUPRAProviderBroker: ObservableObject {
    public static let shared = SUPRAProviderBroker()

    @Published public private(set) var lastProviderUsed: SUPRAProviderType?
    @Published public private(set) var lastResponse: SUPRAProviderResponse?
    @Published public private(set) var isExecuting = false
    @Published public private(set) var executionError: String?

    private let inferenceRuntime = InferenceSovereigntyRuntime.shared

    private init() {}

    public func execute(request: SUPRAExecutionRequest) async throws -> SUPRAProviderResponse {
        isExecuting = true
        executionError = nil
        defer { isExecuting = false }

        do {
            let response = try await inferenceRuntime.execute(
                task: SUPRAInferenceTask(
                    missionID: request.missionID,
                    missionTitle: "ProviderBroker Compatibility Execution",
                    prompt: request.prompt,
                    systemPrompt: request.systemPrompt,
                    requiredCapabilities: request.requiredCapabilities,
                    preferredProvider: request.preferredProvider,
                    preferredModel: request.preferredModel,
                    maxTokens: request.maxTokens,
                    temperature: request.temperature
                )
            )
            lastProviderUsed = response.provider
            lastResponse = response
            return response
        } catch {
            executionError = error.localizedDescription
            throw error
        }
    }
}
