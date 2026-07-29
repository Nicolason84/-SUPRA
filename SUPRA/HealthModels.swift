import Foundation

// MARK: - Alert Severity

enum AlertSeverity: String, Codable, CaseIterable, Equatable {
    case info = "Info"
    case warning = "Warning"
    case critical = "Critical"

    var icon: String {
        switch self {
        case .info: "info.circle"
        case .warning: "exclamationmark.triangle"
        case .critical: "xmark.octagon.fill"
        }
    }

    var color: String {
        switch self {
        case .info: "blue"
        case .warning: "orange"
        case .critical: "red"
        }
    }
}

// MARK: - Alert Category

enum AlertCategory: String, Codable, CaseIterable, Equatable {
    case connection = "Connection"
    case artifact = "Artifact"
    case performance = "Performance"
    case integration = "Integration"
    case system = "System"
}

// MARK: - Alert Model

struct AlertModel: Identifiable, Equatable, Codable {
    let id: UUID
    let severity: AlertSeverity
    let title: String
    let message: String
    let timestamp: Date
    let category: AlertCategory
    var acknowledged: Bool

    init(
        severity: AlertSeverity,
        title: String,
        message: String,
        timestamp: Date = Date(),
        category: AlertCategory = .system,
        acknowledged: Bool = false
    ) {
        self.id = UUID()
        self.severity = severity
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.category = category
        self.acknowledged = acknowledged
    }
}
