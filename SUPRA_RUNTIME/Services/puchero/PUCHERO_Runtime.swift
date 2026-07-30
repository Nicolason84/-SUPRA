import Foundation

public final class PUCHERO_Runtime: Sendable {
    public static let shared = PUCHERO_Runtime()

    public struct KnowledgeCandidate: Codable, Hashable, Sendable {
        public let canId: CAN_ID
        public let canVersion: CAN_VERSION = .v1
        public let canName: String
        public let canPackage: CAN_KNOWLEDGE
        public let linkedConcepts: [CAN_RELATION_REF]
        public let contradictions: [Contradiction]
        public let fusedDuplicates: [FusionRecord]
        public let accumulatedEvidence: [CAN_ID]
        public let coherenceScore: Double
        public let confidenceScore: Double
        public let tick: Int64
        public let state: CAN_STATE_STATUS
        public let trace: [CAN_ID]
        public let projectionTargets: [String]
        public let validated: Bool
        public let rejectionReason: String?
    }

    public struct Contradiction: Codable, Hashable, Sendable {
        public let id: String
        public let conceptA: CAN_ID
        public let conceptB: CAN_ID
        public let type: ContradictionType
        public let severity: CAN_SEVERITY
        public let evidence: [CAN_ID]
        public let tick: Int64
        public let resolution: ContradictionResolution

        public enum ContradictionType: String, Codable, Hashable, Sendable {
            case mutuallyExclusive = "mutually_exclusive"
            case overlappingAuthority = "overlapping_authority"
            case conflictingConstraint = "conflicting_constraint"
            case temporalInconsistency = "temporal_inconsistency"
            case semanticConflict = "semantic_conflict"
            case duplicateWithDifference = "duplicate_with_difference"
        }

        public enum ContradictionResolution: String, Codable, Hashable, Sendable {
            case pending = "pending"
            case merged = "merged"
            case rejected = "rejected"
        case escalated = "escalated"
        case defused = "defused"
        }
    }

    public struct FusionRecord: Codable, Hashable, Sendable {
        public let id: String
        public let sourceConcepts: [CAN_ID]
        public let resultingConcept: CAN_ID
        public let rationale: String
        public let evidence: [CAN_ID]
        public let tick: Int64
        public let confidenceDelta: Double
        public let projectionsMerged: [String]
    }

    private init() {}

    public func mature(from knowledgePackage: CAN_KNOWLEDGE) -> KnowledgeCandidate {
        let tick = NAMBROCAHORA.advance()

        let linkedConcepts = linkConcepts(in: knowledgePackage)
        let contradictions = detectContradictions(in: knowledgePackage, linked: linkedConcepts)
        let fusedDuplicates = fuseDuplicates(in: knowledgePackage, linked: linkedConcepts, contradictions: contradictions)
        let accumulatedEvidence = accumulateEvidence(from: knowledgePackage, linked: linkedConcepts, fused: fusedDuplicates)
        let coherenceScore = measureCoherence(
            knowledgePackage: knowledgePackage,
            linked: linkedConcepts,
            contradictions: contradictions,
            fused: fusedDuplicates
        )
        let confidenceScore = computeConfidence(
            knowledgePackage: knowledgePackage,
            coherenceScore: coherenceScore,
            contradictions: contradictions,
            fused: fusedDuplicates
        )
        let validated = coherenceScore >= 0.75 && contradictions.filter { $0.severity == .critical }.isEmpty

        let candidate = KnowledgeCandidate(
            canId: CAN_ID(type: .knowledge, hash: knowledgePackage.canId.hash.prefix(16)),
            canName: "Knowledge Candidate: \(knowledgePackage.canName)",
            canPackage: knowledgePackage,
            linkedConcepts: linkedConcepts,
            contradictions: contradictions,
            fusedDuplicates: fusedDuplicates,
            accumulatedEvidence: accumulatedEvidence,
            coherenceScore: coherenceScore,
            confidenceScore: confidenceScore,
            tick: tick,
            state: validated ? .canonical : .review,
            trace: [knowledgePackage.canId, CAN_ID(type: .knowledge, hash: knowledgePackage.canId.hash.prefix(16))],
            projectionTargets: buildProjectionTargets(from: knowledgePackage),
            validated: validated,
            rejectionReason: validated ? nil : "Coherence below threshold or critical contradictions found"
        )

        return candidate
    }

    public func matureBatch(from packages: [CAN_KNOWLEDGE]) -> [KnowledgeCandidate] {
        return packages.map { mature(from: $0) }
    }

    private func linkConcepts(in knowledge: CAN_KNOWLEDGE) -> [CAN_RELATION_REF] {
        var relations: [CAN_RELATION_REF] = []

        for existingRelation in knowledge.canRelations {
            relations.append(existingRelation)
        }

        let sourceWords = knowledge.canSource.map { $0.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty } }.flatMap { $0 }
        let evidenceWords = knowledge.canEvidence.map { $0.value.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty } }.flatMap { $0 }

        let allKeywords = Set(sourceWords + evidenceWords)

        for keyword in allKeywords {
            let relatedKeywords = allKeywords.filter { areSemanticallyRelated(keyword, $0) }
            if relatedKeywords.count > 1 {
                let hash = "\(keyword)||\(relatedKeywords.sorted().joined(separator: ","))"
                let relation = CAN_RELATION_REF(
                    target: CAN_ID(type: .knowledge, hash: hash.prefix(16)),
                    relationType: .references,
                    direction: "outbound",
                    weight: Double(relatedKeywords.count) / Double(allKeywords.count),
                    evidence: knowledge.canEvidence,
                    compiledAt: NAMBROCAHORA.advance(),
                    validated: true
                )
                relations.append(relation)
            }
        }

        return relations
    }

    private func detectContradictions(in knowledge: CAN_KNOWLEDGE, linked: [CAN_RELATION_REF]) -> [Contradiction] {
        var contradictions: [Contradiction] = []

        let constraints = knowledge.canConstraints
        if constraints.count > 1 {
            for i in 0..<(constraints.count - 1) {
                let a = constraints[i]
                let b = constraints[i + 1]
                if a.hash != b.hash {
                    let contradiction = Contradiction(
                        id: "contr:\(a.hash.prefix(8))-|\(b.hash.prefix(8))",
                        conceptA: a,
                        conceptB: b,
                        type: .conflictingConstraint,
                        severity: .warning,
                        evidence: [a, b],
                        tick: NAMBROCAHORA.advance(),
                        resolution: .pending
                    )
                    contradictions.append(contradiction)
                }
            }
        }

        let sources = Set(knowledge.canSource)
        if sources.count > 1 && knowledge.canConfidence < 0.6 {
            let contradiction = Contradiction(
                id: "contr:source_conflict:\(UUID().uuidString.prefix(8))",
                conceptA: knowledge.canId,
                conceptB: CAN_ID(type: .knowledge, hash: sources.sorted().first!.prefix(16)),
                type: .semanticConflict,
                severity: .info,
                evidence: knowledge.canEvidence,
                tick: NAMBROCAHORA.advance(),
                resolution: .pending
            )
            contradictions.append(contradiction)
        }

        return contradictions
    }

    private func fuseDuplicates(in knowledge: CAN_KNOWLEDGE, linked: [CAN_RELATION_REF], contradictions: [Contradiction]) -> [FusionRecord] {
        var fusions: [FusionRecord] = []

        let duplicateRelations = linked.filter { $0.relationType == .equivalentTo || $0.relationType == .duplicates }
        guard duplicateRelations.count > 0 else { return fusions }

        for relation in duplicateRelations {
            let fusion = FusionRecord(
                id: "fuse:\(relation.target.hash.prefix(8))",
                sourceConcepts: [knowledge.canId, relation.target],
                resultingConcept: CAN_ID(type: .knowledge, hash: "\(knowledge.canId.hash)|\(relation.target.hash)".prefix(16)),
                rationale: "Duplicate detected via semantic equivalence — \(knowledge.canName) merged with related concept",
                evidence: knowledge.canEvidence + [relation.target],
                tick: NAMBROCAHORA.advance(),
                confidenceDelta: 0.05,
                projectionsMerged: knowledge.canProjections
            )
            fusions.append(fusion)
        }

        return fusions
    }

    private func accumulateEvidence(from knowledge: CAN_KNOWLEDGE, linked: [CAN_RELATION_REF], fused: [FusionRecord]) -> [CAN_ID] {
        var evidence = knowledge.canEvidence

        for relation in linked {
            evidence.append(relation.target)
        }

        for fusion in fused {
            evidence.append(contentsOf: fusion.evidence)
        }

        return Array(Set(evidence))
    }

    private func measureCoherence(
        knowledgePackage: CAN_KNOWLEDGE,
        linked: [CAN_RELATION_REF],
        contradictions: [Contradiction],
        fused: [FusionRecord]
    ) -> Double {
        guard !knowledgePackage.canContent.isEmpty else { return 0.0 }

        let baseScore = knowledgePackage.canConfidence
        let relationBonus = min(0.2, Double(linked.count) * 0.02)
        let contradictionPenalty = Double(contradictions.filter { $0.severity == .critical }.count) * 0.15
        let contradictionWarningPenalty = Double(contradictions.filter { $0.severity == .warning }.count) * 0.05
        let fusionBonus = fused.isEmpty ? 0.0 : Double(fused.count) * 0.03
        let evidenceBonus = min(0.15, Double(knowledgePackage.canEvidence.count) * 0.01)

        let score = baseScore + relationBonus - contradictionPenalty - contradictionWarningPenalty + fusionBonus + evidenceBonus

        return max(0.0, min(1.0, score))
    }

    private func computeConfidence(
        knowledgePackage: CAN_KNOWLEDGE,
        coherenceScore: Double,
        contradictions: [Contradiction],
        fused: [FusionRecord]
    ) -> Double {
        let criticalContradictions = contradictions.filter { $0.severity == .critical }.count
        let warningContradictions = contradictions.filter { $0.severity == .warning }.count

        var confidence = knowledgePackage.canConfidence
        confidence *= coherenceScore
        confidence -= Double(criticalContradictions) * 0.1
        confidence -= Double(warningContradictions) * 0.03
        confidence += fused.isEmpty ? 0.0 : 0.02

        return max(0.0, min(1.0, confidence))
    }

    private func buildProjectionTargets(from knowledge: CAN_KNOWLEDGE) -> [String] {
        var targets = Set(knowledge.canProjections)

        if targets.isEmpty {
            targets = ["swift", "json", "markdown"]
        }

        if knowledge.canContent.contains("constraint") || knowledge.canContent.contains("rule") {
            targets.insert("bash")
        }

        return Array(targets).sorted()
    }

    private func areSemanticallyRelated(_ wordA: String, _ wordB: String) -> Bool {
        if wordA == wordB { return true }

        let semanticGroups: [[String]] = [
            ["concept", "notion", "idea", "thought", "notion"],
            ["entity", "component", "module", "service", "system"],
            ["relation", "link", "connect", "bind", "associate"],
            ["constraint", "rule", "policy", "limit", "boundary"],
            ["projection", "render", "transform", "output", "view"],
            ["runtime", "execute", "run", "process", "interpret"],
            ["knowledge", "truth", "fact", "evidence", "proof"],
            ["canonical", "standard", "formal", "official", "normative"]
        ]

        for group in semanticGroups {
            if group.contains(wordA) && group.contains(wordB) {
                return true
            }
        }

        return false
    }
}