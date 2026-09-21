import Foundation
import Combine
import CryptoKit

@MainActor
final class DecisionStore: ObservableObject {
    enum Filter: String, CaseIterable, Identifiable {
        case all = "Toutes"
        case humanGateRequired = "Human Gate"
        case pending = "En attente"
        case inReview = "En revue"

        var id: Self { self }
    }

    enum Sort: String, CaseIterable, Identifiable {
        case newest = "Plus récentes"
        case oldest = "Plus anciennes"
        case priority = "Priorité"
        case confidence = "Confiance"

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
    @Published var activeSort: Sort = .priority {
        didSet { applyPresentation() }
    }

    private let fileManager = FileManager.default
    private var home: URL { fileManager.homeDirectoryForCurrentUser }

    func load() {
        isLoading = true
        errorMessage = nil

        let sources = boardSources()
        var loaded: [Decision] = []

        for source in sources {
            guard fileManager.fileExists(atPath: source.url.path) else { continue }
            do {
                let object = try readObject(source.url)
                loaded.append(makeDecision(source: source, object: object))
            } catch {
                continue
            }
        }

        decisions = loaded
        isLoading = false
        if loaded.isEmpty {
            errorMessage = "Aucun Decision Board réel n’est disponible localement."
        }
        applyPresentation()
    }

    func refresh() {
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

    private struct BoardSource {
        let key: String
        let title: String
        let category: String
        let url: URL
    }

    private func boardSources() -> [BoardSource] {
        [
            BoardSource(
                key: "architecture",
                title: "Architecture",
                category: "Architecture",
                url: home.appendingPathComponent(
                    "NOVA_OS/SUPRA_READ_RECONCILED_VERDICT_AND_REPUBLISH_ARCHITECTURE_DECISION_BOARD_V1/CURRENT/DECISION_BOARD.json"
                )
            ),
            BoardSource(
                key: "authority",
                title: "Autorité & Human Gate",
                category: "Authority",
                url: home.appendingPathComponent(
                    "NOVA_OS/SUPRA_RESOLVE_AUTHORITY_FIELD_LINEAGE_AND_CLOSE_SINGLE_HUMAN_GATE_V1/CURRENT/DECISION_BOARD_AUTHORITY_FINAL.json"
                )
            ),
            BoardSource(
                key: "storage",
                title: "Stockage & revue",
                category: "Storage",
                url: home.appendingPathComponent(
                    "NOVA_OS/SUPRA_EXECUTE_APPROVED_DERIVED_DATA_BATCH_AND_BUILD_REVIEW_BOARD_FOR_26_70_GB_V1/CURRENT/STORAGE_DECISION_BOARD_AFTER_DERIVED_DATA.json"
                )
            )
        ]
    }

    private func makeDecision(
        source: BoardSource,
        object: [String: Any]
    ) -> Decision {
        let rawStatus = text(object["status"], fallback: "UNKNOWN")
        let verdict = text(object["verdict"], fallback: "")
        let nextAction = text(object["next_action"], fallback: "")
        let gateObject = object["single_human_gate"] as? [String: Any]
        let gateStatus = text(gateObject?["status"], fallback: "")
        let gateAction =
            text(gateObject?["action_nicolas"], fallback: "").isEmpty
            ? text(gateObject?["next_action"], fallback: "")
            : text(gateObject?["action_nicolas"], fallback: "")

        let summary: String
        if !verdict.isEmpty {
            summary = verdict
        } else if !nextAction.isEmpty {
            summary = nextAction
        } else {
            summary = "Board réel disponible · status: \(rawStatus)"
        }

        let date = fileModificationDate(source.url) ?? Date()
        let humanGate = humanGateStatus(
            boardStatus: rawStatus,
            gateStatus: gateStatus
        )

        var actions: [Decision.NextAction] = []
        if !gateAction.isEmpty && gateAction.uppercased() != "NONE" {
            actions.append(
                Decision.NextAction(
                    id: stableUUID(source.key + ":gate"),
                    title: gateAction,
                    owner: "Nicolas",
                    dueDate: nil
                )
            )
        }
        if !nextAction.isEmpty && nextAction.uppercased() != "NONE",
           nextAction != gateAction {
            actions.append(
                Decision.NextAction(
                    id: stableUUID(source.key + ":next"),
                    title: nextAction,
                    owner: "SUPRA",
                    dueDate: nil
                )
            )
        }

        let evidence = [
            Decision.Evidence(
                id: stableUUID(source.key + ":evidence"),
                title: "Decision Board local",
                detail: "status=\(rawStatus)" + (gateStatus.isEmpty ? "" : " · gate=\(gateStatus)"),
                source: source.url.path
            )
        ]

        return Decision(
            id: stableUUID(source.url.path),
            title: source.title,
            status: decisionStatus(rawStatus),
            priority: decisionPriority(rawStatus, humanGate: humanGate),
            category: source.category,
            date: date,
            humanGate: humanGate,
            confidence: nil,
            summary: summary,
            evidence: evidence,
            nextActions: actions,
            history: [
                Decision.HistoryEntry(
                    id: stableUUID(source.key + ":history"),
                    date: date,
                    title: "Board observé",
                    detail: rawStatus
                )
            ]
        )
    }

    private func decisionStatus(_ raw: String) -> Decision.Status {
        let value = raw.uppercased()
        if value.contains("REJECT") || value.contains("FAIL") {
            return .rejected
        }
        if value.contains("APPROVED")
            || value.contains("PASS")
            || value.contains("CLOSED")
            || value.contains("FROZEN")
            || value.contains("READY")
            || value.contains("SUCCESS") {
            return .approved
        }
        if value.contains("REVIEW")
            || value.contains("WAIT")
            || value.contains("PROVISIONAL")
            || value.contains("HUMAN_GATE") {
            return .inReview
        }
        return .pending
    }

    private func decisionPriority(
        _ raw: String,
        humanGate: Decision.HumanGate
    ) -> Decision.Priority {
        let value = raw.uppercased()
        if value.contains("FAIL") || value.contains("BLOCK") || humanGate == .required {
            return .critical
        }
        if value.contains("WAIT") || value.contains("REVIEW") || value.contains("WARNING") {
            return .high
        }
        if value.contains("PASS") || value.contains("CLOSED") || value.contains("FROZEN") {
            return .low
        }
        return .medium
    }

    private func humanGateStatus(
        boardStatus: String,
        gateStatus: String
    ) -> Decision.HumanGate {
        let board = boardStatus.uppercased()
        let gate = gateStatus.uppercased()

        if board.contains("HUMAN_GATE") {
            return .required
        }

        if !gate.isEmpty {
            if ["NONE", "CLOSED", "PASS", "COMPLETED", "NOT_REQUIRED"].contains(gate) {
                return .completed
            }
            return .required
        }

        return .notRequired
    }

    private func readObject(_ url: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(
                domain: "DecisionStore",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid JSON: \(url.path)"]
            )
        }
        return object
    }

    private func fileModificationDate(_ url: URL) -> Date? {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?
            .contentModificationDate
    }

    private func text(_ value: Any?, fallback: String) -> String {
        guard let value else { return fallback }
        if let string = value as? String { return string }
        return String(describing: value)
    }

    private func stableUUID(_ value: String) -> UUID {
        let digest = SHA256.hash(data: Data(value.utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        let id = [
            String(hex.prefix(8)),
            String(hex.dropFirst(8).prefix(4)),
            String(hex.dropFirst(12).prefix(4)),
            String(hex.dropFirst(16).prefix(4)),
            String(hex.dropFirst(20).prefix(12))
        ].joined(separator: "-")
        return UUID(uuidString: id) ?? UUID()
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
