import Foundation
import Combine

struct DemoResult: Identifiable {
    let id: UUID
    let phase: String
    let status: String
    let detail: String
    let durationMs: Int
}

@MainActor
final class ExecutiveDemoMode: ObservableObject {
    static let shared = ExecutiveDemoMode()

    @Published private(set) var results: [DemoResult] = []
    @Published private(set) var isRunning = false
    @Published private(set) var startedAt: Date?
    @Published private(set) var completedAt: Date?

    private let worldModel = SUPRAWorldModel.shared
    private let businessPlatform = SUPRABusinessPlatform.shared
    private let proposalEngine = SUPRAMissionProposalEngine.shared
    private let observer = SUPRAMissionObserver.shared
    private let intelligenceGraph = SUPRAIntelligenceGraph.shared
    private let workerFabric = SUPRAWorkerFabric.shared
    private let executor = SUPRAMissionExecutor.shared

    private init() {}

    func runFullDemo() async {
        guard !isRunning else { return }
        isRunning = true
        results = []
        startedAt = Date()

        await runPhase("Environment Analysis", phase: 1) {
            worldModel.refresh()
            return worldModel.world != nil
        }

        await runPhase("Memory Synchronization", phase: 2) {
            let worker = self.workerFabric.memoryWorker
            let result = await worker.work()
            return result.success
        }

        await runPhase("Problem Detection", phase: 3) {
            let observations = self.observer.observe()
            return !observations.isEmpty
        }

        await runPhase("Mission Proposals", phase: 4) {
            self.proposalEngine.refresh()
            return !self.proposalEngine.proposals.isEmpty
        }

        await runPhase("Decision Classification", phase: 5) {
            return self.proposalEngine.autoQueue.count > 0
                || self.proposalEngine.supervisionQueue.count > 0
                || self.proposalEngine.humanQueue.count > 0
        }

        await runPhase("Auto Execution", phase: 6) {
            for proposal in self.proposalEngine.autoQueue.prefix(3) {
                _ = self.executor.execute(proposal)
            }
            return self.executor.autoExecutedCount > 0
        }

        await runPhase("Business Intelligence", phase: 7) {
            self.businessPlatform.refresh()
            return self.businessPlatform.customerTwin != nil
        }

        await runPhase("Value Calculation", phase: 8) {
            guard let w = self.worldModel.world else { return false }
            let metrics = SUPRAPricingModel.valueMetrics(from: w)
            let tier = SUPRAPricingModel.recommendedTier(for: metrics)
            return tier != .explorer || metrics.compositeScore > 0
        }

        await runPhase("Intelligence Graph", phase: 9) {
            self.intelligenceGraph.refresh()
            return self.intelligenceGraph.nodeCount > 0
        }

        completedAt = Date()
        isRunning = false
    }

    private func runPhase(_ name: String, phase: Int, action: () async -> Bool) async {
        let start = Date()
        let success = await action()
        let duration = Int(Date().timeIntervalSince(start) * 1000)
        results.append(DemoResult(
            id: UUID(), phase: name,
            status: success ? "✅ PASS" : "⚠️ DEGRADED",
            detail: success ? "\(duration)ms" : "Completed with warnings",
            durationMs: duration
        ))
    }

    var totalDurationMs: Int {
        guard let start = startedAt, let end = completedAt else { return 0 }
        return Int(end.timeIntervalSince(start) * 1000)
    }

    var passCount: Int {
        results.filter { $0.status.contains("PASS") }.count
    }

    var summary: String {
        guard !results.isEmpty else { return "No demo run yet" }
        return """
        SUPRA EXECUTIVE DEMO
        Phases: \(passCount)/\(results.count) passed
        Duration: \(totalDurationMs)ms
        Environment: \(results.first(where: { $0.phase == "Environment Analysis" })?.status ?? "—")
        Proposals: \(results.first(where: { $0.phase == "Mission Proposals" })?.status ?? "—")
        Auto Execution: \(results.first(where: { $0.phase == "Auto Execution" })?.status ?? "—")
        Value: \(results.first(where: { $0.phase == "Value Calculation" })?.status ?? "—")
        """
    }
}
