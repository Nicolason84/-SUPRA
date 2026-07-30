import Foundation
import Combine

enum SyncChangeType: String, Codable, CaseIterable, Identifiable {
    case created, modified, deleted, renamed, moved
    case evolved, obsolete, merged, conflicted

    var id: String { rawValue }
}

struct SyncChange: Identifiable, Codable, Equatable {
    let id: String
    let twinId: String
    let changeType: SyncChangeType
    let objectId: String
    let objectName: String
    let previousState: [String: String]?
    let currentState: [String: String]?
    let detectedAt: String
    var applied: Bool

    static func == (lhs: SyncChange, rhs: SyncChange) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class TwinSynchronizer: ObservableObject {
    @Published var pendingChanges: [SyncChange] = []
    @Published var appliedChanges: [SyncChange] = []
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?

    private let kernel: NOVAKnowledgeKernel
    private let registry: TwinRegistry
    private let bindings: TwinBindings
    private let lifecycles: TwinLifecycleManager

    nonisolated init(kernel: NOVAKnowledgeKernel = MainActor.assumeIsolated { NOVAKnowledgeKernel.shared },
         registry: TwinRegistry = MainActor.assumeIsolated { TwinRegistry.shared },
         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
         lifecycles: TwinLifecycleManager = MainActor.assumeIsolated { TwinLifecycleManager() }) {
        self.kernel = kernel
        self.registry = registry
        self.bindings = bindings
        self.lifecycles = lifecycles
    }

    func sync() {
        isSyncing = true
        pendingChanges = []

        let objects = kernel.allObjectsSnapshot()
        let twins = registry.twins

        for twin in twins {
            let twinBindings = bindings.bindings(for: twin.id)
            for binding in twinBindings {
                guard binding.sourceType == "workspace" else { continue }

                let objectExists = objects.contains { $0.id == binding.sourceId }
                if !objectExists {
                    pendingChanges.append(SyncChange(
                        id: "sync_del_\(binding.id)",
                        twinId: twin.id,
                        changeType: .deleted,
                        objectId: binding.sourceId,
                        objectName: binding.sourceName,
                        previousState: ["status": "active"],
                        currentState: ["status": "deleted"],
                        detectedAt: ISO8601DateFormatter().string(from: Date()),
                        applied: false
                    ))
                }
            }

            if let sourceObj = objects.first(where: { $0.id == twin.sourceId }) {
                let twinName = twin.name.lowercased()
                let objName = sourceObj.name.lowercased()
                if twinName != objName {
                    pendingChanges.append(SyncChange(
                        id: "sync_mod_\(twin.id)",
                        twinId: twin.id,
                        changeType: .modified,
                        objectId: sourceObj.id,
                        objectName: sourceObj.name,
                        previousState: ["name": twin.name],
                        currentState: ["name": sourceObj.name],
                        detectedAt: ISO8601DateFormatter().string(from: Date()),
                        applied: false
                    ))
                }
            }
        }

        isSyncing = false
        lastSyncDate = Date()
    }

    func apply(_ change: SyncChange) {
        switch change.changeType {
        case .deleted:
            _ = lifecycles.transition(twinId: change.twinId, to: .archived, reason: "Source supprimée: \(change.objectName)")
        case .modified:
            if var twin = registry.find(byId: change.twinId) {
                let newName = change.currentState?["name"] ?? twin.name
                twin = TwinIdentity(
                    id: twin.id, type: twin.type, name: newName,
                    description: twin.description, sourceId: twin.sourceId,
                    sourceType: twin.sourceType, createdAt: twin.createdAt,
                    updatedAt: ISO8601DateFormatter().string(from: Date()),
                    version: twin.version + 1, hash: twin.hash,
                    authority: twin.authority, confidence: twin.confidence
                )
                registry.register(twin)
                _ = lifecycles.transition(twinId: change.twinId, to: .syncing, reason: "Synchronisé: \(change.objectName)")
            }
        default:
            break
        }

        var mutableChange = change
        mutableChange.applied = true
        appliedChanges.append(mutableChange)
        pendingChanges.removeAll { $0.id == change.id }
    }

    func applyAll() {
        for change in pendingChanges {
            apply(change)
        }
    }

    func summary() -> String {
        return "Synchronizer: \(pendingChanges.count) changements en attente, \(appliedChanges.count) appliqués. Dernière sync: \(lastSyncDate?.ISO8601Format() ?? "jamais")"
    }
}
