import Foundation

public final class ComparePhase: Sendable {
    public init() {}

    public func execute(clusters: [DuplicateCluster]) -> [ComparativeAnalysis] {
        return clusters.map { cluster in
            analyze(cluster: cluster)
        }
    }

    private func analyze(cluster: DuplicateCluster) -> ComparativeAnalysis {
        let primary = cluster.artifacts.first
        let comparisons = cluster.artifacts.dropFirst().map { artifact in
            compare(primaryArtifact: primary!, candidate: artifact)
        }

        let semanticScore = computeSemanticScore(cluster: cluster)
        let structuralScore = computeStructuralScore(cluster: cluster)
        let overlapScore = computeOverlapScore(cluster: cluster)
        let overallConfidence = (semanticScore * 0.4) + (structuralScore * 0.3) + (overlapScore * 0.3)

        return ComparativeAnalysis(
            clusterId: cluster.id,
            semanticKey: cluster.semanticKey,
            primaryArtifact: primary,
            candidateArtifacts: Array(cluster.artifacts.dropFirst()),
            comparisons: comparisons,
            semanticScore: semanticScore,
            structuralScore: structuralScore,
            overlapScore: overlapScore,
            overallConfidence: overallConfidence,
            recommendation: recommendAction(for: overallConfidence, cluster: cluster),
            evidence: generateEvidence(cluster: cluster)
        )
    }

    private func compare(primaryArtifact: ArtifactReference, candidate: ArtifactReference) -> ComparisonResult {
        let nameSimilarity = computeNameSimilarity(primaryArtifact, candidate)
        let contentSimilarity = computeContentSimilarity(primaryArtifact, candidate)
        let structuralSimilarity = computeStructuralSimilarity(primaryArtifact, candidate)
        let semanticOverlap = computeSemanticOverlap(primaryArtifact, candidate)

        let overall = (nameSimilarity * 0.3) + (contentSimilarity * 0.3) + (structuralSimilarity * 0.2) + (semanticOverlap * 0.2)

        return ComparisonResult(
            candidate: candidate,
            nameSimilarity: nameSimilarity,
            contentSimilarity: contentSimilarity,
            structuralSimilarity: structuralSimilarity,
            semanticOverlap: semanticOverlap,
            overallScore: overall,
            isDuplicate: overall > 0.85,
            isEquivalent: overall > 0.70 && overall <= 0.85,
            isRelated: overall > 0.40 && overall <= 0.70,
            isDistinct: overall <= 0.40
        )
    }

    private func computeNameSimilarity(_ a: ArtifactReference, _ b: ArtifactReference) -> Double {
        let aWords = Set(a.name.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })
        let bWords = Set(b.name.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })

        if aWords.isEmpty || bWords.isEmpty { return 0.0 }
        let intersection = aWords.intersection(bWords)
        let union = aWords.union(bWords)
        return Double(intersection.count) / Double(union.count)
    }

    private func computeContentSimilarity(_ a: ArtifactReference, _ b: ArtifactReference) -> Double {
        if a.checksum == b.checksum { return 1.0 }
        return 0.0
    }

    private func computeStructuralSimilarity(_ a: ArtifactReference, _ b: ArtifactReference) -> Double {
        if a.type == b.type { return 0.9 }
        if sourceCategoryMatches(a.sourceCategory, b.sourceCategory) { return 0.7 }
        return 0.3
    }

    private func sourceCategoryMatches(_ catA: String, _ catB: String) -> Bool {
        let categoryGroups = [
            ["source_code", "swift_source"],
            ["orchestration", "bash_orchestration"],
            ["data", "json_data"],
            ["configuration", "yaml_configuration"],
            ["documentation", "markdown_documentation"],
            ["data_definition", "sql_definition"]
        ]
        for group in categoryGroups {
            if group.contains(catA) && group.contains(catB) { return true }
        }
        return false
    }

    private func computeSemanticOverlap(_ a: ArtifactReference, _ b: ArtifactReference) -> Double {
        let aSemantics = Set(a.semanticFingerprint.split(separator: "|").map { String($0) })
        let bSemantics = Set(b.semanticFingerprint.split(separator: "|").map { String($0) })

        if aSemantics.isEmpty || bSemantics.isEmpty { return 0.0 }
        let intersection = aSemantics.intersection(bSemantics)
        return Double(intersection.count) / Double(max(aSemantics.count, bSemantics.count))
    }

    private func computeSemanticScore(cluster: DuplicateCluster) -> Double {
        let avg = cluster.artifacts.map { $0.semanticFingerprint }.reduce(into: [:]) { counts, fp in
            counts[fp, default: 0] += 1
        }
        let maxCount = avg.values.max() ?? 1
        return Double(maxCount) / Double(cluster.artifacts.count)
    }

    private func computeStructuralScore(cluster: DuplicateCluster) -> Double {
        let types = Set(cluster.artifacts.map { $0.type })
        if types.count == 1 { return 1.0 }
        return 1.0 - (Double(types.count - 1) * 0.25)
    }

    private func computeOverlapScore(cluster: DuplicateCluster) -> Double {
        guard cluster.artifacts.count > 1 else { return 1.0 }
        let primary = cluster.artifacts[0]
        let overlaps = cluster.artifacts.dropFirst().filter { art in
            art.sourceCategory == primary.sourceCategory
        }
        return Double(overlaps.count + 1) / Double(cluster.artifacts.count)
    }

    private func recommendAction(for confidence: Double, cluster: DuplicateCluster) -> Recommendation {
        if confidence >= 0.90 {
            return .canonicalize
        } else if confidence >= 0.75 {
            return .merge
        } else if confidence >= 0.50 {
            return .review
        } else {
            return .keepSeparate
        }
    }

    private func generateEvidence(cluster: DuplicateCluster) -> [String] {
        var evidence: [String] = []

        let types = Set(cluster.artifacts.map { $0.type })
        evidence.append("Artifact types: \(types.map { $0.rawValue }.joined(separator: ", "))")
        evidence.append("Cluster size: \(cluster.artifacts.count)")
        evidence.append("Confidence: \(String(format: "%.2f", cluster.confidence))")

        let uniquePaths = Set(cluster.artifacts.map { $0.path })
        evidence.append("Unique source paths: \(uniquePaths.count)")

        let uniqueChecksums = Set(cluster.artifacts.map { $0.checksum })
        evidence.append("Unique checksums: \(uniqueChecksums.count)")

        if uniqueChecksums.count == 1 {
            evidence.append("All artifacts share identical checksum — exact duplicates")
        }

        return evidence
    }
}

public struct ComparativeAnalysis: Codable, Hashable, Sendable {
    public let clusterId: String
    public let semanticKey: String
    public let primaryArtifact: ArtifactReference?
    public let candidateArtifacts: [ArtifactReference]
    public let comparisons: [ComparisonResult]
    public let semanticScore: Double
    public let structuralScore: Double
    public let overlapScore: Double
    public let overallConfidence: Double
    public let recommendation: Recommendation
    public let evidence: [String]

    public enum Recommendation: String, Codable, Hashable, Sendable {
        case canonicalize = "canonicalize"
        case merge = "merge"
        case review = "review"
        case keepSeparate = "keep_separate"
    }
}

public struct ComparisonResult: Codable, Hashable, Sendable {
    public let candidate: ArtifactReference?
    public let nameSimilarity: Double
    public let contentSimilarity: Double
    public let structuralSimilarity: Double
    public let semanticOverlap: Double
    public let overallScore: Double
    public let isDuplicate: Bool
    public let isEquivalent: Bool
    public let isRelated: Bool
    public let isDistinct: Bool
}