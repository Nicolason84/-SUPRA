import Foundation
import CAnnoNicoContracts
import PucheroMemoryAdapter
import NicoAppAdapter
import VideoSwapAdapter

enum SUPRACAnnoNicoIntegration {
    static let packageID = "CAnnoNicoIntegrationPackage"

    static let pucheroSource =
        "/Users/nicolasalonso/NOVA_OS/PUCHERO"

    static let nicoAppSource =
        "/Users/nicolasalonso/NOVA_OS/NICO_APP_V1"

    static let videoSwapSource =
        "/Users/nicolasalonso/Desktop/SUPRA_VIDEO_SWAP_V2"

    static func snapshot() -> CAnnoNicoIntegrationSnapshot {
        CAnnoNicoIntegrationSnapshot(
            references: [
                PucheroMemoryAdapter(
                    sourcePath: pucheroSource
                ).snapshot(),
                NicoAppAdapter(
                    sourcePath: nicoAppSource
                ).snapshot(),
                VideoSwapAdapter(
                    sourcePath: videoSwapSource
                ).snapshot()
            ]
        )
    }

    static var recoveredCount: Int {
        snapshot().references.filter {
            $0.state == .recovered
        }.count
    }
}
