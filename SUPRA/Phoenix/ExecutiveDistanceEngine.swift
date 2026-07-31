// MARK: - Mission Maturity Scale
// Fixed to avoid multiple raw type inheritance

public enum MissionMaturity: String, Sendable, Codable, CaseIterable {
    case undefined = "0"
    case specified = "1"
    case implemented = "2"
    case compiles = "3"
    case validated = "4"
    case certified = "5"
    case canonized = "6"

    public var displayName: String {
        switch self {
        case .undefined: return "Undefined"
        case .specified: return "Specified"
        case .implemented: return "Implemented"
        case .compiles: return "Compiles"
        case .validated: return "Validated"
        case .certified: return "Certified"
        case .canonized: return "Canonized"
        }
    }

    public var description: String {
        "\(rawValue) — \(displayName)"
    }

    public var rawValueInt: Int {
        Int(rawValue) ?? 0
    }

    public func next() -> MissionMaturity? {
        guard let nextInt = Int(rawValue).flatMap({ $0 < 6 ? $0 + 1 : nil }) else {
            return nil
        }
        return MissionMaturity(rawValue: String(nextInt))
    }

    public func distance(to target: MissionMaturity) -> Int {
        max(0, target.rawValueInt - rawValueInt)
    }
}