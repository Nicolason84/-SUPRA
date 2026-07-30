import Foundation

public final class CanonizePhase: Sendable {
    public init() {}

    public func execute(comparisons: [ComparativeAnalysis]) -> [CanonicalEntity] {
        var entities: [CanonicalEntity] = []

        for comparison in comparisons {
            let entity = buildCanonicalEntity(from: comparison)
            entities.append(entity)
        }

        return entities
    }

    private func buildCanonicalEntity(from comparison: ComparativeAnalysis) -> CanonicalEntity {
        let primary = comparison.primaryArtifact
        let canType = primary?.type.flatMap { typeForArtifact($0) } ?? .structure
        let canName = primary?.name ?? "unknown"
        let semantics = buildSemantics(from: comparison)
        let responsibilities = extractResponsibilities(from: comparison)
        let capabilities = extractCapabilities(from: comparison)
        let state = CAN_STATE_STATUS(active)
        let tick = NAMBROCAHORA.advance()

        let artifacts = [primary].compactMap { $0 } + comparison.candidateArtifacts
        let evidence = buildEvidence(from: comparison)

        return CanonicalEntity(
            canId: primary?.canonicalId ?? CAN_ID(type: canType, hash: comparison.clusterId.prefix(16)),
            canType: canType,
            canName: canName,
            canSemantics: semantics,
            canResponsibilities: responsibilities,
            canCapabilities: capabilities,
            canRelations: [],
            canState: state,
            canTick: tick,
            canArtifacts: artifacts,
            canEvidence: evidence,
            canSource: primary.map { [$0.path] } ?? [],
            canProjections: buildProjections(for: canType),
            canConfidence: comparison.overallConfidence,
            canValidated: comparison.overallConfidence >= 0.75
        )
    }

    private func buildSemantics(from comparison: ComparativeAnalysis) -> [String: String] {
        var semantics: [String: String] = [:]
        semantics["semanticKey"] = comparison.semanticKey
        semantics["clusterId"] = comparison.clusterId
        semantics["sourceCategory"] = comparison.primaryArtifact?.sourceCategory ?? "unknown"
        semantics["primaryType"] = comparison.primaryArtifact?.type.rawValue ?? "unknown"
        semantics["recommendation"] = comparison.recommendation.rawValue
        semantics["confidence"] = String(format: "%.4f", comparison.overallConfidence)
        semantics["semanticScore"] = String(format: "%.4f", comparison.semanticScore)
        semantics["structuralScore"] = String(format: "%.4f", comparison.structuralScore)
        semantics["overlapScore"] = String(format: "%.4f", comparison.overlapScore)
        return semantics
    }

    private func extractResponsibilities(from comparison: ComparativeAnalysis) -> [String] {
        var responsibilities: Set<String> = []

        for artifact in comparison.primaryArtifact.map { [$0] } + comparison.candidateArtifacts {
            let nameWords = artifact.name.components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }
                .map { $0.lowercased() }

            for word in nameWords {
                if ["snapshot", "state", "event", "decision", "knowledge", "memory", "runtime", "workflow", "service", "connector", "manifest", "registry", "model", "document", "config", "source", "provider", "executor", "orchestrator", "monitor", "validator", "projection", "compiler", "kernel", "core", "broker", "manager", "controller", "handler", "processor", "engine", "bridge", "adapter", "pipeline", "gate", "authority", "constraint", "policy", "rule"].contains(word) {
                    responsibilities.insert(word)
                }
            }
        }

        return Array(responsibilities).sorted()
    }

    private func extractCapabilities(from comparison: ComparativeAnalysis) -> [CAN_ID] {
        return comparison.primaryArtifact.map { artifact in
            let hash = artifact.checksum.prefix(12)
            return CAN_ID(type: .capability, hash: String(hash))
        } ?? []
    }

    private func buildEvidence(from comparison: ComparativeAnalysis) -> [CAN_ID] {
        return comparison.evidence.compactMap { text in
            let hash = text.prefix(16)
            return CAN_ID(type: .evidence, hash: String(hash))
        }
    }

    private func buildProjections(for type: CAN_TYPE) -> [String] {
        switch type {
        case .structure:
            return ["swift", "json", "markdown"]
        case .script:
            return ["bash", "json"]
        case .config:
            return ["json", "yaml", "markdown"]
        case .document:
            return ["markdown", "json", "html"]
        case .model, .runtime, .workflow:
            return ["swift", "json", "yaml", "markdown"]
        case .manifest, .registry:
            return ["json", "yaml", "markdown"]
        default:
            return ["json", "markdown"]
        }
    }

    private func typeForArtifact(_ type: ARTIFACT_TYPE) -> CAN_TYPE {
        switch type {
        case .swiftFile, .swiftStructure, .swiftEnum, .swiftStruct, .swiftClass:
            return .structure
        case .bashScript:
            return .script
        case .jsonFile:
            return .config
        case .yamlFile:
            return .config
        case .markdownFile:
            return .document
        case .sqlFile:
            return .structure
        case .manifest:
            return .manifest
        case .registry:
            return .registry
        case .model:
            return .model
        }
    }
}