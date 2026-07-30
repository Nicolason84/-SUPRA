import Foundation
import Combine

struct SUPRAWorldSnapshot {
    let memory: WorldMemorySection
    let runtime: WorldRuntimeSection
    let resources: WorldResourceSection
    let missions: WorldMissionSection
    let intelligence: WorldIntelligenceSection
    let decision: WorldDecisionSection
    let timestamp: Date
}

struct WorldMemorySection {
    let cannonicoSources: Int
    let cannonicoRecovered: Int
    let projectCount: Int
    let filesystemCount: Int
    let multiMemoryHealth: String
}

struct WorldRuntimeSection {
    let isConnected: Bool
    let agentCount: Int
    let activeMissions: Int
    let connectionState: String
    let gatewayConnected: Bool
    let gatewayWorkers: Int
}

struct WorldResourceSection {
    let cpuUsage: Double
    let ramFraction: Double
    let freeDiskGB: Double
    let isHighLoad: Bool
    let isCritical: Bool
    let throttleLevel: String
}

struct WorldMissionSection {
    let total: Int
    let active: Int
    let blocked: Int
    let completed: Int
    let autoQueue: Int
    let supervisionQueue: Int
    let humanQueue: Int
    let executedCount: Int
}

struct WorldIntelligenceSection {
    let healthScore: Double
    let confidenceScore: Double
    let anomalyCount: Int
    let insightCount: Int
    let nextBestAction: String?
}

struct WorldDecisionSection {
    let autonomyLevel: Double
    let autoCount: Int
    let supervisionCount: Int
    let humanCount: Int
    let sovereignCount: Int
}

@MainActor
final class SUPRAWorldModel: ObservableObject {
    static let shared = SUPRAWorldModel()

    @Published private(set) var world: SUPRAWorldSnapshot?
    @Published private(set) var lastUpdated: Date?

    private let access = SUPRACanonicalWorldAccess.shared
    private let intelligenceEngine = SUPRAIntelligenceEngine.shared
    private let proposalEngine = SUPRAMissionProposalEngine.shared
    private let executor = SUPRAMissionExecutor.shared
    private var cancellables = Set<AnyCancellable>()
    private var lastHash = 0

    private init() {
        subscribe()
    }

    func refresh() {
        build()
    }

    private func subscribe() {
        Timer.publish(every: 15, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] (_: Date) in self?.buildIfChanged() }
            .store(in: &cancellables)

        intelligenceEngine.$state
            .sink { [weak self] (_: SUPRAIntelligenceState) in self?.buildIfChanged() }
            .store(in: &cancellables)

        proposalEngine.$autoQueue
            .sink { [weak self] (_: [MissionProposal]) in self?.buildIfChanged() }
            .store(in: &cancellables)

        proposalEngine.$humanQueue
            .sink { [weak self] (_: [MissionProposal]) in self?.buildIfChanged() }
            .store(in: &cancellables)
    }

    private func buildIfChanged() {
        let h = computeHash()
        guard h != lastHash else { return }
        lastHash = h
        build()
    }

    private func computeHash() -> Int {
        var h = Hasher()
        h.combine(intelligenceEngine.state.computedAt)
        h.combine(proposalEngine.autoQueue.count)
        h.combine(proposalEngine.humanQueue.count)
        return h.finalize()
    }

    private func build() {
        let all = access.getAllStates()
        let eng = intelligenceEngine.state
        let prop = proposalEngine

        let sovereign = prop.humanQueue.filter { $0.verdict.authority == .sovereignHumanOnly }.count

        world = SUPRAWorldSnapshot(
            memory: WorldMemorySection(
                cannonicoSources: all.cannonico.sourceCount,
                cannonicoRecovered: all.cannonico.recoveredCount,
                projectCount: all.projects.totalProjects,
                filesystemCount: all.environment.activeDirectories,
                multiMemoryHealth: all.globalHealth
            ),
            runtime: WorldRuntimeSection(
                isConnected: all.runtime.isConnected,
                agentCount: all.runtime.agentCount,
                activeMissions: all.runtime.activeMissions,
                connectionState: all.runtime.connectionState,
                gatewayConnected: all.runtime.gatewayConnected,
                gatewayWorkers: all.runtime.gatewayWorkers
            ),
            resources: WorldResourceSection(
                cpuUsage: all.resources.cpuUsage,
                ramFraction: all.resources.ramFraction,
                freeDiskGB: all.resources.freeDiskGB,
                isHighLoad: all.resources.isHighLoad,
                isCritical: all.resources.isCritical,
                throttleLevel: all.resources.throttleLevel
            ),
            missions: WorldMissionSection(
                total: all.missions.total,
                active: all.missions.active,
                blocked: all.missions.blocked,
                completed: all.missions.completed,
                autoQueue: all.missions.autoQueue,
                supervisionQueue: all.missions.supervisionQueue,
                humanQueue: all.missions.humanQueue,
                executedCount: all.missions.executedCount
            ),
            intelligence: WorldIntelligenceSection(
                healthScore: eng.healthScore,
                confidenceScore: eng.confidenceScore,
                anomalyCount: eng.anomalyCount,
                insightCount: eng.insights.count,
                nextBestAction: eng.nextBestAction
            ),
            decision: WorldDecisionSection(
                autonomyLevel: prop.autoQueue.isEmpty && prop.proposals.isEmpty ? 0
                    : Double(prop.autoQueue.count) / Double(max(prop.proposals.count, 1)),
                autoCount: prop.autoQueue.count,
                supervisionCount: prop.supervisionQueue.count,
                humanCount: prop.humanQueue.count,
                sovereignCount: sovereign
            ),
            timestamp: Date()
        )
        lastUpdated = Date()
    }

    func summary() -> String {
        guard let w = world else { return "World model not ready" }
        return """
        SUPRA WORLD MODEL
        Memory: \(w.memory.cannonicoSources) sources / \(w.memory.cannonicoRecovered) recovered
        Resources: CPU \(Int(w.resources.cpuUsage * 100))% / RAM \(Int(w.resources.ramFraction * 100))%
        Missions: \(w.missions.active) active / \(w.missions.total) total
        Autonomy: \(Int(w.decision.autonomyLevel * 100))%
        """
    }
}
