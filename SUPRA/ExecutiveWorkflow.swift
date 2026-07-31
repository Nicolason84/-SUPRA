import Foundation
import Combine

enum ExecutiveWorkflowStatus: String, Codable, Sendable {
    case ready = "READY"
    case partial = "PARTIAL"
    case blocked = "BLOCKED"
}

struct ExecutiveWorkflow: Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let inputs: [String]
    let outputs: [String]
    let artifacts: [String]
    var status: ExecutiveWorkflowStatus
}

struct WorkflowExecutionRecord: Identifiable, Sendable {
    let id: UUID
    let workflowID: String
    let workflowName: String
    let startDate: Date
    let duration: TimeInterval
    let result: String
    let decision: String
    let confidence: Double
    let artifacts: [String]
    let reportPath: String?
}

struct ExecutiveReport: Identifiable, Sendable {
    let id: UUID
    let workflowName: String
    let date: Date
    let summary: String
    let context: String
    let analysis: String
    let evidence: [String]
    let risks: [String]
    let opportunities: [String]
    let decision: String
    let recommendedActions: [String]
    let confidence: Double
    let artifacts: [String]
    let reportID: String
}

@MainActor
final class ExecutiveWorkflowRegistry: ObservableObject {
    static let shared = ExecutiveWorkflowRegistry()

    @Published private(set) var workflows: [ExecutiveWorkflow] = []
    @Published private(set) var executionHistory: [WorkflowExecutionRecord] = []
    @Published private(set) var isExecuting = false
    @Published private(set) var lastReport: ExecutiveReport?
    @Published private(set) var lastError: String?

    private let logger = SUPRARuntimeLogger.shared
    private let businessPlatform = SUPRABusinessPlatform.shared
    private let worldModel = SUPRAWorldModel.shared
    private let decisionEngine = SUPRADecisionEngine.shared
    private let missionExecutor = SUPRAMissionExecutor.shared

    private init() {
        registerWorkflows()
    }

    private func registerWorkflows() {
        workflows = [
            ExecutiveWorkflow(
                id: "business_health",
                name: "Business Health Analysis",
                description: "Analyse l'état de santé global du système : environnement, mémoire, décisions, missions, et intelligence embarquée. Produit un rapport exécutif avec score de santé, risques détectés et actions recommandées.",
                inputs: ["SUPRAWorldModel", "SUPRABusinessPlatform", "SUPRAEnvironmentWorldModel"],
                outputs: ["ExecutiveReport", "Health Score", "Risk Assessment"],
                artifacts: ["EXECUTIVE_REPORT.json", "HEALTH_SNAPSHOT.json"],
                status: .ready
            ),
            ExecutiveWorkflow(
                id: "decision_audit",
                name: "Decision Audit",
                description: "Audite les décisions architecturales enregistrées (ARCHITECTURAL_DECISIONS.json), évalue leur statut, priorité, confiance, et produit un rapport de qualité décisionnelle.",
                inputs: ["ARCHITECTURAL_DECISIONS.json", "DecisionStore"],
                outputs: ["Audit Report", "Decision Quality Score", "Human Gate Required"],
                artifacts: ["DECISION_AUDIT_REPORT.json"],
                status: .ready
            ),
            ExecutiveWorkflow(
                id: "monetization_report",
                name: "Monetization & Value Report",
                description: "Calcule les métriques de valeur business : temps économisé, risque réduit, qualité décisionnelle, autonomie. Produit un ROI estimé et recommande le niveau d'abonnement adapté.",
                inputs: ["SUPRAWorldModel", "SUPRAMonetizationEngine"],
                outputs: ["Value Report", "ROI Calculation", "Tier Recommendation"],
                artifacts: ["MONETIZATION_REPORT.json"],
                status: .ready
            ),
            ExecutiveWorkflow(
                id: "environment_assessment",
                name: "Environment Assessment",
                description: "Évalue l'environnement d'exécution (CPU, RAM, stockage, thermal, processus). Détecte les goulets d'étranglement et produit des recommandations d'optimisation.",
                inputs: ["SUPRAEnvironmentWorldModel", "RuntimeDataService"],
                outputs: ["Environment Report", "Bottleneck Detection", "Optimization Recommendations"],
                artifacts: ["ENVIRONMENT_REPORT.json"],
                status: .ready
            ),
            ExecutiveWorkflow(
                id: "opportunity_discovery",
                name: "Opportunity Discovery",
                description: "Explore les opportunités détectées par les moteurs d'évolution et de recommandation. Priorise les actions à forte valeur et identifie les décisions humaines nécessaires.",
                inputs: ["SUPRAEvolutionEngine", "SUPRARecommendationEngine", "SUPRAIntelligenceEngine"],
                outputs: ["Opportunity Report", "Priority Actions", "Human Decision Queue"],
                artifacts: ["OPPORTUNITY_REPORT.json"],
                status: .ready
            )
        ]
    }

    func executeWorkflow(id: String) async -> ExecutiveReport? {
        guard let workflow = workflows.first(where: { $0.id == id }) else {
            lastError = "Workflow not found: \(id)"
            return nil
        }
        guard !isExecuting else {
            lastError = "A workflow is already executing"
            return nil
        }

        isExecuting = true
        lastError = nil
        let startDate = Date()
        logger.log(.mission, "Workflow[\(workflow.name)]: Starting")

        SUPRARuntimeLogger.shared.log(.boot, "Workflow[\(workflow.name)]: Sélection")

        var report: ExecutiveReport?

        switch id {
        case "business_health":
            report = await executeBusinessHealth(workflow: workflow, startDate: startDate)
        case "decision_audit":
            report = await executeDecisionAudit(workflow: workflow, startDate: startDate)
        case "monetization_report":
            report = await executeMonetizationReport(workflow: workflow, startDate: startDate)
        case "environment_assessment":
            report = await executeEnvironmentAssessment(workflow: workflow, startDate: startDate)
        case "opportunity_discovery":
            report = await executeOpportunityDiscovery(workflow: workflow, startDate: startDate)
        default:
            lastError = "Unknown workflow: \(id)"
        }

        let duration = Date().timeIntervalSince(startDate)
        SUPRARuntimeLogger.shared.log(.performance, "Workflow[\(workflow.name)]: Durée \(Int(duration * 1000))ms")

        if let report = report {
            let record = WorkflowExecutionRecord(
                id: UUID(),
                workflowID: id,
                workflowName: report.workflowName,
                startDate: startDate,
                duration: duration,
                result: report.summary.prefix(200).description,
                decision: report.decision,
                confidence: report.confidence,
                artifacts: report.artifacts,
                reportPath: "workflow_\(id)_\(ISO8601DateFormatter().string(from: startDate))"
            )
            executionHistory.append(record)
            lastReport = report
            logger.log(.mission, "Workflow[\(workflow.name)]: Terminé — confiance \(Int(report.confidence * 100))%")

            SUPRARuntimeLogger.shared.log(.dashboard, "Workflow[\(workflow.name)]: Archivage")
            SUPRARuntimeLogger.shared.log(.dashboard, "Workflow[\(workflow.name)]: Freeze")

            logger.log(.ui, "Workflow[\(workflow.name)]: Rapport disponible")
        } else {
            logger.log(.error, "Workflow[\(workflow.name)]: Échec — \(lastError ?? "unknown error")")
        }

        isExecuting = false
        return report
    }

    private func executeBusinessHealth(workflow: ExecutiveWorkflow, startDate: Date) async -> ExecutiveReport {
        SUPRARuntimeLogger.shared.log(.boot, "Workflow[\(workflow.name)]: Chargement des données")
        businessPlatform.refresh()
        worldModel.refresh()

        SUPRARuntimeLogger.shared.log(.root, "Workflow[\(workflow.name)]: Analyse")
        let customerTwin = businessPlatform.customerTwin
        let world = worldModel.world

        var contextLines: [String] = []
        var analysisLines: [String] = []
        var evidenceList: [String] = []
        var risks: [String] = []
        var opportunities: [String] = []

        if let c = customerTwin {
            contextLines.append("Company: \(c.company.name)")
            contextLines.append("Industry: \(c.company.industry)")
            contextLines.append("Active Projects: \(c.company.activeProjects)")
            analysisLines.append("Environment Score: \(Int(c.environment.overallScore * 100))%")
            analysisLines.append("System Health: \(c.environment.systemHealth)")
            evidenceList.append("CPU Load: \(Int(c.environment.cpuLoad * 100))%")
            evidenceList.append("RAM Load: \(Int(c.environment.ramLoad * 100))%")
            evidenceList.append("Disk Free: \(Int(c.environment.diskFree))GB")

            if c.environment.cpuLoad > 0.8 {
                risks.append("CPU load critical (\(Int(c.environment.cpuLoad * 100))%) — risque de dégradation des performances")
            }
            if c.environment.ramLoad > 0.85 {
                risks.append("RAM saturation (\(Int(c.environment.ramLoad * 100))%) — risque de swap mémoire")
            }
            if c.environment.diskFree < 20 {
                risks.append("Espace disque faible (\(Int(c.environment.diskFree))GB restants)")
            }
            if c.environment.cpuLoad < 0.5 && c.environment.ramLoad < 0.5 {
                opportunities.append("Ressources disponibles pour missions parallèles supplémentaires")
            }
        }

        if let w = world {
            analysisLines.append("Missions: \(w.missions.active) active / \(w.missions.total) total")
            analysisLines.append("Autonomy Level: \(Int(w.decision.autonomyLevel * 100))%")
            analysisLines.append("Auto-Executed: \(w.decision.autoCount)")
            analysisLines.append("Blocked Missions: \(w.missions.blocked)")
            evidenceList.append("Memory Sources: \(w.memory.cannonicoSources)")
            evidenceList.append("Memory Health: \(w.memory.multiMemoryHealth)")
            evidenceList.append("Intelligence Health: \(Int(w.intelligence.healthScore * 100))%")
            evidenceList.append("Insights: \(w.intelligence.insightCount)")

            if w.missions.blocked > 3 {
                risks.append("\(w.missions.blocked) missions bloquées — nécessite intervention")
            }
            if w.decision.autonomyLevel > 0.7 {
                opportunities.append("Potentiel d'autonomie élevé (\(Int(w.decision.autonomyLevel * 100))%) — envisager mode auto-execute")
            }
        }

        SUPRARuntimeLogger.shared.log(.decision, "Workflow[\(workflow.name)]: Décision")

        let overallHealth: String
        let healthScore: Double
        let envScore = customerTwin?.environment.overallScore ?? 0
        let autScore = world?.decision.autonomyLevel ?? 0
        healthScore = (envScore + autScore) / 2.0
        if healthScore > 0.7 {
            overallHealth = "GOOD"
        } else if healthScore > 0.4 {
            overallHealth = "FAIR"
        } else {
            overallHealth = "CRITICAL"
        }

        let decision = "Santé globale: \(overallHealth) (score: \(Int(healthScore * 100))%) — \(risks.isEmpty ? "Aucun risque critique" : "\(risks.count) risques détectés")"
        let actions = recommendedActions(for: overallHealth, risks: risks, opportunities: opportunities)

        SUPRARuntimeLogger.shared.log(.dashboard, "Workflow[\(workflow.name)]: Rapport")
        SUPRARuntimeLogger.shared.log(.dashboard, "Workflow[\(workflow.name)]: Archivage")
        SUPRARuntimeLogger.shared.log(.dashboard, "Workflow[\(workflow.name)]: Freeze")

        return ExecutiveReport(
            id: UUID(),
            workflowName: workflow.name,
            date: startDate,
            summary: "Analyse de santé business terminée. Score: \(Int(healthScore * 100))%. Statut: \(overallHealth). \(risks.count) risques, \(opportunities.count) opportunités.",
            context: contextLines.joined(separator: "\n"),
            analysis: analysisLines.joined(separator: "\n"),
            evidence: evidenceList,
            risks: risks,
            opportunities: opportunities,
            decision: decision,
            recommendedActions: actions,
            confidence: healthScore,
            artifacts: ["EXECUTIVE_REPORT.json", "HEALTH_SNAPSHOT.json"],
            reportID: "BUS-\(ISO8601DateFormatter().string(from: startDate))"
        )
    }

    private func executeDecisionAudit(workflow: ExecutiveWorkflow, startDate: Date) async -> ExecutiveReport {
        let store = SUPRACompositionRoot.shared.decisionStore
        store.load()
        let decisions = store.visibleDecisions

        let total = decisions.count
        let approved = decisions.filter { $0.status == .approved }.count
        let pending = decisions.filter { $0.status == .pending || $0.status == .inReview }.count
        let humanGate = decisions.filter { $0.humanGate == .required || $0.humanGate == .completed }.count
        let highPriority = decisions.filter { $0.priority == .critical || $0.priority == .high }.count
        let avgConfidence = decisions.compactMap(\.confidence).reduce(0, +) / max(Double(decisions.compactMap(\.confidence).count), 1)

        let qualityScore = total > 0 ? Double(approved) / Double(total) : 0
        let confidence = (qualityScore + avgConfidence) / 2.0

        var risks: [String] = []
        if pending > 3 { risks.append("\(pending) décisions en attente — goulot d'étranglement décisionnel") }
        if humanGate > 0 { risks.append("\(humanGate) décisions nécessitant validation humaine") }

        var opportunities: [String] = []
        if avgConfidence > 0.7 { opportunities.append("Haute confiance décisionnelle (\(Int(avgConfidence * 100))%)") }

        let decision = "Qualité décisionnelle: \(Int(qualityScore * 100))%. \(approved)/\(total) approuvées. Confiance moyenne: \(Int(avgConfidence * 100))%."
        let actions = recommendedActions(for: qualityScore > 0.7 ? "GOOD" : "FAIR", risks: risks, opportunities: opportunities)

        return ExecutiveReport(
            id: UUID(),
            workflowName: workflow.name,
            date: startDate,
            summary: "Audit de \(total) décisions. Qualité: \(Int(qualityScore * 100))%. \(pending) en attente, \(humanGate) nécessitant validation humaine.",
            context: "Source: ARCHITECTURAL_DECISIONS.json",
            analysis: "Décisions: \(total) totales, \(approved) approuvées, \(pending) en attente, \(highPriority) haute priorité",
            evidence: [
                "Total: \(total)",
                "Approuvées: \(approved)",
                "En attente: \(pending)",
                "Validation humaine: \(humanGate)",
                "Haute priorité: \(highPriority)",
                "Confiance moyenne: \(Int(avgConfidence * 100))%"
            ],
            risks: risks,
            opportunities: opportunities,
            decision: decision,
            recommendedActions: actions,
            confidence: confidence,
            artifacts: ["DECISION_AUDIT_REPORT.json"],
            reportID: "DEC-\(ISO8601DateFormatter().string(from: startDate))"
        )
    }

    private func executeMonetizationReport(workflow: ExecutiveWorkflow, startDate: Date) async -> ExecutiveReport {
        worldModel.refresh()
        guard let world = worldModel.world else {
            return ExecutiveReport(
                id: UUID(), workflowName: workflow.name, date: startDate,
                summary: "World model not available — cannot compute value metrics",
                context: "", analysis: "", evidence: [], risks: ["World model not initialized"],
                opportunities: [], decision: "Cannot compute", recommendedActions: ["Initialize world model first"],
                confidence: 0, artifacts: ["MONETIZATION_REPORT.json"],
                reportID: "VAL-ERR-\(ISO8601DateFormatter().string(from: startDate))"
            )
        }

        let metrics = SUPRAPricingModel.valueMetrics(from: world)
        let tier = SUPRAPricingModel.recommendedTier(for: metrics)
        let savings = SUPRAPricingModel.savingsReport(metrics: metrics, tier: tier)

        let valueUSD = (metrics.estimatedValueUSD as NSDecimalNumber).intValue
        let monthlyPrice = (tier.monthlyPrice as NSDecimalNumber).intValue
        let roi = monthlyPrice > 0 ? (valueUSD / monthlyPrice) * 100 : 0

        let confidence = metrics.compositeScore

        return ExecutiveReport(
            id: UUID(),
            workflowName: workflow.name,
            date: startDate,
            summary: "Rapport de valeur: $\(valueUSD)/mois estimés. ROI: \(roi)%. Niveau recommandé: \(tier.rawValue).",
            context: "Basé sur les métriques d'exécution actuelles du système SUPRA",
            analysis: savings,
            evidence: [
                "Temps économisé: \(Int(metrics.timeSavedMinutes)) min/mois",
                "Risque réduit: \(Int(metrics.riskReduced * 100))%",
                "Qualité décisionnelle: \(Int(metrics.decisionQuality * 100))%",
                "Niveau d'autonomie: \(Int(metrics.automationLevel * 100))%"
            ],
            risks: tier == .explorer ? ["Niveau explorer limité — passer à Executive pour débloquer le potentiel"] : [],
            opportunities: [
                "ROI de \(roi)% sur l'investissement mensuel",
                "Passage au niveau \(tier.rawValue) pour \(monthlyPrice)$/mois"
            ],
            decision: "Niveau recommandé: \(tier.rawValue) à $\(monthlyPrice)/mois. Valeur estimée: $\(valueUSD)/mois.",
            recommendedActions: [
                "Souscrire au niveau \(tier.rawValue)",
                "Activer les fonctionnalités \(tier.rawValue)",
                "Monitorer le ROI mensuellement"
            ],
            confidence: confidence,
            artifacts: ["MONETIZATION_REPORT.json"],
            reportID: "VAL-\(ISO8601DateFormatter().string(from: startDate))"
        )
    }

    private func executeEnvironmentAssessment(workflow: ExecutiveWorkflow, startDate: Date) async -> ExecutiveReport {
        let envModel = SUPRAEnvironmentWorldModel.shared
        envModel.refresh()
        let state = envModel.state

        var evidence: [String] = []
        var risks: [String] = []
        var opportunities: [String] = []

        if let hw = state?.hardware {
            evidence.append("CPU: \(Int(hw.cpuUsage * 100))% • \(hw.cpuCount) cores")
            evidence.append("RAM: \(Int(hw.ramUsedGB))/\(Int(hw.physicalRAMGB)) GB")
            evidence.append("Stockage: \(Int(hw.storageFreeGB))GB libre")
            evidence.append("Thermal: \(hw.thermalState)")

            if hw.cpuUsage > 0.8 { risks.append("CPU en surcharge (\(Int(hw.cpuUsage * 100))%)") }
            if hw.ramUsedGB > hw.physicalRAMGB * 0.85 { risks.append("RAM presque saturée (\(Int(hw.ramUsedGB))/\(Int(hw.physicalRAMGB)) GB)") }
            if hw.storageFreeGB < 20 { risks.append("Espace disque faible (\(Int(hw.storageFreeGB))GB)") }
            if hw.cpuUsage < 0.3 { opportunities.append("CPU disponible pour tâches supplémentaires") }
            if hw.storageFreeGB > 100 { opportunities.append("Large espace disque disponible") }
        }

        if let sw = state?.software {
            evidence.append("Applications actives: \(sw.applicationCount)")
            evidence.append("Services: \(sw.servicesCount)")
        }

        let healthScore = risks.isEmpty ? 0.9 : max(0.1, 1.0 - Double(risks.count) * 0.2)
        let decision = risks.isEmpty ? "Environnement sain — aucun problème critique" : "\(risks.count) problèmes détectés — actions recommandées"

        return ExecutiveReport(
            id: UUID(), workflowName: workflow.name, date: startDate,
            summary: "Assessment environnement terminé. \(risks.count) risques, \(opportunities.count) opportunités.",
            context: "Mac actuel — monitoring temps réel",
            analysis: "Score santé: \(Int(healthScore * 100))%",
            evidence: evidence, risks: risks, opportunities: opportunities,
            decision: decision,
            recommendedActions: recommendedActions(for: healthScore > 0.7 ? "GOOD" : healthScore > 0.4 ? "FAIR" : "CRITICAL", risks: risks, opportunities: opportunities),
            confidence: healthScore, artifacts: ["ENVIRONMENT_REPORT.json"],
            reportID: "ENV-\(ISO8601DateFormatter().string(from: startDate))"
        )
    }

    private func executeOpportunityDiscovery(workflow: ExecutiveWorkflow, startDate: Date) async -> ExecutiveReport {
        let evolution = SUPRAEvolutionEngine.shared
        let recommendation = SUPRARecommendationEngine.shared
        let intelligence = SUPRAIntelligenceEngine.shared

        var evidence: [String] = []
        var risks: [String] = []
        var opportunities: [String] = []

        let proposals = evolution.proposals
        let autoExecuted = evolution.autoExecutedCount
        let humanPending = evolution.humanPending
        let activeRecommendations = recommendation.active
        let insights = intelligence.state.insights

        evidence.append("Propositions d'évolution: \(proposals.count)")
        evidence.append("Actions auto-exécutées: \(autoExecuted)")
        evidence.append("Décisions humaines en attente: \(humanPending.count)")
        evidence.append("Recommandations actives: \(activeRecommendations.count)")
        evidence.append("Insights: \(insights.count)")

        if humanPending.count > 2 { risks.append("\(humanPending.count) décisions humaines en attente de validation") }
        if proposals.isEmpty { opportunities.append("Aucune proposition — le système est stable") }
        if autoExecuted > 0 { opportunities.append("\(autoExecuted) actions déjà automatisées avec succès") }

        if let next = intelligence.state.nextBestAction {
            opportunities.append("Prochaine meilleure action: \(next)")
        }

        if let insight = insights.first {
            opportunities.append("Insight clé: \(insight)")
        }

        let confidence = intelligence.state.healthScore
        let decision = "\(opportunities.count) opportunités détectées, \(risks.count) risques identifiés"

        return ExecutiveReport(
            id: UUID(), workflowName: workflow.name, date: startDate,
            summary: "\(opportunities.count) opportunités, \(risks.count) risques. \(proposals.count) propositions en cours.",
            context: "Moteurs d'évolution, recommandation et intelligence",
            analysis: "\(humanPending.count) décisions humaines nécessaires — \(autoExecuted) déjà automatisées",
            evidence: evidence, risks: risks, opportunities: opportunities,
            decision: decision,
            recommendedActions: recommendedActions(for: confidence > 0.7 ? "GOOD" : "FAIR", risks: risks, opportunities: opportunities),
            confidence: confidence, artifacts: ["OPPORTUNITY_REPORT.json"],
            reportID: "OPP-\(ISO8601DateFormatter().string(from: startDate))"
        )
    }

    private func recommendedActions(for health: String, risks: [String], opportunities: [String]) -> [String] {
        var actions: [String] = []
        if health == "CRITICAL" {
            actions.append("Intervention immédiate requise — priorité haute")
        }
        for risk in risks.prefix(3) {
            actions.append("Traiter: \(risk)")
        }
        for opp in opportunities.prefix(2) {
            actions.append("Exploiter: \(opp)")
        }
        if actions.isEmpty {
            actions.append("Aucune action requise — système en bonne santé")
        }
        return actions
    }

    func summary() -> String {
        var s = "EXECUTIVE WORKFLOW REGISTRY\n"
        s += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        for w in workflows {
            s += "• \(w.name) [\(w.status.rawValue)]\n"
            s += "  \(w.description.prefix(80))...\n"
        }
        s += "\nExécutions: \(executionHistory.count)\n"
        if let last = executionHistory.last {
            s += "Dernière: \(last.workflowName) — \(last.result.prefix(100))\n"
        }
        return s
    }
}
