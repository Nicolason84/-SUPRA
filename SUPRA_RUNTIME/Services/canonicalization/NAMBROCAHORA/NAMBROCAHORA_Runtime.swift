import Foundation

public enum NAMBROCAHORA_Runtime: Sendable {
    public static var currentTick: Int64 {
        get { _currentTick }
        set { _currentTick = newValue }
    }

    private static var _currentTick: Int64 = 0

    public static func advance() -> Int64 {
        _currentTick += 1
        return _currentTick
    }

    public static func now() -> Int64 {
        _currentTick
    }

    public static func elapsed(from tick: Int64) -> Int64 {
        _currentTick - tick
    }

    public static func compare(_ a: Int64, _ b: Int64) -> ComparisonResult {
        if a < b { return .orderedAscending }
        if a > b { return .orderedDescending }
        return .orderedSame
    }

    public static func isBefore(_ a: Int64, _ b: Int64) -> Bool {
        a < b
    }

    public static func isAfter(_ a: Int64, _ b: Int64) -> Bool {
        a > b
    }

    public static func format(_ tick: Int64) -> String {
        "tick:\(tick)"
    }

    public static func parse(_ tickString: String) -> Int64? {
        let prefix = "tick:"
        guard tickString.hasPrefix(prefix) else {
            return Int64(tickString)
        }
        return Int64(String(tickString.dropFirst(prefix.count)))
    }

    public static func toISO8601(_ tick: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(tick) / 1000.0)
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }

    public static func fromISO8601(_ isoString: String) -> Int64? {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return nil }
        return Int64(date.timeIntervalSince1970 * 1000)
    }

    public static func validateTick(_ tick: Int64) -> Bool {
        tick >= 0
    }

    public static func nextTick(after tick: Int64) -> Int64 {
        tick + 1
    }

    public static func reset() {
        _currentTick = 0
    }
}