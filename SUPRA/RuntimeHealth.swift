import Foundation

struct RuntimeHealth: Equatable {
    var isConnected: Bool = false
    var agentCount: Int = 0
    var activeProviderCount: Int = 0
    var totalProviderCount: Int = 0
    var activeMissionCount: Int = 0
    var lastSyncDate: Date?
    var lastSyncDurationMs: Int = 0
    var fileCount: Int = 0
    var errorsSinceLastSync: Int = 0
    var connectionState: RuntimeConnectionState = .disconnected

    var lastSyncFormatted: String {
        guard let date = lastSyncDate else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var statusIcon: String {
        isConnected ? "circle.fill" : "circle.dashed"
    }

    var statusColor: String {
        isConnected ? "green" : "red"
    }

    static let initial = RuntimeHealth()
}
