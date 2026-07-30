import Foundation
import Combine
import CAnnoNicoContracts

struct CAnnoNicoSnapshotState {
    let snapshot: CAnnoNicoIntegrationSnapshot
    let cachedAt: Date
    let sourceCount: Int
    let recoveredCount: Int

    var age: TimeInterval { Date().timeIntervalSince(cachedAt) }
    var isStale: Bool { age > 30 }
    var references: [CAnnoNicoSourceReference] { snapshot.references }
}

@MainActor
final class CAnnoNicoSnapshotStore: ObservableObject {
    static let shared = CAnnoNicoSnapshotStore()

    @Published private(set) var state: CAnnoNicoSnapshotState?
    @Published private(set) var isRefreshing = false
    @Published private(set) var lastRefreshError: String?

    private let ttl: TimeInterval
    private var refreshTask: Task<Void, Never>?
    private let protectedAccess = ProtectedFolderAccessCoordinator.shared

    init(ttl: TimeInterval = 30) {
        self.ttl = ttl
    }

    var currentState: CAnnoNicoSnapshotState {
        if let s = state, !s.isStale {
            return s
        }
        return refresh()
    }

    var recoveredCount: Int {
        state?.recoveredCount ?? 0
    }

    var references: [CAnnoNicoSourceReference] {
        state?.references ?? []
    }

    var cachedAt: Date? { state?.cachedAt }

    var age: TimeInterval { state?.age ?? 0 }

    @discardableResult
    func refresh() -> CAnnoNicoSnapshotState {
        let snapshot = CAnnoNicoIntegrationSnapshot(references: canonicalReferences())
        let recovered = snapshot.references.filter { $0.state == .recovered }.count
        let newState = CAnnoNicoSnapshotState(
            snapshot: snapshot,
            cachedAt: Date(),
            sourceCount: snapshot.references.count,
            recoveredCount: recovered
        )
        state = newState
        lastRefreshError = nil
        return newState
    }

    func refreshIfNeeded() {
        if state == nil || state!.isStale {
            refresh()
        }
    }

    func refreshAsync() async {
        isRefreshing = true
        refresh()
        isRefreshing = false
    }

    func forceRefresh() async {
        isRefreshing = true
        refresh()
        isRefreshing = false
    }

    func invalidate() {
        state = nil
    }

    private func canonicalReferences() -> [CAnnoNicoSourceReference] {
        [
            reference(
                id: "puchero.memory",
                folderNames: ["PUCHERO"],
                role: "READ_ONLY_MEMORY_AND_LINEAGE",
                inputs: ["canonical_queries", "evidence_requests"],
                outputs: ["memory_references", "proof_lineage"],
                capabilities: ["READ_EXISTING_MEMORY", "RESOLVE_PROOF_REFERENCES", "NO_DATA_DUPLICATION"]
            ),
            reference(
                id: "nico.app",
                folderNames: ["NICO_APP_V1"],
                role: "HUMAN_INTERFACE_AND_PERSONAL_CONTEXT",
                inputs: ["human_context", "case_selection", "decision_requests"],
                outputs: ["human_views", "case_context", "decision_feedback"],
                capabilities: ["REFERENCE_EXISTING_NICO_APP", "EXPOSE_HUMAN_CONTEXT", "NO_ENGINE_RECREATION"]
            ),
            reference(
                id: "video.swap",
                folderNames: ["SUPRA_VIDEO_SWAP_V2"],
                role: "MEDIA_TRANSFORMATION_MODULE",
                inputs: ["video", "face_reference", "creative_prompt"],
                outputs: ["rendered_video", "render_proof", "job_history"],
                capabilities: ["REFERENCE_EXISTING_VIDEO_SWAP", "LOCAL_RENDER_QUEUE", "TRACEABLE_MEDIA_OUTPUT", "NO_RENDER_ENGINE_RECREATION"]
            )
        ]
    }

    private func reference(
        id: String,
        folderNames: Set<String>,
        role: String,
        inputs: [String],
        outputs: [String],
        capabilities: [String]
    ) -> CAnnoNicoSourceReference {
        let path = protectedAccess.snapshot.authorizedRootPaths.first {
            folderNames.contains(URL(fileURLWithPath: $0).lastPathComponent)
        } ?? protectedAccess.snapshot.entries.first {
            $0.isDirectory && folderNames.contains($0.name)
        }?.path
        return CAnnoNicoSourceReference(
            id: id,
            role: role,
            path: path,
            state: path == nil ? .unavailable : .recovered,
            inputs: inputs,
            outputs: outputs,
            capabilities: capabilities
        )
    }
}
