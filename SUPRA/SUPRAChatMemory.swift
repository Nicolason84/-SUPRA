import Foundation
import Combine

private struct SUPRAChatArchive: Codable, Sendable {
    let schema: String
    let updatedAt: Date
    let messages: [ChatMessage]

    enum CodingKeys: String, CodingKey {
        case schema
        case updatedAt = "updated_at"
        case messages
    }
}

struct SUPRAChatMemoryHit: Codable, Sendable, Hashable {
    let category: String
    let subjectID: String
    let projectID: String
    let statement: String
    let truthClass: String
    let applicability: String

    enum CodingKeys: String, CodingKey {
        case category
        case subjectID = "subject_id"
        case projectID = "project_id"
        case statement
        case truthClass = "truth_class"
        case applicability
    }
}

struct SUPRAChatMemoryPacket: Codable, Sendable {
    let source: String
    let hits: [SUPRAChatMemoryHit]

    var contextText: String {
        guard !hits.isEmpty else {
            return "[LONG_MEMORY_READ_ONLY]\nsource=\(source)\nNO_RELEVANT_MEMORY_FOUND"
        }

        var lines = [
            "[LONG_MEMORY_READ_ONLY]",
            "source=\(source)",
            "Historical memory is context, not automatically current evidence.",
            "Conflicts must remain explicit; do not silently promote historical claims."
        ]

        for hit in hits.prefix(8) {
            let statement = String(hit.statement.prefix(900))
            lines.append(
                "- [\(hit.truthClass)/\(hit.applicability)] " +
                "\(hit.category) · \(hit.subjectID) · \(statement)"
            )
        }

        return lines.joined(separator: "\n")
    }
}

@MainActor
final class SUPRAChatMemoryStore: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var longMemorySource = "Conversation locale"

    private let maxStoredMessages = 400
    private let archiveURL: URL

    init() {
        let support = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/SUPRA/ChatMemory", isDirectory: true)

        archiveURL = support.appendingPathComponent("current-thread-v1.json")
        load()
        refreshLongMemorySource()
    }

    func append(_ message: ChatMessage) {
        messages.append(message)
        if messages.count > maxStoredMessages {
            messages.removeFirst(messages.count - maxStoredMessages)
        }
        persist()
    }

    func clearConversation() {
        messages.removeAll()
        persist()
    }

    func refreshLongMemorySource() {
        longMemorySource = SUPRAChatLongMemory.sourceLabel()
    }

    func contextTail(
        maxMessages: Int = 14,
        maxCharacters: Int = 9_000
    ) -> String {
        let selected = messages.suffix(maxMessages)
        var output: [String] = []
        var used = 0

        for message in selected {
            let role = message.role == .user ? "NICOLAS" : "SUPRA_OJO"
            let content = String(message.content.prefix(1_400))
            let line = "[\(role)] \(content)"
            let remaining = maxCharacters - used
            guard remaining > 0 else { break }

            if line.count > remaining {
                output.append(String(line.prefix(remaining)))
                break
            }

            output.append(line)
            used += line.count
        }

        return output.joined(separator: "\n")
    }

    private func load() {
        guard let data = try? Data(contentsOf: archiveURL),
              let archive = try? JSONDecoder().decode(SUPRAChatArchive.self, from: data)
        else {
            messages = []
            return
        }

        messages = Array(archive.messages.suffix(maxStoredMessages))
    }

    private func persist() {
        do {
            let directory = archiveURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )

            let archive = SUPRAChatArchive(
                schema: "SUPRA_CHAT_ARCHIVE_V1",
                updatedAt: Date(),
                messages: messages
            )
            let data = try JSONEncoder().encode(archive)
            try data.write(to: archiveURL, options: [.atomic])
        } catch {
            // Persistence failure must not break the live conversation.
        }
    }
}

enum SUPRAChatLongMemory {
    nonisolated static func sourceLabel() -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let db = home.appendingPathComponent(
            "NOVA_OS/_CANNONICO_MEMORY_CORE_V1/cannonico_memory_core_v1.sqlite"
        )
        if FileManager.default.fileExists(atPath: db.path) {
            return "CAnnoNico FTS5"
        }

        let index = home.appendingPathComponent(
            "Desktop/SUPRA_MEMORY_LIVE/_SUPRA_MEMORY_INDEX/supra_memory_index.jsonl"
        )
        if FileManager.default.fileExists(atPath: index.path) {
            return "SUPRA Memory Index"
        }

        return "Conversation locale"
    }

    nonisolated static func retrieve(
        _ query: String,
        limit: Int = 8
    ) async -> SUPRAChatMemoryPacket {
        await Task.detached(priority: .utility) {
            retrieveSynchronously(query, limit: limit)
        }.value
    }

    nonisolated private static func retrieveSynchronously(
        _ query: String,
        limit: Int
    ) -> SUPRAChatMemoryPacket {
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.count >= 3 else {
            return SUPRAChatMemoryPacket(source: "NONE", hits: [])
        }

        let home = FileManager.default.homeDirectoryForCurrentUser
        let db = home.appendingPathComponent(
            "NOVA_OS/_CANNONICO_MEMORY_CORE_V1/cannonico_memory_core_v1.sqlite"
        )
        let index = home.appendingPathComponent(
            "Desktop/SUPRA_MEMORY_LIVE/_SUPRA_MEMORY_INDEX/supra_memory_index.jsonl"
        )

        guard FileManager.default.fileExists(atPath: db.path)
                || FileManager.default.fileExists(atPath: index.path)
        else {
            return SUPRAChatMemoryPacket(source: "UNAVAILABLE", hits: [])
        }

        let script = #"""
import json, os, re, sqlite3

query=os.environ.get("SUPRA_MEMORY_QUERY","").strip()
db=os.environ.get("SUPRA_MEMORY_DB","")
index=os.environ.get("SUPRA_MEMORY_INDEX","")
limit=max(1,min(int(os.environ.get("SUPRA_MEMORY_LIMIT","8")),12))

tokens=[]
for token in re.findall(r"[A-Za-zÀ-ÿ0-9_\-]{3,}", query.lower()):
    if token not in tokens:
        tokens.append(token)
tokens=tokens[:10]

def normalize(obj):
    statement=str(obj.get("statement") or obj.get("summary") or obj.get("text") or obj.get("content") or "").strip()
    if not statement:
        return None
    sensitivity=str(obj.get("sensitivity_class") or "").upper()
    if sensitivity in {"SECRET","CREDENTIAL","PASSWORD","TOKEN"}:
        return None
    return {
        "category":str(obj.get("category") or obj.get("type") or "FACTS"),
        "subject_id":str(obj.get("subject_id") or obj.get("subject") or obj.get("project") or ""),
        "project_id":str(obj.get("project_id") or obj.get("project") or ""),
        "statement":statement[:1600],
        "truth_class":str(obj.get("truth_class") or "HISTORIQUE_RECOVERED"),
        "applicability":str(obj.get("current_applicability") or obj.get("status") or "UNKNOWN")
    }

hits=[]
source="UNAVAILABLE"

if tokens and os.path.isfile(db):
    try:
        con=sqlite3.connect("file:"+db+"?mode=ro", uri=True)
        con.row_factory=sqlite3.Row
        cur=con.cursor()
        fts=" OR ".join('"'+t.replace('"','')+'"' for t in tokens)
        rows=cur.execute(
            "SELECT m.* FROM memory_fts f JOIN memory m ON m.memory_id=f.memory_id "
            "WHERE memory_fts MATCH ? LIMIT ?",
            (fts,limit)
        ).fetchall()
        for row in rows:
            item=normalize(dict(row))
            if item: hits.append(item)
        con.close()
        source="CANNONICO_FTS5"
    except Exception:
        hits=[]

if tokens and not hits and os.path.isfile(index):
    scored=[]
    try:
        with open(index,"r",encoding="utf-8",errors="replace") as f:
            for line in f:
                low=line.lower()
                score=sum(1 for t in tokens if t in low)
                if score <= 0:
                    continue
                try:
                    obj=json.loads(line)
                except Exception:
                    continue
                item=normalize(obj if isinstance(obj,dict) else {})
                if not item:
                    continue
                scored.append((score,item))
                if len(scored) > 200:
                    scored=sorted(scored,key=lambda x:x[0],reverse=True)[:80]
        scored=sorted(scored,key=lambda x:x[0],reverse=True)[:limit]
        hits=[item for _,item in scored]
        source="SUPRA_MEMORY_INDEX"
    except Exception:
        pass

print(json.dumps({"source":source,"hits":hits},ensure_ascii=False))
"""#

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = ["-c", script]

        var environment = ProcessInfo.processInfo.environment
        environment["SUPRA_MEMORY_QUERY"] = clean
        environment["SUPRA_MEMORY_DB"] = db.path
        environment["SUPRA_MEMORY_INDEX"] = index.path
        environment["SUPRA_MEMORY_LIMIT"] = String(limit)
        process.environment = environment

        let output = Pipe()
        process.standardOutput = output
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else {
                return SUPRAChatMemoryPacket(source: "ERROR", hits: [])
            }

            let data = output.fileHandleForReading.readDataToEndOfFile()
            return try JSONDecoder().decode(SUPRAChatMemoryPacket.self, from: data)
        } catch {
            return SUPRAChatMemoryPacket(source: "ERROR", hits: [])
        }
    }
}
