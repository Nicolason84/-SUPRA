import Foundation

struct SUPRAEnvironmentBrief {
    let headline: String
    let globalAssessment: String
    let primaryRisk: String?
    let primaryOpportunity: String?
    let confidencePhi: Double
    let recommendedAction: String?
    let authority: String
    let evidenceSummary: String
    let estimatedGain: String?
    let lastChangeSummary: String
    let timestamp: Date

    static func generate(from state: CompleteEnvironmentState, copilot: SUPRAOptimizationCopilot) -> SUPRAEnvironmentBrief {
        let headline: String
        let assessment: String
        let risk: String?
        let opportunity: String?
        let gain: String?

        if state.environmentScore >= 0.8 {
            headline = "Votre environnement est sain et bien géré."
            assessment = "Le système est stable avec un score de \(Int(state.environmentScore * 100))%. Aucune intervention critique nécessaire."
        } else if state.environmentScore >= 0.5 {
            headline = "Quelques points méritent votre attention."
            assessment = "Le score environnement est de \(Int(state.environmentScore * 100))%. Des optimisations sont possibles."
        } else {
            headline = "Votre environnement nécessite une intervention."
            assessment = "Le score est de \(Int(state.environmentScore * 100))%. Plusieurs domaines requièrent votre attention."
        }

        let highImpact = copilot.findings.filter { $0.impactScore > 0.6 }
        if let top = highImpact.first {
            risk = "Risque principal : \(top.title) — \(top.detail)"
            opportunity = top.suggestedAction
            gain = "Gain estimé : réduction de \(Int(top.impactScore * 100))% du risque dans ce domaine"
        } else if let any = copilot.findings.first {
            risk = any.title
            opportunity = any.suggestedAction
            gain = nil
        } else {
            risk = nil
            opportunity = nil
            gain = nil
        }

        let autoCount = copilot.autoQueue.count
        let humanCount = copilot.humanQueue.count
        let evidence: String
        if !copilot.findings.isEmpty {
            evidence = "\(copilot.findings.count) opportunités identifiées : \(autoCount) automatiques, \(humanCount) nécessitant une décision humaine"
        } else if let hw = state.hardware {
            evidence = "CPU \(Int(hw.cpuUsage * 100))%, RAM \(Int(hw.ramUsedGB))/\(Int(hw.physicalRAMGB))GB, disque \(Int(hw.storageFreeGB))GB libres, \(hw.thermalState)"
        } else {
            evidence = "Données collectées — analyse en cours"
        }

        let changes = state.timestamp.formatted(date: .abbreviated, time: .shortened)

        return SUPRAEnvironmentBrief(
            headline: headline,
            globalAssessment: assessment,
            primaryRisk: risk,
            primaryOpportunity: opportunity,
            confidencePhi: copilot.findings.isEmpty ? 0.85 : copilot.findings.map(\.confidence).reduce(0, +) / Double(copilot.findings.count),
            recommendedAction: opportunity,
            authority: autoCount > 0 ? "AUTO (\(autoCount))" : humanCount > 0 ? "HUMAN (\(humanCount))" : "NONE",
            evidenceSummary: evidence,
            estimatedGain: gain,
            lastChangeSummary: "Dernière mise à jour : \(changes)",
            timestamp: Date()
        )
    }

    func response(for intent: String) -> String {
        let q = intent.lowercased()
        if q.contains("ralentit") || q.contains("lent") || q.contains("cpu") || q.contains("performance") {
            return primaryRisk ?? "Aucun ralentissement détecté. Le système est stable."
        }
        if q.contains("stockage") || q.contains("disque") || q.contains("storage") || q.contains("espace") {
            return evidenceSummary
        }
        if q.contains("projet") || q.contains("actif") || q.contains("actifs") {
            return "\(primaryOpportunity ?? "Analyse en cours")"
        }
        if q.contains("inutilisé") || q.contains("dormant") || q.contains("tool") || q.contains("outil") {
            return "\(primaryRisk ?? "Aucun outil inutilisé détecté.")"
        }
        if q.contains("optimiser") || q.contains("optimisation") || q.contains("améliorer") {
            return "\(recommendedAction ?? "Tout est optimisé.") — \(estimatedGain ?? "")"
        }
        if q.contains("changé") || q.contains("evolution") || q.contains("hier") || q.contains("nouveau") {
            return lastChangeSummary
        }
        if q.contains("meilleur") || q.contains("impact") || q.contains("maintenant") || q.contains("priorité") {
            return "\(headline) \(recommendedAction ?? "Aucune action prioritaire.") Confiance Φ \(Int(confidencePhi * 100))%"
        }
        return "\(headline) \(globalAssessment) \(evidenceSummary)"
    }
}
