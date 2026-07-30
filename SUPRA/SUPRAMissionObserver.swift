import Foundation
import Combine

enum ObservationType: String, Codable {
    case memoryStale = "MEMORY_STALE"
    case memoryDisconnected = "MEMORY_DISCONNECTED"
    case resourceHighLoad = "RESOURCE_HIGH_LOAD"
    case resourceCritical = "RESOURCE_CRITICAL"
    case runtimeOffline = "RUNTIME_OFFLINE"
    case runtimeDegraded = "RUNTIME_DEGRADED"
    case intelligenceAnomaly = "INTELLIGENCE_ANOMALY"
    case missionBlocked = "MISSION_BLOCKED"
    case optimizationAvailable = "OPTIMIZATION_AVAILABLE"
    case snapshotStale = "SNAPSHOT_STALE"
    case conflictDetected = "CONFLICT_DETECTED"
}

struct ObservationEvent: Identifiable {
    let id: UUID
    let type: ObservationType
    let title: String
    let detail: String
    let source: String
    let confidence: Double
    let observedAt: Date
}

@MainActor
final class SUPRAMissionObserver: ObservableObject {
    static let shared = SUPRAMissionObserver()

    @Published private(set) var observations: [ObservationEvent] = []
    @Published private(set) var lastObservationAt: Date?

    private weak var intelligenceEngine: SUPRAIntelligenceEngine?
    private weak var multiMemory: MultiMemoryStore?
    private let governor = SUPRAResourceGovernor.shared
    private let snapshotStore = CAnnoNicoSnapshotStore.shared
    private var lastHash = 0

    private init() {}

    func bind(intelligenceEngine: SUPRAIntelligenceEngine, multiMemory: MultiMemoryStore) {
        self.intelligenceEngine = intelligenceEngine
        self.multiMemory = multiMemory
    }

    func observe() -> [ObservationEvent] {
        var results: [ObservationEvent] = []

        results.append(contentsOf: observeMemory())
        results.append(contentsOf: observeResources())
        results.append(contentsOf: observeIntelligence())
        results.append(contentsOf: observeSnapshot())

        observations = results
        lastObservationAt = Date()
        return results
    }

    func observeIfChanged() -> [ObservationEvent] {
        let hash = computeHash()
        guard hash != lastHash else { return observations }
        lastHash = hash
        return observe()
    }

    private func computeHash() -> Int {
        var h = Hasher()
        h.combine(multiMemory?.snapshot.lastUpdated)
        h.combine(governor.snapshot.timestamp)
        h.combine(intelligenceEngine?.state.computedAt)
        h.combine(snapshotStore.state?.cachedAt)
        return h.finalize()
    }

    private func observeMemory() -> [ObservationEvent] {
        var events: [ObservationEvent] = []
        for mem in multiMemory?.snapshot.memories ?? [] {
            if !mem.isConnected {
                events.append(ObservationEvent(
                    id: UUID(), type: .memoryDisconnected,
                    title: "\(mem.name) disconnected",
                    detail: "Memory source \(mem.name) is not reachable",
                    source: "MultiMemoryStore", confidence: 0.9,
                    observedAt: Date()))
            } else if mem.confidence < 0.5 {
                events.append(ObservationEvent(
                    id: UUID(), type: .memoryStale,
                    title: "\(mem.name) confidence low",
                    detail: "Confidence \(Int(mem.confidence * 100))% below threshold",
                    source: "MultiMemoryStore", confidence: mem.confidence,
                    observedAt: Date()))
            }
            for anomaly in mem.anomalies {
                events.append(ObservationEvent(
                    id: UUID(), type: .conflictDetected,
                    title: "\(mem.name) anomaly",
                    detail: anomaly,
                    source: "MultiMemoryStore", confidence: 0.8,
                    observedAt: Date()))
            }
        }
        return events
    }

    private func observeResources() -> [ObservationEvent] {
        let snap = governor.snapshot
        if snap.isCritical {
            return [ObservationEvent(
                id: UUID(), type: .resourceCritical,
                title: "Resources critical",
                detail: "CPU \(Int(snap.cpuUsage * 100))% / RAM \(Int(snap.ramFraction * 100))%",
                source: "SUPRAResourceGovernor", confidence: 0.95,
                observedAt: Date())]
        }
        if snap.isHighLoad {
            return [ObservationEvent(
                id: UUID(), type: .resourceHighLoad,
                title: "Resources high load",
                detail: "CPU \(Int(snap.cpuUsage * 100))% / RAM \(Int(snap.ramFraction * 100))%",
                source: "SUPRAResourceGovernor", confidence: 0.85,
                observedAt: Date())]
        }
        if snap.isIdle {
            return [ObservationEvent(
                id: UUID(), type: .optimizationAvailable,
                title: "System idle — optimization window",
                detail: "CPU \(Int(snap.cpuUsage * 100))% — resources available",
                source: "SUPRAResourceGovernor", confidence: 0.9,
                observedAt: Date())]
        }
        return []
    }

    private func observeIntelligence() -> [ObservationEvent] {
        guard let s = intelligenceEngine?.state else { return [] }
        if s.anomalyCount > 3 {
            return [ObservationEvent(
                id: UUID(), type: .intelligenceAnomaly,
                title: "\(s.anomalyCount) anomalies detected",
                detail: "Intelligence engine reports \(s.anomalyCount) active anomalies",
                source: "SUPRAIntelligenceEngine", confidence: 0.9,
                observedAt: Date())]
        }
        if s.healthScore < 0.4 {
            return [ObservationEvent(
                id: UUID(), type: .intelligenceAnomaly,
                title: "System health critical",
                detail: "Health score \(Int(s.healthScore * 100))%",
                source: "SUPRAIntelligenceEngine", confidence: 0.85,
                observedAt: Date())]
        }
        return []
    }

    private func observeSnapshot() -> [ObservationEvent] {
        guard let state = snapshotStore.state else {
            return [ObservationEvent(
                id: UUID(), type: .snapshotStale,
                title: "CAnnoNico cache empty",
                detail: "No snapshot available — refresh needed",
                source: "CAnnoNicoSnapshotStore", confidence: 1.0,
                observedAt: Date())]
        }
        if state.isStale {
            return [ObservationEvent(
                id: UUID(), type: .snapshotStale,
                title: "CAnnoNico cache stale",
                detail: "\(Int(snapshotStore.age))s since last refresh",
                source: "CAnnoNicoSnapshotStore", confidence: 0.9,
                observedAt: Date())]
        }
        return []
    }
}
