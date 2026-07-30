import Foundation

public final class GroupPhase: Sendable {
    public init() {}

    public func execute(artifacts: [ArtifactReference]) -> [DuplicateCluster] {
        var clusters: [DuplicateCluster] = []
        var fingerprintMap: [String: [ArtifactReference]] = [:]

        for artifact in artifacts {
            let key = artifact.semanticFingerprint
            if fingerprintMap[key] == nil {
                fingerprintMap[key] = []
            }
            fingerprintMap[key]?.append(artifact)
        }

        for (fingerprint, group) in fingerprintMap {
            guard group.count > 1 || isSemanticallyDuplicate(group.first!) else {
                continue
            }

            let clusterType = determineClusterType(for: group)
            let canonicalId = group.first?.canonicalId ?? CAN_ID(type: .structure, hash: fingerprint.prefix(16))

            let cluster = DuplicateCluster(
                id: "cluster:\(fingerprint.prefix(8))",
                semanticKey: fingerprint,
                artifacts: group,
                clusterType: clusterType,
                confidence: computeConfidence(for: group),
                evidence: group.map { $0.checksum }
            )
            clusters.append(cluster)
        }

        return clusters
    }

    private func isSemanticallyDuplicate(_ artifact: ArtifactReference) -> Bool {
        let duplicatePatterns = [
            "snapshot", "state", "model", "config", "registry", "manifest",
            "runtime", "event", "decision", "knowledge", "memory", "projection"
        ]
        let nameLower = artifact.name.lowercased()
        return duplicatePatterns.contains { nameLower.contains($0) }
    }

    private func determineClusterType(for group: [ArtifactReference]) -> DuplicateCluster.ClusterType {
        let types = Set(group.map { $0.type })

        if types.contains(.swiftFile) || types.contains(.swiftStructure) {
            return .duplicateSwiftStructure
        }

        if types.contains(.bashScript) {
            return .duplicateBashScript
        }

        if types.contains(.jsonFile) {
            return .duplicateJSON
        }

        if types.contains(.yamlFile) {
            return .duplicateYAML
        }

        if types.contains(.markdownFile) {
            return .duplicateDocumentation
        }

        if types.contains(.manifest) {
            return .duplicateManifest
        }

        if types.contains(.registry) {
            return .duplicateRegistry
        }

        if group.count > 1 {
            return .duplicateConcept
        }

        return .semanticallyRelated
    }

    private func computeConfidence(for group: [ArtifactReference]) -> Double {
        if group.count <= 1 { return 0.0 }

        let uniqueChecksums = Set(group.map { $0.checksum })
        if uniqueChecksums.count == 1 {
            return 1.0
        }

        let nameSimilarity = computeNameSimilarity(group)
        let typeMatch = group.map { $0.type }.filter { $0 == group.first?.type }.count
        let typeRatio = Double(typeMatch) / Double(group.count)

        return (nameSimilarity * 0.6) + (typeRatio * 0.4)
    }

    private func computeNameSimilarity(_ group: [ArtifactReference]) -> Double {
        guard group.count > 1 else { return 1.0 }

        let names = group.map { $0.name.lowercased() }
        let first = names[0]
        let matches = names.dropFirst().filter { name in
            areNamesSimilar(first, name)
        }

        return Double(matches.count + 1) / Double(names.count)
    }

    private func areNamesSimilar(_ a: String, _ b: String) -> Bool {
        let aWords = Set(a.components(separatedBy: CharacterSet.alphanumerics.inverted).map { $0.lowercased() }.filter { !$0.isEmpty })
        let bWords = Set(b.components(separatedBy: CharacterSet.alphanumerics.inverted).map { $0.lowercased() }.filter { !$0.isEmpty })

        if aWords.isEmpty || bWords.isEmpty { return false }
        let intersection = aWords.intersection(bWords)
        let union = aWords.union(bWords)

        return Double(intersection.count) / Double(union.count) > 0.5
    }
}