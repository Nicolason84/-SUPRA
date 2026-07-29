import Foundation
import Combine

@MainActor
final class DecisionStore: ObservableObject {
    private static func resolveSourceURL() -> URL {
        let versionPath = "\(SUPRAEnvironmentResolver.shared.projectRoot)/version.json"
        if let data = try? Data(contentsOf: URL(fileURLWithPath: versionPath)),
           let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let sources = obj["sources"] as? [String: Any],
           let decisions = sources["decisions"] as? [String: Any],
           let path = decisions["path"] as? String {
            let expanded = path.replacingOccurrences(of: "~", with: FileManager.default.homeDirectoryForCurrentUser.path)
            let url = URL(fileURLWithPath: expanded)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        let fallback = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(
            "NOVA_OS/SUPRA_READ_RECONCILED_VERDICT_AND_REPUBLISH_ARCHITECTURE_DECISION_BOARD_V1/CURRENT/ARCHITECTURAL_DECISIONS.json"
        )
        if FileManager.default.fileExists(atPath: fallback.path) {
            return fallback
        }
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(
            "NOVA_OS/SUPRA/ARCHITECTURAL_DECISIONS.json"
        )
    }

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

        do {
            decisions = try readDecisions(at: Self.resolveSourceURL())
        } catch {
            decisions = []
            errorMessage = error.localizedDescription
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

    private func readDecisions(at url: URL) throws -> [Decision] {
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let records = root["decisions"] as? [[String: Any]]
        else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let date = (root["generated_at"] as? String).flatMap(ISO8601DateFormatter().date) ?? .distantPast
        let category = root["mission"] as? String ?? url.deletingLastPathComponent().lastPathComponent

        return records.compactMap { record in
            guard let sourceID = record["decision_id"] as? String,
                  let title = record["decision"] as? String,
                  let sourceStatus = record["status"] as? String
            else { return nil }

            let evidenceValue = record["evidence"].map(String.init(describing:))
            let normalizedStatus = sourceStatus.uppercased()
            let status: Decision.Status = normalizedStatus.contains("CONFIRMED") ? .approved : .inReview
            let humanGate: Decision.HumanGate = normalizedStatus.contains("FOUNDER") ? .completed : .notRequired

            return Decision(
                id: UUID(),
                title: title,
                status: status,
                priority: .medium,
                category: category,
                date: date,
                humanGate: humanGate,
                confidence: nil,
                summary: sourceStatus,
                evidence: evidenceValue.map {
                    [Decision.Evidence(id: UUID(), title: sourceID, detail: $0, source: url.path)]
                } ?? [],
                nextActions: [],
                history: [Decision.HistoryEntry(id: UUID(), date: date, title: sourceStatus, detail: sourceID)]
            )
        }
    }
}
