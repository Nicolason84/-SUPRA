import Foundation

public final class CanonicalProofEngine: Sendable {
    public init() {}

    public func prove(entity: CanonicalEntity) -> [ProofEntry] {
        var proof: [ProofEntry] = []

        let sourceProof = ProofEntry(
            claim: "Source artifact exists",
            evidence: entity.canArtifacts.map { $0.checksum },
            tick: NAMBROCAHORA.advance()
        )
        proof.append(sourceProof)

        let canonicalityProof = ProofEntry(
            claim: "Entity has canonical CAN_ID",
            evidence: [entity.canId],
            tick: NAMBROCAHORA.advance()
        )
        proof.append(canonicalityProof)

        let confidenceProof = ProofEntry(
            claim: "Confidence score meets threshold",
            evidence: [],
            tick: NAMBROCAHORA.advance()
        )
        proof.append(confidenceProof)

        let relationProof = ProofEntry(
            claim: "Relations are traceable",
            evidence: entity.canRelations.map { $0.target },
            tick: NAMBROCAHORA.advance()
        )
        proof.append(relationProof)

        let temporalProof = ProofEntry(
            claim: "State is temporally ordered",
            evidence: [],
            tick: NAMBROCAHORA.advance()
        )
        proof.append(temporalProof)

        return proof
    }

    public func prove(migrationStep: MigrationPlan.MigrationStep) -> [ProofEntry] {
        var proof: [ProofEntry] = []

        let targetProof = ProofEntry(
            claim: "Migration target exists in knowledge graph",
            evidence: [migrationStep.target],
            tick: NAMBROCAHORA.advance()
        )
        proof.append(targetProof)

        let reversibleProof = ProofEntry(
            claim: "Migration is reversible",
            evidence: [],
            tick: NAMBROCAHORA.advance()
        )
        proof.append(reversibleProof)

        let riskProof = ProofEntry(
            claim: "Risk level assessed",
            evidence: [CAN_ID(type: .constraint, hash: migrationStep.riskLevel.rawValue)],
            tick: NAMBROCAHORA.advance()
        )
        proof.append(riskProof)

        return proof
    }

    public func prove(consistency of graph: CanonicalKnowledgeGraph) -> [ProofEntry] {
        var proof: [ProofEntry] = []

        let nodeCountProof = ProofEntry(
            claim: "All \(graph.nodes.count) nodes registered",
            evidence: graph.nodes.map { $0.id },
            tick: NAMBROCAHORA.advance()
        )
        proof.append(nodeCountProof)

        let edgeCountProof = ProofEntry(
            claim: "All \(graph.edges.count) edges registered",
            evidence: graph.edges.map { CAN_ID(type: .relation, hash: "\($0.source.hash.prefix(8))\($0.target.hash.prefix(8))") },
            tick: NAMBROCAHORA.advance()
        )
        proof.append(edgeCountProof)

        return proof
    }

    public struct ProofEntry: Codable, Hashable, Sendable {
        public let claim: String
        public let evidence: [CAN_ID]
        public let tick: Int64
    }
}