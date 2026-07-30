import Foundation
import Combine

struct RuntimeMetricsSnapshot: Equatable, Codable {
    let totalEvents: Int
    let errorEvents: Int
    let validationFailures: Int
    let validationPasses: Int
    let activeMissions: Int
    let activeProviders: Int
    let totalProviders: Int
    let agentCount: Int
    let fileCount: Int
    let lastSyncDurationMs: Int
    let connectionState: RuntimeConnectionState
    let isConnected: Bool
    let lastUpdated: Date

    static let empty = RuntimeMetricsSnapshot(
        totalEvents: 0,
        errorEvents: 0,
        validationFailures: 0,
        validationPasses: 0,
        activeMissions: 0,
        activeProviders: 0,
        totalProviders: 0,
        agentCount: 0,
        fileCount: 0,
        lastSyncDurationMs: 0,
        connectionState: .disconnected,
        isConnected: false,
        lastUpdated: .distantPast
    )
}

@MainActor
final class MetricsCollector: ObservableObject {
    @Published private(set) var snapshot: RuntimeMetricsSnapshot = .empty

    private let runtimeMetrics: SUPRARuntimeMetrics
    private var lastRecordedSnapshot: RuntimeMetricsSnapshot = .empty

    init(runtimeMetrics: SUPRARuntimeMetrics? = nil) {
        self.runtimeMetrics = runtimeMetrics ?? .shared
    }

    func ingest(health: RuntimeHealth, events: [RuntimeEvent]) {
        let next = RuntimeMetricsSnapshot(
            totalEvents: events.count,
            errorEvents: events.filter { $0.type == .error }.count,
            validationFailures: events.filter { $0.type == .validationFailed }.count,
            validationPasses: events.filter { $0.type == .validationPassed }.count,
            activeMissions: health.activeMissionCount,
            activeProviders: health.activeProviderCount,
            totalProviders: health.totalProviderCount,
            agentCount: health.agentCount,
            fileCount: health.fileCount,
            lastSyncDurationMs: health.lastSyncDurationMs,
            connectionState: health.connectionState,
            isConnected: health.isConnected,
            lastUpdated: Date()
        )

        snapshot = next
        recordIfChanged(from: lastRecordedSnapshot, to: next)
        lastRecordedSnapshot = next
    }

    private func recordIfChanged(from previous: RuntimeMetricsSnapshot, to next: RuntimeMetricsSnapshot) {
        guard previous != next else { return }

        runtimeMetrics.recordCustom(
            name: "stability.total_events",
            value: Double(next.totalEvents),
            unit: "count",
            tags: ["connection": next.connectionState.rawValue]
        )
        runtimeMetrics.recordCustom(
            name: "stability.error_events",
            value: Double(next.errorEvents),
            unit: "count",
            tags: ["connection": next.connectionState.rawValue]
        )
        runtimeMetrics.recordCustom(
            name: "stability.active_missions",
            value: Double(next.activeMissions),
            unit: "count"
        )
        runtimeMetrics.recordCustom(
            name: "stability.active_providers",
            value: Double(next.activeProviders),
            unit: "count"
        )
        runtimeMetrics.recordCustom(
            name: "stability.sync_duration",
            value: Double(next.lastSyncDurationMs),
            unit: "ms"
        )
    }
}
