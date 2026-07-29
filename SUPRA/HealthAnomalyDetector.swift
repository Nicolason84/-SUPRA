import Foundation
import Combine

@MainActor
final class HealthAnomalyDetector: ObservableObject {
    @Published var alerts: [AlertModel] = []
    private var maxAlerts = 50

    /// Thresholds for anomaly detection
    private let syncDurationWarningThresholdMs = 5_000
    private let errorCountWarningThreshold = 1
    private let errorCountCriticalThreshold = 5
    private let consecutiveViolationsRequired = 3

    private var violationCounts: [String: Int] = [:]

    func analyze(_ health: RuntimeHealth) -> [AlertModel] {
        var newAlerts: [AlertModel] = []

        newAlerts.append(contentsOf: checkConnectionState(health.connectionState))
        newAlerts.append(contentsOf: checkSyncDuration(health.lastSyncDurationMs))
        newAlerts.append(contentsOf: checkErrorCount(health.errorsSinceLastSync))
        newAlerts.append(contentsOf: checkAgentAvailability(health.agentCount, health.totalProviderCount))
        newAlerts.append(contentsOf: checkProviderAvailability(health.activeProviderCount, health.totalProviderCount))
        newAlerts.append(contentsOf: checkMissionAvailability(health.activeMissionCount))

        for alert in newAlerts {
            addAlert(alert)
        }

        return newAlerts
    }

    func checkConnectionState(_ state: RuntimeConnectionState) -> [AlertModel] {
        switch state {
        case .disconnected:
            return [makeAlert(
                severity: .critical,
                title: "Runtime Disconnected",
                message: "The Runtime connection is down. Executive Boot and Continuity features are unavailable.",
                category: .connection
            )]
        case .offline:
            return [makeAlert(
                severity: .critical,
                title: "Runtime Offline",
                message: "The Runtime is offline. No health monitoring is possible until reconnection.",
                category: .connection
            )]
        case .degraded:
            return [makeAlert(
                severity: .warning,
                title: "Runtime Degraded",
                message: "The Runtime connection is degraded. Some features may be limited.",
                category: .connection
            )]
        case .connecting:
            return [] // Transient state — no alert
        case .connected:
            return [] // Healthy — no alert
        }
    }

    func checkSyncDuration(_ durationMs: Int) -> [AlertModel] {
        guard durationMs > syncDurationWarningThresholdMs else { return [] }
        return [makeAlert(
            severity: .warning,
            title: "Slow Sync",
            message: "Last sync took \(durationMs)ms, exceeding the \(syncDurationWarningThresholdMs)ms threshold. Performance may be degraded.",
            category: .performance
        )]
    }

    func checkErrorCount(_ errors: Int) -> [AlertModel] {
        guard errors > 0 else { return [] }
        let severity: AlertSeverity = errors >= errorCountCriticalThreshold ? .critical : .warning
        return [makeAlert(
            severity: severity,
            title: errors >= errorCountCriticalThreshold ? "Critical Error Count" : "Errors Detected",
            message: "\(errors) error(s) since last sync. \(errors >= errorCountCriticalThreshold ? "Immediate investigation recommended." : "Monitor for recurring errors.")",
            category: .system
        )]
    }

    func checkAgentAvailability(_ active: Int, _ total: Int) -> [AlertModel] {
        guard total > 0, active == 0 else { return [] }
        return [makeAlert(
            severity: .critical,
            title: "No Active Agents",
            message: "All \(total) agent(s) are inactive. Mission execution and continuity features are unavailable.",
            category: .system
        )]
    }

    func checkProviderAvailability(_ active: Int, _ total: Int) -> [AlertModel] {
        guard total > 0, active == 0 else { return [] }
        return [makeAlert(
            severity: .warning,
            title: "No Active Providers",
            message: "All \(total) provider(s) are inactive. Knowledge and capability features are limited.",
            category: .integration
        )]
    }

    func checkMissionAvailability(_ active: Int) -> [AlertModel] {
        guard active == 0 else { return [] }
        return [makeAlert(
            severity: .info,
            title: "No Active Missions",
            message: "No missions are currently active. Use the Mission Center to start a new mission.",
            category: .system
        )]
    }

    private func makeAlert(
        severity: AlertSeverity,
        title: String,
        message: String,
        category: AlertCategory
    ) -> AlertModel {
        // De-duplicate: same title within 60 seconds = repeat, skip
        let recent = alerts.filter {
            $0.title == title && $0.timestamp.timeIntervalSinceNow > -60
        }
        guard recent.isEmpty else { return AlertModel(severity: .info, title: "Duplicate suppressed", message: "") }

        return AlertModel(
            severity: severity,
            title: title,
            message: message,
            category: category
        )
    }

    func acknowledge(_ alertId: UUID) {
        if let index = alerts.firstIndex(where: { $0.id == alertId }) {
            alerts[index].acknowledged = true
        }
    }

    func acknowledgeAll() {
        for i in alerts.indices {
            alerts[i].acknowledged = true
        }
    }

    func clearAcknowledged() {
        alerts.removeAll { $0.acknowledged }
    }

    private func addAlert(_ alert: AlertModel) {
        if alert.title == "Duplicate suppressed" && alert.severity == .info { return }
        alerts.insert(alert, at: 0)
        if alerts.count > maxAlerts {
            alerts = Array(alerts.prefix(maxAlerts))
        }
    }
}
