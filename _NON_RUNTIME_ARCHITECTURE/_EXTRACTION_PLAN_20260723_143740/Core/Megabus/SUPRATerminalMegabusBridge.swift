import Foundation
import SwiftUI

nonisolated struct SUPRATerminalMegabusEnvelope: Codable, Sendable {
    let messageId: String
    let source: String
    let target: String
    let type: String
    let payload: [String: String]

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case source
        case target
        case type
        case payload
    }
}

nonisolated enum SUPRATerminalMegabusBridge {
    private static var rootURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(
                "NOVA_OS/SUPRA_TERMINAL_MEGABUS_V1",
                isDirectory: true
            )
    }

    private static var inboxURL: URL {
        rootURL.appendingPathComponent("INBOX", isDirectory: true)
    }

    private static var terminalRegistryURL: URL {
        rootURL
            .appendingPathComponent("TERMINALS", isDirectory: true)
            .appendingPathComponent("CURRENT.json")
    }

    static func publish(
        source: String,
        target: String,
        type: String,
        payload: [String: String]
    ) throws {
        try FileManager.default.createDirectory(
            at: inboxURL,
            withIntermediateDirectories: true
        )

        let message = SUPRATerminalMegabusEnvelope(
            messageId: UUID().uuidString,
            source: source,
            target: target,
            type: type,
            payload: payload
        )

        let data = try JSONEncoder().encode(message)
        let destination = inboxURL
            .appendingPathComponent(message.messageId)
            .appendingPathExtension("json")

        try data.write(to: destination, options: .atomic)
    }

    static func status() -> String {
        FileManager.default.fileExists(
            atPath: terminalRegistryURL.path
        ) ? "CONNECTED" : "OFFLINE"
    }

    static func registerSUPRAAndGabriel() {
        try? publish(
            source: "supra.swiftui",
            target: "supra.megabus",
            type: "CLIENT_REGISTERED",
            payload: [
                "client": "SUPRA",
                "role": "FINAL_AUTHORITY"
            ]
        )

        try? publish(
            source: "supra.gabriel",
            target: "supra.megabus",
            type: "CLIENT_REGISTERED",
            payload: [
                "client": "GABRIEL",
                "role": "VISIBLE_CONDUCTOR"
            ]
        )
    }
}
