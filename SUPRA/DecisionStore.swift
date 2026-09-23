import Foundation
import Combine

@MainActor
final class DecisionStore: ObservableObject {
    enum Filter: String, CaseIterable, Identifiable {
        case all = "All"
        case humanGateRequired = "Human Gate Required"
        case pending = "Pending"
        case inReview = "In Review"
        case historical = "Historical"

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
        isLoading = true
        errorMessage = nil

        do {
            decisions = try loadHistoricalProjection()
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

    private func loadHistoricalProjection() throws -> [Decision] {
        let fm = FileManager.default
        guard let appSupport = fm.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw ProjectionError.applicationSupportUnavailable
        }

        let url = appSupport
            .appendingPathComponent("SUPRA", isDirectory: true)
            .appendingPathComponent("Projection", isDirectory: true)
            .appendingPathComponent("ARCHITECTURAL_DECISIONS.json")

        guard fm.fileExists(atPath: url.path) else {
            throw ProjectionError.projectionMissing(url.path)
        }

        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rows = root["decisions"] as? [[String: Any]]
        else {
            throw ProjectionError.invalidProjection
        }

        let sourceDate = parseDate(
            root["source_generated_at"] ?? root["projection_generated_at"]
        ) ?? .distantPast
        let sourceStatus = stringValue(root["source_status"])
        let sourceMission = stringValue(root["source_mission"])
        let executionAuthorized = (root["execution_authorized"] as? Bool) ?? false

        return rows.compactMap { row in
            let sourceID = stringValue(row["decision_id"])
            let title = stringValue(row["decision"])
            guard !sourceID.isEmpty, !title.isEmpty else { return nil }

            let storedStatus = stringValue(row["status"])
            let evidenceValue = stringValue(row["evidence"])
            let sourceDescriptor = [
                "HISTORICAL",
                storedStatus.isEmpty ? nil : "STORED_STATUS=\(storedStatus)",
                sourceStatus.isEmpty ? nil : "SOURCE_STATUS=\(sourceStatus)",
                "EXECUTION_AUTHORIZED=\(executionAuthorized ? "YES" : "NO")"
            ]
            .compactMap { $0 }
            .joined(separator: " · ")

            let evidence: [Decision.Evidence] = evidenceValue.isEmpty
                ? []
                : [
                    Decision.Evidence(
                        id: stableUUID("evidence-" + sourceID),
                        title: "Historical evidence reference",
                        detail: evidenceValue,
                        source: sourceMission.isEmpty ? nil : sourceMission
                    )
                ]

            return Decision(
                id: stableUUID(sourceID),
                title: title,
                status: .historical,
                priority: .medium,
                category: "Historical Architecture · Read Only",
                date: sourceDate,
                humanGate: .notRequired,
                confidence: nil,
                summary: sourceDescriptor,
                evidence: evidence,
                nextActions: [],
                history: [
                    Decision.HistoryEntry(
                        id: stableUUID("history-" + sourceID),
                        date: sourceDate,
                        title: "Historical decision projected",
                        detail: sourceMission.isEmpty
                            ? sourceDescriptor
                            : "\(sourceDescriptor) · SOURCE_MISSION=\(sourceMission)"
                    )
                ]
            )
        }
    }

    private func parseDate(_ value: Any?) -> Date? {
        guard let raw = value as? String, !raw.isEmpty else { return nil }
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: raw) { return date }
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fractional.date(from: raw)
    }

    private func stringValue(_ value: Any?) -> String {
        if let value = value as? String { return value }
        if let value { return String(describing: value) }
        return ""
    }

    private func stableUUID(_ seed: String) -> UUID {
        var bytes = Array(seed.utf8)
        if bytes.isEmpty { bytes = [0] }
        var hash = [UInt8](repeating: 0, count: 16)
        for (index, byte) in bytes.enumerated() {
            hash[index % 16] = hash[index % 16] &+ byte &+ UInt8(truncatingIfNeeded: index)
        }
        hash[6] = (hash[6] & 0x0F) | 0x40
        hash[8] = (hash[8] & 0x3F) | 0x80
        return UUID(uuid: (
            hash[0], hash[1], hash[2], hash[3],
            hash[4], hash[5], hash[6], hash[7],
            hash[8], hash[9], hash[10], hash[11],
            hash[12], hash[13], hash[14], hash[15]
        ))
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
            case .historical: decision.status == .historical
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

    private enum ProjectionError: LocalizedError {
        case applicationSupportUnavailable
        case projectionMissing(String)
        case invalidProjection

        var errorDescription: String? {
            switch self {
            case .applicationSupportUnavailable:
                return "SUPRA application support directory is unavailable."
            case .projectionMissing(let path):
                return "Governed decision projection is not available yet: \(path)"
            case .invalidProjection:
                return "Governed decision projection is invalid."
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
