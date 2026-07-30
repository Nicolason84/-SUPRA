import Foundation

struct EnvironmentPotential {
    let storageRecoverableEstimate: String
    let cpuOptimizationOpportunity: Bool
    let ramPressureOpportunity: Bool
    let inactiveApplications: Int
    let duplicateCandidates: Int
    let staleProjects: Int
    let unresolvedSources: Int
    let automationCandidates: Int
    let humanDecisionsRequired: Int
    let environmentKnowledgeCoverage: Double

    let storageSource: String
    let cpuSource: String
    let timestamp: Date
    let confidence: Double
    let limits: String

    static func compute(from state: CompleteEnvironmentState, copilot: SUPRAOptimizationCopilot) -> EnvironmentPotential {
        let hw = state.hardware
        let sw = state.software
        let dt = state.data
        let dv = state.developer

        let storageRecoverable: Int
        if let d = dv { storageRecoverable = d.derivedDataSizeMB } else { storageRecoverable = 0 }

        let coverage: Double
        var scored = 0.0
        var total = 0.0
        if hw != nil { scored += 1 }; total += 1
        if sw != nil { scored += 1 }; total += 1
        if dt != nil { scored += 1 }; total += 1
        if dv != nil { scored += 1 }; total += 1
        if state.memory.cannonico.sourceCount > 0 { scored += 1 }; total += 1
        coverage = total > 0 ? scored / total : 0

        return EnvironmentPotential(
            storageRecoverableEstimate: "~\(storageRecoverable)MB (DerivedData)",
            cpuOptimizationOpportunity: hw?.cpuUsage ?? 0 > 0.7,
            ramPressureOpportunity: (hw?.ramUsedGB ?? 0) > (hw?.physicalRAMGB ?? 1) * 0.85,
            inactiveApplications: sw?.applicationCount ?? 0 > 20 ? (sw!.applicationCount - 20) : 0,
            duplicateCandidates: dt?.duplicateCount ?? 0,
            staleProjects: dv?.uncommittedRepos ?? 0,
            unresolvedSources: state.memory.cannonico.references.filter { $0.state != "recovered" }.count,
            automationCandidates: copilot.autoQueue.count,
            humanDecisionsRequired: copilot.humanQueue.count,
            environmentKnowledgeCoverage: coverage,
            storageSource: "DeveloperTwin.DerivedData.size",
            cpuSource: "HardwareTwin.currentCpuUsage",
            timestamp: Date(),
            confidence: copilot.findings.isEmpty ? 0.7 : copilot.findings.map(\.confidence).reduce(0, +) / Double(copilot.findings.count),
            limits: "V1 — estimé, collecte différée, aucun scan système hors des domaines couverts"
        )
    }
}
