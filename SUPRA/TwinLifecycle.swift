import Foundation
import Combine

struct TwinLifecycle: Identifiable, Codable, Equatable {
    let id: String
    let twinId: String
    let status: TwinStatus
    let createdBy: String?
    let createdAt: String
    let updatedAt: String
    let lastSyncAt: String?
    let lastVerifiedAt: String?
    let versionHistory: [TwinVersionRecord]
    let transitionHistory: [TwinTransitionRecord]

    static func == (lhs: TwinLifecycle, rhs: TwinLifecycle) -> Bool {
        lhs.id == rhs.id
    }
}

struct TwinVersionRecord: Identifiable, Codable, Equatable {
    let id: String
    let version: Int
    let status: TwinStatus
    let changeDescription: String
    let changedBy: String?
    let changedAt: String
    let hash: String?

    static func == (lhs: TwinVersionRecord, rhs: TwinVersionRecord) -> Bool {
        lhs.id == rhs.id
    }
}

struct TwinTransitionRecord: Identifiable, Codable, Equatable {
    let id: String
    let fromStatus: TwinStatus
    let toStatus: TwinStatus
    let reason: String
    let triggeredBy: String?
    let triggeredAt: String

    static func == (lhs: TwinTransitionRecord, rhs: TwinTransitionRecord) -> Bool {
        lhs.id == rhs.id
    }
}

enum TwinLifecycleEvent: String, Codable, CaseIterable, Identifiable {
    case created, synced, verified, updated, archived, deleted, error

    var id: String { rawValue }
}

@MainActor
final class TwinLifecycleManager: ObservableObject {
    @Published var lifecycles: [String: TwinLifecycle] = [:]

    func register(_ lifecycle: TwinLifecycle) {
        lifecycles[lifecycle.twinId] = lifecycle
    }

    func transition(twinId: String, to newStatus: TwinStatus, reason: String) -> TwinLifecycle? {
        guard var lifecycle = lifecycles[twinId] else { return nil }

        let transition = TwinTransitionRecord(
            id: "trans_\(UUID().uuidString.prefix(8))",
            fromStatus: lifecycle.status,
            toStatus: newStatus,
            reason: reason,
            triggeredBy: "system",
            triggeredAt: ISO8601DateFormatter().string(from: Date())
        )

        let versionRecord = TwinVersionRecord(
            id: "ver_\(lifecycle.versionHistory.count + 1)",
            version: lifecycle.versionHistory.count + 1,
            status: newStatus,
            changeDescription: reason,
            changedBy: "system",
            changedAt: ISO8601DateFormatter().string(from: Date()),
            hash: nil
        )

        lifecycle = TwinLifecycle(
            id: lifecycle.id,
            twinId: twinId,
            status: newStatus,
            createdBy: lifecycle.createdBy,
            createdAt: lifecycle.createdAt,
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            lastSyncAt: lifecycle.lastSyncAt,
            lastVerifiedAt: lifecycle.lastVerifiedAt,
            versionHistory: lifecycle.versionHistory + [versionRecord],
            transitionHistory: lifecycle.transitionHistory + [transition]
        )

        lifecycles[twinId] = lifecycle
        return lifecycle
    }

    func lifecycle(for twinId: String) -> TwinLifecycle? {
        lifecycles[twinId]
    }

    func activeTwins() -> [TwinLifecycle] {
        lifecycles.values.filter { $0.status == .active || $0.status == .syncing }
    }

    func statusSummary() -> [TwinStatus: Int] {
        Dictionary(grouping: lifecycles.values, by: { $0.status }).mapValues(\.count)
    }
}
