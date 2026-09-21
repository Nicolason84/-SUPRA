import Foundation
import Combine
import CryptoKit

@MainActor
final class DecisionStore: ObservableObject {
    enum Filter: String, CaseIterable, Identifiable {
        case all = "All"
        case humanGateRequired = "Human Gate Required"
        case pending = "Pending"
        case inReview = "In Review"

        var id: Self { self }
    }

    enum Sort: String, CaseIterable, Identifiable {
        case newest = "Newest"
        case oldest = "Oldest"
        case priority = "Priority"
        case confidence = "Confidence"

        var id: Self { self }
    }

    @Published private(set) var decisions: [Decision] = []
    @Published private(set) var visibleDecisions: [Decision] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var query = "" {
        didSet { applyPresentation() }
    }
    @Published var activeFilter: Filter = .all {
        didSet { applyPresentation() }
    }
    @Published var activeSort: Sort = .newest {
        didSet { applyPresentation() }
    }

    func load() {
        guard decisions.isEmpty else {
            applyPresentation()
            return
        }

        isLoading = true
        errorMessage = nil

        let result = loadDecisionBoards()
        decisions = result.decisions
        errorMessage = result.errors.isEmpty ? nil : result.errors.joined(separator: " · ")

        isLoading = false
        applyPresentation()
    }

    func refresh() {
        decisions = []
        load()
    }

    func search(_ text: String) {
        query = text
    }

    func filter(_ filter: Filter) {
        activeFilter = filter
    }

    func sort(_ sort: Sort) {
        activeSort = sort
    }

    private func loadDecisionBoards() -> (decisions: [Decision], errors: [String]) {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let sources: [DecisionBoardSource] = [
            DecisionBoardSource(
                id: "architecture",
                title: "Architecture",
                category: "Architecture",
                url: home.appendingPathComponent(
                    "NOVA_OS/SUPRA_READ_RECONCILED_VERDICT_AND_REPUBLISH_ARCHITECTURE_DECISION_BOARD_V1/CURRENT/DECISION_BOARD.json"
                )
            ),
            DecisionBoardSource(
                id: "authority",
                title: "Authority Gate",
                category: "Authority",
                url: home.appendingPathComponent(
                    "NOVA_OS/SUPRA_RESOLVE_AUTHORITY_FIELD_LINEAGE_AND_CLOSE_SINGLE_HUMAN_GATE_V1/CURRENT/DECISION_BOARD_AUTHORITY_FINAL.json"
                )
            ),
            DecisionBoardSource(
                id: "storage",
                title: "Storage",
                category: "Storage",
                url: home.appendingPathComponent(
                    "NOVA_OS/SUPRA_EXECUTE_APPROVED_DERIVED_DATA_BATCH_AND_BUILD_REVIEW_BOARD_FOR_26_70_GB_V1/CURRENT/STORAGE_DECISION_BOARD_AFTER_DERIVED_DATA.json"
                )
            )
        ]

        var output: [Decision] = []
        var errors: [String] = []

        for source in sources {
            do {
                output.append(try decodeBoard(source))
            } catch {
                errors.append("\(source.title): \(error.localizedDescription)")
            }
        }

        return (output, errors)
    }

    private func decodeBoard(_ source: DecisionBoardSource) throws -> Decision {
        let data = try Data(contentsOf: source.url, options: [.mappedIfSafe])
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(
                domain: "SUPRA.DecisionStore",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "JSON invalide"]
            )
        }

        let statusText = text(object["status"], fallback: "UNKNOWN")
        let verdict = text(
            object["verdict"],
            fallback: text(object["next_action"], fallback: "Aucun verdict")
        )
        let nextAction = text(object["next_action"], fallback: verdict)
        let date = modificationDate(source.url)

        let gateStatus: String? = {
            guard let gate = object["single_human_gate"] as? [String: Any] else { return nil }
            return text(gate["status"], fallback: "UNKNOWN")
        }()

        let humanGate = humanGateStatus(gateStatus)
        let decisionStatus = decisionStatus(statusText, gateStatus: gateStatus)
        let priority = decisionPriority(
            sourceID: source.id,
            status: statusText,
            gateStatus: gateStatus,
            object: object
        )

        var evidence: [Decision.Evidence] = [
            Decision.Evidence(
                id: stableUUID("evidence:\(source.id):board"),
                title: "\(source.title) board",
                detail: verdict,
                source: source.url.path
            )
        ]

        if let recovered = object["derived_data_recovered_human"] {
            evidence.append(
                Decision.Evidence(
                    id: stableUUID("evidence:\(source.id):recovered"),
                    title: "Recovered",
                    detail: String(describing: recovered),
                    source: source.url.path
                )
            )
        }

        if let review = object["remaining_review_total_human"] {
            evidence.append(
                Decision.Evidence(
                    id: stableUUID("evidence:\(source.id):review"),
                    title: "Remaining review",
                    detail: String(describing: review),
                    source: source.url.path
                )
            )
        }

        let nextActions: [Decision.NextAction] = nextAction.isEmpty
            ? []
            : [
                Decision.NextAction(
                    id: stableUUID("next:\(source.id):\(nextAction)"),
                    title: nextAction,
                    owner: humanGate == .required ? "NICOLAS" : "SUPRA",
                    dueDate: nil
                )
            ]

        return Decision(
            id: stableUUID("decision:\(source.id)"),
            title: source.title,
            status: decisionStatus,
            priority: priority,
            category: source.category,
            date: date,
            humanGate: humanGate,
            confidence: nil,
            summary: "\(statusText) · \(verdict)",
            evidence: evidence,
            nextActions: nextActions,
            history: []
        )
    }

    private func decisionStatus(
        _ status: String,
        gateStatus: String?
    ) -> Decision.Status {
        let value = (status + " " + (gateStatus ?? "")).uppercased()

        if value.contains("REJECT") || value.contains("FAIL") {
            return .rejected
        }
        if value.contains("BLOCK") || value.contains("HUMAN_GATE") || value.contains("REVIEW") {
            return .inReview
        }
        if value.contains("PASS") || value.contains("FROZEN") || value.contains("CLOSED") || value.contains("APPROVED") {
            return .approved
        }
        if value.contains("DEFER") || value.contains("WAIT") {
            return .deferred
        }
        return .pending
    }

    private func humanGateStatus(_ gate: String?) -> Decision.HumanGate {
        guard let gate else { return .notRequired }
        let value = gate.uppercased()
        if value.contains("CLOSED") || value.contains("PASS") || value.contains("NONE") || value.contains("COMPLETE") {
            return .completed
        }
        return .required
    }

    private func decisionPriority(
        sourceID: String,
        status: String,
        gateStatus: String?,
        object: [String: Any]
    ) -> Decision.Priority {
        let combined = (status + " " + (gateStatus ?? "")).uppercased()
        if combined.contains("BLOCK") || combined.contains("FAIL") || combined.contains("HUMAN_GATE") {
            return .critical
        }
        if sourceID == "storage",
           let items = object["remaining_review_items"] as? Int,
           items > 0 {
            return .high
        }
        return .medium
    }

    private func modificationDate(_ url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate)
            ?? .distantPast
    }

    private func text(_ value: Any?, fallback: String) -> String {
        guard let value else { return fallback }
        return String(describing: value)
    }

    private func stableUUID(_ value: String) -> UUID {
        let digest = SHA256.hash(data: Data(value.utf8))
        var bytes = Array(digest.prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }


    private func loadDecisionBoards() -> [Decision] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let sources: [(String, String, String)] = [
            (
                "Architecture",
                "Architecture / responsabilité canonique",
                "NOVA_OS/SUPRA_READ_RECONCILED_VERDICT_AND_REPUBLISH_ARCHITECTURE_DECISION_BOARD_V1/CURRENT/DECISION_BOARD.json"
            ),
            (
                "Autorité",
                "Autorité / human gate",
                "NOVA_OS/SUPRA_RESOLVE_AUTHORITY_FIELD_LINEAGE_AND_CLOSE_SINGLE_HUMAN_GATE_V1/CURRENT/DECISION_BOARD_AUTHORITY_FINAL.json"
            ),
            (
                "Stockage",
                "Stockage / revue après dérivés",
                "NOVA_OS/SUPRA_EXECUTE_APPROVED_DERIVED_DATA_BATCH_AND_BUILD_REVIEW_BOARD_FOR_26_70_GB_V1/CURRENT/STORAGE_DECISION_BOARD_AFTER_DERIVED_DATA.json"
            )
        ]

        return sources.compactMap { category, title, relativePath in
            let url = home.appendingPathComponent(relativePath)
            guard let data = try? Data(contentsOf: url),
                  let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                return nil
            }

            let rawStatus = String(describing: object["status"] ?? "UNKNOWN").uppercased()
            let verdict = String(describing: object["verdict"] ?? object["decision"] ?? "Decision board matérialisé.")

            let status: Decision.Status
            if rawStatus.contains("PASS") || rawStatus.contains("FROZEN") || rawStatus.contains("CLOSED") || rawStatus.contains("COMPLETE") {
                status = .approved
            } else if rawStatus.contains("REJECT") || rawStatus.contains("FAIL") {
                status = .rejected
            } else if rawStatus.contains("BLOCK") || rawStatus.contains("WAIT") || rawStatus.contains("PENDING") {
                status = .pending
            } else {
                status = .inReview
            }

            var gate: Decision.HumanGate = .notRequired
            if let value = object["single_human_gate"] as? [String: Any] {
                let gateStatus = String(describing: value["status"] ?? "UNKNOWN").uppercased()
                if gateStatus.contains("REQUIRED") || gateStatus.contains("OPEN") || gateStatus.contains("PENDING") {
                    gate = .required
                } else if gateStatus.contains("CLOSED") || gateStatus.contains("PASS") || gateStatus.contains("COMPLETE") {
                    gate = .completed
                }
            }

            return Decision(
                id: UUID(),
                title: title,
                status: status,
                priority: gate == .required ? .critical : status == .pending ? .high : .medium,
                category: category,
                date: (try? FileManager.default.attributesOfItem(atPath: url.path)[.modificationDate] as? Date) ?? Date(),
                humanGate: gate,
                confidence: nil,
                summary: verdict,
                evidence: [
                    Decision.Evidence(
                        id: UUID(),
                        title: "Decision board",
                        detail: rawStatus,
                        source: url.path
                    )
                ],
                nextActions: gate == .required ? [
                    Decision.NextAction(
                        id: UUID(),
                        title: "Human Gate requis",
                        owner: "Nicolas",
                        dueDate: nil
                    )
                ] : [],
                history: [
                    Decision.HistoryEntry(
                        id: UUID(),
                        date: Date(),
                        title: rawStatus,
                        detail: verdict
                    )
                ]
            )
        }
    }

    private func applyPresentation() {
        let filtered = decisions.filter { decision in
            let matchesQuery = query.isEmpty
                || decision.title.localizedStandardContains(query)
                || decision.category.localizedStandardContains(query)
                || decision.summary.localizedStandardContains(query)

            let matchesFilter: Bool = switch activeFilter {
            case .all: true
            case .humanGateRequired: decision.humanGate == .required
            case .pending: decision.status == .pending
            case .inReview: decision.status == .inReview
            }
            return matchesQuery && matchesFilter
        }

        visibleDecisions = filtered.sorted { lhs, rhs in
            switch activeSort {
            case .newest: lhs.date > rhs.date
            case .oldest: lhs.date < rhs.date
            case .priority:
                priorityRank(lhs.priority) < priorityRank(rhs.priority)
            case .confidence:
                (lhs.confidence ?? -1) > (rhs.confidence ?? -1)
            }
        }
    }

    private func priorityRank(_ priority: Decision.Priority) -> Int {
        switch priority {
        case .critical: 0
        case .high: 1
        case .medium: 2
        case .low: 3
        }
    }
}

private struct DecisionBoardSource {
    let id: String
    let title: String
    let category: String
    let url: URL
}
