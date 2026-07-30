import Foundation

public final class CANNoNICO_Runtime: Sendable {
    public static let shared = CANNoNICO_Runtime()

    private var identityCore: [CAN_ID: CanonicalEntity] = [:]
    private var knowledgeCore: [CAN_ID: CAN_KNOWLEDGE] = [:]
    private var relationCore: [CAN_ID: CAN_RELATION_REF] = [:]
    private var capabilityCore: [CAN_ID: CAN_CAPABILITY] = [:]
    private var eventCore: [CAN_ID: CAN_EVENT] = [:]
    private var decisionCore: [CAN_ID: CAN_DECISION] = [:]
    private var stateCore: [CAN_ID: CAN_STATE] = [:]
    private var constraintCore: [CAN_ID: CAN_CONSTRAINT] = [:]
    private var temporalCore: [String: Int64] = [:]

    private init() {}

    public func register(entity: CanonicalEntity) {
        identityCore[entity.canId] = entity
        for relation in entity.canRelations {
            relationCore[relation.target] = relation
        }
        for capability in entity.canCapabilities {
            capabilityCore[capability] = CAN_CAPABILITY(
                canId: capability,
                canType: "capability",
                canName: entity.canName,
                canDescription: "Capability derived from \(entity.canName)",
                canEntity: entity.canId,
                canQuality: CAN_QUALITY(
                    accuracy: 0.95,
                    latencyMs: 0,
                    availability: 1.0,
                    throughput: 1.0,
                    reliability: 1.0
                ),
                canRequirements: [],
                canLimitations: [],
                canEvidence: entity.canEvidence,
                canCompiledAt: NAMBROCAHORA.advance(),
                canValidated: true
            )
        }
        for source in entity.canSource {
            temporalCore[source] = NAMBROCAHORA.advance()
        }
    }

    public func register(knowledge: CAN_KNOWLEDGE) {
        knowledgeCore[knowledge.canId] = knowledge
    }

    public func register(event: CAN_EVENT) {
        eventCore[event.canId] = event
    }

    public func register(decision: CAN_DECISION) {
        decisionCore[decision.canId] = decision
    }

    public func register(state: CAN_STATE) {
        stateCore[state.canId] = state
    }

    public func register(constraint: CAN_CONSTRAINT) {
        constraintCore[constraint.canId] = constraint
    }

    public func queryIdentity(for canId: CAN_ID) -> CanonicalEntity? {
        identityCore[canId]
    }

    public func queryKnowledge(for canId: CAN_ID) -> CAN_KNOWLEDGE? {
        knowledgeCore[canId]
    }

    public func queryRelations(for canId: CAN_ID) -> [CAN_RELATION_REF] {
        relationCore.values.filter { $0.target == canId || $0.canId.value.hasPrefix(canId.value.prefix(20)) }
    }

    public func queryCapabilities(for canId: CAN_ID) -> [CAN_CAPABILITY] {
        capabilityCore.values.filter { $0.canEntity == canId }
    }

    public func queryEvents(for canId: CAN_ID? = nil) -> [CAN_EVENT] {
        if let canId = canId {
            return eventCore.values.filter { $0.canEntity == canId }
        }
        return Array(eventCore.values)
    }

    public func queryDecisions(for canId: CAN_ID? = nil) -> [CAN_DECISION] {
        if let canId = canId {
            return decisionCore.values.filter { $0.canEvidence.contains(canId) }
        }
        return Array(decisionCore.values)
    }

    public func queryStates(for canId: CAN_ID? = nil) -> [CAN_STATE] {
        if let canId = canId {
            return stateCore.values.filter { $0.canEntity == canId }
        }
        return Array(stateCore.values)
    }

    public func queryConstraints(for canId: CAN_ID? = nil) -> [CAN_CONSTRAINT] {
        if let canId = canId {
            return constraintCore.values.filter { $0.canEntity == canId }
        }
        return Array(constraintCore.values)
    }

    public func getRuntimeStatus() -> CAN_STATE {
        let tick = NAMBROCAHORA.advance()
        return CAN_STATE(
            canId: CAN_ID(type: .runtime, hash: "runtime_status"),
            canType: "state",
            canEntity: CAN_ID(type: .runtime, hash: "runtime_core"),
            canStatus: .active,
            canMode: .normal,
            canPhase: .publish,
            canTick: tick,
            canProperties: [
                "entities": String(identityCore.count),
                "knowledge": String(knowledgeCore.count),
                "relations": String(relationCore.count),
                "capabilities": String(capabilityCore.count),
                "events": String(eventCore.count),
                "decisions": String(decisionCore.count),
                "states": String(stateCore.count),
                "constraints": String(constraintCore.count)
            ],
            canEvidence: [],
            canCompiledAt: tick
        )
    }

    public func verifyCanonization() -> [String] {
        var violations: [String] = []

        for entity in identityCore.values {
            if entity.canId.hash.count < 16 {
                violations.append("CAN_ID too short for \(entity.canName): \(entity.canId.value)")
            }
            if entity.canConfidence < 0.5 {
                violations.append("Low confidence for \(entity.canName): \(entity.canConfidence)")
            }
            if entity.canArtifacts.isEmpty {
                violations.append("No source artifacts for \(entity.canName)")
            }
        }

        for knowledge in knowledgeCore.values {
            if knowledge.canConfidence < 0.5 {
                violations.append("Low confidence knowledge: \(knowledge.canName)")
            }
        }

        return violations
    }

    public func getAllEntities() -> [CanonicalEntity] {
        Array(identityCore.values)
    }

    public func getAllKnowledge() -> [CAN_KNOWLEDGE] {
        Array(knowledgeCore.values)
    }

    public func getAllEvents() -> [CAN_EVENT] {
        Array(eventCore.values)
    }

    public func getAllDecisions() -> [CAN_DECISION] {
        Array(decisionCore.values)
    }

    public func getAllStates() -> [CAN_STATE] {
        Array(stateCore.values)
    }

    public func getAllConstraints() -> [CAN_CONSTRAINT] {
        Array(constraintCore.values)
    }
}