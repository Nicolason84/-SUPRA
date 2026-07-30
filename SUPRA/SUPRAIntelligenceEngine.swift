import Foundation
import Combine

@MainActor
final class SUPRAIntelligenceEngine: ObservableObject {
    static let shared = SUPRAIntelligenceEngine()

    @Published private(set) var state = SUPRAIntelligenceState.initial

    private let governor = SUPRAResourceGovernor.shared
    private let scheduler = SUPRAScheduler.shared
    private let snapshotStore = CAnnoNicoSnapshotStore.shared
    private weak var multiMemory: MultiMemoryStore?
    private weak var missionStore: MissionStore?
    private var lastInputHash: Int?
    private var cancellables = Set<AnyCancellable>()
    private var multiMemoryCancellable: AnyCancellable?
    private var missionStoreCancellable: AnyCancellable?

    private init() {
        subscribe()
    }

    func refresh() {
        compute()
    }

    func bind(multiMemory: MultiMemoryStore, missionStore: MissionStore) {
        self.multiMemory = multiMemory
        self.missionStore = missionStore
        multiMemoryCancellable = multiMemory.$snapshot.sink { [weak self] _ in
            self?.computeIfChanged()
        }
        missionStoreCancellable = missionStore.$missions.sink { [weak self] _ in
            self?.computeIfChanged()
        }
        computeIfChanged()
    }

    private func subscribe() {
        governor.$snapshot.sink { [weak self] _ in self?.computeIfChanged() }.store(in: &cancellables)
        snapshotStore.$state.sink { [weak self] _ in self?.computeIfChanged() }.store(in: &cancellables)
    }

    private func computeIfChanged() {
        let hash = inputHash()
        if hash != lastInputHash {
            lastInputHash = hash
            compute()
        }
    }

    private func inputHash() -> Int {
        var hasher = Hasher()
        hasher.combine(multiMemory?.snapshot.lastUpdated)
        hasher.combine(governor.snapshot.cpuUsage)
        hasher.combine(governor.snapshot.ramFraction)
        hasher.combine(snapshotStore.state?.cachedAt)
        hasher.combine(missionStore?.missions.count ?? 0)
        return hasher.finalize()
    }

    private func compute() {
        let start = Date()

        var insights: [SUPRAInsight] = []
        insights.append(contentsOf: healthInsights())
        insights.append(contentsOf: anomalyInsights())
        insights.append(contentsOf: resourceInsights())
        insights.append(contentsOf: memoryInsights())

        let healthScore = calculateHealthScore(insights: insights)
        let confidenceScore = calculateConfidenceScore()
        let priorityScore = calculatePriorityScore(insights: insights)
        let anomalyCount = insights.filter { $0.category == .anomaly }.count
        let nextAction = determineNextAction(insights: insights)

        let duration = Int(Date().timeIntervalSince(start) * 1000)

        state = SUPRAIntelligenceState(
            healthScore: healthScore,
            confidenceScore: confidenceScore,
            priorityScore: priorityScore,
            anomalyCount: anomalyCount,
            insights: insights,
            nextBestAction: nextAction,
            computedAt: Date(),
            computeDurationMs: duration
        )
    }

    private func healthInsights() -> [SUPRAInsight] {
        let mmHealth = multiMemory?.snapshot.globalHealth ?? "initializing"
        var result: [SUPRAInsight] = []

        switch mmHealth {
        case "critical":
            result.append(SUPRAInsight(id: "health_critical", category: .health, severity: .critical, confidence: 0.95, message: "MultiMemory health is critical", suggestedAction: "Inspect memory source connectivity"))
        case "degraded":
            result.append(SUPRAInsight(id: "health_degraded", category: .health, severity: .warning, confidence: 0.85, message: "MultiMemory health is degraded", suggestedAction: "Review memory source status"))
        default:
            result.append(SUPRAInsight(id: "health_ok", category: .health, severity: .info, confidence: 0.9, message: "MultiMemory health is \(mmHealth)", suggestedAction: nil))
        }

        return result
    }

    private func anomalyInsights() -> [SUPRAInsight] {
        var result: [SUPRAInsight] = []

        let mm = multiMemory?.snapshot ?? MultiMemorySnapshot(
            memories: [],
            globalHealth: "critical",
            lastUpdated: .distantPast
        )
        for memory in mm.memories where !memory.isConnected {
            result.append(SUPRAInsight(
                id: "mm_disconnected_\(memory.id)",
                category: .anomaly,
                severity: .warning,
                confidence: 0.9,
                message: "\(memory.name) memory source is disconnected",
                suggestedAction: "Check \(memory.name) data source and refresh"
            ))
        }
        for memory in mm.memories {
            for anomaly in memory.anomalies {
                result.append(SUPRAInsight(
                    id: "mm_anomaly_\(memory.id)_\(anomaly.prefix(20))",
                    category: .anomaly,
                    severity: .warning,
                    confidence: 0.8,
                    message: "\(memory.name): \(anomaly)",
                    suggestedAction: "Inspect \(memory.name) source"
                ))
            }
        }

        if snapshotStore.state == nil {
            result.append(SUPRAInsight(id: "cannonico_no_cache", category: .anomaly, severity: .warning, confidence: 1.0, message: "CAnnoNico cache is empty", suggestedAction: "Trigger snapshot refresh"))
        } else if snapshotStore.state!.isStale {
            result.append(SUPRAInsight(id: "cannonico_stale", category: .anomaly, severity: .info, confidence: 0.9, message: "CAnnoNico cache is stale (\(Int(snapshotStore.age))s)", suggestedAction: nil))
        }

        let blocked = missionStore?.missions.filter { $0.status == .blocked }.count ?? 0
        if blocked > 0 {
            result.append(SUPRAInsight(id: "missions_blocked", category: .anomaly, severity: blocked > 3 ? .critical : .warning, confidence: 0.85, message: "\(blocked) missions are blocked", suggestedAction: "Review blocked missions and resolve dependencies"))
        }

        return result
    }

    private func resourceInsights() -> [SUPRAInsight] {
        var result: [SUPRAInsight] = []
        let g = governor.snapshot

        if g.isCritical {
            result.append(SUPRAInsight(id: "resource_critical", category: .priority, severity: .critical, confidence: 0.95, message: "CPU (\(Int(g.cpuUsage * 100))%) / RAM (\(Int(g.ramFraction * 100))%) critical", suggestedAction: "Pause all non-essential tasks immediately"))
        } else if g.isHighLoad {
            result.append(SUPRAInsight(id: "resource_high", category: .priority, severity: .warning, confidence: 0.85, message: "High load: CPU \(Int(g.cpuUsage * 100))%, RAM \(Int(g.ramFraction * 100))%", suggestedAction: "Reduce background workers and defer intensive tasks"))
        }

        if scheduler.isPaused {
            result.append(SUPRAInsight(id: "scheduler_paused", category: .health, severity: .info, confidence: 1.0, message: "Scheduler is paused", suggestedAction: "Resume scheduler when load normalizes"))
        }

        return result
    }

    private func memoryInsights() -> [SUPRAInsight] {
        var result: [SUPRAInsight] = []
        let mm = multiMemory?.snapshot ?? MultiMemorySnapshot(
            memories: [],
            globalHealth: "critical",
            lastUpdated: .distantPast
        )

        let disconnected = mm.memories.filter { !$0.isConnected }.count
        let lowConfidence = mm.memories.filter { $0.confidence < 0.5 }.count

        if disconnected == mm.memories.count {
            result.append(SUPRAInsight(id: "memory_all_down", category: .anomaly, severity: .critical, confidence: 0.95, message: "All memory sources are disconnected", suggestedAction: "Verify MultiMemoryStore registry files exist"))
        }

        if lowConfidence > 0 && lowConfidence <= disconnected {
            result.append(SUPRAInsight(id: "memory_low_confidence", category: .recommendation, severity: .info, confidence: 0.7, message: "\(lowConfidence) memory source(s) have low confidence", suggestedAction: "Refresh data sources"))
        }

        return result
    }

    private func calculateHealthScore(insights: [SUPRAInsight]) -> Double {
        let critical = insights.filter { $0.severity == .critical }.count
        let warnings = insights.filter { $0.severity == .warning }.count
        let total = max(insights.count, 1)
        return Double(total - critical * 3 - warnings) / Double(total)
    }

    private func calculateConfidenceScore() -> Double {
        let memories = multiMemory?.snapshot.memories ?? []
        let mmConfidence = memories.reduce(0) { $0 + $1.confidence }
        let count = max(memories.count, 1)
        return mmConfidence / Double(count)
    }

    private func calculatePriorityScore(insights: [SUPRAInsight]) -> Double {
        let critical = insights.filter { $0.severity == .critical }.count
        let warnings = insights.filter { $0.severity == .warning }.count
        return min(Double(critical * 10 + warnings * 3) / 20.0, 1.0)
    }

    private func determineNextAction(insights: [SUPRAInsight]) -> String? {
        let sorted = insights.sorted { $0.severity > $1.severity }
            .filter { $0.suggestedAction != nil }
        return sorted.first?.suggestedAction
    }
}
