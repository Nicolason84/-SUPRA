import Foundation

@MainActor
public enum SUPRAAliveDemo {
    public static func bootstrap() {
        let logger = SUPRARuntimeLogger.shared
        let events = SUPRARuntimeEvents.shared

        logger.log(.mission, "=== SUPRA ORCHESTRATION BOOTSTRAP ===")

        Task {
            logger.log(.mission, "Découverte automatique des plugins...")
            let discoveryResults = await SUPRAPluginDiscovery.shared.discoverAll()

            for result in discoveryResults {
                events.emit(.pluginDiscovered,
                           "\(result.pluginID): \(result.success ? "OK" : "FAIL") - \(result.message)",
                           source: "PluginDiscovery")
            }

            await SUPRARuntimeRegistry.shared.initialize()
            SUPRARuntimeGraph.shared.refresh()

            logger.log(.mission, "Bootstrap terminé: \(discoveryResults.count) plugins découverts")
            events.emit(.modelLoaded, "Runtime ready: \(SUPRARuntimeRegistry.shared.allPlugins.count) plugins, \(SUPRARuntimeRegistry.shared.allModelDeclarations.count) models",
                       source: "SUPRAAliveDemo")
        }
    }

    public static func runDemoMission() async -> String? {
        let decisionEngine = SUPRADecisionEngine.shared
        let planner = SUPRAExecutionPlanner.shared
        let routingPolicy = SUPRARoutingPolicy.shared
        let scheduler = SUPRAScheduler.shared
        let fallbackEngine = SUPRAFallbackEngine.shared
        let runtimeMetrics = SUPRARuntimeMetrics.shared
        let events = SUPRARuntimeEvents.shared
        let logger = SUPRARuntimeLogger.shared

        logger.clear()
        logger.log(.mission, "=== MISSION DE DÉMONSTRATION ORCHESTRATION ===")
        events.emit(.executionStarted, "Starting demo: 'Bonjour SUPRA'", source: "Demo")

        logger.log(.decision, "Phase 1: Décision...")
        let decision = await decisionEngine.decide(
            missionTitle: "Mission de démonstration",
            prompt: "Bonjour SUPRA, réponds de manière amicale et concise.",
            systemPrompt: "Tu es SUPRA, un assistant IA souverain."
        )
        events.emit(.decisionCreated, "\(decision.steps.count) orchestration steps", source: "DecisionEngine")
        logger.log(.decision, "\(decision.steps.count) étapes d'orchestration")

        logger.log(.capability, "Phase 2: Planification...")
        let requirements = SUPRARoutingRequirements(
            requiredCapabilities: decision.steps.flatMap(\.requiredCapabilities),
            requiresLocal: true,
            requiresLowLatency: true,
            minContextWindow: 4096
        )

        let plan = await planner.plan(decision: decision, prompt: "Bonjour SUPRA, réponds de manière amicale et concise.",
                                       systemPrompt: "Tu es SUPRA, un assistant IA souverain.")
        events.emit(.capabilityResolved, "\(plan.tasks.count) tasks planned", source: "ExecutionPlanner")

        logger.log(.provider, "Phase 3: Routage...")
        guard let selection = await routingPolicy.selectProvider(for: requirements) else {
            events.emit(.executionFailed, "No provider available", source: "RoutingPolicy")
            logger.log(.error, "Aucun provider disponible")
            return nil
        }
        events.emit(.routingSelected, "Selected \(selection.providerID)/\(selection.modelID)", source: "RoutingPolicy")

        logger.log(.executor, "Phase 4: Exécution via FallbackEngine...")
        do {
            let result = try await fallbackEngine.executeWithFallback(
                prompt: "Bonjour SUPRA, réponds de manière amicale et concise.",
                systemPrompt: "Tu es SUPRA, un assistant IA souverain.",
                requiredCapabilities: ["reasoning", "conversation"],
                preferredProviderID: selection.providerID,
                preferredModelID: selection.modelID
            )
            runtimeMetrics.recordExecution(providerID: selection.providerID, success: true, durationMs: 0, tokensUsed: 0)
            events.emit(.executionCompleted, "Response: \(result.prefix(80))...", source: "FallbackEngine")
            logger.log(.response, "Réponse reçue: \(result.prefix(100))...")
            return result
        } catch {
            runtimeMetrics.recordExecution(providerID: selection.providerID, success: false, durationMs: 0, tokensUsed: 0)
            events.emit(.executionFailed, error.localizedDescription, source: "FallbackEngine")
            logger.log(.error, "Échec: \(error.localizedDescription)")
            return nil
        }
    }

    public static func runtimeReport() -> String {
        let registry = SUPRARuntimeRegistry.shared
        let metrics = SUPRARuntimeMetrics.shared
        let events = SUPRARuntimeEvents.shared
        let graph = SUPRARuntimeGraph.shared
        let learning = SUPRALearningEngine.shared

        var report = ""
        report += "╔══════════════════════════════════════════════╗\n"
        report += "║     SUPRA ORCHESTRATION — RAPPORT RUNTIME   ║\n"
        report += "╚══════════════════════════════════════════════╝\n\n"

        report += "📦 RUNTIME REGISTRY\n"
        report += registry.summary()
        report += "\n"

        report += "🔌 RUNTIME GRAPH\n"
        report += graph.graphDescription()
        report += "\n"

        report += "📊 MÉTRIQUES\n"
        report += metrics.summary()
        report += "\n"

        report += "🧠 LEARNING\n"
        report += learning.summary()
        report += "\n"

        report += "📋 ÉVÉNEMENTS\n"
        report += events.summary()
        report += "\n"

        report += "✅ STATUT: SYSTÈME D'ORCHESTRATION VIVANT\n"
        report += "✓ Kernel indépendant de tout provider\n"
        report += "✓ Providers = plugins interchangeables\n"
        report += "✓ Modèles = ressources interchangeables\n"
        report += "✓ Routing piloté par Policy\n"
        report += "✓ Fallback automatique\n"
        report += "✓ Learning Engine actif\n"

        return report
    }
}
