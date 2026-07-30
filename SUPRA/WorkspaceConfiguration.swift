import Foundation

struct WorkspaceConfiguration: Codable {
    var scanPaths: [URL]
    var excludePaths: [String]
    var maxFileSizeBytes: Int64
    var maxScanDepth: Int
    var fileExtensions: [String]
    var excludedExtensions: [String]
    var scanInterval: TimeInterval
    var enableAutoScan: Bool
    var contextMaxResults: Int

    static let `default` = WorkspaceConfiguration(
        scanPaths: [
        ],
        excludePaths: [
            ".git", "node_modules", ".build", ".swiftpm",
            "DerivedData", "Pods", "Carthage", "build",
            ".opencode", "FREEZE_", "_MISSIONS", "_VERIFICATIONS"
        ],
        maxFileSizeBytes: 10_485_760,
        maxScanDepth: 8,
        fileExtensions: [
            "swift", "py", "js", "ts", "jsx", "tsx", "rb", "go", "rs",
            "md", "txt", "json", "yaml", "yml", "toml", "xml", "plist",
            "pdf", "png", "jpg", "jpeg", "gif", "svg",
            "sh", "bash", "zsh", "fish",
            "sqlite", "db", "sql",
            "log", "out",
            "zip", "tar", "gz", "bz2",
            "xcodeproj", "xcworkspace", "playground"
        ],
        excludedExtensions: [
            "o", "a", "so", "dylib", "dSYM", "app", "dmg", "pkg",
            "ipa", "kext", "framework", "xcframework",
            "DS_Store", "localized"
        ],
        scanInterval: 300,
        enableAutoScan: false,
        contextMaxResults: 20
    )
}
