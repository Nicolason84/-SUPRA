import Foundation

// MARK: - Dashboard Metric

/// A single metric for the executive dashboard.
public struct SUPRADashboardMetric: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let name: String
    public let value: Double
    public let unit: String
    public let color: String
    public let icon: String
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        name: String,
        value: Double,
        unit: String = "",
        color: String = "",
        icon: String = "",
        timestamp: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.unit = unit
        self.color = color
        self.icon = icon
        self.timestamp = timestamp
    }
}

// MARK: - Dashboard Data

/// Complete dashboard data for the Executive Dashboard.
public struct SUPRADashboardData: Sendable {
    public let timestamp: Date
    public let overallStatus: String
    public let uptime: TimeInterval
    public let metrics: [SUPRADashboardMetric]
    public let missionStatus: String
    public let executionProgress: Double
    public let systemHealth: String
    public let activeTasks: Int
    public let completedTasks: Int
    public let failedTasks: Int
    public let activeAnomalies: Int
    public let activeAlerts: Int
    public let checkpointCount: Int
    public let recoveryCount: Int

    public init(
        timestamp: Date = Date(),
        overallStatus: String = "HEALTHY",
        uptime: TimeInterval = 0,
        metrics: [SUPRADashboardMetric] = [],
        missionStatus: String = "IDLE",
        executionProgress: Double = 0,
        systemHealth: String = "HEALTHY",
        activeTasks: Int = 0,
        completedTasks: Int = 0,
        failedTasks: Int = 0,
        activeAnomalies: Int = 0,
        activeAlerts: Int = 0,
        checkpointCount: Int = 0,
        recoveryCount: Int = 0
    ) {
        self.timestamp = timestamp
        self.overallStatus = overallStatus
        self.uptime = uptime
        self.metrics = metrics
        self.missionStatus = missionStatus
        self.executionProgress = executionProgress
        self.systemHealth = systemHealth
        self.activeTasks = activeTasks
        self.completedTasks = completedTasks
        self.failedTasks = failedTasks
        self.activeAnomalies = activeAnomalies
        self.activeAlerts = activeAlerts
        self.checkpointCount = checkpointCount
        self.recoveryCount = recoveryCount
    }

    public var summary: String {
        """
        ═════════════════════════════════════════════
        EXECUTIVE DASHBOARD DATA
        ═════════════════════════════════════════════
        Status: \(overallStatus)
        Uptime: \(Int(uptime))s
        Tasks: \(completedTasks)/\(completedTasks + failedTasks) completed
        Health: \(systemHealth)
        Anomalies: \(activeAnomalies)
        Alerts: \(activeAlerts)
        ═════════════════════════════════════════════
        """
    }
}