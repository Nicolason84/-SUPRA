import Foundation

public final class TUV5RuntimeCompiler: Sendable {
    public static let shared = TUV5RuntimeCompiler()

    public struct TUV5CompilationReport: Codable, Hashable, Sendable {
        public let compilationId: String
        public let status: String
        public let tick: Int64
        public let sourceCount: Int
        public let conceptCount: Int
        public let relationCount: Int
        public let knowledgeCount: Int
        public let canonicalEntities: [CanonicalEntity]
        public let evidenceChains: [[CAN_ID]]
        public let projections: [String]
        public let violations: [String]
        public let consistencyScore: Double
    }

    private init() {}

    public func compile(repositoryPath: String) async throws -> TUV5CompilationReport {
        let tick = NAMBROCAHORA.advance()

        let detectionPhase = DetectPhase()
        let artifacts = try await detectionPhase.execute(path: repositoryPath)

        let groupingPhase = GroupPhase()
        let clusters = groupingPhase.execute(artifacts: artifacts)

        let comparisonPhase = ComparePhase()
        let comparisons = comparisonPhase.execute(clusters: clusters)

        let canonizationPhase = CanonizePhase()
        let canonicalEntities = canonizationPhase.execute(comparisons: comparisons)

        let conceptCount = canonicalEntities.count
        let relationCount = canonicalEntities.reduce(0) { $0 + $1.canRelations.count }

        let report = TUV5CompilationReport(
            compilationId: "tuv5:comp:\(UUID().uuidString)",
            status: "COMPILED",
            tick: tick,
            sourceCount: artifacts.count,
            conceptCount: conceptCount,
            relationCount: relationCount,
            knowledgeCount: conceptCount,
            canonicalEntities: canonicalEntities,
            evidenceChains: [],
            projections: buildProjections(for: canonicalEntities),
            violations: [],
            consistencyScore: computeConsistencyScore(for: canonicalEntities)
        )

        return report
    }

    public func compactKnowledge(from entities: [CanonicalEntity]) -> CAN_KNOWLEDGE {
        let tick = NAMBROCAHORA.advance()
        let hash = entities.map { $0.canId.value }.joined().sha256().prefix(16)

        let canId = CAN_ID(type: .knowledge, hash: String(hash))

        return CAN_KNOWLEDGE(
            canId: canId,
            canType: "knowledge",
            canVersion: .v1,
            canName: "Compacted Runtime Knowledge",
            canContent: entities.map { $0.canName }.joined(separator: "|"),
            canSource: entities.flatMap { $0.canSource },
            canEvidence: entities.flatMap { $0.canEvidence },
            canConfidence: entities.map { $0.canConfidence }.reduce(1.0, min),
            canCompiledAt: tick,
            canState: .active,
            canRelations: entities.flatMap { $0.canRelations },
            canConstraints: [],
            canProjections: entities.flatMap { $0.canProjections },
            canTrace: [canId],
            canValidated: true,
            canRejected: false,
            canRejectionReason: nil
        )
    }

    private func buildProjections(for entities: [CanonicalEntity]) -> [String] {
        var projections: Set<String> = []
        for entity in entities {
            projections.formUnion(entity.canProjections)
        }
        return Array(projections).sorted()
    }

    private func computeConsistencyScore(for entities: [CanonicalEntity]) -> Double {
        guard !entities.isEmpty else { return 1.0 }

        let validatedCount = entities.filter { $0.canValidated }.count
        return Double(validatedCount) / Double(entities.count)
    }
}