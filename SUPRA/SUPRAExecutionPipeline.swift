import Foundation
import Combine

@MainActor
public final class SUPRAExecutionPipeline: ObservableObject {
    public static let shared = SUPRAExecutionPipeline()

    @Published public private(set) var lastResult: String?
    @Published public private(set) var lastError: String?
    @Published public private(set) var isPipelineRunning = false
    @Published public private(set) var pipelineEvents: [String] = []

    private let executor = SUPRAOrchestrationExecutor.shared
    private let missionBroker = SUPRAMissionBroker.shared
    private let providerBroker = SUPRAProviderBroker.shared
    private let logger = SUPRARuntimeLogger.shared
    private let modelRegistry = SUPRAModelRegistry.shared

    private init() {}

    public func run(missionTitle: String, prompt: String,
                    systemPrompt: String = "") async -> String? {
        isPipelineRunning = true
        lastResult = nil
        lastError = nil
        pipelineEvents = []
        defer { isPipelineRunning = false }

        logger.clear()
        logger.log(.mission, "Démarrage mission: \(missionTitle)")

        guard let response = await executor.execute(
            missionTitle: missionTitle,
            prompt: prompt,
            systemPrompt: systemPrompt
        ) else {
            lastError = executor.lastError ?? "Échec inconnu"
            logger.log(.error, "Pipeline échoué: \(lastError!)")
            pipelineEvents.append("❌ ÉCHEC: \(lastError!)")
            return nil
        }

        logger.log(.response, "Mission terminée avec succès")
        logger.log(.memory, "Réponse stockée dans le contexte")
        logger.log(.ui, "Mise à jour UI disponible")

        lastResult = response.content
        pipelineEvents = logger.events.map { "\($0.stage.rawValue): \($0.message)" }

        logger.log(.decision, "Pipeline terminé - résultat: \(response.content.prefix(80))...")
        return response.content
    }

    public func pipelineStatus() -> String {
        var status = "Pipeline SUPRA\n"
        status += "━━━━━━━━━━━━━━━━━━━━\n"
        status += "État: \(isPipelineRunning ? "🟢 EN COURS" : "⏹️  INACTIF")\n"
        status += "Dernière mission: \(lastResult != nil ? "✅ SUCCÈS" : "❌ ÉCHEC")\n"
        if let result = lastResult {
            status += "Réponse: \(result.prefix(120))...\n"
        }
        if let error = lastError {
            status += "Erreur: \(error)\n"
        }
        status += "\nÉvénements:\n"
        for event in pipelineEvents {
            status += "  • \(event)\n"
        }
        status += logger.summary()
        return status
    }
}
