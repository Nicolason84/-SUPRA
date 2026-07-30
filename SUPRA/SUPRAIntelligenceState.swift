import Foundation

struct SUPRAIntelligenceState {
    let healthScore: Double
    let confidenceScore: Double
    let priorityScore: Double
    let anomalyCount: Int
    let insights: [SUPRAInsight]
    let nextBestAction: String?
    let computedAt: Date
    let computeDurationMs: Int

    static let initial = SUPRAIntelligenceState(
        healthScore: 0,
        confidenceScore: 0,
        priorityScore: 0,
        anomalyCount: 0,
        insights: [],
        nextBestAction: nil,
        computedAt: Date(),
        computeDurationMs: 0
    )
}
