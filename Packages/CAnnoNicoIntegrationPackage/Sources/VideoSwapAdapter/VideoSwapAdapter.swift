import Foundation
import CAnnoNicoContracts

public struct VideoSwapAdapter: CAnnoNicoAdapter {
    public static let adapterID = "video.swap"

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
            role: "MEDIA_TRANSFORMATION_MODULE",
            path: sourcePath,
            state: exists ? .recovered : .unavailable,
            inputs: ["video", "face_reference", "creative_prompt"],
            outputs: ["rendered_video", "render_proof", "job_history"],
            capabilities: [
                "REFERENCE_EXISTING_VIDEO_SWAP",
                "LOCAL_RENDER_QUEUE",
                "TRACEABLE_MEDIA_OUTPUT",
                "NO_RENDER_ENGINE_RECREATION"
            ]
        )
    }
}
