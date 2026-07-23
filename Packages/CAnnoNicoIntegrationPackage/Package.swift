// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CAnnoNicoIntegrationPackage",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "CAnnoNicoIntegration",
            targets: [
                "CAnnoNicoContracts",
                "PucheroMemoryAdapter",
                "NicoAppAdapter",
                "VideoSwapAdapter"
            ]
        )
    ],
    targets: [
        .target(name: "CAnnoNicoContracts"),
        .target(
            name: "PucheroMemoryAdapter",
            dependencies: ["CAnnoNicoContracts"]
        ),
        .target(
            name: "NicoAppAdapter",
            dependencies: ["CAnnoNicoContracts"]
        ),
        .target(
            name: "VideoSwapAdapter",
            dependencies: ["CAnnoNicoContracts"]
        )
    ]
)
