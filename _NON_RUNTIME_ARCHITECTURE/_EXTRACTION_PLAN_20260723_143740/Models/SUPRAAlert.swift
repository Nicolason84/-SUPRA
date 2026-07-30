import Foundation
import SwiftUI

struct SUPRAAlert: Codable, Identifiable {
    let id: String
    let severity: String
    let title: String
    let detail: String

    init(
        id: String = UUID().uuidString,
        severity: String,
        title: String,
        detail: String
    ) {
        self.id = id
        self.severity = severity
        self.title = title
        self.detail = detail
    }

    enum CodingKeys: String, CodingKey {
        case severity
        case title
        case detail
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        severity = try container.decode(String.self, forKey: .severity)
        title = try container.decode(String.self, forKey: .title)
        detail = try container.decode(String.self, forKey: .detail)

        id = "\(severity):\(title)"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(severity, forKey: .severity)
        try container.encode(title, forKey: .title)
        try container.encode(detail, forKey: .detail)
    }
}

#Preview {
    ContentView()
        .frame(width: 1200, height: 760)
}


// MARK: - SUPRA LIVE CURRENT BOARDS V1

private enum SUPRALiveSection: String, CaseIterable, Identifiable {
    case workspace = "Workspace"
    case architecture = "Architecture"
    case authority = "Authority Gate"
    case storage = "Storage"
    case decisions = "Decision Inbox"
    case system = "Live System Status"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .workspace: return "rectangle.3.group"
        case .architecture: return "point.3.connected.trianglepath.dotted"
        case .authority: return "checkmark.shield"
        case .storage: return "internaldrive"
        case .decisions: return "tray.full"
        case .system: return "waveform.path.ecg"
        }
    }
}

private struct SUPRALiveSnapshot {
    var architectureStatus = "UNAVAILABLE"
    var architectureVerdict = "No current architecture board"
    var authorityStatus = "UNAVAILABLE"
    var authorityVerdict = "No current authority board"
    var authorityGate = "UNKNOWN"
    var storageStatus = "UNAVAILABLE"
    var recovered = "—"
    var reviewVolume = "—"
    var reviewItems = 0
    var storageNext = "No storage decision board"
    var updatedAt = Date()
}

@MainActor
private final class SUPRALiveBoardsModel: ObservableObject {
    @Published var snapshot = SUPRALiveSnapshot()
    @Published var lastError: String?

    private var timer: Timer?
    private let home = FileManager.default.homeDirectoryForCurrentUser

    private var architectureURL: URL {
        home.appendingPathComponent("NOVA_OS/SUPRA_READ_RECONCILED_VERDICT_AND_REPUBLISH_ARCHITECTURE_DECISION_BOARD_V1/CURRENT/DECISION_BOARD.json")
    }

    private var authorityURL: URL {
        home.appendingPathComponent("NOVA_OS/SUPRA_RESOLVE_AUTHORITY_FIELD_LINEAGE_AND_CLOSE_SINGLE_HUMAN_GATE_V1/CURRENT/DECISION_BOARD_AUTHORITY_FINAL.json")
    }

    private var storageURL: URL {
        home.appendingPathComponent("NOVA_OS/SUPRA_EXECUTE_APPROVED_DERIVED_DATA_BATCH_AND_BUILD_REVIEW_BOARD_FOR_26_70_GB_V1/CURRENT/STORAGE_DECISION_BOARD_AFTER_DERIVED_DATA.json")
    }

    func start() {
        stop()
        reload()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.reload()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func reload() {
        do {
            let architecture = try readObject(architectureURL)
            let authority = try readObject(authorityURL)
            let storage = try readObject(storageURL)

            var next = SUPRALiveSnapshot()
            next.architectureStatus = text(architecture["status"], fallback: "UNKNOWN")
            next.architectureVerdict = text(architecture["verdict"], fallback: "No verdict")
            next.authorityStatus = text(authority["status"], fallback: "UNKNOWN")
            next.authorityVerdict = text(authority["verdict"], fallback: "No verdict")

            if let gate = authority["single_human_gate"] as? [String: Any] {
                next.authorityGate = text(gate["status"], fallback: "UNKNOWN")
            }

            next.storageStatus = text(storage["status"], fallback: "UNKNOWN")
            next.recovered = text(storage["derived_data_recovered_human"], fallback: "—")
            next.reviewVolume = text(storage["remaining_review_total_human"], fallback: "—")
            next.reviewItems = storage["remaining_review_items"] as? Int ?? 0
            next.storageNext = text(storage["next_action"], fallback: "No next action")
            next.updatedAt = Date()

            snapshot = next
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func openArchitectureEvidence() {
        NSWorkspace.shared.open(architectureURL)
    }

    func openAuthorityEvidence() {
        NSWorkspace.shared.open(authorityURL)
    }

    func openStorageEvidence() {
        NSWorkspace.shared.open(storageURL)
    }

    private func readObject(_ url: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(
                domain: "SUPRALiveBoards",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid JSON object: \(url.path)"]
            )
        }
        return object
    }

    private func text(_ value: Any?, fallback: String) -> String {
        guard let value else { return fallback }
        return String(describing: value)
    }
}
