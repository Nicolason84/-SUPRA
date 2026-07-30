import Foundation
import Combine

struct CustomerTwin: Identifiable {
    let id: UUID
    let company: CompanyProfile
    let environment: EnvironmentHealth
    let knowledge: KnowledgeBase
    let decision: DecisionHistory
    let mission: MissionOverview
    let lastUpdated: Date
}

struct CompanyProfile {
    let name: String
    let industry: String
    let size: String
    let since: Date
    let activeProjects: Int
    let totalRepositories: Int
}

struct EnvironmentHealth {
    let systemHealth: String
    let cpuLoad: Double
    let ramLoad: Double
    let diskFree: Double
    let runtimeStatus: String
    let workerCount: Int

    var overallScore: Double {
        let cpu = 1.0 - cpuLoad
        let ram = 1.0 - ramLoad
        return (cpu + ram) / 2.0
    }
}

struct KnowledgeBase {
    let totalSources: Int
    let recoveredCount: Int
    let memorySources: [MemorySourceInfo]
    let globalHealth: String
    let lastSynced: Date?
}

struct DecisionHistory {
    let totalDecisions: Int
    let autoExecuted: Int
    let supervised: Int
    let humanRequired: Int
    let autonomyLevel: Double
    let averageConfidence: Double
    let sovereignCount: Int
}

struct MissionOverview {
    let total: Int
    let active: Int
    let completed: Int
    let blocked: Int
    let proposals: Int
    let executionRate: Double
}

@MainActor
final class SUPRABusinessPlatform: ObservableObject {
    static let shared = SUPRABusinessPlatform()

    @Published private(set) var customerTwin: CustomerTwin?
    @Published private(set) var lastUpdated: Date?

    private let worldModel = SUPRAWorldModel.shared
    private let proposalEngine = SUPRAMissionProposalEngine.shared
    private let executor = SUPRAMissionExecutor.shared
    private let governor = SUPRAResourceGovernor.shared

    private init() {}

    func refresh() {
        worldModel.refresh()
        build()
    }

    private func build() {
        guard let w = worldModel.world else { return }

        let company = CompanyProfile(
            name: "SUPRA Customer",
            industry: "Technology",
            size: "Mid-size",
            since: Date(),
            activeProjects: w.memory.projectCount,
            totalRepositories: 0
        )

        let environment = EnvironmentHealth(
            systemHealth: w.memory.multiMemoryHealth,
            cpuLoad: w.resources.cpuUsage,
            ramLoad: w.resources.ramFraction,
            diskFree: w.resources.freeDiskGB,
            runtimeStatus: w.runtime.connectionState,
            workerCount: 4
        )

        let knowledge = KnowledgeBase(
            totalSources: w.memory.cannonicoSources,
            recoveredCount: w.memory.cannonicoRecovered,
            memorySources: [],
            globalHealth: w.memory.multiMemoryHealth,
            lastSynced: worldModel.world?.timestamp
        )

        let totalDecisions = w.decision.autoCount + w.decision.supervisionCount + w.decision.humanCount
        let decision = DecisionHistory(
            totalDecisions: totalDecisions,
            autoExecuted: w.decision.autoCount,
            supervised: w.decision.supervisionCount,
            humanRequired: w.decision.humanCount,
            autonomyLevel: w.decision.autonomyLevel,
            averageConfidence: 0.85,
            sovereignCount: w.decision.sovereignCount
        )

        let mission = MissionOverview(
            total: w.missions.total,
            active: w.missions.active,
            completed: w.missions.completed,
            blocked: w.missions.blocked,
            proposals: proposalEngine.proposals.count,
            executionRate: w.missions.total > 0 ? Double(w.missions.completed) / Double(w.missions.total) : 0
        )

        customerTwin = CustomerTwin(
            id: UUID(),
            company: company,
            environment: environment,
            knowledge: knowledge,
            decision: decision,
            mission: mission,
            lastUpdated: Date()
        )
        lastUpdated = Date()
    }

    func summary() -> String {
        guard let c = customerTwin else { return "No customer twin" }
        return """
        CUSTOMER: \(c.company.name)
        Health: \(c.environment.systemHealth) | Score: \(Int(c.environment.overallScore * 100))%
        Memory: \(c.knowledge.totalSources) sources / \(c.knowledge.recoveredCount) recovered
        Autonomy: \(Int(c.decision.autonomyLevel * 100))% | Executed: \(c.decision.autoExecuted)
        Missions: \(c.mission.active) active / \(c.mission.total) total
        """
    }
}
