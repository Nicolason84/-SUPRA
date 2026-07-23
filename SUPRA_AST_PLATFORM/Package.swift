// swift-tools-version: 6.2
import PackageDescription

let swiftHostModules = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host"
let swiftHostFlags: [SwiftSetting] = [.unsafeFlags(["-I\(swiftHostModules)"])]
let swiftHostLinker: [LinkerSetting] = [.unsafeFlags(["-L\(swiftHostModules)", "-Xlinker", "-rpath", "-Xlinker", swiftHostModules])]

let package = Package(
    name: "SUPRA_AST_PLATFORM",
    products: [
        .library(name: "SUPRAAST", targets: ["SUPRAAST"]),
        .executable(name: "supra-ast", targets: ["CLI"])
    ],
    targets: [
        .target(name: "SUPRAAST", resources: [.process("Resources")], swiftSettings: swiftHostFlags, linkerSettings: swiftHostLinker),
        .executableTarget(name: "CLI", dependencies: ["SUPRAAST"], swiftSettings: swiftHostFlags, linkerSettings: swiftHostLinker),
        .testTarget(name: "SUPRAASTTests", dependencies: ["SUPRAAST"], swiftSettings: swiftHostFlags, linkerSettings: swiftHostLinker)
    ]
)
