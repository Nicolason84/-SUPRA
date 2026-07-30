import Foundation
import Combine

public struct SUPRAExecutionRecord: Sendable {
    public let providerID: String
    public let modelID: String
    public let success: Bool
    public let durationMs: Int
    public let tokensUsed: Int
    public let timestamp: Date
    public let error: String?

    public init(providerID: String, modelID: String = "", success: Bool,
                durationMs: Int, tokensUsed: Int, timestamp: Date = Date(),
                error: String? = nil) {
        self.providerID = providerID
        self.modelID = modelID
        self.success = success
        self.durationMs = durationMs
        self.tokensUsed = tokensUsed
        self.timestamp = timestamp
        self.error = error
    }
}

@MainActor
public final class SUPRALearningEngine: ObservableObject {
    public static let shared = SUPRALearningEngine()

    @Published public private(set) var history: [SUPRAExecutionRecord] = []
    @Published public private(set) var providerScores: [String: Double] = [:]
    @Published public private(set) var isLearningEnabled = true

    private let maxHistory = 5000

    private init() {}

    public func recordExecution(providerID: String, success: Bool,
                                 durationMs: Int, tokensUsed: Int,
                                 modelID: String = "") async {
        guard isLearningEnabled else { return }

        let record = SUPRAExecutionRecord(
            providerID: providerID,
            modelID: modelID,
            success: success,
            durationMs: durationMs,
            tokensUsed: tokensUsed,
            error: success ? nil : "execution_failed"
        )

        history.append(record)
        if history.count > maxHistory {
            history = Array(history.suffix(maxHistory / 2))
        }

        updateScore(providerID: providerID, success: success, durationMs: durationMs)
    }

    public func scoreForProvider(_ providerID: String, modelID: String) async -> Double {
        let providerRecords = history.filter { $0.providerID == providerID }
        guard !providerRecords.isEmpty else { return 0 }

        let recent = providerRecords.suffix(20)
        let successRate = Double(recent.filter(\.success).count) / Double(recent.count)
        let avgDuration = recent.map(\.durationMs).reduce(0, +) / max(recent.count, 1)

        var score = successRate * 30
        if avgDuration < 1000 { score += 10 }
        else if avgDuration < 5000 { score += 5 }

        return score
    }

    private func updateScore(providerID: String, success: Bool, durationMs: Int) {
        let current = providerScores[providerID] ?? 50.0
        let delta = success ? 1.0 : -5.0
        let newScore = max(0, min(100, current + delta))
        providerScores[providerID] = newScore
    }

    public func bestProvider(for capabilities: [String]) -> String? {
        let candidates = providerScores.filter { providerID, _ in
            history.contains { $0.providerID == providerID && $0.success }
        }
        return candidates.sorted { $0.value > $1.value }.first?.key
    }

    public func summary() -> String {
        var s = "Learning Engine: \(history.count) records\n"
        for (provider, score) in providerScores.sorted(by: { $0.value > $1.value }) {
            let recent = history.filter { $0.providerID == provider }.suffix(10)
            let successRate = recent.isEmpty ? 0 : Double(recent.filter(\.success).count) / Double(recent.count) * 100
            s += "  \(provider): score=\(String(format: "%.1f", score)), success=\(String(format: "%.0f", successRate))%\n"
        }
        return s
    }

    public func clear() {
        history = []
        providerScores = [:]
    }
}
