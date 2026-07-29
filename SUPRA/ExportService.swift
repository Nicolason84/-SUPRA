import Foundation
import Combine
import AppKit

// MARK: - ExportService

@MainActor
final class ExportService: ObservableObject {
    @Published private(set) var isExporting = false
    @Published private(set) var lastExportDate: Date?
    @Published private(set) var lastExportPath: String?

    private let state: SUPRACommandCenterState

    init(state: SUPRACommandCenterState = .shared) {
        self.state = state
    }

    // MARK: - Export

    func export(configuration: ExportConfiguration) async -> Bool {
        guard let snapshot = state.snapshot else { return false }

        isExporting = true
        defer { isExporting = false }

        let content = generateContent(snapshot: snapshot, configuration: configuration)
        let panel = NSSavePanel()
        panel.title = "Export Dashboard Data"
        panel.message = "Save \(configuration.format.title) export"
        panel.nameFieldStringValue = "supra-dashboard.\(configuration.format.fileExtension)"
        panel.allowedContentTypes = []
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return false }

        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            lastExportDate = Date()
            lastExportPath = url.path
            return true
        } catch {
            return false
        }
    }

    // MARK: - Content Generation

    private func generateContent(snapshot: CommandCenterSnapshot, configuration: ExportConfiguration) -> String {
        switch configuration.format {
        case .csv:
            return generateCSV(snapshot: snapshot, configuration: configuration)
        case .json:
            return generateJSON(snapshot: snapshot, configuration: configuration)
        case .markdown:
            return generateMarkdown(snapshot: snapshot, configuration: configuration)
        }
    }

    // MARK: - CSV

    private func generateCSV(snapshot: CommandCenterSnapshot, configuration: ExportConfiguration) -> String {
        var lines: [String] = []
        lines.append("Section,Metric,Value")

        if configuration.scope == .all || configuration.scope == .health {
            lines.append("Health,Overall,\(snapshot.health.overall)")
            lines.append("Health,Build,\(snapshot.health.build)")
            lines.append("Health,Runtime,\(snapshot.health.runtime)")
            lines.append("Health,Git,\(snapshot.health.git)")
            lines.append("Health,Agents,\(snapshot.health.agents)")
            lines.append("Health,Storage,\(snapshot.health.storage)")
            lines.append("Health,Capabilities,\(snapshot.health.capabilities)")
            lines.append("Health,Active Projects,\(snapshot.health.activeProjects)")
        }

        if configuration.scope == .all || configuration.scope == .runtime {
            lines.append("Runtime,Connected,\(snapshot.runtime.isConnected)")
            lines.append("Runtime,Agent Count,\(snapshot.runtime.agentCount)")
            lines.append("Runtime,Active Missions,\(snapshot.runtime.activeMissions)")
            lines.append("Runtime,Last Sync,\(snapshot.runtime.lastSync)")
            lines.append("Runtime,Gateway Connected,\(snapshot.runtime.gatewayConnected)")
        }

        if configuration.scope == .all || configuration.scope == .missions {
            lines.append("Missions,Total,\(snapshot.missions.total)")
            lines.append("Missions,Active,\(snapshot.missions.active)")
            lines.append("Missions,Blocked,\(snapshot.missions.blocked)")
            lines.append("Missions,Completed,\(snapshot.missions.completed)")
        }

        if configuration.scope == .all || configuration.scope == .intelligence {
            lines.append("Intelligence,Health Score,\(snapshot.intelligence.healthScore)")
            lines.append("Intelligence,Anomaly Count,\(snapshot.intelligence.anomalyCount)")
            lines.append("Intelligence,Insight Count,\(snapshot.intelligence.insightCount)")
        }

        if configuration.scope == .all || configuration.scope == .resources {
            lines.append("Resources,CPU Usage,\(Int(snapshot.resources.cpuUsage * 100))%")
            lines.append("Resources,RAM Usage,\(Int(snapshot.resources.ramFraction * 100))%")
            lines.append("Resources,Free Disk GB,\(snapshot.resources.freeDiskGB)")
            lines.append("Resources,High Load,\(snapshot.resources.isHighLoad)")
            lines.append("Resources,Critical,\(snapshot.resources.isCritical)")
        }

        if configuration.options.includeTimestamps {
            lines.insert("Section,Metric,Value,Timestamp", at: 0)
            let timestamp = ISO8601DateFormatter().string(from: snapshot.lastUpdated)
            lines = lines.map { line in
                line.hasPrefix("Section,") ? line : "\(line),\(timestamp)"
            }
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - JSON

    private func generateJSON(snapshot: CommandCenterSnapshot, configuration: ExportConfiguration) -> String {
        var dict: [String: Any] = [:]

        if configuration.options.includeTimestamps {
            dict["exportedAt"] = ISO8601DateFormatter().string(from: Date())
            dict["snapshotDate"] = ISO8601DateFormatter().string(from: snapshot.lastUpdated)
        }

        dict["format"] = configuration.format.rawValue
        dict["scope"] = configuration.scope.rawValue

        if configuration.scope == .all || configuration.scope == .health {
            dict["health"] = [
                "overall": snapshot.health.overall,
                "build": snapshot.health.build,
                "runtime": snapshot.health.runtime,
                "git": snapshot.health.git,
                "agents": snapshot.health.agents,
                "storage": snapshot.health.storage,
                "capabilities": snapshot.health.capabilities,
                "activeProjects": snapshot.health.activeProjects
            ]
        }

        if configuration.scope == .all || configuration.scope == .runtime {
            dict["runtime"] = [
                "isConnected": snapshot.runtime.isConnected,
                "agentCount": snapshot.runtime.agentCount,
                "activeMissions": snapshot.runtime.activeMissions,
                "lastSync": snapshot.runtime.lastSync,
                "gatewayConnected": snapshot.runtime.gatewayConnected
            ]
        }

        if configuration.scope == .all || configuration.scope == .missions {
            dict["missions"] = [
                "total": snapshot.missions.total,
                "active": snapshot.missions.active,
                "blocked": snapshot.missions.blocked,
                "completed": snapshot.missions.completed
            ]
        }

        if configuration.scope == .all || configuration.scope == .intelligence {
            dict["intelligence"] = [
                "healthScore": snapshot.intelligence.healthScore,
                "anomalyCount": snapshot.intelligence.anomalyCount,
                "insightCount": snapshot.intelligence.insightCount
            ]
        }

        if configuration.scope == .all || configuration.scope == .resources {
            dict["resources"] = [
                "cpuUsage": snapshot.resources.cpuUsage,
                "ramFraction": snapshot.resources.ramFraction,
                "freeDiskGB": snapshot.resources.freeDiskGB,
                "isHighLoad": snapshot.resources.isHighLoad,
                "isCritical": snapshot.resources.isCritical
            ]
        }

        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }

    // MARK: - Markdown

    private func generateMarkdown(snapshot: CommandCenterSnapshot, configuration: ExportConfiguration) -> String {
        var lines: [String] = []
        lines.append("# SUPRA Dashboard Export")
        lines.append("")

        if configuration.options.includeTimestamps {
            lines.append("**Exported**: \(Date().formatted(date: .complete, time: .standard))")
            lines.append("**Snapshot**: \(snapshot.lastUpdated.formatted(date: .complete, time: .standard))")
            lines.append("")
        }

        if configuration.scope == .all || configuration.scope == .health {
            lines.append("## System Health")
            lines.append("")
            lines.append("| Metric | Value |")
            lines.append("|--------|-------|")
            lines.append("| Overall | \(snapshot.health.overall) |")
            lines.append("| Build | \(snapshot.health.build) |")
            lines.append("| Runtime | \(snapshot.health.runtime) |")
            lines.append("| Git | \(snapshot.health.git) |")
            lines.append("| Agents | \(snapshot.health.agents) |")
            lines.append("| Storage | \(snapshot.health.storage) |")
            lines.append("| Capabilities | \(snapshot.health.capabilities) |")
            lines.append("| Active Projects | \(snapshot.health.activeProjects) |")
            lines.append("")
        }

        if configuration.scope == .all || configuration.scope == .runtime {
            lines.append("## Runtime")
            lines.append("")
            lines.append("| Metric | Value |")
            lines.append("|--------|-------|")
            lines.append("| Connected | \(snapshot.runtime.isConnected) |")
            lines.append("| Agent Count | \(snapshot.runtime.agentCount) |")
            lines.append("| Active Missions | \(snapshot.runtime.activeMissions) |")
            lines.append("| Last Sync | \(snapshot.runtime.lastSync) |")
            lines.append("| Gateway Connected | \(snapshot.runtime.gatewayConnected) |")
            lines.append("")
        }

        if configuration.scope == .all || configuration.scope == .missions {
            lines.append("## Missions")
            lines.append("")
            lines.append("| Metric | Value |")
            lines.append("|--------|-------|")
            lines.append("| Total | \(snapshot.missions.total) |")
            lines.append("| Active | \(snapshot.missions.active) |")
            lines.append("| Blocked | \(snapshot.missions.blocked) |")
            lines.append("| Completed | \(snapshot.missions.completed) |")
            lines.append("")
        }

        if configuration.scope == .all || configuration.scope == .intelligence {
            lines.append("## Intelligence")
            lines.append("")
            lines.append("| Metric | Value |")
            lines.append("|--------|-------|")
            lines.append("| Health Score | \(String(format: "%.2f", snapshot.intelligence.healthScore)) |")
            lines.append("| Anomaly Count | \(snapshot.intelligence.anomalyCount) |")
            lines.append("| Insight Count | \(snapshot.intelligence.insightCount) |")
            lines.append("")
        }

        if configuration.scope == .all || configuration.scope == .resources {
            lines.append("## Resources")
            lines.append("")
            lines.append("| Metric | Value |")
            lines.append("|--------|-------|")
            lines.append("| CPU Usage | \(Int(snapshot.resources.cpuUsage * 100))% |")
            lines.append("| RAM Usage | \(Int(snapshot.resources.ramFraction * 100))% |")
            lines.append("| Free Disk GB | \(snapshot.resources.freeDiskGB) |")
            lines.append("| High Load | \(snapshot.resources.isHighLoad) |")
            lines.append("| Critical | \(snapshot.resources.isCritical) |")
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }
}
