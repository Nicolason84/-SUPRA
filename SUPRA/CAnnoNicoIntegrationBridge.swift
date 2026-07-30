import Foundation
import CAnnoNicoContracts
import PucheroMemoryAdapter
import NicoAppAdapter
import VideoSwapAdapter

enum SUPRACAnnoNicoIntegration {
    static let packageID = "CAnnoNicoIntegrationPackage"

    private static func ensureResolved() {
        SUPRAEnvironmentResolver.shared.resolve()
    }

    static var pucheroSource: String {
        ensureResolved()
        return SUPRAEnvironmentResolver.shared.path(for: "pucheroRoot")
            ?? NSHomeDirectory() + "/NOVA_OS/PUCHERO"
    }

    static var nicoAppSource: String {
        ensureResolved()
        return SUPRAEnvironmentResolver.shared.path(for: "nicoAppRoot")
            ?? NSHomeDirectory() + "/NOVA_OS/NICO_APP_V1"
    }

    static var videoSwapSource: String {
        ensureResolved()
        return SUPRAEnvironmentResolver.shared.path(for: "videoSwapRoot")
            ?? ""
    }

    // INTERNAL — only call from CAnnoNicoSnapshotStore
    // All UI code must use CAnnoNicoSnapshotStore.shared.currentState
    internal static func snapshot() -> CAnnoNicoIntegrationSnapshot {
        ensureResolved()
        let pucheroState = SUPRAEnvironmentResolver.shared.state(for: "pucheroRoot")
        let nicoState = SUPRAEnvironmentResolver.shared.state(for: "nicoAppRoot")
        let videoState = SUPRAEnvironmentResolver.shared.state(for: "videoSwapRoot")

        var refs: [CAnnoNicoSourceReference] = []

        if pucheroState == .resolved {
            refs.append(PucheroMemoryAdapter(sourcePath: pucheroSource).snapshot())
        }
        if nicoState == .resolved {
            refs.append(NicoAppAdapter(sourcePath: nicoAppSource).snapshot())
        }
        if videoState == .resolved {
            refs.append(VideoSwapAdapter(sourcePath: videoSwapSource).snapshot())
        }

        return CAnnoNicoIntegrationSnapshot(references: refs)
    }
}
