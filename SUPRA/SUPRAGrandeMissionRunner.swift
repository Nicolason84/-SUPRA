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
        let flowMarker: SUPRAFlowMarker?

        enum CodingKeys: String, CodingKey {
            case schema
            case missionID
            case phaseID
            case phaseTitle
            case startedAt
            case finishedAt
            case status
            case response
            case flowMarker = "flow_marker"
        }
    }

    struct HumanDecisionRecord: Codable, Sendable {
        let schema: String
        let missionID: String
        let phaseID: String
        let decidedAt: String
        let authority: String
        let decision: String
    }

    @Published private(set) var isRunning = false
    @Published private(set) var lastError: String?
    @Published private(set) var activePhaseID: String?

    let missionID = "GRANDE_MISSION_TOTAL_IMAC_CANNONICO_ALONSO_20260921"

    let phases: [Phase] = [
        .init(id: "01_RECOVER_TOTAL_REPERTORY", title: "Recover existing total repertory", objective: "Recover and reconcile existing Environment Manager, Project/Product/Capability registries, Runtime Discovery, Canonical Store, Atlas, memory, inventories, reports, manifests and Total System/File Twin evidence. Do not rescan from zero where equivalent evidence exists."),
        .init(id: "02_MEMORY_RECONCILIATION", title: "Memory reconciliation", objective: "Reconcile canonical conversations, messages, decisions, freezes, conflicts, source inventories, references, timelines and superseded states. Preserve raw history and explicit contradictions."),
        .init(id: "03_CANNONICO_HARDWARE_SOFTWARE", title: "CAnnoNico hardware + software", objective: "Build current evidence-backed hardware/software/environment graph using existing evidence first. No secrets. Separate historical from current/proven."),
        .init(id: "04_RESPONSIBILITY_AUTHORITY", title: "Responsibility + authority", objective: "Resolve canonical owners, responsibilities, authority, read/write scope, human gates, source-of-truth, fallbacks and overlaps only where evidence supports the decision."),
        .init(id: "05_PYRAMIDE_ALONSO", title: "Pyramide Alonso L1→L7", objective: "Map verified assets and capabilities across L1 Foundation through L7 Executive/Autonomy. Report proof, stability, control and recoverability without invented confidence."),
        .init(id: "06_CIRCULATION_CIRCULARITY", title: "Circulation + circularity", objective: "Map WORLD→OBSERVE→EVIDENCE→DECIDE→MISSION→EXECUTE→RESULT→LEARN→MEMORY→CANON→WORLD. Identify broken, dead-end, duplicate, unobserved and uncontrolled loops."),
        .init(id: "07_DEDUP_FUSION", title: "Deduplication + fusion", objective: "Compare duplicate/overlapping assets by authority, evidence, freshness, dependencies and live usage. Propose only reversible merge/hybridize/connect/retire/archive actions."),
        .init(id: "08_OPERATIONALIZATION", title: "Operationalization", objective: "For verified capabilities, establish live input/output/runtime/dependency/observability/gate/routing/recovery paths. Promote only executable or clearly bounded capabilities."),
        .init(id: "09_AUTONOMOUS_LOOPS", title: "Existing autonomous loops", objective: "Identify and activate only existing reversible, observable, authority-bounded and evidence-returning loops. Never move money, sign, submit legal/admin, publish consequential content or delete canonical evidence."),
        .init(id: "10_CONTROLLED_AUTO_EVOLUTION", title: "Controlled auto-evolution", objective: "Establish observed-limit→evidence→root-cause→recover-existing→gap-proof→change→test→compare→gate→promote→freeze→memory-return loop and produce final system verdict.")
    ]

    private let runtime: SUPRAChatRuntimeAdapter
    private let fileManager = FileManager.default
    private let iso = ISO8601DateFormatter()

    private init() {
        runtime = SUPRAChatRuntimeAdapter()
    }

    var rootURL: URL {
        fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("NOVA_OS/SUPRA_GRANDE_MISSION_V1", isDirectory: true)
    }

    var inboxURL: URL { rootURL.appendingPathComponent("INBOX", isDirectory: true) }
    var outboxURL: URL { rootURL.appendingPathComponent("OUTBOX", isDirectory: true) }
    var decisionsURL: URL { rootURL.appendingPathComponent("DECISIONS", isDirectory: true) }
    var stateURL: URL { rootURL.appendingPathComponent("STATE.json") }

    func startIfNeeded() {
        guard !isRunning, !isTerminal, !isAwaitingHumanDecision else { return }
        Task { await run() }
    }

    var blockedPhase: Phase? {
        phases.first { phase in
            guard let receipt = receipt(for: phase.id) else { return false }
            return receipt.status == "BLOCKED" || receipt.status == "UNPROVEN"
        }
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

        let record = HumanDecisionRecord(
            schema: "SUPRA_GRANDE_MISSION_HUMAN_DECISION_V1",
            missionID: missionID,
            phaseID: phaseID,
            decidedAt: iso.string(from: Date()),
            authority: "NICOLAS",
            decision: String(trimmed.prefix(8_000))
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
                let startedAt = iso.string(from: Date())
                let marker = makeFlowMarker(
                    for: phase,
                    startedAt: startedAt
                )

                try writeRequest(
                    phase: phase,
                    startedAt: startedAt,
                    flowMarker: marker
                )

                let response = try await runtime.execute(
                    prompt: promptForPhase(
                        phase,
                        flowMarker: marker
                    ),
                    mode: .plan
                )

                let finishedAt = iso.string(from: Date())

                let upper = response.uppercased()
                let explicitPass =
                    upper.contains("PHASE_VERDICT=PASS")
                    || upper.contains("PHASE_VERDICT: PASS")

                let explicitBlock =
                    upper.contains("PHASE_VERDICT=BLOCKED")
                    || upper.contains("HUMAN_GATE_REQUIRED=YES")

                let status =
                    explicitPass
                    ? "PASS"
                    : (explicitBlock ? "BLOCKED" : "UNPROVEN")

                let finishedMarker = finishFlowMarker(
                    marker,
                    status: status,
                    response: response,
                    finishedAt: finishedAt
                )

                let receipt = PhaseReceipt(
                    schema: "SUPRA_GRANDE_MISSION_PHASE_RECEIPT_V1",
                    missionID: missionID,
                    phaseID: phase.id,
                    phaseTitle: phase.title,
                    startedAt: startedAt,
                    finishedAt: finishedAt,
                    status: status,
                    response: response,
                    flowMarker: finishedMarker
                )

                try writeReceipt(receipt)
                try writeState(
                    currentPhase: phase.id,
                    status: status,
                    detail: response,
                    flowMarker: finishedMarker
                )

                guard status == "PASS" else {
                    lastError = "Phase \(phase.id) stopped with \(status)."
                    return
                }
            }

            try writeState(
                currentPhase: "COMPLETE",
                status: "PASS",
                detail: "All ten phases returned explicit PASS receipts."
            )
        } catch {
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
        startedAt: String,
        flowMarker: SUPRAFlowMarker
    ) throws {
        let object: [String: Any] = [
            "schema": "SUPRA_GRANDE_MISSION_PHASE_REQUEST_V1",
            "mission_id": missionID,
            "phase_id": phase.id,
            "phase_title": phase.title,
            "started_at": startedAt,
            "authority": "NICOLAS",
            "mode": "EXECUTE_NOT_REINVESTIGATE",
            "objective": phase.objective,
            "flow_marker": try flowMarker.asJSONObject()
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
        detail: String,
        flowMarker: SUPRAFlowMarker? = nil
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

        var object: [String: Any] = [
            "schema": "SUPRA_GRANDE_MISSION_STATE_V1",
            "mission_id": missionID,
            "authority": "NICOLAS",
            "current_phase": currentPhase,
            "status": status,
            "updated_at": iso.string(from: Date()),
            "detail": String(detail.prefix(4_000)),
            "phases": states
        ]

        if let flowMarker {
            object["flow_marker"] = try flowMarker.asJSONObject()
        }

        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys]
        )

        try data.write(
            to: stateURL,
            options: .atomic
        )
    }

    private func makeFlowMarker(
        for phase: Phase,
        startedAt: String
    ) -> SUPRAFlowMarker {
        let priorSamePhase = receipt(for: phase.id)
        let priorSameMarker = priorSamePhase?.flowMarker
        let priorPhaseMarker = previousPhaseReceipt(for: phase.id)?.flowMarker

        let decisionIsNewer: Bool = {
            guard let receipt = priorSamePhase,
                  let decision = humanDecision(for: phase.id),
                  let receiptDate = iso.date(from: receipt.finishedAt),
                  let decisionDate = iso.date(from: decision.decidedAt)
            else {
                return false
            }

            return decisionDate > receiptDate
        }()

        let node = canonicalNode(for: phase.id)

        let previousNode: String?
        if decisionIsNewer {
            previousNode = "CONTROL"
        } else {
            previousNode =
                priorSameMarker?.nodeID
                ?? priorPhaseMarker?.nodeID
                ?? "MISSIONS"
        }

        let parentSpan =
            priorSameMarker?.spanID
            ?? priorPhaseMarker?.spanID

        let retryCount =
            priorSameMarker.map { $0.retryCount + 1 }
            ?? 0

        return SUPRAFlowMarker(
            schema: "SUPRA_FLOW_MARKER_V1",
            flowID: missionID,
            traceID: "TRACE-\(missionID)",
            spanID: "\(phase.id)-\(UUID().uuidString.lowercased())",
            parentSpanID: parentSpan,
            missionID: missionID,
            phaseID: phase.id,
            nodeID: node,
            previousNodeID: previousNode,
            edgeID: "\(previousNode ?? "MISSIONS")->\(node)",
            sourceRef: "docs/GRANDE_MISSION_TOTAL_IMAC_CANNONICO_ALONSO_20260921.md",
            authority: "NICOLAS",
            humanGate: "NO",
            createdAt: startedAt,
            enteredAt: startedAt,
            startedAt: startedAt,
            finishedAt: nil,
            queueMs: 0,
            serviceMs: nil,
            waitMs: humanWaitMilliseconds(for: phase.id),
            status: "RUNNING",
            outcome: nil,
            retryCount: retryCount,
            evidenceRefs: [],
            memoryReturn: nil,
            canonReturn: nil
        )
    }

    private func finishFlowMarker(
        _ marker: SUPRAFlowMarker,
        status: String,
        response: String,
        finishedAt: String
    ) -> SUPRAFlowMarker {
        let evidence = fieldValue(
            "EVIDENCE_REFS",
            in: response
        )
        .map(splitReferences)
        ?? []

        let memoryReturn = fieldValue(
            "MEMORY_RETURN",
            in: response
        )

        let canonReturn = fieldValue(
            "CANNONICO_RETURN",
            in: response
        )

        let humanGate =
            fieldValue("HUMAN_GATE_REQUIRED", in: response)
            ?? (status == "BLOCKED" ? "YES" : "NO")

        let serviceMs: Int? = {
            guard let start = iso.date(from: marker.startedAt),
                  let finish = iso.date(from: finishedAt)
            else {
                return nil
            }

            return max(
                0,
                Int(finish.timeIntervalSince(start) * 1_000)
            )
        }()

        return SUPRAFlowMarker(
            schema: marker.schema,
            flowID: marker.flowID,
            traceID: marker.traceID,
            spanID: marker.spanID,
            parentSpanID: marker.parentSpanID,
            missionID: marker.missionID,
            phaseID: marker.phaseID,
            nodeID: marker.nodeID,
            previousNodeID: marker.previousNodeID,
            edgeID: marker.edgeID,
            sourceRef: marker.sourceRef,
            authority: marker.authority,
            humanGate: humanGate,
            createdAt: marker.createdAt,
            enteredAt: marker.enteredAt,
            startedAt: marker.startedAt,
            finishedAt: finishedAt,
            queueMs: marker.queueMs,
            serviceMs: serviceMs,
            waitMs: marker.waitMs,
            status: status,
            outcome: fieldValue(
                "PHASE_VERDICT",
                in: response
            ) ?? status,
            retryCount: marker.retryCount,
            evidenceRefs: evidence,
            memoryReturn: memoryReturn,
            canonReturn: canonReturn
        )
    }

    private func previousPhaseReceipt(
        for phaseID: String
    ) -> PhaseReceipt? {
        guard let index = phases.firstIndex(where: {
            $0.id == phaseID
        }),
        index > 0 else {
            return nil
        }

        return receipt(
            for: phases[index - 1].id
        )
    }

    private func canonicalNode(
        for phaseID: String
    ) -> String {
        switch phaseID {
        case "01_RECOVER_TOTAL_REPERTORY",
             "02_MEMORY_RECONCILIATION",
             "03_CANNONICO_HARDWARE_SOFTWARE",
             "07_DEDUP_FUSION":
            return "CANNONICO"

        case "04_RESPONSIBILITY_AUTHORITY":
            return "CONTROL"

        case "05_PYRAMIDE_ALONSO",
             "10_CONTROLLED_AUTO_EVOLUTION":
            return "SUPRA"

        case "06_CIRCULATION_CIRCULARITY",
             "08_OPERATIONALIZATION",
             "09_AUTONOMOUS_LOOPS":
            return "RUNTIME"

        default:
            return "MISSIONS"
        }
    }

    private func humanWaitMilliseconds(
        for phaseID: String
    ) -> Int {
        guard let receipt = receipt(for: phaseID),
              let decision = humanDecision(for: phaseID),
              let blockedAt = iso.date(from: receipt.finishedAt),
              let decidedAt = iso.date(from: decision.decidedAt),
              decidedAt > blockedAt
        else {
            return 0
        }

        return max(
            0,
            Int(decidedAt.timeIntervalSince(blockedAt) * 1_000)
        )
    }

    private func fieldValue(
        _ key: String,
        in response: String
    ) -> String? {
        let prefix = key.uppercased() + "="

        for rawLine in response.split(
            whereSeparator: { $0.isNewline }
        ) {
            let line = String(rawLine)
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let upper = line.uppercased()

            guard upper.hasPrefix(prefix) else {
                continue
            }

            let index = line.index(
                line.startIndex,
                offsetBy: prefix.count
            )

            let value = String(line[index...])
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            return value.isEmpty ? nil : value
        }

        return nil
    }

    private func splitReferences(
        _ raw: String
    ) -> [String] {
        raw
            .split(whereSeparator: {
                $0 == "," || $0 == ";"
            })
            .map {
                String($0).trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }
            .filter { !$0.isEmpty }
    }

    private func promptForPhase(
        _ phase: Phase,
        flowMarker: SUPRAFlowMarker
    ) -> String {
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
        MISSION_ID=\(missionID)
        PHASE_ID=\(phase.id)
        PHASE_TITLE=\(phase.title)

        FLOW_ID=\(flowMarker.flowID)
        TRACE_ID=\(flowMarker.traceID)
        SPAN_ID=\(flowMarker.spanID)
        PARENT_SPAN_ID=\(flowMarker.parentSpanID ?? "NONE")
        NODE_ID=\(flowMarker.nodeID)
        PREVIOUS_NODE_ID=\(flowMarker.previousNodeID ?? "NONE")
        EDGE_ID=\(flowMarker.edgeID)
        FLOW_MARKER_IS_NOT_AN_ENGINE=YES

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
