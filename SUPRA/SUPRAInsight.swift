import Foundation

enum InsightCategory: String, Codable {
    case health = "Health"
    case anomaly = "Anomaly"
    case priority = "Priority"
    case recommendation = "Recommendation"
}

enum InsightSeverity: String, Codable, Comparable {
    case info = "Info"
    case warning = "Warning"
    case critical = "Critical"

    static func < (lhs: InsightSeverity, rhs: InsightSeverity) -> Bool {
        let order: [InsightSeverity] = [.info, .warning, .critical]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

struct SUPRAInsight: Identifiable {
    let id: String
    let category: InsightCategory
    let severity: InsightSeverity
    let confidence: Double
    let message: String
    let suggestedAction: String?
}
