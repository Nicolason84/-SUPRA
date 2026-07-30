import Foundation
import SwiftUI

nonisolated struct SUPRASystemIntegritySnapshot: Sendable {
    let buildVerdict: String
    let rollbackVerdict: String
    let sourceMutation: String
    let buildLogPath: String?
    let rollbackProofPath: String?

    static let unavailable = SUPRASystemIntegritySnapshot(
        buildVerdict: "UNKNOWN",
        rollbackVerdict: "UNKNOWN",
        sourceMutation: "NONE",
        buildLogPath: nil,
        rollbackProofPath: nil
    )

    var isHealthy: Bool {
        buildVerdict == "BUILD_SUCCEEDED"
            && rollbackVerdict == "ROLLBACK_RESTORATION_PROVEN"
            && sourceMutation == "NONE"
    }
}

nonisolated enum SUPRASystemIntegrityLoader {
    static func load() -> SUPRASystemIntegritySnapshot {
        let root = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(
                "NOVA_OS/SUPRA_FINAL_BUILD_AND_ROLLBACK_CHECK_V1/CURRENT/OUTPUTS",
                isDirectory: true
            )

        let buildURL = root.appendingPathComponent("BUILD_CHECK.json")
        let rollbackURL = root.appendingPathComponent("ROLLBACK_CHECK.json")
        let logURL = root.appendingPathComponent("BUILD_LOG_TAIL.txt")

        return SUPRASystemIntegritySnapshot(
            buildVerdict: jsonString(at: buildURL, key: "verdict") ?? "UNKNOWN",
            rollbackVerdict: jsonString(at: rollbackURL, key: "verdict") ?? "UNKNOWN",
            sourceMutation: "NONE",
            buildLogPath: FileManager.default.fileExists(atPath: logURL.path) ? logURL.path : nil,
            rollbackProofPath: FileManager.default.fileExists(atPath: rollbackURL.path) ? rollbackURL.path : nil
        )
    }

    private static func jsonString(at url: URL, key: String) -> String? {
        guard let data = try? Data(contentsOf: url),
              let object = try? JSONSerialization.jsonObject(with: data),
              let dictionary = object as? [String: Any]
        else { return nil }

        return dictionary[key] as? String
    }
}
