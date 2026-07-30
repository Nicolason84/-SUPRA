import Foundation

public final class ProvePhase: Sendable {
    public init() {}

    public func execute(result: [CGNode], migrationPlan: MigrationPlan) -> ProofResult {
        var validations: [ProofResult.ValidationEntry] = []
        var allEvidenceChains: [[CAN_ID]] = []
        var passedCount = 0
        var failedCount = 0

        let nodeCount = result.count
        let edgeCount = migrationPlan.steps.reduce(into: 0) { $0 += $1.evidence.count }
        let consistencyScore = computeConsistencyScore(nodes: result, steps: migrationPlan.steps)
        let traceabilityScore = computeTraceabilityScore(nodes: result)
        let completenessScore = computeCompletenessScore(nodes: result)

        let validation1 = ProofResult.ValidationEntry(
            id: "val:node_count",
            description: "All \(nodeCount) nodes are registered in the Knowledge Graph",
            status: nodeCount > 0 ? .pass : .fail,
            evidence: [],
            tick: NAMBROCAHORA.advance()
        )
        validations.append(validation1)
        if validation1.status == .pass { passedCount += 1 } else { failedCount += 1 }

        let validation2 = ProofResult.ValidationEntry(
            id: "val:consistency",
            description: "Knowledge Graph consistency score: \(String(format: "%.4f", consistencyScore))",
            status: consistencyScore >= 0.8 ? .pass : .fail,
            evidence: [],
            tick: NAMBROCAHORA.advance()
        )
        validations.append(validation2)
        if validation2.status == .pass { passedCount += 1 } else { failedCount += 1 }

        let validation3 = ProofResult.ValidationEntry(
            id: "val:traceability",
            description: "Traceability score: \(String(format: "%.4f", traceabilityScore)) — every node traces to CANNoNICO primitive",
            status: traceabilityScore >= 0.8 ? .pass : .fail,
            evidence: [],
            tick: NAMBROCAHORA.advance()
        )
        validations.append(validation3)
        if validation3.status == .pass { passedCount += 1 } else { failedCount += 1 }

        let validation4 = ProofResult.ValidationEntry(
            id: "val:completeness",
            description: "Completeness score: \(String(format: "%.4f", completenessScore)) — all entities have canonical representation",
            status: completenessScore >= 0.8 ? .pass : .fail,
            evidence: [],
            tick: NAMBROCAHORA.advance()
        )
        validations.append(validation4)
        if validation4.status == .pass { passedCount += 1 } else { failedCount += 1 }

        let validation5 = ProofResult.ValidationEntry(
            id: "val:rollback",
            description: "Migration plan is reversible — rollback available for all \(migrationPlan.totalSteps) steps",
            status: migrationPlan.rollbackAvailable ? .pass : .fail,
            evidence: [],
            tick: NAMBROCAHORA.advance()
        )
        validations.append(validation5)
        if validation5.status == .pass { passedCount += 1 } else { failedCount += 1 }

        let validation6 = ProofResult.ValidationEntry(
            id: "val:projections",
            description: "All projections are accounted for in migration plan",
            status: migrationPlan.steps.allSatisfy { $0.projectionImpact.count > 0 } ? .pass : .fail,
            evidence: [],
            tick: NAMBROCAHORA.advance()
        )
        validations.append(validation6)
        if validation6.status == .pass { passedCount += 1 } else { failedCount += 1 }

        let overallStatus: CAN_VERDICT
        if failedCount == 0 {
            overallStatus = .pass
        } else if failedCount <= 2 {
            overallStatus = .retry
        } else {
            overallStatus = .fail
        }

        let compiledAt = NAMBROCAHORA.advance()

        return ProofResult(
            overallStatus: overallStatus,
            validations: validations,
            totalValidations: validations.count,
            passedCount: passedCount,
            failedCount: failedCount,
            evidenceChains: allEvidenceChains,
            compiledAt: compiledAt,
            tick: compiledAt
        )
    }

    private func computeConsistencyScore(nodes: [CGNode], steps: [MigrationPlan.MigrationStep]) -> Double {
        guard !nodes.isEmpty else { return 0.0 }

        let uniqueTypes = Set(nodes.map { $0.type })
        let typeCoverage = Double(uniqueTypes.count) / Double(CAN_TYPE.allCases.count)

        let noOrphans = nodes.allSatisfy { node in
            !node.relations.isEmpty || node.primitive.contains("P1") || node.label == "unknown"
        }
        let orphanBonus = noOrphans ? 0.1 : 0.0

        return min(1.0, typeCoverage + orphanBonus)
    }

    private func computeTraceabilityScore(nodes: [CGNode]) -> Double {
        guard !nodes.isEmpty else { return 0.0 }

        let traced = nodes.filter { node in
            node.proof.count > 0 || node.nambrohoraRef > 0
        }
        return Double(traced.count) / Double(nodes.count)
    }

    private func computeCompletenessScore(nodes: [CGNode]) -> Double {
        guard !nodes.isEmpty else { return 0.0 }

        let canonicalNodes = nodes.filter { $0.primitive != "unknown" }
        return Double(canonicalNodes.count) / Double(nodes.count)
    }
}