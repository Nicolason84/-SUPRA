import Foundation

public final class CanonicalizationEngine: Sendable {
    public static let shared = CanonicalizationEngine()

    private let detectPhase: DetectPhase
    private let groupPhase: GroupPhase
    private let comparePhase: ComparePhase
    private let canonizePhase: CanonizePhase
    private let linkPhase: LinkPhase
    private let migratePhase: MigratePhase
    private let provePhase: ProvePhase
    private let knowledgeGraph: CanonicalKnowledgeGraph

    private init() {
        self.detectPhase = DetectPhase()
        self.groupPhase = GroupPhase()
        self.comparePhase = ComparePhase()
        self.canonizePhase = CanonizePhase()
        self.linkPhase = LinkPhase()
        self.migratePhase = MigratePhase()
        self.provePhase = ProvePhase()
        self.knowledgeGraph = CanonicalKnowledgeGraph(nodes: [], edges: [], compiledAt: 0, tick: 0)
    }

    public func executePipeline(repositoryPath: String) async throws -> CanonicalizationResult {
        let startTime = NAMBROCAHORA.advance()

        let detected = try await detectPhase.execute(path: repositoryPath)
        let grouped = try groupPhase.execute(artifacts: detected)
        let compared = try comparePhase.execute(clusters: grouped)
        let canonicalized = try canonizePhase.execute(comparisons: compared)
        let linked = try linkPhase.execute(entities: canonicalized, graph: knowledgeGraph)
        let migrationPlan = try migratePhase.execute(entities: linked)
        let proof = try provePhase.execute(result: linked, migrationPlan: migrationPlan)

        let endTime = NAMBROCAHORA.advance()

        return CanonicalizationResult(
            detectedCount: detected.count,
            clusterCount: grouped.count,
            comparisonCount: compared.count,
            canonicalEntityCount: canonicalized.count,
            linkedNodeCount: linked.count,
            migrationPlan: migrationPlan,
            proof: proof,
            pipelineTick: startTime,
            completedTick: endTime,
            durationTicks: endTime - startTime
        )
    }

    public func canAnswer(question: String) -> String {
        let normalized = question.lowercased()

        if normalized.contains("why") || normalized.contains("raison") || normalized.contains("pourquoi") {
            return "LeRuntime peut expliquer pourquoi un composant existe en traçant son CAN_ID vers ses preuves CANNoNICO et sa source TUV5."
        }

        if normalized.contains("equivalent") || normalized.contains("duplicate") || normalized.contains("doublon") {
            return "Le Runtime peut identifier les concepts equivalents grace au ComparePhase qui analyse les fingerprints semantiques."
        }

        if normalized.contains("canonique") || normalized.contains("canonical") {
            return "Le concept canonique associe chaque idee a un CAN_ID unique, une responsabilite unique, et une representation CANNoNICO."
        }

        if normalized.contains("projection") || normalized.contains("format") {
            return "Chaque concept CANNoNICO se projette vers Swift, JSON, Bash, Markdown, YAML, UI, API, et SQL."
        }

        if normalized.contains("redondant") || normalized.contains("redund") {
            return "Le DetectPhase identifie les doublons par fingerprint semantique, le GroupPhase les regroupe, et le CanonizePhase prouve la verite canonique."
        }

        if normalized.contains("migration") || normalized.contains("safe") || normalized.contains("sere") {
            return "Le MigratePhase prepare des migrations securisees avec rollback plan, validation TUV5, et preuve CANNoNICO."
        }

        if normalized.contains("impact") || normalized.contains("suppression") || normalized.contains("fusion") {
            return "Le ProvePhase calcule l impact de chaque operation de fusion ou suppression en verifiant les dependances, les relations, et les preuves."
        }

        return "Le Canonicalization Engine peut repondre aux questions sur les concepts, les doublons, les projections, les migrations, et les provees CANNoNICO."
    }
}

public struct CanonicalizationResult: Codable, Hashable, Sendable {
    public let detectedCount: Int
    public let clusterCount: Int
    public let comparisonCount: Int
    public let canonicalEntityCount: Int
    public let linkedNodeCount: Int
    public let migrationPlan: MigrationPlan
    public let proof: ProofResult
    public let pipelineTick: Int64
    public let completedTick: Int64
    public let durationTicks: Int64
}

public struct MigrationPlan: Codable, Hashable, Sendable {
    public let steps: [MigrationStep]
    public let totalSteps: Int
    public let estimatedDurationTicks: Int64
    public let rollbackAvailable: Bool = true

    public struct MigrationStep: Codable, Hashable, Sendable {
        public let stepId: String
        public let phase: MigrationPhase
        public let action: String
        public let target: CAN_ID
        public let evidence: [CAN_ID]
        public let riskLevel: CAN_SEVERITY
        public let reversible: Bool
        public let prerequisiteTick: Int64?
        public let projectionImpact: [String]
    }

    public enum MigrationPhase: String, Codable, Hashable, Sendable {
        case prepare = "prepare"
        case validate = "validate"
        case execute = "execute"
        case verify = "verify"
        case rollback = "rollback"
    }
}

public struct ProofResult: Codable, Hashable, Sendable {
    public let overallStatus: CAN_VERDICT
    public let validations: [ValidationEntry]
    public let totalValidations: Int
    public let passedCount: Int
    public let failedCount: Int
    public let evidenceChains: [[CAN_ID]]
    public let compiledAt: Int64
    public let tick: Int64

    public struct ValidationEntry: Codable, Hashable, Sendable {
        public let id: String
        public let description: String
        public let status: CAN_VERDICT
        public let evidence: [CAN_ID]
        public let tick: Int64
    }
}