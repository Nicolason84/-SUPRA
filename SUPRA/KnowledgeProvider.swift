import Foundation

protocol KnowledgeProvider {
    var sourceType: KnowledgeSourceType { get }
    var displayName: String { get }

    func discover() async -> [KnowledgeObject]
    func relations() async -> [KnowledgeRelation]
}

extension KnowledgeProvider {
    func ensureId(_ base: String) -> String {
        "\(sourceType.rawValue):\(base)"
    }

    func date(from string: String) -> Date? {
        let defaultFormatter = ISO8601DateFormatter()
        let fullDate = ISO8601DateFormatter()
        fullDate.formatOptions = [.withFullDate]
        let fullDateTime = ISO8601DateFormatter()
        fullDateTime.formatOptions = [.withFullDate, .withFullTime]
        let formatters = [defaultFormatter, fullDate, fullDateTime]
        for fmt in formatters {
            if let d = fmt.date(from: string) { return d }
        }
        return nil
    }
}
