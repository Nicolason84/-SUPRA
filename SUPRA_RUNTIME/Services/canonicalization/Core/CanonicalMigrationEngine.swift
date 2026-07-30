import Foundation

public final class CanonicalMigrationEngine: Sendable {
    public init() {}

    public func prepareMigration(for entities: [CanonicalEntity]) -> MigrationPlan {
        let migratePhase = MigratePhase()
        return migratePhase.execute(entities: entities)
    }

    public func validateMigration(_ plan: MigrationPlan) -> [String] {
        var validations: [String] = []

        for step in plan.steps {
            if step.phase == .validate {
                validations.append("Validation step: \(step.action)")
            }
            if step.riskLevel == .critical || step.riskLevel == .error {
                validations.append("CAUTION: \(step.action) has risk level \(step.riskLevel.rawValue)")
            }
            if !step.reversible {
                validations.append("WARNING: \(step.action) is not reversible")
            }
        }

        return validations
    }

    public func rollbackPlan(for plan: MigrationPlan) -> MigrationPlan {
        let reversedSteps = plan.steps.reversed().map { step in
            MigrationPlan.MigrationStep(
                stepId: "\(step.stepId):rollback",
                phase: .rollback,
                action: "Rollback: \(step.action)",
                target: step.target,
                evidence: step.evidence,
                riskLevel: .info,
                reversible: true,
                prerequisiteTick: nil,
                projectionImpact: step.projectionImpact
            )
        }

        return MigrationPlan(
            steps: reversedSteps,
            totalSteps: reversedSteps.count,
            estimatedDurationTicks: plan.estimatedDurationTicks,
            rollbackAvailable: true
        )
    }

    public func computeImpact(of fusion: FusionOperation) -> ImpactAssessment {
        let affectedNodes = fusion.targets.count
        let affectedRelations = fusion.targets.reduce(0) { count, target in
            count + target.canRelations.count
        }
        let affectedProjections = fusion.targets.reduce(into: Set<String>()) { set, target in
            set.formUnion(target.canProjections)
        }

        return ImpactAssessment(
            affectedEntities: affectedNodes,
            affectedRelations: affectedRelations,
            affectedProjections: Array(affectedProjections),
            riskLevel: fusion.targets.count > 5 ? .warning : .info,
            reversible: true,
            estimatedDurationTicks: Int64(fusion.targets.count) * 5
        )
    }
}

public struct FusionOperation {
    public let id: String
    public let targets: [CanonicalEntity]
    public let canonicalEntity: CanonicalEntity
    public let rationale: String
    public let evidence: [String]
}

public struct ImpactAssessment {
    public let affectedEntities: Int
    public let affectedRelations: Int
    public let affectedProjections: [String]
    public let riskLevel: CAN_SEVERITY
    public let reversible: Bool
    public let estimatedDurationTicks: Int64
}