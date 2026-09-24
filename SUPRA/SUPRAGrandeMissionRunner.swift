import Foundation
import Combine

@MainActor
final class SUPRAGrandeMissionRunner: ObservableObject {
    static let shared = SUPRAGrandeMissionRunner()

    struct Phase: Identifiable, Sendable {
        let id: String
        let title: String
        let objective: String
    }

    struct PhaseReceipt: Codable, Sendable {
        let schema: String
        let missionID: String
        let phaseID: String
        let phaseTitle: String
        let startedAt: String
        let finishedAt: String
        let status: String
        let response: String
        let origin_conversation_id: String?
        let origin_chat: String?
    }

    struct HumanDecisionRecord: Codable, Sendable {
        let schema: String
        let missionID: String
        let phaseID: String
        let decidedAt: String
        let authority: String
        let decision: String
        let origin_conversation_id: String?
        let origin_chat: String?
    }

    struct HumanGatePacketRecord: Codable, Sendable {
        let schema: String
        let missionID: String
        let phaseID: String
        let receiptFinishedAt: String
        let createdAt: String
        let packet: String
        let origin_conversation_id: String?
        let origin_chat: String?
    }

    struct ExecutiveObjectiveResult: Sendable {
        let objectiveID: String
        let admissionPath: String
        let receiptPath: String
        let status: String
        let response: String
        let humanGateRequired: Bool
        let originConversationID: String
    }

    enum ExecutiveInterruptionIntent: String, Sendable {
        case standby = "STANDBY"
        case abort = "ABORTED"
    }

    private func microMissionResponsibilityLevel(in text: String) -> Int? {
        let prefix = "RESPONSIBILITY_LEVEL=L"
        for rawLine in text.split(whereSeparator: \.isNewline) {
            let line = String(rawLine)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .uppercased()
            guard line.hasPrefix(prefix) else { continue }
            let suffix = line.dropFirst(prefix.count)
            guard let first = suffix.first,
                  let level = Int(String(first)),
                  (1...7).contains(level)
            else { continue }
            if suffix.count == 1 { return level }
            let next = suffix[suffix.index(after: suffix.startIndex)]
            if next == "_" || next == " " || next == "|" {
                return level
            }
        }
        return nil
    }

    private func microMissionActionID(in text: String) -> String? {
        for rawLine in text.split(whereSeparator: \.isNewline) {
            let line = String(rawLine).trimmingCharacters(in: .whitespacesAndNewlines)
            guard line.uppercased().hasPrefix("ACTION_CENTER_ACTION_ID=") else { continue }
            let value = line.split(separator: "=", maxSplits: 1).dropFirst().first.map(String.init) ?? ""
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        return nil
    }

    private func executiveContractValue(
        _ key: String,
        in text: String
    ) -> String? {
        let wanted = key.uppercased()
        var payload = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let payloadLines = payload.components(separatedBy: .newlines)
        if payloadLines.count >= 3,
           payloadLines.first?.hasPrefix("```") == true,
           payloadLines.last?.trimmingCharacters(in: .whitespacesAndNewlines) == "```" {
            payload = payloadLines.dropFirst().dropLast().joined(separator: "\n")
        }

        if let data = payload.data(using: .utf8),
           let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            for (rawKey, rawValue) in object where rawKey.uppercased() == wanted {
                return String(describing: rawValue)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .uppercased()
            }
        }

        let linePrefix = wanted + "="
        let xmlOpen = "<" + wanted + ">"
        let xmlClose = "</" + wanted + ">"

        for rawLine in text.split(whereSeparator: \.isNewline) {
            let line = String(rawLine).trimmingCharacters(in: .whitespacesAndNewlines)
            let upper = line.uppercased()

            if upper.hasPrefix(linePrefix) {
                return String(line.dropFirst(linePrefix.count))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .uppercased()
            }

            let compact = upper
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "\t", with: "")
            if compact.hasPrefix(xmlOpen),
               compact.hasSuffix(xmlClose),
               compact.count > xmlOpen.count + xmlClose.count {
                return String(compact.dropFirst(xmlOpen.count).dropLast(xmlClose.count))
            }
        }

        return nil
    }

    private func executeAllowlistedMicroAction(
        actionID: String,
        objectiveID: String
    ) async throws -> String {
        let manifest = try SUPRAActionRuntime.loadManifest()
        guard let action = manifest.actions.first(where: { $0.id == actionID }) else {
            throw NSError(
                domain: "SUPRA.MicroMission",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Allowlisted action not found: \(actionID)"]
            )
        }

        let output = try await Task.detached(priority: .userInitiated) {
            try SUPRAActionRuntime.execute(action)
        }.value

        return """
        STATUS=PASS
        MICRO_MISSION_ROUTE=SUPRA_ACTION_CENTER_V1
        ACTION_CENTER_ACTION_ID=\(actionID)
        OBJECTIVE_ID=\(objectiveID)
        \(output)
        HUMAN_GATE_REQUIRED=NO
        ACTION_NICOLAS=NONE
        EXECUTION_VERDICT=MATERIAL_RESULT
        """
    }

    private struct MicroActionBackupSnapshot: Sendable {
        let path: String
        let existed: Bool
        let data: Data?
    }

    private func microMissionExpectedFailureCode(in text: String) -> Int32? {
        guard let raw = executiveContractValue("EXPECTED_FAILURE_CODE", in: text) else {
            return nil
        }
        return Int32(raw)
    }

    private func executeVerifiedRollbackMicroAction(
        actionID: String,
        objectiveID: String,
        expectedFailureCode: Int32
    ) async throws -> String {
        let manifest = try SUPRAActionRuntime.loadManifest()
        guard let action = manifest.actions.first(where: { $0.id == actionID }) else {
            throw NSError(
                domain: "SUPRA.MicroMission",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Allowlisted action not found: \(actionID)"]
            )
        }

        try SUPRAActionRuntime.verify(action)
        guard !action.backupPaths.isEmpty else {
            throw NSError(
                domain: "SUPRA.MicroMission",
                code: 412,
                userInfo: [NSLocalizedDescriptionKey: "L4 rollback verification requires explicit backup paths."]
            )
        }

        let fileManager = FileManager.default
        let before: [MicroActionBackupSnapshot] = try action.backupPaths.map { rawPath in
            let url = URL(fileURLWithPath: rawPath).resolvingSymlinksInPath()
            let existed = fileManager.fileExists(atPath: url.path)
            return MicroActionBackupSnapshot(
                path: url.path,
                existed: existed,
                data: existed ? try Data(contentsOf: url) : nil
            )
        }

        do {
            _ = try await Task.detached(priority: .userInitiated) {
                try SUPRAActionRuntime.execute(action)
            }.value
            throw NSError(
                domain: "SUPRA.MicroMission",
                code: 409,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "L4 expected failure code \(expectedFailureCode), but the action succeeded."
                ]
            )
        } catch let actionError as SUPRAActionError {
            guard case .executionFailed(let actualCode) = actionError,
                  actualCode == expectedFailureCode else {
                throw actionError
            }
        }

        for snapshot in before {
            let existsAfter = fileManager.fileExists(atPath: snapshot.path)
            guard existsAfter == snapshot.existed else {
                throw NSError(
                    domain: "SUPRA.MicroMission",
                    code: 500,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "L4 rollback verification failed for \(snapshot.path): existence mismatch."
                    ]
                )
            }
            if snapshot.existed {
                let afterData = try Data(contentsOf: URL(fileURLWithPath: snapshot.path))
                guard afterData == snapshot.data else {
                    throw NSError(
                        domain: "SUPRA.MicroMission",
                        code: 501,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "L4 rollback verification failed for \(snapshot.path): content mismatch."
                        ]
                    )
                }
            }
        }

        return """
        STATUS=PASS
        MICRO_MISSION_ROUTE=SUPRA_ACTION_CENTER_V1
        ACTION_CENTER_ACTION_ID=\(actionID)
        OBJECTIVE_ID=\(objectiveID)
        RESPONSIBILITY_LEVEL=L4_VERIFY_ROLLBACK
        EXPECTED_FAILURE_CODE=\(expectedFailureCode)
        L4_ROLLBACK_VERIFIED=YES
        RESTORE_MATCH=YES
        VERIFIED_BACKUP_PATHS=\(before.count)
        HUMAN_GATE_REQUIRED=NO
        ACTION_NICOLAS=NONE
        EXECUTION_VERDICT=MATERIAL_RESULT
        """
    }

    @Published private(set) var isRunning = false
    @Published private(set) var lastError: String?
    @Published private(set) var activePhaseID: String?
    @Published private(set) var activeExecutiveObjectiveID: String?
    @Published private(set) var isStandby = false
    @Published private(set) var isAborted = false

    private var executiveRuntimeTask: Task<String, Error>?
    private var phaseRuntimeTask: Task<String, Error>?
    private var executiveInterruptionIntent: ExecutiveInterruptionIntent?
    private var phaseAbortRequested = false

    let missionID = "GRANDE_MISSION_TOTAL_IMAC_CANNONICO_ALONSO_20260921"

    let phases: [Phase] = [
        .init(id: "01_RECOVER_TOTAL_REPERTORY", title: "Recover existing total repertory", objective: "Recover and reconcile existing Environment Manager, Project/Product/Capability registries, Runtime Discovery, Canonical Store, Atlas, memory, inventories, reports, manifests and Total System/File Twin evidence. Do not rescan from zero where equivalent evidence exists."),
        .init(id: "02_MEMORY_RECONCILIATION", title: "Memory reconciliation", objective: "Reconcile canonical conversations, messages, decisions, freezes, conflicts, source inventories, references, timelines and superseded states. Preserve raw history and explicit contradictions."),
        .init(id: "03_CANNONICO_HARDWARE_SOFTWARE", title: "CAnnoNico hardware + software", objective: "Build current evidence-backed hardware/software/environment graph using existing evidence first. No secrets. Separate historical from current/proven."),
        .init(id: "04_RESPONSIBILITY_AUTHORITY", title: "Responsibility + authority", objective: "Resolve canonical owners, responsibilities, authority, read/write scope, human gates, source-of-truth, fallbacks and overlaps only where evidence supports the decision."),
        .init(id: "05_PYRAMIDE_ALONSO", title: "Pyramide Alonso L1→L7", objective: "Map verified assets and capabilities across L1 Foundation through L7 Executive/Autonomy. Report proof, stability, control and recoverability without invented confidence."),
        .init(id: "06_CIRCULATION_CIRCULARITY", title: "Circulation + circularity", objective: "Map WORLD→OBSERVE→EVIDENCE→DECIDE→MISSION→EXECUTE→RESULT→LEARN→MEMORY→CANON→WORLD. Identify broken, dead-end, duplicate, unobserved and uncontrolled loops."),
        .init(id: "07_DEDUP_FUSION", title: "Deduplication + fusion", objective: "Compare duplicate/overlapping assets by authority, evidence, freshness, dependencies and live usage. Propose only reversible merge/hybridize/connect/retire/archive actions."),
        .init(id: "08_OPERATIONALIZATION", title: "Operationalization", objective: "For each VERIFIED capability, establish and prove: current input, output, runtime path, dependency path, observability, gate, mission routing and recovery path. Promote only executable or clearly bounded capabilities. Reuse existing owners/registries first; do not create an equivalent engine. Required outputs: OPERATIONAL_CAPABILITY_REGISTRY_V1 and MISSION_ROUTING_V1."),
        .init(id: "09_AUTONOMOUS_LOOPS", title: "Existing autonomous loops", objective: "Activate only EXISTING proven loops that are reversible, observable, authority-bounded, evidence-returning and memory-returning. Eligible examples: health monitoring, stale credential detection, evidence indexing, reconciliation proposals, deadline monitoring, inbox triage, non-destructive sync verification and process drift detection. Never autonomously move money, sign, submit legal/admin declarations, publish materially consequential content, delete canonical evidence or change authority. Required output: AUTONOMY_ACTIVATION_REGISTRY_V1."),
        .init(id: "10_CONTROLLED_AUTO_EVOLUTION", title: "Controlled auto-evolution", objective: "Only from a real observed limitation, execute the controlled loop OBSERVED_LIMIT→EVIDENCE→ROOT_CAUSE→RECOVER_EXISTING_SOLUTION→GAP_PROOF→PROPOSE_CHANGE→BUILD→TEST→COMPARE→HUMAN_GATE_IF_REQUIRED→PROMOTE→FREEZE→MEMORY_RETURN. Required outputs: AUTO_EVOLUTION_POLICY_V1, LEARNING_LOOP_REGISTRY_V1 and the final GRANDE_MISSION_TOTAL_SYSTEM_RECEIPT_V1 with evidence, rollback references, blockers/human gates, Alonso L1-L7, circulation/circularity, runtime/bridge, autonomy readiness/activation and verdict TOTAL_SYSTEM_READY|TOTAL_SYSTEM_READY_WITH_BOUNDED_BLOCKERS|NOT_READY.")
    ]

    private let runtime: SUPRAChatRuntimeAdapter
    private let fileManager = FileManager.default
    private let iso = ISO8601DateFormatter()

    private init() {
        runtime = SUPRAChatRuntimeAdapter()
        restorePersistedExecutionControlState()
    }

    private func restorePersistedExecutionControlState() {
        guard let data = try? Data(contentsOf: stateURL),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let status = object["status"] as? String else {
            return
        }
        isStandby = status == "STANDBY"
        isAborted = status == "ABORTED"
    }

    var rootURL: URL {
        fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("NOVA_OS/SUPRA_GRANDE_MISSION_V1", isDirectory: true)
    }

    var inboxURL: URL { rootURL.appendingPathComponent("INBOX", isDirectory: true) }
    var outboxURL: URL { rootURL.appendingPathComponent("OUTBOX", isDirectory: true) }
    var decisionsURL: URL { rootURL.appendingPathComponent("DECISIONS", isDirectory: true) }
    var stateURL: URL { rootURL.appendingPathComponent("STATE.json") }

    func executeExecutiveObjective(
        objective: String,
        runtimePrompt: String,
        originConversationID: String? = nil
    ) async throws -> ExecutiveObjectiveResult {
        let originConversationID = originConversationID ?? SUPRAConversationLineage.canonicalID()
        let trimmed = objective.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw NSError(
                domain: "SUPRA.ExecutiveObjective",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Executive objective cannot be empty."]
            )
        }

        guard activeExecutiveObjectiveID == nil else {
            throw NSError(
                domain: "SUPRA.ExecutiveObjective",
                code: 409,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "An executive objective is already running. Reuse, Standby, Abort or Resume it; no second durable admission was created."
                ]
            )
        }

        let microMissionText = trimmed + "\n" + runtimePrompt
        let microResponsibilityLevel = microMissionResponsibilityLevel(in: microMissionText)
        let actionCenterMicroMission = (microResponsibilityLevel ?? 0) >= 3
        let runtimeRoute = actionCenterMicroMission
            ? "SUPRAExecutiveStore->SUPRAActionRuntime"
            : "SUPRAChatRuntimeAdapter->SUPRAExecutiveStore->/v1/chat/OpenCode"

        try prepareDirectories()

        let objectiveID = makeExecutiveObjectiveID()
        activeExecutiveObjectiveID = objectiveID
        executiveInterruptionIntent = nil
        defer {
            if activeExecutiveObjectiveID == objectiveID {
                activeExecutiveObjectiveID = nil
                executiveRuntimeTask = nil
                executiveInterruptionIntent = nil
            }
        }

        let startedAt = iso.string(from: Date())
        let admissionURL = inboxURL.appendingPathComponent("\(objectiveID).json")
        let receiptURL = outboxURL.appendingPathComponent("\(objectiveID).result.json")

        let request: [String: Any] = [
            "schema": "SUPRA_EXECUTIVE_OBJECTIVE_REQUEST_V1",
            "mission_id": objectiveID,
            "objective_id": objectiveID,
            "origin_conversation_id": originConversationID,
            "origin_chat": originConversationID,
            "authority": "NICOLAS",
            "mode": "EXECUTE_NOT_REINVESTIGATE",
            "started_at": startedAt,
            "objective": trimmed,
            "runtime_route": runtimeRoute
        ]

        let requestData = try JSONSerialization.data(
            withJSONObject: request,
            options: [.prettyPrinted, .sortedKeys]
        )
        try requestData.write(to: admissionURL, options: .atomic)

        do {
            let response: String

            if actionCenterMicroMission {
                guard microMissionText.uppercased().contains("AUTO_EXECUTE_ALLOWLISTED_ACTION=YES") else {
                    throw NSError(
                        domain: "SUPRA.MicroMission",
                        code: 403,
                        userInfo: [NSLocalizedDescriptionKey: "L3+ requires AUTO_EXECUTE_ALLOWLISTED_ACTION=YES."]
                    )
                }
                guard let actionID = microMissionActionID(in: microMissionText) else {
                    throw NSError(
                        domain: "SUPRA.MicroMission",
                        code: 400,
                        userInfo: [NSLocalizedDescriptionKey: "L3+ requires ACTION_CENTER_ACTION_ID=<allowlisted id>."]
                    )
                }
                if microResponsibilityLevel == 4,
                   let expectedFailureCode = microMissionExpectedFailureCode(in: microMissionText) {
                    response = try await executeVerifiedRollbackMicroAction(
                        actionID: actionID,
                        objectiveID: objectiveID,
                        expectedFailureCode: expectedFailureCode
                    )
                } else {
                    response = try await executeAllowlistedMicroAction(
                        actionID: actionID,
                        objectiveID: objectiveID
                    )
                }
            } else {
                try await runtime.checkHealth()

                let correlatedPrompt = """
            EXECUTIVE_OBJECTIVE
            OBJECTIVE_ID=\(objectiveID)
            ORIGIN_CONVERSATION_ID=\(originConversationID)
            ORIGIN_CHAT=\(originConversationID)
            RUNTIME_ADMISSION=\(admissionURL.path)
            RUNTIME_CORRELATION_REQUIRED=YES
            ORIGIN_CHAT_EXACT_REQUIRED=YES

            \(runtimePrompt)

            The OBJECTIVE_ID above is the durable admission identity for this execution.
            Preserve it in the response and do not replace it with a chat/session identity.

            RETURN ALSO:
            OBJECTIVE_ID=\(objectiveID)
            EXECUTION_VERDICT=MATERIAL_RESULT|HUMAN_GATE|UNPROVEN
            """

                let effectiveMode: ChatMode =
                    microResponsibilityLevel == nil ? .ask : .plan

                let runtimeTask = Task<String, Error> {
                    try await runtime.execute(
                        prompt: correlatedPrompt,
                        mode: effectiveMode
                    )
                }
                executiveRuntimeTask = runtimeTask
                response = try await runtimeTask.value
                executiveRuntimeTask = nil
            }

            let normalized = response
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let upper = normalized.uppercased()
            let contractCompact = upper
                .replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "\t", with: "")
            let contractFlat = contractCompact
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: "")
            let humanGateRequired =
                upper.contains("HUMAN_GATE_REQUIRED=YES")
                || upper.contains("EXECUTION_VERDICT=HUMAN_GATE")
                || contractCompact.contains("HUMAN_GATE_REQUIRED:YES")
                || contractCompact.contains("EXECUTION_VERDICT:HUMAN_GATE")
                || contractFlat.contains("<HUMAN_GATE_REQUIRED>YES</HUMAN_GATE_REQUIRED>")
                || contractFlat.contains("<EXECUTION_VERDICT>HUMAN_GATE</EXECUTION_VERDICT>")
            let runningOnly = [
                "RUNNING",
                "RUNNING...",
                "RUNNING…",
                "SUPRA IS EXECUTING THROUGH THE EXISTING RUNTIME..."
            ].contains(upper)

            let explicitMaterialResult =
                upper.contains("EXECUTION_VERDICT=MATERIAL_RESULT")
                || upper.contains("STATUS=PASS")
                || contractCompact.contains("EXECUTION_VERDICT:MATERIAL_RESULT")
                || contractCompact.contains("STATUS:PASS")
                || contractFlat.contains("<EXECUTION_VERDICT>MATERIAL_RESULT</EXECUTION_VERDICT>")
                || contractFlat.contains("<STATUS>PASS</STATUS>")
            let explicitUnproven =
                upper.contains("EXECUTION_VERDICT=UNPROVEN")
                || upper.contains("STATUS=UNPROVEN")
                || contractCompact.contains("EXECUTION_VERDICT:UNPROVEN")
                || contractCompact.contains("STATUS:UNPROVEN")
                || contractFlat.contains("<EXECUTION_VERDICT>UNPROVEN</EXECUTION_VERDICT>")
                || contractFlat.contains("<STATUS>UNPROVEN</STATUS>")

            let status: String
            if humanGateRequired {
                status = "BLOCKED"
            } else if explicitUnproven || normalized.isEmpty || runningOnly {
                status = "UNPROVEN"
            } else if explicitMaterialResult && !runningOnly {
                status = "PASS"
            } else {
                status = "UNPROVEN"
            }

            let finishedAt = iso.string(from: Date())
            let receipt: [String: Any] = [
                "schema": "SUPRA_EXECUTIVE_OBJECTIVE_RECEIPT_V1",
                "mission_id": objectiveID,
                "objective_id": objectiveID,
                "origin_conversation_id": originConversationID,
                "origin_chat": originConversationID,
                "authority": "NICOLAS",
                "started_at": startedAt,
                "finished_at": finishedAt,
                "status": status,
                "human_gate_required": humanGateRequired ? "YES" : "NO",
                "objective": trimmed,
                "runtime_admission": admissionURL.path,
                "runtime_route": runtimeRoute,
                "response": normalized,
                "proof_refs": [
                    admissionURL.path,
                    receiptURL.path
                ],
                "action_nicolas": humanGateRequired ? "SEE_EXECUTIVE_RETURN" : "NONE"
            ]

            let receiptData = try JSONSerialization.data(
                withJSONObject: receipt,
                options: [.prettyPrinted, .sortedKeys]
            )
            try receiptData.write(to: receiptURL, options: .atomic)

            return ExecutiveObjectiveResult(
                objectiveID: objectiveID,
                admissionPath: admissionURL.path,
                receiptPath: receiptURL.path,
                status: status,
                response: normalized,
                humanGateRequired: humanGateRequired,
                originConversationID: originConversationID
            )
        } catch is CancellationError {
            let finishedAt = iso.string(from: Date())
            let intent = executiveInterruptionIntent ?? .abort
            let receipt: [String: Any] = [
                "schema": "SUPRA_EXECUTIVE_OBJECTIVE_RECEIPT_V1",
                "mission_id": objectiveID,
                "objective_id": objectiveID,
                "origin_conversation_id": originConversationID,
                "origin_chat": originConversationID,
                "authority": "NICOLAS",
                "started_at": startedAt,
                "finished_at": finishedAt,
                "status": "CANCELLED",
                "interruption": intent.rawValue,
                "human_gate_required": "NO",
                "objective": trimmed,
                "runtime_admission": admissionURL.path,
                "runtime_route": runtimeRoute,
                "response": "Execution interrupted by Nicolas: \(intent.rawValue)",
                "proof_refs": [admissionURL.path, receiptURL.path],
                "action_nicolas": "NONE"
            ]
            if let receiptData = try? JSONSerialization.data(
                withJSONObject: receipt,
                options: [.prettyPrinted, .sortedKeys]
            ) {
                try? receiptData.write(to: receiptURL, options: .atomic)
            }
            throw CancellationError()
        } catch {
            let finishedAt = iso.string(from: Date())
            let receipt: [String: Any] = [
                "schema": "SUPRA_EXECUTIVE_OBJECTIVE_RECEIPT_V1",
                "mission_id": objectiveID,
                "objective_id": objectiveID,
                "origin_conversation_id": originConversationID,
                "origin_chat": originConversationID,
                "authority": "NICOLAS",
                "started_at": startedAt,
                "finished_at": finishedAt,
                "status": "ERROR",
                "human_gate_required": "NO",
                "objective": trimmed,
                "runtime_admission": admissionURL.path,
                "runtime_route": runtimeRoute,
                "response": error.localizedDescription,
                "proof_refs": [admissionURL.path],
                "action_nicolas": "NONE"
            ]
            if let receiptData = try? JSONSerialization.data(
                withJSONObject: receipt,
                options: [.prettyPrinted, .sortedKeys]
            ) {
                try? receiptData.write(to: receiptURL, options: .atomic)
            }
            throw error
        }
    }

    func requestExecutiveInterruption(_ intent: ExecutiveInterruptionIntent) {
        guard activeExecutiveObjectiveID != nil else { return }
        executiveInterruptionIntent = intent
        executiveRuntimeTask?.cancel()
    }

    private func makeExecutiveObjectiveID() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let stamp = formatter.string(from: Date())
        let suffix = String(UUID().uuidString.prefix(8)).uppercased()
        return "EXECUTIVE_OBJECTIVE_\(stamp)_\(suffix)"
    }

    func startIfNeeded() {
        guard !isRunning,
              !isStandby,
              !isAborted,
              !isTerminal,
              !isAwaitingHumanDecision else { return }
        Task { await run() }
    }

    func standbyCurrentMission() {
        guard isRunning else { return }
        isStandby = true
        phaseAbortRequested = false
        phaseRuntimeTask?.cancel()
    }

    func resumeFromStandby() {
        guard isStandby else { return }
        isStandby = false
        isAborted = false
        startIfNeeded()
    }

    func abortCurrentMission() {
        guard isRunning || isStandby else { return }
        phaseAbortRequested = true
        isStandby = false
        isAborted = true
        phaseRuntimeTask?.cancel()
        try? writeState(
            currentPhase: activePhaseID ?? "ABORTED",
            status: "ABORTED",
            detail: "Mission execution aborted by Nicolas. Existing evidence and PASS receipts are preserved."
        )
    }

    var blockedPhase: Phase? {
        phases.first { phase in
            guard let receipt = receipt(for: phase.id) else { return false }
            return receiptRequiresHumanDecision(receipt)
        }
    }

    private func receiptRequiresHumanDecision(
        _ receipt: PhaseReceipt
    ) -> Bool {
        guard receipt.status == "BLOCKED" else { return false }

        let upper = receipt.response.uppercased()
        return upper.contains("HUMAN_GATE_REQUIRED=YES")
    }

    var isAwaitingHumanDecision: Bool {
        guard let phase = blockedPhase,
              let receipt = receipt(for: phase.id)
        else { return false }

        guard let decision = humanDecision(for: phase.id) else {
            return true
        }

        guard let receiptDate = iso.date(from: receipt.finishedAt),
              let decisionDate = iso.date(from: decision.decidedAt)
        else {
            return true
        }

        // If the latest decision is newer than the blocked receipt, it has not
        // yet been consumed and the runner may resume automatically.
        return decisionDate <= receiptDate
    }

    func receipt(for phaseID: String) -> PhaseReceipt? {
        let url = outboxURL.appendingPathComponent("\(phaseID).result.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(PhaseReceipt.self, from: data)
    }

    func receiptStatus(for phaseID: String) -> String? {
        receipt(for: phaseID)?.status
    }

    func humanDecision(for phaseID: String) -> HumanDecisionRecord? {
        let url = decisionsURL.appendingPathComponent("\(phaseID).decision.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(HumanDecisionRecord.self, from: data)
    }

    func humanGatePacket(
        for phaseID: String,
        receiptFinishedAt: String
    ) -> String? {
        let url = decisionsURL.appendingPathComponent("\(phaseID).packet.json")

        guard let data = try? Data(contentsOf: url),
              let record = try? JSONDecoder().decode(
                  HumanGatePacketRecord.self,
                  from: data
              ),
              record.receiptFinishedAt == receiptFinishedAt
        else {
            return nil
        }

        return record.packet
    }

    func saveHumanGatePacket(
        phaseID: String,
        receiptFinishedAt: String,
        packet: String
    ) throws {
        try prepareDirectories()

        let originConversationID = SUPRAConversationLineage.canonicalID()
        let record = HumanGatePacketRecord(
            schema: "SUPRA_GRANDE_MISSION_HUMAN_GATE_PACKET_V1",
            missionID: missionID,
            phaseID: phaseID,
            receiptFinishedAt: receiptFinishedAt,
            createdAt: iso.string(from: Date()),
            packet: String(packet.prefix(24_000)),
            origin_conversation_id: originConversationID,
            origin_chat: originConversationID
        )

        let data = try JSONEncoder().encode(record)

        try data.write(
            to: decisionsURL.appendingPathComponent("\(phaseID).packet.json"),
            options: .atomic
        )
    }

    func clearHumanGatePacket(
        phaseID: String
    ) {
        let url = decisionsURL.appendingPathComponent("\(phaseID).packet.json")
        try? fileManager.removeItem(at: url)
    }

    func submitHumanDecision(phaseID: String, decision: String) async throws {
        let trimmed = decision.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw NSError(
                domain: "SUPRA.GrandeMission",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Decision cannot be empty."]
            )
        }

        try prepareDirectories()

        let originConversationID = SUPRAConversationLineage.canonicalID()
        let record = HumanDecisionRecord(
            schema: "SUPRA_GRANDE_MISSION_HUMAN_DECISION_V1",
            missionID: missionID,
            phaseID: phaseID,
            decidedAt: iso.string(from: Date()),
            authority: "NICOLAS",
            decision: String(trimmed.prefix(8_000)),
            origin_conversation_id: originConversationID,
            origin_chat: originConversationID
        )

        let data = try JSONEncoder().encode(record)
        try data.write(
            to: decisionsURL.appendingPathComponent("\(phaseID).decision.json"),
            options: .atomic
        )

        await run()
    }

    func run() async {
        guard !isRunning else { return }

        isRunning = true
        lastError = nil

        defer {
            activePhaseID = nil
            isRunning = false
        }

        do {
            try prepareDirectories()
            try await runtime.checkHealth()

            for phase in phases {
                if receiptStatus(for: phase.id) == "PASS" {
                    continue
                }

                activePhaseID = phase.id
                var machineAttempt = 0
                let maxMachineAttempts = 2
                var previousMachineBlock: String?

                while machineAttempt < maxMachineAttempts {
                    machineAttempt += 1
                    let startedAt = iso.string(from: Date())

                    try writeRequest(
                        phase: phase,
                        startedAt: startedAt
                    )

                    var phasePrompt = promptForPhase(phase)

                    if let previousMachineBlock {
                        phasePrompt += """

                        MACHINE_RECOVERY_ATTEMPT=\(machineAttempt)
                        PREVIOUS_MACHINE_BLOCK:
                        \(String(previousMachineBlock.prefix(6_000)))

                        The previous attempt did not identify a human-only gate.
                        Resolve the smallest machine-solvable/reversible blocker now using existing capabilities.
                        Do not repeat the same diagnosis without executing the next safe repair/test.
                        """
                    }

                    let runtimeTask = Task<String, Error> {
                        try await runtime.execute(
                            prompt: phasePrompt,
                            mode: .ask
                        )
                    }
                    phaseRuntimeTask = runtimeTask
                    let response = try await runtimeTask.value
                    phaseRuntimeTask = nil

                    let finishedAt = iso.string(from: Date())
                    let upper = response.uppercased()

                    let explicitPass =
                        upper.contains("PHASE_VERDICT=PASS")
                        || upper.contains("PHASE_VERDICT: PASS")

                    let explicitHumanGate =
                        upper.contains("HUMAN_GATE_REQUIRED=YES")

                    let explicitBlockedVerdict =
                        upper.contains("PHASE_VERDICT=BLOCKED")
                        || upper.contains("PHASE_VERDICT: BLOCKED")

                    let status: String
                    if explicitPass {
                        status = "PASS"
                    } else if explicitHumanGate {
                        status = "BLOCKED"
                    } else {
                        // A machine-solvable BLOCKED/UNPROVEN response is not
                        // a Nicolas gate. Keep the evidence and perform one
                        // bounded recovery attempt inside the same run.
                        status = "UNPROVEN"
                    }

                    let originConversationID = SUPRAConversationLineage.canonicalID()
                    let receipt = PhaseReceipt(
                        schema: "SUPRA_GRANDE_MISSION_PHASE_RECEIPT_V1",
                        missionID: missionID,
                        phaseID: phase.id,
                        phaseTitle: phase.title,
                        startedAt: startedAt,
                        finishedAt: finishedAt,
                        status: status,
                        response: response,
                        origin_conversation_id: originConversationID,
                        origin_chat: originConversationID
                    )

                    try writeReceipt(receipt)
                    try writeState(
                        currentPhase: phase.id,
                        status: status,
                        detail: response
                    )

                    if status == "PASS" {
                        break
                    }

                    if status == "BLOCKED" {
                        lastError = "Phase \(phase.id) requires an explicit human decision."
                        return
                    }

                    if machineAttempt < maxMachineAttempts {
                        previousMachineBlock =
                            explicitBlockedVerdict
                            ? response
                            : "UNPROVEN without human gate. " + response
                        continue
                    }

                    lastError =
                        "Phase \(phase.id) remains UNPROVEN after \(maxMachineAttempts) bounded machine attempts."
                    return
                }
            }

            try writeState(
                currentPhase: "COMPLETE",
                status: "PASS",
                detail: "All ten phases returned explicit PASS receipts."
            )
        } catch is CancellationError {
            phaseRuntimeTask = nil
            if isStandby {
                lastError = nil
                try? writeState(
                    currentPhase: activePhaseID ?? "STANDBY",
                    status: "STANDBY",
                    detail: "Mission placed in standby by Nicolas. Resume preserves existing PASS receipts and restarts only the current non-PASS phase."
                )
            } else if phaseAbortRequested || isAborted {
                lastError = nil
                try? writeState(
                    currentPhase: activePhaseID ?? "ABORTED",
                    status: "ABORTED",
                    detail: "Mission execution aborted by Nicolas. Existing evidence and PASS receipts are preserved."
                )
            } else {
                lastError = "Mission execution cancelled."
                try? writeState(
                    currentPhase: activePhaseID ?? "CANCELLED",
                    status: "CANCELLED",
                    detail: "Mission execution cancelled."
                )
            }
            phaseAbortRequested = false
        } catch {
            phaseRuntimeTask = nil
            lastError = error.localizedDescription
            try? writeState(
                currentPhase: activePhaseID ?? "UNKNOWN",
                status: "ERROR",
                detail: error.localizedDescription
            )
        }
    }

    var isTerminal: Bool {
        guard let data = try? Data(contentsOf: stateURL),
              let object = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any],
              let phase = object["current_phase"] as? String,
              let status = object["status"] as? String
        else {
            return false
        }

        return phase == "COMPLETE" && status == "PASS"
    }

    private func prepareDirectories() throws {
        try fileManager.createDirectory(
            at: inboxURL,
            withIntermediateDirectories: true
        )
        try fileManager.createDirectory(
            at: outboxURL,
            withIntermediateDirectories: true
        )
        try fileManager.createDirectory(
            at: decisionsURL,
            withIntermediateDirectories: true
        )
    }

    private func writeRequest(
        phase: Phase,
        startedAt: String
    ) throws {
        let originConversationID = SUPRAConversationLineage.canonicalID()
        let object: [String: Any] = [
            "schema": "SUPRA_GRANDE_MISSION_PHASE_REQUEST_V1",
            "mission_id": missionID,
            "phase_id": phase.id,
            "phase_title": phase.title,
            "origin_conversation_id": originConversationID,
            "origin_chat": originConversationID,
            "started_at": startedAt,
            "authority": "NICOLAS",
            "mode": "EXECUTE_NOT_REINVESTIGATE",
            "objective": phase.objective
        ]

        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys]
        )

        try data.write(
            to: inboxURL.appendingPathComponent("\(phase.id).json"),
            options: .atomic
        )
    }

    private func writeReceipt(
        _ receipt: PhaseReceipt
    ) throws {
        let data = try JSONEncoder().encode(receipt)

        try data.write(
            to: outboxURL.appendingPathComponent(
                "\(receipt.phaseID).result.json"
            ),
            options: .atomic
        )
    }

    private func writeState(
        currentPhase: String,
        status: String,
        detail: String
    ) throws {
        let states = phases.map { phase in
            [
                "phase_id": phase.id,
                "title": phase.title,
                "status":
                    receiptStatus(for: phase.id)
                    ?? (phase.id == currentPhase ? status : "PENDING")
            ]
        }

        let originConversationID = SUPRAConversationLineage.canonicalID()
        let object: [String: Any] = [
            "schema": "SUPRA_GRANDE_MISSION_STATE_V1",
            "mission_id": missionID,
            "origin_conversation_id": originConversationID,
            "origin_chat": originConversationID,
            "authority": "NICOLAS",
            "current_phase": currentPhase,
            "status": status,
            "updated_at": iso.string(from: Date()),
            "detail": String(detail.prefix(4_000)),
            "phases": states
        ]

        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys]
        )

        try data.write(
            to: stateURL,
            options: .atomic
        )
    }

    private func promptForPhase(
        _ phase: Phase
    ) -> String {
        let originConversationID = SUPRAConversationLineage.canonicalID()
        let decision = humanDecision(for: phase.id)?.decision
        let decisionBlock: String

        if let decision {
            decisionBlock = """
            HUMAN_DECISION_PRESENT=YES
            HUMAN_DECISION_AUTHORITY=NICOLAS
            HUMAN_DECISION:
            \(decision)

            Apply this decision only to the current blocked phase.
            If it resolves the gate, continue the phase.
            If it is insufficient or ambiguous, remain BLOCKED and return one precise remaining decision question with explicit options.
            """
        } else {
            decisionBlock = "HUMAN_DECISION_PRESENT=NO"
        }

        return """
        GRANDE_MISSION_PHASE
        AUTHORITY=NICOLAS
        HOST_CANONICAL=MACBOOK
        LEGACY_ALIAS_IMAC=MACBOOK
        MISSION_ID=\(missionID)
        PHASE_ID=\(phase.id)
        PHASE_TITLE=\(phase.title)
        ORIGIN_CONVERSATION_ID=\(originConversationID)
        ORIGIN_CHAT=\(originConversationID)
        ORIGIN_CHAT_EXACT_REQUIRED=YES
        MODE=EXECUTE_NOT_REINVESTIGATE
        EXECUTION_PROFILE=FAST_SAFE
        MEMORY_FIRST=YES
        PATRIMONY_FIRST=YES
        PROOF_FIRST=YES

        MAX_PARALLEL_WORKERS=3
        USE_EXISTING_GABRIEL_CONDUCTOR=YES
        BATCH_EVIDENCE_READS=YES
        PREFETCH_NEXT_SAFE_PHASE=YES
        NO_WAIT_FOR_UI=YES
        NO_RESCAN_IF_FRESH_EVIDENCE_EXISTS=YES
        CACHE_AND_REUSE_PROVEN_EVIDENCE=YES
        MERGE_DUPLICATE_READS=YES
        FAIL_FAST_ON_REAL_BLOCKER=YES

        AUTO_EXECUTE_READ_ONLY=YES
        AUTO_EXECUTE_REVERSIBLE_LOCAL=YES
        AUTO_EXECUTE_ISOLATED_BRANCH_CHANGES=YES
        AUTO_EXECUTE_BUILD_TEST_COMPARE=YES
        AUTO_EXECUTE_NONDESTRUCTIVE_REGISTRY_UPDATE=YES
        AUTO_EXECUTE_EXISTING_SERVICE_RESTART=YES
        AUTO_EXECUTE_EVIDENCE_INDEXING=YES
        AUTO_EXECUTE_MEMORY_RETURN=YES

        HUMAN_GATE_ONLY_FOR=MONEY_MOVEMENT|LEGAL_ADMIN_SUBMISSION|PUBLIC_EXTERNAL_SEND|SIGNATURE_BINDING_COMMITMENT|DESTRUCTIVE_DELETE_OR_PURGE|SECURITY_PERMISSION_CHANGE|AUTHORITY_CHANGE|PRODUCTION_MUTATION_WITHOUT_ROLLBACK

        NO_NEW_ENGINE=YES
        NO_NEW_BRIDGE=YES
        NO_NEW_RUNTIME=YES
        NO_DESTRUCTIVE_ACTION=YES
        NO_GLOBAL_RESCAN_IF_EQUIVALENT_EVIDENCE_EXISTS=YES

        OBJECTIVE:
        \(phase.objective)

        \(decisionBlock)

        Use existing local owners, registries, evidence and capabilities first.
        Execute all machine-solvable read-only/reversible work available to the existing runtime.
        Parallelize independent read-only/reversible work up to three workers.
        Batch evidence reads and reuse fresh proven evidence instead of rescanning.
        Prefetch read-only evidence for the next phase while the current phase executes.
        Do not stop for reversible local implementation, build/test/compare, evidence indexing, internal non-destructive registry work, or restart of an existing service when rollback is available.
        Preserve the Single Writer Rule for canonical writes.
        Do not claim execution or freshness without evidence.

        If a human-only gate is encountered, do not merely say BLOCKED.
        Return the exact reason, one precise decision question, explicit options and consequences so Nicolas can answer inline.

        RETURN EXACTLY:
        PHASE_VERDICT=PASS|BLOCKED|UNPROVEN
        CURRENT_STATE=
        WORK_COMPLETED=
        EVIDENCE_REFS=
        MEMORY_RETURN=
        CANNONICO_RETURN=
        BLOCKERS=
        HUMAN_GATE_REQUIRED=YES|NO
        DECISION_QUESTION=
        OPTION_A=
        OPTION_B=
        OPTION_C=
        SAFE_DEFAULT=
        CONSEQUENCE_A=
        CONSEQUENCE_B=
        CONSEQUENCE_C=
        NEXT_PHASE_READY=YES|NO
        """
    }
}
