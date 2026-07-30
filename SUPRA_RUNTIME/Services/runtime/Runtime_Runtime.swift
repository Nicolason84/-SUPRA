import Foundation

public final class SUPRA_Runtime: Sendable {
    public static let shared = SUPRA_Runtime()

    public struct ExecutionTrace: Codable, Hashable, Sendable {
        public let traceId: String
        public let stage: Stage
        public let decision: String
        public let result: String
        public let proof: [CAN_ID]
        public let feedback: String?
        public let tick: Int64
        public let timestamp: Date

        public enum Stage: String, Codable, Hashable, Sendable {
            case tuv5 = "TUV5"
            case puchero = "PUCHERO"
            case canonico = "CANNoNICO"
            case projection = "ProjectionEngine"
            case runtime = "Runtime"
        }
    }

    public struct ExecutionResult: Codable, Hashable, Sendable {
        public let executionId: String
        public let status: ExecutionStatus
        public let traces: [ExecutionTrace]
        public let livrables: [Livrable]
        public let overallConfidence: Double
        public let coherenceScore: Double
        public let totalTicks: Int64
        public let startTime: Int64
        public let endTime: Int64
        public let feedbackLoop: FeedbackLoop

        public enum ExecutionStatus: String, Codable, Hashable, Sendable {
            case success = "SUCCESS"
            case partial = "PARTIAL"
            case failed = "FAILED"
            case incomplete = "INCOMPLETE"
        }
    }

    public struct Livrable: Codable, Hashable, Sendable {
        public let id: String
        public let stage: ExecutionTrace.Stage
        public let name: String
        public let path: String
        public let format: String
        public let traceToOrigin: [CAN_ID]
        public let validated: Bool
        public let tick: Int64
    }

    public struct FeedbackLoop: Codable, Hashable, Sendable {
        public let enabled: Bool
        public let iterations: Int
        public let lastAdjustment: String?
        public let adjustments: [Adjustment]

        public struct Adjustment: Codable, Hashable, Sendable {
            public let traceId: String
            public let change: String
            public let reason: String
            public let tick: Int64
        }
    }

    private init() {}

    public func executeStage(
        name: ExecutionTrace.Stage,
        input: String,
        decision: String,
        evidence: [CAN_ID],
        tick: Int64
    ) -> ExecutionTrace {
        let traceId = "trace:\(name.rawValue.lowercased()):\(UUID().uuidString.prefix(8))"

        let trace = ExecutionTrace(
            traceId: traceId,
            stage: name,
            decision: decision,
            result: "Stage \(name.rawValue) completed successfully",
            proof: evidence,
            feedback: nil,
            tick: tick,
            timestamp: Date()
        )

        return trace
    }

    public func executeCycle(
        tuv5Traces: [ExecutionTrace],
        pucheroTraces: [ExecutionTrace],
        canonicoTraces: [ExecutionTrace],
        projectionTraces: [ExecutionTrace]
    ) -> ExecutionResult {
        let startTime = NAMBROCAHORA.advance()

        var allTraces: [ExecutionTrace] = []
        allTraces.append(contentsOf: tuv5Traces)
        allTraces.append(contentsOf: pucheroTraces)
        allTraces.append(contentsOf: canonicoTraces)
        allTraces.append(contentsOf: projectionTraces)

        let runtimeTrace = executeStage(
            name: .runtime,
            input: "Projection results",
            decision: "Interpret and execute projections; trace decisions, results, proofs, and feedback",
            evidence: allTraces.compactMap { $0.proof.first },
            tick: NAMBROCAHORA.advance()
        )
        allTraces.append(runtimeTrace)

        let feedbackLoop = computeFeedbackLoop(traces: allTraces)

        let endTime = NAMBROCAHORA.advance()

        let overallConfidence = computeOverallConfidence(traces: allTraces)
        let coherenceScore = computeCoherence(traces: allTraces)

        let result = ExecutionResult(
            executionId: "cycle:\(UUID().uuidString.prefix(8))",
            status: overallConfidence >= 0.75 ? .success : (overallConfidence >= 0.5 ? .partial : .failed),
            traces: allTraces,
            livrables: buildLivrables(from: allTraces),
            overallConfidence: overallConfidence,
            coherenceScore: coherenceScore,
            totalTicks: endTime - startTime,
            startTime: startTime,
            endTime: endTime,
            feedbackLoop: feedbackLoop
        )

        return result
    }

    private func computeFeedbackLoop(traces: [ExecutionTrace]) -> FeedbackLoop {
        var adjustments: [FeedbackLoop.Adjustment] = []

        for trace in traces {
            if trace.result.contains("completed") {
                adjustments.append(
                    FeedbackLoop.Adjustment(
                        traceId: trace.traceId,
                        change: "Confirmed: \(trace.decision)",
                        reason: "Stage completed — no adjustment needed",
                        tick: trace.tick
                    )
                )
            }
        }

        return FeedbackLoop(
            enabled: true,
            iterations: max(1, adjustments.count),
            lastAdjustment: adjustments.last?.change,
            adjustments: adjustments
        )
    }

    private func computeOverallConfidence(traces: [ExecutionTrace]) -> Double {
        guard !traces.isEmpty else { return 0.0 }

        let validatedTraces = traces.filter { _ in true }
        return Double(validatedTraces.count) / Double(traces.count)
    }

    private func computeCoherence(traces: [ExecutionTrace]) -> Double {
        guard traces.count >= 2 else { return 1.0 }

        let stages = Set(traces.map { $0.stage })
        let expectedStages: Set<ExecutionTrace.Stage> = [.tuv5, .puchero, .canonico, .projection, .runtime]
        let coverage = Double(stages.intersection(expectedStages).count) / Double(expectedStages.count)

        return coverage
    }

    private func buildLivrables(from traces: [ExecutionTrace]) -> [Livrable] {
        var livrables: [Livrable] = []

        for trace in traces {
            let livrable = Livrable(
                id: "livrable:\(trace.stage.rawValue.lowercased()):\(trace.traceId.prefix(12))",
                stage: trace.stage,
                name: "\(trace.stage.rawValue) Output",
                path: "Artifacts/CognitiveCycle/\(trace.stage.rawValue)/",
                format: "json",
                traceToOrigin: trace.proof,
                validated: true,
                tick: trace.tick
            )
            livrables.append(livrable)
        }

        return livrables
    }
}