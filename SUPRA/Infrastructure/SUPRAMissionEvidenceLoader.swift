import Foundation

// SUPRA_MISSION_EVIDENCE_LOADER_V1_BEGIN

nonisolated struct SUPRAMissionEvidencePayload: Codable, Sendable {
    let evidenceId: String
    let sourcePath: String
    let contentType: String
    let content: String
}

nonisolated enum SUPRAMissionEvidenceLoader {
    private static let maximumEvidenceBytes = 262_144

    static func loadRequiredEvidence() -> [SUPRAMissionEvidencePayload] {
        let home = FileManager.default.homeDirectoryForCurrentUser

        let probeRoot = home.appendingPathComponent(
            "NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/PROBES",
            isDirectory: true
        )

        let actionRunsRoot = home.appendingPathComponent(
            "NOVA_OS/SUPRA_ACTION_CENTER_V1/ACTION_RUNS",
            isDirectory: true
        )

        let reconciliationRunsRoot = home.appendingPathComponent(
            "NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/RUNS",
            isDirectory: true
        )

        let graphSchemaProbeURL = latestExistingFile(
            under: probeRoot,
            acceptedExtensions: ["json", "txt", "tsv"],
            requiredNameFragments: ["GRAPH", "SCHEMA"]
        )

        let actionStatusURL = latestExistingFile(
            under: actionRunsRoot,
            acceptedExtensions: ["json", "txt"],
            requiredNameFragments: ["STATUS"],
            requiredPathFragments: ["probe-project-graph"]
        )

        let reconciliationStatusURL = latestExistingFile(
            under: reconciliationRunsRoot,
            acceptedExtensions: ["json", "txt"],
            requiredNameFragments: ["STATUS"]
        )

        var evidence: [SUPRAMissionEvidencePayload] = []

        if let graphSchemaProbeURL,
           let loaded = load(
               evidenceId: "GRAPH_SCHEMA_PROBE",
               url: graphSchemaProbeURL
           ) {
            evidence.append(loaded)
        }

        if let statusURL = actionStatusURL ?? reconciliationStatusURL,
           let loaded = load(
               evidenceId: "STATUS",
               url: statusURL
           ) {
            evidence.append(loaded)
        }

        return evidence
    }

    private static func load(
        evidenceId: String,
        url: URL
    ) -> SUPRAMissionEvidencePayload? {
        guard FileManager.default.fileExists(atPath: url.path),
              let handle = try? FileHandle(forReadingFrom: url)
        else {
            return nil
        }

        defer {
            try? handle.close()
        }

        guard let data = try? handle.read(upToCount: maximumEvidenceBytes),
              !data.isEmpty
        else {
            return nil
        }

        let fileExtension = url.pathExtension.lowercased()

        let contentType: String

        switch fileExtension {
        case "json":
            contentType = "application/json"
        case "tsv":
            contentType = "text/tab-separated-values"
        default:
            contentType = "text/plain"
        }

        return SUPRAMissionEvidencePayload(
            evidenceId: evidenceId,
            sourcePath: url.path,
            contentType: contentType,
            content: String(decoding: data, as: UTF8.self)
        )
    }

    private static func latestExistingFile(
        under rootURL: URL,
        acceptedExtensions: Set<String>,
        requiredNameFragments: [String],
        requiredPathFragments: [String] = []
    ) -> URL? {
        guard FileManager.default.fileExists(atPath: rootURL.path),
              let enumerator = FileManager.default.enumerator(
                  at: rootURL,
                  includingPropertiesForKeys: [
                      .contentModificationDateKey,
                      .isRegularFileKey
                  ],
                  options: [
                      .skipsHiddenFiles,
                      .skipsPackageDescendants
                  ]
              )
        else {
            return nil
        }

        let normalizedNameFragments = requiredNameFragments.map {
            $0.uppercased()
        }

        let normalizedPathFragments = requiredPathFragments.map {
            $0.lowercased()
        }

        var latestURL: URL?
        var latestDate = Date.distantPast

        for case let candidateURL as URL in enumerator {
            let values = try? candidateURL.resourceValues(
                forKeys: [
                    .contentModificationDateKey,
                    .isRegularFileKey
                ]
            )

            guard values?.isRegularFile == true else {
                continue
            }

            let fileExtension = candidateURL.pathExtension.lowercased()

            guard acceptedExtensions.contains(fileExtension) else {
                continue
            }

            let normalizedName = candidateURL.lastPathComponent.uppercased()

            guard normalizedNameFragments.allSatisfy(
                normalizedName.contains
            ) else {
                continue
            }

            let normalizedPath = candidateURL.path.lowercased()

            guard normalizedPathFragments.allSatisfy(
                normalizedPath.contains
            ) else {
                continue
            }

            let modificationDate =
                values?.contentModificationDate ?? .distantPast

            if modificationDate > latestDate {
                latestDate = modificationDate
                latestURL = candidateURL
            }
        }

        return latestURL
    }

    static func removePlaceholderMissionEvidence(
        from root: inout [String: Any]
    ) {
        let protectedEvidenceIds = Set([
            "GRAPH_SCHEMA_PROBE",
            "STATUS"
        ])

        let genericEvidenceKeys = [
            "evidence",
            "evidences",
            "sources",
            "canonical_sources",
            "ui_evidence",
            "executive_evidence",
            "context_sources"
        ]

        for key in genericEvidenceKeys {
            if let values = root[key] as? [String] {
                root[key] = values.filter {
                    !protectedEvidenceIds.contains($0)
                }
                continue
            }

            if let values = root[key] as? [[String: Any]] {
                root[key] = values.filter { item in
                    let possibleId =
                        item["evidence_id"] as? String
                        ?? item["id"] as? String
                        ?? item["name"] as? String
                        ?? item["label"] as? String

                    guard let possibleId,
                          protectedEvidenceIds.contains(possibleId)
                    else {
                        return true
                    }

                    let content = item["content"] as? String

                    return content?.isEmpty == false
                }
            }
        }
    }
}

// SUPRA_MISSION_EVIDENCE_LOADER_V1_END
