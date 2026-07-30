import Foundation

public final class DetectPhase: Sendable {
    public init() {}

    public func execute(path: String) async throws -> [ArtifactReference] {
        var artifacts: [ArtifactReference] = []

        let discovered = try discoverArtifacts(at: path)
        for artifact in discovered {
            let fingerprint = computeSemanticFingerprint(artifact: artifact)
            let canonicalId = computeCANID(artifact: artifact)
            let enriched = ArtifactReference(
                id: artifact.id,
                type: artifact.type,
                path: artifact.path,
                name: artifact.name,
                sizeBytes: artifact.sizeBytes,
                lastModified: artifact.lastModified,
                checksum: artifact.checksum,
                canonicalId: canonicalId,
                semanticFingerprint: fingerprint,
                sourceCategory: classifySource(artifact: artifact)
            )
            artifacts.append(enriched)
        }

        return artifacts
    }

    private func discoverArtifacts(at path: String) throws -> [ArtifactReference] {
        var results: [ArtifactReference] = []

        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else {
            return results
        }

        let rootURL = URL(fileURLWithPath: path)

        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants],
            errorHandler: { _, _ in true }
        ) else {
            return results
        }

        for case let elementURL as URL in enumerator {
            let relativePath = elementURL.path.replacingOccurrences(of: path, with: "")
            guard let asset = buildArtifactReference(url: elementURL, relativePath: relativePath) else {
                continue
            }
            results.append(asset)
        }

        return results
    }

    private func buildArtifactReference(url: URL, relativePath: String) -> ArtifactReference? {
        let fileManager = FileManager.default

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory),
              !isDirectory.boolValue else {
            return nil
        }

        let ext = url.pathExtension.lowercased()
        let type = artifactType(forExtension: ext)

        let attributes = try? fileManager.attributesOfItem(atPath: url.path)
        let sizeBytes = attributes?[.size] as? Int64 ?? 0
        let modDate = attributes?[.contentModificationDate] as? Date ?? Date()
        let content = try? String(contentsOf: url, encoding: .utf8) ?? ""
        let checksum = computeChecksum(content: content)
        let name = url.lastPathComponent

        return ArtifactReference(
            id: UUID().uuidString,
            type: type,
            path: relativePath,
            name: name,
            sizeBytes: sizeBytes,
            lastModified: Int64(modDate.timeIntervalSince1970 * 1000),
            checksum: checksum,
            canonicalId: nil,
            semanticFingerprint: "",
            sourceCategory: sourceCategory(forExtension: ext)
        )
    }

    private func artifactType(forExtension ext: String) -> ARTIFACT_TYPE {
        switch ext {
        case "swift": return .swiftFile
        case "sh", "bash": return .bashScript
        case "json": return .jsonFile
        case "yaml", "yml": return .yamlFile
        case "md", "markdown": return .markdownFile
        case "sql": return .sqlFile
        default: return .swiftFile
        }
    }

    private func sourceCategory(forExtension ext: String) -> String {
        switch ext {
        case "swift": return "source_code"
        case "sh", "bash": return "orchestration"
        case "json": return "data"
        case "yaml", "yml": return "configuration"
        case "md", "markdown": return "documentation"
        case "sql": return "data_definition"
        default: return "unknown"
        }
    }

    private func computeChecksum(content: String) -> String {
        let data = content.data(using: .utf8) ?? Data()
        var hash = [UInt8](repeating: 0, count: 32)
        data.withUnsafeBytes { bytes in
            CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private func computeSemanticFingerprint(artifact: ArtifactReference) -> String {
        let components = [
            artifact.type.rawValue,
            artifact.sourceCategory,
            artifact.name
        ]
        let combined = components.joined(separator: "|")
        return combined.sha256()
    }

    private func computeCANID(artifact: ArtifactReference) -> CAN_ID {
        let hash = artifact.checksum.prefix(16)
        return CAN_ID(type: typeForArtifact(artifact.type), hash: String(hash))
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

    private func classifySource(artifact: ArtifactReference) -> String {
        switch artifact.type {
        case .swiftFile: return "swift_source"
        case .bashScript: return "bash_orchestration"
        case .jsonFile: return "json_data"
        case .yamlFile: return "yaml_configuration"
        case .markdownFile: return "markdown_documentation"
        case .sqlFile: return "sql_definition"
        default: return "unknown"
        }
    }
}