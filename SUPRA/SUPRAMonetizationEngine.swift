import Foundation

enum SUPRAProductTier: String, Codable, CaseIterable {
    case explorer = "Explorer"
    case executive = "Executive"
    case enterprise = "Enterprise"

    var monthlyPrice: Decimal {
        switch self {
        case .explorer: 49
        case .executive: 199
        case .enterprise: 999
        }
    }

    var annualPrice: Decimal { monthlyPrice * 12 * 0.8 }

    var maxMissionsPerDay: Int {
        switch self {
        case .explorer: 50
        case .executive: 500
        case .enterprise: .max
        }
    }

    var maxMemorySources: Int {
        switch self {
        case .explorer: 3
        case .executive: 10
        case .enterprise: .max
        }
    }

    var includesAutoExecute: Bool {
        switch self {
        case .explorer: false
        case .executive: true
        case .enterprise: true
        }
    }

    var includesBusinessIntelligence: Bool {
        switch self {
        case .explorer: false
        case .executive: true
        case .enterprise: true
        }
    }

    var includesCustomerTwin: Bool {
        switch self {
        case .explorer: false
        case .executive: false
        case .enterprise: true
        }
    }

    var workerLimit: Int {
        switch self {
        case .explorer: 1
        case .executive: 4
        case .enterprise: 16
        }
    }
}

struct MissionValueMetrics {
    let timeSavedMinutes: Double
    let riskReduced: Double
    let decisionQuality: Double
    let automationLevel: Double

    var compositeScore: Double {
        (timeSavedMinutes / 60 + riskReduced + decisionQuality + automationLevel) / 4.0
    }

    var estimatedValueUSD: Decimal {
        let hours = Decimal(timeSavedMinutes / 60)
        let hourlyRate = Decimal(150)
        let riskValue = Decimal(riskReduced) * 500
        let qualityValue = Decimal(decisionQuality) * 300
        return hours * hourlyRate + riskValue + qualityValue
    }
}

struct SUPRAPricingModel {

    static func valueMetrics(from world: SUPRAWorldSnapshot) -> MissionValueMetrics {
        let timeSaved = Double(world.missions.completed) * 45.0
        let risk = 1.0 - (Double(world.missions.blocked) / max(Double(world.missions.total), 1))
        let decisionQuality = world.decision.autonomyLevel
        let automation = world.decision.autonomyLevel

        return MissionValueMetrics(
            timeSavedMinutes: timeSaved,
            riskReduced: risk,
            decisionQuality: decisionQuality,
            automationLevel: automation
        )
    }

    static func recommendedTier(for metrics: MissionValueMetrics) -> SUPRAProductTier {
        let score = metrics.compositeScore
        if score > 0.7 { return .enterprise }
        if score > 0.4 { return .executive }
        return .explorer
    }

    static func savingsReport(metrics: MissionValueMetrics, tier: SUPRAProductTier) -> String {
        let monthly = (tier.monthlyPrice as NSDecimalNumber).intValue
        let value = (metrics.estimatedValueUSD as NSDecimalNumber).intValue
        let roi = monthly > 0 ? (value / monthly) * 100 : 0
        return """
        VALUE REPORT — \(tier.rawValue.uppercased())
        Monthly investment: $\(monthly)
        Estimated value created: $\(value)/month
        ROI: \(roi)%
        Time saved: \(Int(metrics.timeSavedMinutes)) minutes
        Risk reduced: \(Int(metrics.riskReduced * 100))%
        Decision quality: \(Int(metrics.decisionQuality * 100))%
        """
    }
}
