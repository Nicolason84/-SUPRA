import Foundation

public final class MigratePhase: Sendable {
    public init() {}

    public func execute(entities: [CGNode]) -> MigrationPlan {
        var steps: [MigrationPlan.MigrationStep] = []

        for entity in entities {
            let step = buildMigrationStep(for: entity)
            steps.append(step)
        }

        let totalDuration = Int64(steps.count) * 10
        let rollbackAvailable = true

        return MigrationPlan(
            steps: steps,
            totalSteps: steps.count,
            estimatedDurationTicks: totalDuration,
            rollbackAvailable: rollbackAvailable
        )
    }

    private func buildMigrationStep(for node: CGNode) -> MigrationPlan.MigrationStep {
        let phase: MigrationPlan.MigrationPhase
        let action: String
        let riskLevel: CAN_SEVERITY
        let reversible = true

        switch node.primitive {
        case "P1 CAN_ID + P2 CAN_TYPE":
            phase = .prepare
            action = "Map \(node.label) to CAN_ID identity — no behavioral change"
            riskLevel = .info
        case "P5 CAN_KNOWLEDGE + P6 CAN_RELATION":
            phase = .execute
            action = "Consolidate \(node.label) knowledge into CANNoNICO KnowledgeCore"
            riskLevel = .warning
        case "P9 CAN_EVENT + P10 CAN_TIME":
            phase = .execute
            action = "Convert \(node.label) event timestamps to NAMBROCAHORA ticks"
            riskLevel = .error
        case "P12 CAN_DECISION":
            phase = .validate
            action = "Validate \(node.label) decisions trace to CANNoNICO DecisionCore"
            riskLevel = .warning
        case "P8 CAN_CONSTRAINT":
            phase = .validate
            action = "Validate \(node.label) constraints in CANNoNICO ConstraintCore"
            riskLevel = .critical
        default:
            phase = .prepare
            action = "Register \(node.label) in CANNoNICO canonical model"
            riskLevel = .info
        }

        let prereqTick: Int64? = nil
        let projectionImpact = buildProjectionImpact(for: node)

        return MigrationPlan.MigrationStep(
            stepId: "mig:\(node.id.hash)",
            phase: phase,
            action: action,
            target: node.id,
            evidence: node.proof,
            riskLevel: riskLevel,
            reversible: reversible,
            prerequisiteTick: prereqTick,
            projectionImpact: projectionImpact
        )
    }

    private func buildProjectionImpact(for node: CGNode) -> [String] {
        var impacts: [String] = []

        switch node.type {
        case .structure:
            impacts.append("Swift source projections will be regenerated")
        case .config:
            impacts.append("JSON/YAML configuration projections will be updated")
        case .document:
            impacts.append("Markdown documentation projections will be regenerated")
        case .model, .runtime:
            impacts.append("All runtime projections (Swift/JSON/Bash/MD/UI/API) must be regenerated")
        default:
            impacts.append("Projections will be regenerated via Projection Engine")
        }

        impacts.append("NAMBROCAHORA ticks will be recomputed post-migration")
        impacts.append("CANNoNICO proof chains will be regenerated")

        return impacts
    }
}