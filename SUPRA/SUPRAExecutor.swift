import Foundation
import Combine

@MainActor
public final class SUPRAOrchestrationExecutor: ObservableObject {
    public static let shared = SUPRAOrchestrationExecutor()

    @Published public private(set) var currentContext: SUPRAExecutionContext?
    @Published public private(set) var isExecuting = false
    @Published public private(set) var lastError: String?

    private let missionBroker = SUPRAMissionBroker.shared
    private let inferenceRuntime = InferenceSovereigntyRuntime.shared
    private let logger = SUPRARuntimeLogger.shared

    private init() {}

    public func execute(missionTitle: String, prompt: String,
                        systemPrompt: String = "",
                        preferredProvider: SUPRAProviderType? = nil) async -> SUPRAProviderResponse? {
        isExecuting = true
        lastError = nil
        defer { isExecuting = false }

        logger.log(.mission, "Planification de la mission: \(missionTitle)")
        let plan = await missionBroker.route(
            missionTitle: missionTitle,
            prompt: prompt,
            systemPrompt: systemPrompt,
            preferredProvider: preferredProvider
        )
        logger.log(.capability, "Capacités: \(plan.capabilities.map(\.rawValue).joined(separator: ", "))")

        let request = SUPRAExecutionRequest(
            missionID: plan.missionID,
            prompt: plan.prompt,
            systemPrompt: plan.systemPrompt,
            requiredCapabilities: plan.capabilities,
            preferredProvider: nil,
            preferredModel: nil,
            maxTokens: plan.maxTokens,
            temperature: plan.temperature
        )
        let task = SUPRAInferenceTask(
            missionID: plan.missionID,
            missionTitle: plan.title,
            prompt: plan.prompt,
            systemPrompt: plan.systemPrompt,
            requiredCapabilities: plan.capabilities,
            preferredProvider: plan.preferredProvider,
            preferredModel: plan.preferredModel,
            maxTokens: plan.maxTokens,
            temperature: plan.temperature
        )

        currentContext = SUPRAExecutionContext(
            missionID: plan.missionID,
            missionTitle: plan.title,
            request: request,
            startedAt: Date()
        )

        logger.log(.executor, "Exécution via InferenceSovereigntyRuntime...")
        do {
            let response = try await inferenceRuntime.execute(task: task)
            currentContext = SUPRAExecutionContext(
                missionID: plan.missionID,
                missionTitle: plan.title,
                request: request,
                response: response,
                completedAt: Date()
            )
            logger.log(.response, "Réponse reçue: \(response.content.prefix(100))...")
            logger.log(.model, "Modèle: \(response.model), Provider: \(response.provider.rawValue), Durée: \(response.durationMs)ms")
            return response
        } catch {
            lastError = error.localizedDescription
            logger.log(.error, "Échec: \(error.localizedDescription)")
            return nil
        }
    }
}
