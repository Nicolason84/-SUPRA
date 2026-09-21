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

                try writeRequest(
                    phase: phase,
                    startedAt: startedAt
                )

                let response = try await runtime.execute(
                    prompt: promptForPhase(phase),
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

                let receipt = PhaseReceipt(
                    schema: "SUPRA_GRANDE_MISSION_PHASE_RECEIPT_V1",
                    missionID: missionID,
                    phaseID: phase.id,
                    phaseTitle: phase.title,
                    startedAt: startedAt,
                    finishedAt: finishedAt,
                    status: status,
                    response: response
                )

                try writeReceipt(receipt)
                try writeState(
                    currentPhase: phase.id,
                    status: status,
                    detail: response
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
        startedAt: String
    ) throws {
        let object: [String: Any] = [
            "schema": "SUPRA_GRANDE_MISSION_PHASE_REQUEST_V1",
            "mission_id": missionID,
            "phase_id": phase.id,
            "phase_title": phase.title,
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

        let object: [String: Any] = [
            "schema": "SUPRA_GRANDE_MISSION_STATE_V1",
            "mission_id": missionID,
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
