import Foundation

enum DecisionAuthority: String, Codable, Comparable {
    case autoExecute = "AUTO_EXECUTE"
    case supervised = "SUPERVISED"
    case humanRequired = "HUMAN_REQUIRED"
    case sovereignHumanOnly = "SOVEREIGN_HUMAN_ONLY"

    var autonomyLevel: Double {
        switch self {
        case .autoExecute: 1.0
        case .supervised: 0.5
        case .humanRequired: 0.0
        case .sovereignHumanOnly: 0.0
        }
    }

    var requiresHuman: Bool {
        self == .humanRequired || self == .sovereignHumanOnly
    }

    var requiresSovereign: Bool {
        self == .sovereignHumanOnly
    }

    static func < (lhs: DecisionAuthority, rhs: DecisionAuthority) -> Bool {
        lhs.autonomyLevel < rhs.autonomyLevel
    }
}

enum DecisionImpact: String, Codable, Comparable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case critical = "CRITICAL"

    static func < (lhs: DecisionImpact, rhs: DecisionImpact) -> Bool {
        let order: [DecisionImpact] = [.low, .medium, .high, .critical]
        return (order.firstIndex(of: lhs) ?? 0) < (order.firstIndex(of: rhs) ?? 0)
    }
}

enum DecisionCategory: String, Codable, CaseIterable {
    case memory    = "MEMORY"
    case runtime   = "RUNTIME"
    case mission   = "MISSION"
    case resource  = "RESOURCE"
    case config    = "CONFIG"
    case policy    = "POLICY"
    case financial = "FINANCIAL"
    case legal     = "LEGAL"
    case security  = "SECURITY"
    case authority = "AUTHORITY"
    case system    = "SYSTEM"

    var isSovereign: Bool {
        switch self {
        case .policy, .financial, .legal, .security, .authority:
            true
        case .memory, .runtime, .mission, .resource, .config, .system:
            false
        }
    }
}

struct DecisionVerdict: Equatable {
    let authority: DecisionAuthority
    let reason: String
    let confidence: Double
    let requiredAction: String
    let rollbackAvailable: Bool
}

struct DecisionEvidence {
    let confidenceScore: Double
    let evidenceScore: Double
    let impact: DecisionImpact
    let isReversible: Bool
    let category: DecisionCategory
    let permissionsAvailable: Bool
}
