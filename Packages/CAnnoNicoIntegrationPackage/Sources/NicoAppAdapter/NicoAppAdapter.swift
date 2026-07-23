import Foundation
import CAnnoNicoContracts

public struct NicoAppAdapter: CAnnoNicoAdapter {
    public static let adapterID = "nico.app"

    private let sourcePath: String?

    public init(sourcePath: String?) {
        self.sourcePath = sourcePath
    }

    public func snapshot() -> CAnnoNicoSourceReference {
        let exists = sourcePath.map {
            FileManager.default.fileExists(atPath: $0)
        } ?? false

        return CAnnoNicoSourceReference(
            id: Self.adapterID,
            role: "HUMAN_INTERFACE_AND_PERSONAL_CONTEXT",
            path: sourcePath,
            state: exists ? .recovered : .unavailable,
            inputs: ["human_context", "case_selection", "decision_requests"],
            outputs: ["human_views", "case_context", "decision_feedback"],
            capabilities: [
                "REFERENCE_EXISTING_NICO_APP",
                "EXPOSE_HUMAN_CONTEXT",
                "NO_ENGINE_RECREATION"
            ]
        )
    }
}
