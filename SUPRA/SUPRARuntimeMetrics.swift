import Foundation
import Combine

public struct SUPRAMetricPoint: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let value: Double
    public let unit: String
    public let timestamp: Date
    public let tags: [String: String]

    public init(name: String, value: Double, unit: String = "",
                timestamp: Date = Date(), tags: [String: String] = [:]) {
        self.id = UUID()
        self.name = name
        self.value = value
        self.unit = unit
        self.timestamp = timestamp
        self.tags = tags
    }
}

public struct SUPRAProviderMetrics: Sendable {
    public let providerID: String
    public var totalExecutions: Int
    public var successfulExecutions: Int
    public var failedExecutions: Int
    public var totalDurationMs: Int
    public var avgDurationMs: Int
    public var totalTokensUsed: Int
    public var avgTokensPerExecution: Int
    public var lastExecutedAt: Date?
    public var availability: Double

    public init(providerID: String) {
        self.providerID = providerID
        self.totalExecutions = 0
        self.successfulExecutions = 0
        self.failedExecutions = 0
        self.totalDurationMs = 0
        self.avgDurationMs = 0
        self.totalTokensUsed = 0
        self.avgTokensPerExecution = 0
        self.lastExecutedAt = nil
        self.availability = 1.0
    }
}

@MainActor
public final class SUPRARuntimeMetrics: ObservableObject {
    public static let shared = SUPRARuntimeMetrics()

    @Published public private(set) var metrics: [String: SUPRAProviderMetrics] = [:]
    @Published public private(set) var history: [SUPRAMetricPoint] = []

    private let maxHistory = 2000

    private init() {}

    public func recordExecution(providerID: String, success: Bool,
                                 durationMs: Int, tokensUsed: Int) {
        var m = metrics[providerID] ?? SUPRAProviderMetrics(providerID: providerID)
        m.totalExecutions += 1
        if success { m.successfulExecutions += 1 }
        else { m.failedExecutions += 1 }
        m.totalDurationMs += durationMs
        m.avgDurationMs = m.totalDurationMs / max(m.totalExecutions, 1)
        m.totalTokensUsed += tokensUsed
        m.avgTokensPerExecution = m.totalTokensUsed / max(m.totalExecutions, 1)
        m.lastExecutedAt = Date()
        m.availability = Double(m.successfulExecutions) / Double(max(m.totalExecutions, 1))
        metrics[providerID] = m

        let point = SUPRAMetricPoint(
            name: "execution.\(providerID).\(success ? "success" : "failure")",
            value: Double(durationMs),
            unit: "ms",
            tags: ["provider": providerID, "success": "\(success)"]
        )
        history.append(point)
        if history.count > maxHistory {
            history = Array(history.suffix(maxHistory / 2))
        }
    }

    public func recordCustom(name: String, value: Double, unit: String = "",
                               tags: [String: String] = [:]) {
        let point = SUPRAMetricPoint(name: name, value: value, unit: unit, tags: tags)
        history.append(point)
        if history.count > maxHistory {
            history = Array(history.suffix(maxHistory / 2))
        }
    }

    public func metrics(for providerID: String) -> SUPRAProviderMetrics? { metrics[providerID] }

    public func summary() -> String {
        var s = "Runtime Metrics:\n"
        for (id, m) in metrics.sorted(by: { $0.key < $1.key }) {
            s += "  \(id): \(m.totalExecutions) execs, \(String(format: "%.0f", m.availability * 100))% avail, avg \(m.avgDurationMs)ms, \(m.totalTokensUsed) tokens\n"
        }
        return s
    }

    public func recordTelemetry(_ telemetry: TransmissionTelemetry) {
        recordCustom(name: "transmission.gear.\(telemetry.currentGear.rawValue)",
                     value: Double(telemetry.currentGear.rank),
                     unit: "gear",
                     tags: ["gear": telemetry.currentGear.rawValue,
                            "provider": telemetry.currentProviderID])
        recordCustom(name: "transmission.cpu_pressure",
                     value: telemetry.cpuPressure, unit: "%",
                     tags: ["gear": telemetry.currentGear.rawValue])
        recordCustom(name: "transmission.memory_pressure",
                     value: telemetry.memoryPressure, unit: "%",
                     tags: ["gear": telemetry.currentGear.rawValue])
        recordCustom(name: "transmission.queue_depth",
                     value: Double(telemetry.queueDepth), unit: "tasks",
                     tags: ["gear": telemetry.currentGear.rawValue])
        recordCustom(name: "transmission.task_duration",
                     value: Double(telemetry.taskDurationMs), unit: "ms",
                     tags: ["gear": telemetry.currentGear.rawValue])
        recordCustom(name: "transmission.gear_shifts",
                     value: Double(telemetry.gearShiftCount), unit: "count")
        recordCustom(name: "transmission.fallback_count",
                     value: Double(telemetry.fallbackCount), unit: "count")
        recordCustom(name: "transmission.failed_tasks",
                     value: Double(telemetry.failedTaskCount), unit: "count")
    }

    public func transmissionSummary() -> String {
        let gearPoints = history.filter { $0.name.hasPrefix("transmission.gear.") }
        let cpuPoints = history.filter { $0.name == "transmission.cpu_pressure" }
        let durationPoints = history.filter { $0.name == "transmission.task_duration" }
        return """
        Transmission Telemetry:
          Current gear: \(gearPoints.last?.tags["gear"] ?? "none")
          CPU pressure: \(cpuPoints.last.map { "\(Int($0.value * 100))%" } ?? "N/A")
          Task duration: \(durationPoints.last.map { "\(Int($0.value))ms" } ?? "N/A")
          History points: \(history.count)
        """
    }

    public func clear() {
        metrics = [:]
        history = []
    }
}
