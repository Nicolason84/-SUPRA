import Foundation
import Combine

enum RuntimeStabilityLevel: String, Codable, Equatable {
    case healthy = "HEALTHY"
    case warning = "WARNING"
    case critical = "CRITICAL"
}

struct RuntimeStatus: Codable, Equatable {
    let level: RuntimeStabilityLevel
    let isHealthy: Bool
    let summary: String
    let connectionState: RuntimeConnectionState
    let activeAlertCount: Int
    let criticalAlertCount: Int
    let metrics: RuntimeMetricsSnapshot
    let lastUpdated: Date

    static let initial = RuntimeStatus(
        level: .critical,
        isHealthy: false,
        summary: "Runtime status unavailable",
        connectionState: .disconnected,
        activeAlertCount: 0,
        criticalAlertCount: 0,
        metrics: .empty,
        lastUpdated: .distantPast
    )
}

@MainActor
final class HealthMonitor: ObservableObject {
    @Published private(set) var alerts: [AlertModel] = []
    @Published private(set) var status: RuntimeStatus = .initial

    private let detector: HealthAnomalyDetector

    init(detector: HealthAnomalyDetector? = nil) {
        self.detector = detector ?? HealthAnomalyDetector()
    }

    func evaluate(health: RuntimeHealth, metrics: RuntimeMetricsSnapshot) {
        let currentAlerts = detector.analyze(health).filter {
            !($0.title == "Duplicate suppressed" && $0.severity == .info)
        }
        alerts = currentAlerts

        let criticalCount = currentAlerts.filter { $0.severity == .critical }.count
        let warningCount = currentAlerts.filter { $0.severity == .warning }.count

        let level: RuntimeStabilityLevel
        if !health.isConnected
            || health.connectionState == .offline
            || health.connectionState == .disconnected
            || criticalCount > 0
            || metrics.errorEvents > 0
            || metrics.validationFailures > 0 {
            level = .critical
        } else if warningCount > 0
            || health.connectionState == .degraded
            || health.lastSyncDurationMs > 5_000 {
            level = .warning
        } else {
            level = .healthy
        }

        let summary: String
        switch level {
        case .healthy:
            summary = "Runtime healthy with \(metrics.totalEvents) observed events"
        case .warning:
            summary = "Runtime degraded with \(warningCount) warning alert(s)"
        case .critical:
            summary = "Runtime critical with \(criticalCount) critical alert(s)"
        }

        status = RuntimeStatus(
            level: level,
            isHealthy: level == .healthy,
            summary: summary,
            connectionState: health.connectionState,
            activeAlertCount: currentAlerts.count,
            criticalAlertCount: criticalCount,
            metrics: metrics,
            lastUpdated: Date()
        )
    }
}
