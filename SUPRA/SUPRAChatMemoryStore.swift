import Foundation

enum SUPRAChatMemoryStore {
    private struct PersistedMessage: Codable {
        let id: UUID
        let role: String
        let mode: String
        let content: String
    }

    private static let maxPersistedMessages = 240
    private static let maxContextMessages = 18

    private static var memoryDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/SUPRA/ChatMemory", isDirectory: true)
    }

    private static var historyURL: URL {
        memoryDirectory.appendingPathComponent("conversation.json")
    }

    static let longTermReferences: [String] = [
        "~/NOVA_OS/SUPRA_CONNECTION_LAYER_V1/CURRENT/CURRENT_CONTEXT_BUNDLE.json",
        "~/NOVA_OS/SUPRA_TERMINAL_MEMORY_BRIDGE_V1/CURRENT/CURRENT_CONTEXT.md",
        "~/NOVA_OS/SUPRA_MASTER_CANON_COMPILER_V1_1/CURRENT/MASTER_CANON_MANIFEST.json",
        "~/NOVA_OS/PUCHERO"
    ]

    static func load() -> [ChatMessage] {
        guard let data = try? Data(contentsOf: historyURL),
              let stored = try? JSONDecoder().decode([PersistedMessage].self, from: data)
        else {
            return []
        }

        return stored.compactMap { item in
            guard let mode = ChatMode(rawValue: item.mode) else { return nil }

            let role: ChatMessage.Role
            switch item.role {
            case "user": role = .user
            case "runtime": role = .runtime
            default: return nil
            }

            return ChatMessage(
                id: item.id,
                role: role,
                mode: mode,
                content: item.content
            )
        }
    }

    static func save(_ messages: [ChatMessage]) {
        let bounded = Array(messages.suffix(maxPersistedMessages))
        let stored = bounded.map { message in
            PersistedMessage(
                id: message.id,
                role: message.role == .user ? "user" : "runtime",
                mode: message.mode.rawValue,
                content: message.content
            )
        }

        do {
            try FileManager.default.createDirectory(
                at: memoryDirectory,
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(stored)
            try data.write(to: historyURL, options: .atomic)
        } catch {
            return
        }
    }

    static func clear() {
        try? FileManager.default.removeItem(at: historyURL)
    }

    static func contextEnvelope(messages: [ChatMessage]) -> String {
        let conversation = messages
            .suffix(maxContextMessages)
            .map { message in
                let speaker = message.role == .user ? "NICOLAS" : "SUPRA_OJO"
                return "\(speaker): \(message.content)"
            }
            .joined(separator: "\n")

        let availableMemory = longTermReferences
            .filter { reference in
                let path = NSString(string: reference).expandingTildeInPath
                return FileManager.default.fileExists(atPath: path)
            }

        let refs = availableMemory.isEmpty
            ? "NONE_PROVEN_AVAILABLE"
            : availableMemory.joined(separator: "\n- ")

        return """
        MEMORY_FIRST=YES
        MEMORY_POLICY=REUSE_EXISTING_NO_GLOBAL_SCAN
        MEMORY_TRUTH=MEMORY_IS_CONTEXT_NOT_CANONICAL_TRUTH

        EXISTING_MEMORY_REFERENCES:
        - \(refs)

        RECENT_CONVERSATION_MEMORY:
        \(conversation.isEmpty ? "NONE" : conversation)

        MEMORY_INSTRUCTION:
        Before asking Nicolas to repeat information, recover only relevant context from the existing memory references above.
        Preserve provenance and uncertainty.
        Do not invent missing memory.
        Do not create a new memory engine.
        """
    }

    static func status(messages: [ChatMessage]) -> String {
        let persisted = min(messages.count, maxPersistedMessages)
        let available = longTermReferences.filter {
            FileManager.default.fileExists(
                atPath: NSString(string: $0).expandingTildeInPath
            )
        }.count

        return "\(persisted) msg · \(available)/\(longTermReferences.count) sources"
    }
}
