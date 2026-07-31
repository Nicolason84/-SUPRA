import Foundation
import Combine

struct MissionContextRequest: Codable {
    let missionId: String
    let missionDescription: String
    let keywords: [String]
    let requiredTypes: [CAnnoNicoType]?
    let maxObjects: Int
}

struct MissionContextResult: Identifiable, Codable, Equatable {
    let id: String
    let missionId: String
    let objects: [CAnnoNicoObject]
    let relations: [KnowledgeRelationship]
    let objectCount: Int
    let relationCount: Int
    let preparationTime: Double
    let confidence: Double
    let explanation: String
    let generatedAt: String

    static func == (lhs: MissionContextResult, rhs: MissionContextResult) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class MissionContext: ObservableObject {
    @Published var lastResult: MissionContextResult?
    @Published var isPreparing = false

    private let kernel: NOVAKnowledgeKernel

    init(kernel: NOVAKnowledgeKernel? = nil) {
        self.kernel = kernel ?? .shared
    }

    func prepare(for request: MissionContextRequest) async {
        isPreparing = true
        let start = Date()

        let allObjects = kernel.allObjectsSnapshot()

        var candidates = allObjects

        if let types = request.requiredTypes {
            candidates = candidates.filter { types.contains($0.type) }
        }

        if !request.keywords.isEmpty {
            let lowerKeywords = request.keywords.map { $0.lowercased() }
            candidates = candidates.filter { obj in
                lowerKeywords.contains { keyword in
                    obj.name.lowercased().contains(keyword) ||
                    obj.description.lowercased().contains(keyword) ||
                    obj.tags.contains { $0.lowercased().contains(keyword) }
                }
            }
        }

        let scored = candidates.map { obj -> (CAnnoNicoObject, Double) in
            var score = 0.5
            for keyword in request.keywords {
                let lower = keyword.lowercased()
                if obj.name.lowercased().contains(lower) { score += 0.2 }
                if obj.description.lowercased().contains(lower) { score += 0.1 }
                if obj.tags.contains(where: { $0.lowercased().contains(lower) }) { score += 0.05 }
            }
            if obj.authority != nil { score += 0.1 }
            return (obj, min(score, 1.0))
        }

        let sorted = scored.sorted { a, b in a.1 > b.1 }
        let selected = Array(sorted.prefix(request.maxObjects))
        let selectedIds = Set(selected.map { $0.0.id })

        let relevantRelations = kernel.allRelationsSnapshot().filter { rel in
            selectedIds.contains(rel.sourceId) || selectedIds.contains(rel.targetId)
        }

        let totalScore = selected.isEmpty ? 0 : selected.map { $0.1 }.reduce(0, +) / Double(selected.count)
        let confidence = min(totalScore * 1.2, 1.0)

        let objNames = selected.map { $0.0.name }.prefix(5).joined(separator: ", ")
        let explanation = "Contexte préparé: \(selected.count) objets, \(relevantRelations.count) relations. " +
            "Mots-clés: \(request.keywords.joined(separator: ", ")). " +
            "Objets clés: \(objNames)"

        await MainActor.run {
            lastResult = MissionContextResult(
                id: "ctx_\(request.missionId)_\(Int(start.timeIntervalSince1970))",
                missionId: request.missionId,
                objects: selected.map { $0.0 },
                relations: relevantRelations,
                objectCount: selected.count,
                relationCount: relevantRelations.count,
                preparationTime: Date().timeIntervalSince(start),
                confidence: confidence,
                explanation: explanation,
                generatedAt: ISO8601DateFormatter().string(from: Date())
            )
            isPreparing = false
        }
    }

    func clear() {
        lastResult = nil
    }
}
