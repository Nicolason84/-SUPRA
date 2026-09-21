import Foundation
import Combine

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

        let home = FileManager.default.homeDirectoryForCurrentUser
        let specs: [(String, String, String)] = [
            (
                "Architecture",
                "Architecture",
                "NOVA_OS/SUPRA_READ_RECONCILED_VERDICT_AND_REPUBLISH_ARCHITECTURE_DECISION_BOARD_V1/CURRENT/DECISION_BOARD.json"
            ),
            (
                "Authority / Human Gate",
                "Authority",
                "NOVA_OS/SUPRA_RESOLVE_AUTHORITY_FIELD_LINEAGE_AND_CLOSE_SINGLE_HUMAN_GATE_V1/CURRENT/DECISION_BOARD_AUTHORITY_FINAL.json"
            ),
            (
                "Storage",
                "Operations",
                "NOVA_OS/SUPRA_EXECUTE_APPROVED_DERIVED_DATA_BATCH_AND_BUILD_REVIEW_BOARD_FOR_26_70_GB_V1/CURRENT/STORAGE_DECISION_BOARD_AFTER_DERIVED_DATA.json"
            )
        ]

        decisions = specs.compactMap { title, category, relativePath in
            decision(
                title: title,
                category: category,
                url: home.appendingPathComponent(relativePath)
            )
        }

        if decisions.isEmpty {
            errorMessage = "Aucun decision board local matérialisé."
        }

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

    private func decision(
        title: String,
        category: String,
        url: URL
    ) -> Decision? {
        guard let data = try? Data(contentsOf: url),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }

        let statusText = firstText(
            root,
            keys: ["status", "verdict", "decision", "state"]
        ) ?? "PENDING"

        let upper = statusText.uppercased()
        let status: Decision.Status
        if upper.contains("REJECT") || upper.contains("FAIL") {
            status = .rejected
        } else if upper.contains("DEFER") || upper.contains("WAIT") {
            status = .deferred
        } else if upper.contains("APPROVED")
                    || upper.contains("PASS")
                    || upper.contains("FROZEN")
                    || upper.contains("CLOSED")
                    || upper.contains("COMPLETE") {
            status = .approved
        } else if upper.contains("REVIEW")
                    || upper.contains("HUMAN_GATE")
                    || upper.contains("BLOCK") {
            status = .inReview
        } else {
            status = .pending
        }

        let priority: Decision.Priority
        if upper.contains("CRITICAL")
            || upper.contains("BLOCK")
            || upper.contains("HUMAN_GATE") {
            priority = .critical
        } else if status == .pending || status == .inReview {
            priority = .high
        } else {
            priority = .medium
        }

        let gate = humanGate(root)
        let confidence = confidenceValue(root)

        let verdict = firstText(
            root,
            keys: ["verdict", "decision", "reason", "status"]
        ) ?? statusText

        var evidence: [Decision.Evidence] = [
            Decision.Evidence(
                id: UUID(),
                title: "Decision board local",
                detail: verdict,
                source: url.path
            )
        ]

        if let refs = root["proof_refs"] as? [String] {
            evidence.append(
                contentsOf: refs.prefix(8).map {
                    Decision.Evidence(
                        id: UUID(),
                        title: "Proof ref",
                        detail: $0,
                        source: $0
                    )
                }
            )
        }

        var actions: [Decision.NextAction] = []
        if let action = firstText(
            root,
            keys: ["action_nicolas", "next_action", "next", "action"]
        ), !action.isEmpty, action.uppercased() != "NONE" {
            actions.append(
                Decision.NextAction(
                    id: UUID(),
                    title: action,
                    owner: "Nicolas",
                    dueDate: nil
                )
            )
        }

        let modified =
            (try? FileManager.default.attributesOfItem(atPath: url.path)[.modificationDate] as? Date)
            ?? Date()

        return Decision(
            id: stableUUID("decision:\(url.path)"),
            title: title,
            status: status,
            priority: priority,
            category: category,
            date: modified,
            humanGate: gate,
            confidence: confidence,
            summary: verdict,
            evidence: evidence,
            nextActions: actions,
            history: [
                Decision.HistoryEntry(
                    id: UUID(),
                    date: modified,
                    title: statusText,
                    detail: verdict
                )
            ]
        )
    }

    private func humanGate(_ root: [String: Any]) -> Decision.HumanGate {
        let gateStatus: String?
        if let gate = root["single_human_gate"] as? [String: Any] {
            gateStatus = firstText(gate, keys: ["status", "state", "verdict"])
        } else {
            gateStatus = firstText(
                root,
                keys: ["human_gate", "action_nicolas"]
            )
        }

        let value = (gateStatus ?? "").uppercased()
        if value.contains("REQUIRED")
            || value.contains("PENDING")
            || value.contains("OPEN")
            || value.contains("BLOCK") {
            return .required
        }

        if value.contains("COMPLETE")
            || value.contains("CLOSED")
            || value.contains("PASS") {
            return .completed
        }

        return .notRequired
    }

    private func confidenceValue(_ root: [String: Any]) -> Double? {
        for key in ["confidence", "confidence_score", "score"] {
            if let number = root[key] as? NSNumber {
                let raw = number.doubleValue
                return min(max(raw > 1 ? raw / 100 : raw, 0), 1)
            }
        }
        return nil
    }

    private func firstText(
        _ root: [String: Any],
        keys: [String]
    ) -> String? {
        for key in keys {
            if let value = root[key] as? String, !value.isEmpty {
                return value
            }
        }
        return nil
    }

    private func stableUUID(_ input: String) -> UUID {
        var hash = UInt64(1469598103934665603)
        for byte in input.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        let hex = String(format: "%016llx", hash)
        let padded = hex + hex
        let uuidString =
            String(padded.prefix(8)) + "-" +
            String(padded.dropFirst(8).prefix(4)) + "-" +
            String(padded.dropFirst(12).prefix(4)) + "-" +
            String(padded.dropFirst(16).prefix(4)) + "-" +
            String(padded.dropFirst(20).prefix(12))
        return UUID(uuidString: uuidString) ?? UUID()
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
