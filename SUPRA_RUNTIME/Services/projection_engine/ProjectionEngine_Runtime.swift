import Foundation

public final class ProjectionEngine: Sendable {
    public static let shared = ProjectionEngine()

    public struct ProjectionResult: Codable, Hashable, Sendable {
        public let projectionId: String
        public let targetFormat: String
        public let content: String
        public let sourceCanonicalId: CAN_ID
        public let canonicalName: String
        public let derivationTrace: [CAN_ID]
        public let tick: Int64
        public let validated: Bool
        public let validationReason: String?
    }

    public enum ProjectionFormat: String, Codable, CaseIterable, Sendable {
        case swift = "swift"
        case bash = "bash"
        case json = "json"
        case markdown = "markdown"
        case yaml = "yaml"
        case api = "api"
        case html = "html"
        case sql = "sql"
    }

    private init() {}

    public func project(from canonicalObject: CanonicalKnowledgeObject) -> [ProjectionResult] {
        var results: [ProjectionResult] = []

        for format in ProjectionFormat.allCases {
            let content = generateProjection(canonicalObject: canonicalObject, format: format)
            let result = ProjectionResult(
                projectionId: "proj:\(format.rawValue):\(canonicalObject.canId.hash.prefix(8))",
                targetFormat: format.rawValue,
                content: content,
                sourceCanonicalId: canonicalObject.canId,
                canonicalName: canonicalObject.canName,
                derivationTrace: canonicalObject.canTrace,
                tick: NAMBROCAHORA.advance(),
                validated: verifyDerivation(canonicalObject: canonicalObject, projection: content),
                validationReason: verifyDerivation(canonicalObject: canonicalObject, projection: content) ? nil : "Projection contains logic absent from canonical model"
            )
            results.append(result)
        }

        return results
    }

    public func project(from candidate: PUCHERO_Runtime.KnowledgeCandidate) -> [ProjectionResult] {
        let canonicalObject = canonicalize(candidate)
        return project(from: canonicalObject)
    }

    private func canonicalize(_ candidate: PUCHERO_Runtime.KnowledgeCandidate) -> CanonicalKnowledgeObject {
        let canonicalId = candidate.canPackage.canId
        let tick = NAMBROCAHORA.advance()

        let definitions = buildDefinitions(from: candidate)
        let responsibilities = buildResponsibilities(from: candidate)
        let relations = buildRelations(from: candidate)
        let constraints = buildConstraints(from: candidate)
        let proofs = buildProofs(from: candidate)

        return CanonicalKnowledgeObject(
            canId: canonicalId,
            canName: candidate.canName,
            canVersion: .v1,
            canDefinitions: definitions,
            canResponsibilities: responsibilities,
            canRelations: relations,
            canConstraints: constraints,
            canProofs: proofs,
            nambrohoraRef: candidate.tick,
            canTrace: candidate.trace,
            canProjections: candidate.projectionTargets,
            canConfidence: candidate.confidenceScore,
            canCoherence: candidate.coherenceScore,
            compiledAt: tick,
            canonicalForm: .official,
            validated: candidate.validated,
            rejectionReason: candidate.rejectionReason
        )
    }

    private func buildDefinitions(from candidate: PUCHERO_Runtime.KnowledgeCandidate) -> [String: String] {
        var definitions: [String: String] = [:]

        definitions["name"] = candidate.canName
        definitions["source"] = candidate.canPackage.canSource.joined(separator: ", ")
        definitions["confidence"] = String(format: "%.4f", candidate.confidenceScore)
        definitions["coherence"] = String(format: "%.4f", candidate.coherenceScore)
        definitions["concepts_count"] = String(candidate.canPackage.canRelations.count)
        definitions["contradictions"] = String(candidate.contradictions.count)
        definitions["fusions"] = String(candidate.fusedDuplicates.count)

        return definitions
    }

    private func buildResponsibilities(from candidate: PUCHERO_Runtime.KnowledgeCandidate) -> [String] {
        var responsibilities: Set<String> = []

        responsibilities.insert("transform")
        responsibilities.insert("validate")
        responsibilities.insert("project")
        responsibilities.insert("trace")

        for contradiction in candidate.contradictions {
            responsibilities.insert("resolve:\(contradiction.type.rawValue)")
        }

        for fusion in candidate.fusedDuplicates {
            responsibilities.insert("merge")
        }

        return Array(responsibilities).sorted()
    }

    private func buildRelations(from candidate: PUCHERO_Runtime.KnowledgeCandidate) -> [CAN_RELATION_REF] {
        return candidate.linkedConcepts
    }

    private func buildConstraints(from candidate: PUCHERO_Runtime.KnowledgeCandidate) -> [CAN_ID] {
        return candidate.canPackage.canConstraints
    }

    private func buildProofs(from candidate: PUCHERO_Runtime.KnowledgeCandidate) -> [CAN_ID] {
        return candidate.accumulatedEvidence
    }

    private func generateProjection(canonicalObject: CanonicalKnowledgeObject, format: ProjectionFormat) -> String {
        switch format {
        case .swift:
            return generateSwiftProjection(canonicalObject)
        case .bash:
            return generateBashProjection(canonicalObject)
        case .json:
            return generateJSONProjection(canonicalObject)
        case .markdown:
            return generateMarkdownProjection(canonicalObject)
        case .yaml:
            return generateYAMLProjection(canonicalObject)
        case .api:
            return generateAPIDefinition(canonicalObject)
        case .html:
            return generateHTMLProjection(canonicalObject)
        case .sql:
            return generateSQLProjection(canonicalObject)
        }
    }

    private func generateSwiftProjection(_ obj: CanonicalKnowledgeObject) -> String {
        let lines = [
            "// AUTO-GENERATED by ProjectionEngine — derived exclusively from canonical model",
            "// Canonical ID: \(obj.canId.value)",
            "// NAMBROCAHORA Tick: \(obj.nambrohoraRef)",
            "// Trace: \(obj.canTrace.map { $0.value }.joined(separator: " → "))",
            "",
            "public struct \(safeName(obj.canName)): Sendable {",
            "    public let canId: CAN_ID",
            "    public let canName: String",
            "    public let confidence: Double",
            "    public let coherence: Double",
            "    public let nambrohoraRef: Int64",
            "",
            "    public init(",
            "        canId: CAN_ID,",
            "        canName: String,",
            "        confidence: Double,",
            "        coherence: Double,",
            "        nambrohoraRef: Int64",
            "    ) {",
            "        self.canId = canId",
            "        self.canName = canName",
            "        self.confidence = confidence",
            "        self.coherence = coherence",
            "        self.nambrohoraRef = nambrohoraRef",
            "    }",
            "}",
            ""
        ]

        var output = lines.joined(separator: "\n")

        let responsibilities = obj.canResponsibilities
        if !responsibilities.isEmpty {
            output += "\n// Responsibilities derived from canonical model\n"
            for responsibility in responsibilities {
                output += "public func execute_\(responsibility.replacingOccurrences(of: ":", with: "_"))() {\n    // Canonical responsibility: \(responsibility)\n}\n"
            }
        }

        return output
    }

    private func generateBashProjection(_ obj: CanonicalKnowledgeObject) -> String {
        let lines = [
            "#!/usr/bin/env bash",
            "# AUTO-GENERATED by ProjectionEngine — derived exclusively from canonical model",
            "# Canonical ID: \(obj.canId.value)",
            "# NAMBROCAHORA Tick: \(obj.nambrohoraRef)",
            "# Trace: \(obj.canTrace.map { $0.value }.joined(separator: " → "))",
            "",
            "set -euo pipefail",
            "",
            "SUPRA_CANONICAL_ID=\"\(obj.canId.value)\"",
            "SUPRA_CANONICAL_NAME=\"\(obj.canName)\"",
            "SUPRA_CONFIDENCE=\"\(String(format: "%.4f", obj.canConfidence))\"",
            "SUPRA_COHERENCE=\"\(String(format: "%.4f", obj.canCoherence))\"",
            "SUPRA_NAMBROCAHORA_TICK=\"\(obj.nambrohoraRef)\"",
            "",
            "echo \"[SUPRA Projection: \(obj.canName)]\"",
            "echo \"  Canonical ID: $SUPRA_CANONICAL_ID\"",
            "echo \"  Confidence: $SUPRA_CONFIDENCE\"",
            "echo \"  Coherence: $SUPRA_COHERENCE\"",
            "echo \"  Tick: $SUPRA_NAMBROCAHORA_TICK\"",
            "",
            "exec 3>&1",
            "LOG_FILE=\"${SUPRA_RUNTIME_LOG:-/tmp/supra_projection.log}\"",
            "echo \"[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Projection executed: \(obj.canName)\" | tee /dev/fd/3 >> \"$LOG_FILE\"",
            "",
            "exit 0"
        ]

        return lines.joined(separator: "\n")
    }

    private func generateJSONProjection(_ obj: CanonicalKnowledgeObject) -> String {
        let json: [String: Any] = [
            "$schema": "SUPRA_Projection_V1",
            "canonicalId": obj.canId.value,
            "canonicalName": obj.canName,
            "version": obj.canVersion.rawValue,
            "definitions": obj.canDefinitions,
            "responsibilities": obj.canResponsibilities,
            "relations": obj.canRelations.map { [
                "target": $0.target.value,
                "type": $0.relationType.rawValue,
                "weight": $0.weight,
                "validated": $0.validated
            ]},
            "constraints": obj.canConstraints.map { $0.value },
            "proofs": obj.canProofs.map { $0.value },
            "nambrohoraRef": obj.nambrohoraRef,
            "trace": obj.canTrace.map { $0.value },
            "confidence": obj.canConfidence,
            "coherence": obj.canCoherence,
            "projectionFormat": "json",
            "compiledAt": obj.compiledAt,
            "validated": obj.validated
        ]

        let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        return String(data: data ?? Data(), encoding: .utf8) ?? "{}"
    }

    private func generateMarkdownProjection(_ obj: CanonicalKnowledgeObject) -> String {
        let lines = [
            "# \(obj.canName)",
            "",
            "**Canonical ID:** `\(obj.canId.value)`",
            "**Version:** \(obj.canVersion.rawValue)",
            "**NAMBROCAHORA Tick:** \(obj.nambrohoraRef)",
            "**Confidence:** \(String(format: "%.4f", obj.canConfidence))",
            "**Coherence:** \(String(format: "%.4f", obj.canCoherence))",
            "**Validated:** \(obj.validated ? "Yes" : "No")",
            "",
            "## Definitions",
            ""
        ]

        for (key, value) in obj.canDefinitions {
            lines.append("- **\(key)**: \(value)")
        }

        lines.append("")
        lines.append("## Responsibilities")
        ""

        for responsibility in obj.canResponsibilities {
            lines.append("- \(responsibility)")
        }

        lines.append("")
        lines.append("## Trace")
        ""

        lines.append("```")
        lines.append(obj.canTrace.map { $0.value }.joined(separator: " → "))
        lines.append("```")

        lines.append("")
        lines.append("## Derivation")
        ""
        lines.append("This projection is fully derived from the Canonical Knowledge Object.")
        lines.append("No business information was added directly in this artifact.")
        lines.append("Any modification to the canonical model can be reprojected automatically.")

        return lines.joined(separator: "\n")
    }

    private func generateYAMLProjection(_ obj: CanonicalKnowledgeObject) -> String {
        let lines = [
            "canonical:",
            "  id: \"\(obj.canId.value)\"",
            "  name: \"\(obj.canName)\"",
            "  version: \"\(obj.canVersion.rawValue)\"",
            "  confidence: \(String(format: "%.4f", obj.canConfidence))",
            "  coherence: \(String(format: "%.4f", obj.canCoherence))",
            "  validated: \(obj.validated)",
            "  nambrohora_ref: \(obj.nambrohoraRef)",
            "",
            "definitions:",
        ]

        for (key, value) in obj.canDefinitions {
            lines.append("  \(key): \"\(value)\"")
        }

        lines.append("")
        lines.append("responsibilities:")
        for responsibility in obj.canResponsibilities {
            lines.append("  - \(responsibility)")
        }

        lines.append("")
        lines.append("trace:")
        for traceId in obj.canTrace {
            lines.append("  - \"\(traceId.value)\"")
        }

        return lines.joined(separator: "\n")
    }

    private func generateAPIDefinition(_ obj: CanonicalKnowledgeObject) -> String {
        let lines = [
            "openapi: \"3.0.0\"",
            "info:",
            "  title: \(obj.canName)",
            "  version: \(obj.canVersion.rawValue)",
            "  description: Projection of canonical model \(obj.canId.value)",
            "paths:",
            "  /canonical/",
            "    get:",
            "      summary: Retrieve canonical knowledge object",
            "      parameters:",
            "        - name: canonicalId",
            "          in: path",
            "          required: true",
            "          schema:",
            "            type: string",
            "            example: \"\(obj.canId.value)\"",
            "      responses:",
            "        '200':",
            "          description: Canonical knowledge object",
            "          content:",
            "            application/json:",
            "              schema:",
            "                type: object",
            "                properties:",
            "                  canId:",
            "                    type: string",
            "                  canName:",
            "                    type: string",
            "                  confidence:",
            "                    type: number",
            "                  coherence:",
            "                    type: number",
            "                  validated:",
            "                    type: boolean",
            "                  nambrohoraRef:",
            "                    type: integer"
        ]

        return lines.joined(separator: "\n")
    }

    private func generateHTMLProjection(_ obj: CanonicalKnowledgeObject) -> String {
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <title>\(escapeHTML(obj.canName)) — Canonical Projection</title>
        <style>
        body { font-family: system-ui; margin: 2rem; color: #1a1a1a; }
        .canonical { border: 2px solid #2563eb; border-radius: 8px; padding: 1.5rem; margin: 1rem 0; }
        .field { margin: 0.5rem 0; }
        .label { font-weight: 600; color: #6b7280; }
        .value { font-family: monospace; background: #f3f4f6; padding: 0.2rem 0.5rem; border-radius: 4px; }
        .validated { color: #16a34a; font-weight: bold; }
        .trace { font-family: monospace; font-size: 0.85rem; word-break: break-all; }
        </style>
        </head>
        <body>
        <h1>\(escapeHTML(obj.canName))</h1>
        <div class="canonical">
          <div class="field"><span class="label">Canonical ID:</span> <span class="value">\(escapeHTML(obj.canId.value))</span></div>
          <div class="field"><span class="label">Version:</span> \(obj.canVersion.rawValue)</div>
          <div class="field"><span class="label">Confidence:</span> \(String(format: "%.4f", obj.canConfidence))</div>
          <div class="field"><span class="label">Coherence:</span> \(String(format: "%.4f", obj.canCoherence))</div>
          <div class="field"><span class="label">Validated:</span> <span class="validated">\(obj.validated ? "Yes" : "No")</span></div>
          <div class="field"><span class="label">NAMBROCAHORA Tick:</span> \(obj.nambrohoraRef)</div>
          <div class="field"><span class="label">Trace:</span> <span class="trace">\(obj.canTrace.map { escapeHTML($0.value) }.joined(separator: " → "))</span></div>
        </div>
        </body>
        </html>
        """

        return html
    }

    private func generateSQLProjection(_ obj: CanonicalKnowledgeObject) -> String {
        let lines = [
            "-- AUTO-GENERATED by ProjectionEngine — derived exclusively from canonical model",
            "-- Canonical ID: \(obj.canId.value)",
            "-- NAMBROCAHORA Tick: \(obj.nambrohoraRef)",
            "",
            "CREATE TABLE IF NOT EXISTS supra_canonical (",
            "    can_id TEXT PRIMARY KEY,",
            "    can_name TEXT NOT NULL,",
            "    can_version TEXT NOT NULL DEFAULT 'V1',",
            "    confidence REAL NOT NULL,",
            "    coherence REAL NOT NULL,",
            "    validated INTEGER NOT NULL DEFAULT 0,",
            "    nambrohora_ref INTEGER NOT NULL,",
            "    compiled_at INTEGER NOT NULL",
            ");",
            "",
            "INSERT OR REPLACE INTO supra_canonical VALUES (",
            "    '\(obj.canId.value)',",
            "    '\(obj.canName)',",
            "    '\(obj.canVersion.rawValue)',",
            "\(String(format: "%.4f", obj.canConfidence)),",
            "\(String(format: "%.4f", obj.canCoherence)),",
            "\(obj.validated ? 1 : 0),",
            "\(obj.nambrohoraRef),",
            "\(obj.compiledAt)",
            ");"
        ]

        return lines.joined(separator: "\n")
    }

    private func safeName(_ name: String) -> String {
        name.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined()
    }

    private func escapeHTML(_ input: String) -> String {
        input
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private func verifyDerivation(canonicalObject: CanonicalKnowledgeObject, projection: String) -> Bool {
        let forbiddenPatterns = [
            "TODO:",
            "FIXME:",
            "HACK:",
            "XXX:",
            "business logic",
            "domain specific",
            "custom requirement"
        ]

        for pattern in forbiddenPatterns {
            if projection.localizedCaseInsensitiveContains(pattern) {
                return false
            }
        }

        return true
    }
}

public struct CanonicalKnowledgeObject: Codable, Hashable, Sendable {
    public let canId: CAN_ID
    public let canName: String
    public let canVersion: CAN_VERSION
    public let canDefinitions: [String: String]
    public let canResponsibilities: [String]
    public let canRelations: [CAN_RELATION_REF]
    public let canConstraints: [CAN_ID]
    public let canProofs: [CAN_ID]
    public let nambrohoraRef: Int64
    public let canTrace: [CAN_ID]
    public let canProjections: [String]
    public let canConfidence: Double
    public let canCoherence: Double
    public let compiledAt: Int64
    public let canonicalForm: CanonicalForm
    public let validated: Bool
    public let rejectionReason: String?

    public enum CanonicalForm: String, Codable, Sendable {
        case candidate = "candidate"
        case official = "official"
        case derived = "derived"
    }
}