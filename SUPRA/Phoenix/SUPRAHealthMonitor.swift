import Foundation
import Combine

// MARK: - Ω5.2 — Health Monitor
//
// The Health Monitor continuously observes Runtime State (Authority II)
// and Mission Continuity (Authority III) to produce health reports,
// detect degradation, and emit health events.
//
// Composition:
//   Authority II (Runtime State) → reads session state
//   Authority III (Continuity)   → reads health, checkpoints
//   Ω4.D (Orchestration)         → reads dependency graph
//   Ω4.D (Intelligence)          → reads anomalies
//   Ω5.1 (Mission Executor)      → reads execution status
//
// Ω5.2 does NOT own any Authority responsibility.

// MARK: - Health Status Level

/// Health status severity levels for the executive runtime.
public enum SUPRAHealthLevel: String, Sendable, Codable, Comparable {
    case healthy = "HEALTHY"
    case nominal = "NOMINAL"
    case degraded = "DEGRADED"
    case critical = "CRITICAL"
    case unresponsive = "UNRESPONSIVE"

    public static func < (lhs: SUPRAHealthLevel, rhs: SUPRAHealthLevel) -> Bool {
        let order: [SUPRAHealthLevel] = [.healthy, .nominal, .degraded, .critical, .unresponsive]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

// MARK: - Health Indicator

/// A single health indicator with a name, value, and threshold.
public struct SUPRAHealthIndicator: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let name: String
    public let value: Double
    public let threshold: Double
    public let unit: String
    public let status: SUPRAHealthLevel
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        name: String,
        value: Double,
        threshold: Double,
        unit: String = "",
        status: SUPRAHealthLevel,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.threshold = threshold
        self.unit = unit
        self.status = status
        self.timestamp = timestamp
    }
}

// MARK: - Health Report

/// A comprehensive health report combining all indicator statuses.
public struct SUPRAHealthReport: Sendable {
    public let timestamp: Date
    public let overallLevel: SUPRAHealthLevel
    public let indicators: [SUPRAHealthIndicator]
    public let sessionState: SUPRAExecutionState
    public let continuityHealth: SUPRASessionHealth
    public let checkpointCount: Int
    public let recoveryCount: Int
    public let anomalyCount: Int
    public var isHealthy: Bool { overallLevel < .degraded }

    public init(
        timestamp: Date = Date(),
        overallLevel: SUPRAHealthLevel = .healthy,
        indicators: [SUPRAHealthIndicator] = [],
        sessionState: SUPRAExecutionState = .idle,
        continuityHealth: SUPRASessionHealth = .healthy,
        checkpointCount: Int = 0,
        recoveryCount: Int = 0,
        anomalyCount: Int = 0
    ) {
        self.timestamp = timestamp
        self.overallLevel = overallLevel
        self.indicators = indicators
        self.sessionState = sessionState
        self.continuityHealth = continuityHealth
        self.checkpointCount = checkpointCount
        self.recoveryCount = recoveryCount
        self.anomalyCount = anomalyCount
    }

    public var summary: String {
        """
        Health: \(overallLevel.rawValue) (\(isHealthy ? "OK" : "ATTENTION"))
        Session: \(sessionState.rawValue) | Continuity: \(continuityHealth.rawValue)
        Checkpoints: \(checkpointCount) | Recoveries: \(recoveryCount)
        Anomalies: \(anomalyCount) | Indicators: \(indicators.count)
        """
    }
}

// MARK: - Health Alert

/// A health alert emitted when a threshold is breached.
public struct SUPRAHealthAlert: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let level: SUPRAHealthLevel
    public let message: String
    public let source: String
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        level: SUPRAHealthLevel,
        message: String,
        source: String = "",
        timestamp: Date = Date()
    ) {
        self.id = id
        self.level = level
        self.message = message
        self.source = source
        self.timestamp = timestamp
    }
}

// MARK: - Health Monitor

/// Observes Runtime State (Authority II) and Mission Continuity (Authority III)
/// to produce health reports and detect degraded conditions.
@MainActor
public final class SUPRAHealthMonitor: ObservableObject, Sendable {

    public static let shared = SUPRAHealthMonitor()

    // MARK: - Published State

    /// The latest health report.
    @Published public private(set) var latestReport: SUPRAHealthReport?

    /// Active health alerts.
    @Published public private(set) var activeAlerts: [SUPRAHealthAlert] = []

    /// Whether monitoring is active.
    @Published public private(set) var isMonitoring: Bool = false

    /// Total alerts emitted.
    @Published public private(set) var alertsEmitted: Int = 0

    // MARK: - Internal

    private var monitorTask: Task<Void, Never>?
    private let stateAuthority = SUPRAExecutionStateManager.shared
    private let continuityEngine = SUPRASessionContinuityEngine.shared
    private let intelligence = SUPRARuntimeIntelligence.shared
    private let logger = SUPRARuntimeLogger.shared
    private let runtimeEvents = SUPRARuntimeEvents.shared

    private init() {}

    // MARK: - Monitoring Lifecycle

    /// Starts health monitoring.
    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        monitorTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                guard !Task.isCancelled else { break }
                await self.performHealthCheck()
            }
        }
    }

    /// Stops health monitoring.
    public func stopMonitoring() {
        isMonitoring = false
        monitorTask?.cancel()
        monitorTask = nil
    }

    // MARK: - Health Check

    /// Performs a single health check cycle.
    private func performHealthCheck() {
        // Read from Authority II
        let session = stateAuthority.activeSession
        let sessionState = session?.currentState ?? .idle

        // Read from Authority III
        let continuityHealth = continuityEngine.healthStatus
        let checkpointCount = continuityEngine.checkpointCount
        let recoveryCount = continuityEngine.recoveryCount

        // Read from Ω4.D Intelligence
        let anomalies = intelligence.activeAnomalies
        let anomalyCount = anomalies.count

        // Build health indicators
        var indicators: [SUPRAHealthIndicator] = []

        // Indicator: Session State Health
        let sessionHealthValue = sessionState == .failed || sessionState == .idle ? 0.0 : 1.0
        indicators.append(SUPRAHealthIndicator(
            name: "session.state",
            value: sessionHealthValue,
            threshold: 0.5,
            unit: "ratio",
            status: sessionHealthValue >= 0.5 ? .healthy : .critical
        ))

        // Indicator: Continuity Health
        let continuityHealthValue: Double = {
            switch continuityHealth {
            case .healthy, .restored: return 1.0
            case .degraded: return 0.5
            case .critical, .unresponsive: return 0.0
            }
        }()
        indicators.append(SUPRAHealthIndicator(
            name: "continuity.health",
            value: continuityHealthValue,
            threshold: 0.5,
            unit: "ratio",
            status: continuityHealthValue >= 0.5 ? .healthy : .critical
        ))

        // Indicator: Checkpoint Coverage
        let checkpointValue = checkpointCount > 0 ? 1.0 : 0.0
        indicators.append(SUPRAHealthIndicator(
            name: "checkpoint.coverage",
            value: checkpointValue,
            threshold: 0.0,
            unit: "count",
            status: checkpointValue > 0 ? .healthy : .degraded
        ))

        // Indicator: Recovery Frequency
        let recoveryValue = recoveryCount < 5 ? 1.0 : (recoveryCount < 10 ? 0.5 : 0.0)
        indicators.append(SUPRAHealthIndicator(
            name: "recovery.frequency",
            value: recoveryValue,
            threshold: 0.5,
            unit: "ratio",
            status: recoveryValue >= 0.5 ? .healthy : .critical
        ))

        // Indicator: Anomaly Count
        let anomalyValue = anomalyCount == 0 ? 1.0 : (anomalyCount < 3 ? 0.5 : 0.0)
        indicators.append(SUPRAHealthIndicator(
            name: "anomaly.count",
            value: anomalyValue,
            threshold: 0.5,
            unit: "count",
            status: anomalyValue >= 0.5 ? .healthy : .critical
        ))

        // Determine overall health level
        let overallLevel = indicators.map { $0.status }.min() ?? .healthy

        // Build report
        let report = SUPRAHealthReport(
            timestamp: Date(),
            overallLevel: overallLevel,
            indicators: indicators,
            sessionState: sessionState,
            continuityHealth: continuityHealth,
            checkpointCount: checkpointCount,
            recoveryCount: recoveryCount,
            anomalyCount: anomalyCount
        )

        latestReport = report

        // Check for degraded conditions and emit alerts
        checkForAlerts(report: report)
    }

    // MARK: - Alert Detection

    /// Checks health report for conditions that warrant alerts.
    private func checkForAlerts(report: SUPRAHealthReport) {
        var newAlerts: [SUPRAHealthAlert] = []

        for indicator in report.indicators {
            if indicator.status == .critical {
                newAlerts.append(SUPRAHealthAlert(
                    level: .critical,
                    message: "Health indicator critical: \(indicator.name) = \(indicator.value)",
                    source: "SUPRAHealthMonitor"
                ))
            } else if indicator.status == .degraded {
                newAlerts.append(SUPRAHealthAlert(
                    level: .degraded,
                    message: "Health indicator degraded: \(indicator.name) = \(indicator.value)",
                    source: "SUPRAHealthMonitor"
                ))
            }
        }

        if !newAlerts.isEmpty {
            activeAlerts = newAlerts
            alertsEmitted += newAlerts.count

            for alert in newAlerts {
                logger.log(.error, "Health alert [\(alert.level.rawValue)]: \(alert.message)")
                runtimeEvents.emit(
                    .validationFailed,
                    "Health alert: \(alert.message)",
                    source: "SUPRAHealthMonitor",
                    metadata: [
                        "level": alert.level.rawValue,
                        "message": alert.message
                    ]
                )
            }
        }
    }

    // MARK: - Queries

    /// Returns the health monitor summary.
    public func summary() -> String {
        """
        Health Monitor: \(isMonitoring ? "ACTIVE" : "IDLE")
        Overall: \(latestReport?.overallLevel.rawValue ?? "N/A")
        Healthy: \(latestReport?.isHealthy ?? true)
        Alerts: \(activeAlerts.count) (total: \(alertsEmitted))
        Indicators: \(latestReport?.indicators.count ?? 0)
        """
    }

    // MARK: - Reset

    /// Clears health monitor state.
    public func reset() {
        latestReport = nil
        activeAlerts = []
        isMonitoring = false
        alertsEmitted = 0
    }

    // MARK: - Runtime Integration

    /// Integrates with the PHOENIX Runtime.
    public func integrate(with runtime: PhoenixRuntime) {
        logger.log(.boot, "Health Monitor: integrated with PhoenixRuntime")
    }
}
