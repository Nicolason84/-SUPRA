import Foundation
import Combine

struct MemoryEntry: Identifiable, Codable, Equatable {
    let id: String
    let objectId: String
    let objectName: String
    let objectType: String
    let question: String
    let answer: String
    let sources: [String]
    let authority: KnowledgeAuthority?
    let confidence: Double
    let createdAt: String
    var accessedAt: String?
    var accessCount: Int

    static func == (lhs: MemoryEntry, rhs: MemoryEntry) -> Bool {
        lhs.id == rhs.id
    }
}

struct MemoryQuery: Codable {
    let text: String
    let maxResults: Int
    let minConfidence: Double?
    let authority: KnowledgeAuthority?
}

@MainActor
final class ExecutiveMemory: ObservableObject {
    @Published var entries: [MemoryEntry] = []
    @Published var isBuilding = false

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func build(from kernel: NOVAKnowledgeKernel) {
        isBuilding = true
        entries = []

        let objects = kernel.allObjectsSnapshot()
        let relations = kernel.allRelationsSnapshot()

        for obj in objects {
            let objectRelations = relations.filter { $0.sourceId == obj.id || $0.targetId == obj.id }

            entries.append(MemoryEntry(
                id: "mem_\(obj.id)",
                objectId: obj.id,
                objectName: obj.name,
                objectType: obj.type.rawValue,
                question: "Qu'est-ce que '\(obj.name)' ?",
                answer: "\(obj.name): \(obj.description) [\(obj.source.rawValue), \(obj.type.rawValue)]",
                sources: [obj.source.rawValue] + objectRelations.map(\.type),
                authority: obj.authority,
                confidence: obj.authority.map { Double($0.rank) / 100.0 } ?? 0.5,
                createdAt: obj.created ?? ISO8601DateFormatter().string(from: Date()),
                accessedAt: nil,
                accessCount: 0
            ))

            if let lineage = obj.lineage {
                var answerParts: [String] = []
                if let reason = lineage.createdReason { answerParts.append("Raison: \(reason)") }
                if let mission = lineage.missionId { answerParts.append("Mission: \(mission)") }
                if let commit = lineage.commitId { answerParts.append("Commit: \(commit)") }
                if let decision = lineage.decisionId { answerParts.append("Décision: \(decision)") }

                if !answerParts.isEmpty {
                    entries.append(MemoryEntry(
                        id: "mem_lineage_\(obj.id)",
                        objectId: obj.id,
                        objectName: obj.name,
                        objectType: "lineage",
                        question: "Pourquoi '\(obj.name)' existe-t-il ?",
                        answer: answerParts.joined(separator: ". "),
                        sources: [obj.source.rawValue],
                        authority: obj.authority,
                        confidence: (obj.authority.map { Double($0.rank) / 100.0 } ?? 0.5) * 0.9,
                        createdAt: obj.created ?? ISO8601DateFormatter().string(from: Date()),
                        accessedAt: nil,
                        accessCount: 0
                    ))
                }
            }
        }

        isBuilding = false
    }

    func query(_ query: MemoryQuery) -> [MemoryEntry] {
        var results = entries

        if let minConfidence = query.minConfidence {
            results = results.filter { $0.confidence >= minConfidence }
        }

        if let authority = query.authority {
            results = results.filter { $0.authority == authority }
        }

        if !query.text.isEmpty {
            let lower = query.text.lowercased()
            results = results.filter {
                $0.question.lowercased().contains(lower) ||
                $0.answer.lowercased().contains(lower) ||
                $0.objectName.lowercased().contains(lower)
            }
        }

        results.sort { $0.confidence > $1.confidence }
        return Array(results.prefix(query.maxResults))
    }

    func answer(_ question: String) -> MemoryEntry? {
        let results = query(MemoryQuery(text: question, maxResults: 1, minConfidence: nil, authority: nil))
        return results.first
    }

    func recordAccess(_ id: String) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            var entry = entries[index]
            entry.accessCount += 1
            entry.accessedAt = ISO8601DateFormatter().string(from: Date())
            entries[index] = entry
        }
    }

    func save(to url: URL) throws {
        let data = try encoder.encode(entries)
        try data.write(to: url)
    }

    func load(from url: URL) throws {
        let data = try Data(contentsOf: url)
        entries = try decoder.decode([MemoryEntry].self, from: data)
    }

    func clear() {
        entries = []
    }
}
