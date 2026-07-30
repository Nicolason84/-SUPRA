import Foundation
import Combine

@MainActor
final class ContextEngine: ObservableObject {
    @Published var lastResult: ContextResult?
    @Published var isProcessing = false

    private var index: WorkspaceIndex?
    private var graph: WorkspaceGraph?
    private let maxResults: Int

    init(maxResults: Int = 20) {
        self.maxResults = maxResults
    }

    func loadIndex(_ idx: WorkspaceIndex) {
        index = idx
    }

    func loadGraph(_ g: WorkspaceGraph) {
        graph = g
    }

    func query(_ queryString: String, projectFilter: String? = nil, typeFilter: WorkspaceObjectType? = nil) -> ContextResult {
        isProcessing = true
        let startTime = CFAbsoluteTimeGetCurrent()

        let keywords = extractKeywords(from: queryString)
        guard let index = index else {
            isProcessing = false
            return ContextResult(query: queryString, timestamp: Date(), items: [], totalMatches: 0, totalWeight: 0, responseTimeMs: 0)
        }

        var scored: [(WorkspaceObject, Double, [String])] = []

        for object in index.objects {
            let score = scoreObject(object, keywords: keywords, projectFilter: projectFilter, typeFilter: typeFilter)
            if score.score > 0 {
                scored.append((object, score.score, score.matchedKeywords))
            }
        }

        let sorted = scored.sorted { $0.1 > $1.1 }.prefix(maxResults)

        let items: [ContextResultItem] = sorted.map { obj, score, matched in
            ContextResultItem(
                id: obj.id,
                name: obj.name,
                path: obj.path,
                type: obj.type,
                relevance: score,
                reason: buildReason(obj, score: score),
                matchedKeywords: matched
            )
        }

        let totalWeight = items.reduce(0.0) { $0 + $1.relevance }
        let elapsed = Int((CFAbsoluteTimeGetCurrent() - startTime) * 1000)

        let result = ContextResult(
            query: queryString,
            timestamp: Date(),
            items: items,
            totalMatches: scored.count,
            totalWeight: totalWeight,
            responseTimeMs: elapsed
        )

        lastResult = result
        isProcessing = false
        return result
    }

    struct ObjectScore {
        let score: Double
        let matchedKeywords: [String]
    }

    private func scoreObject(_ object: WorkspaceObject, keywords: [String], projectFilter: String?, typeFilter: WorkspaceObjectType?) -> ObjectScore {
        var score: Double = 0
        var matched: [String] = []

        if let filter = typeFilter, object.type != filter { return ObjectScore(score: 0, matchedKeywords: []) }
        if let proj = projectFilter, object.projectName != proj { score -= 0.3 }

        let nameLower = object.name.lowercased()
        let pathLower = object.path.lowercased()
        let tagsLower = object.tags.map { $0.lowercased() }

        for keyword in keywords {
            let kwLower = keyword.lowercased()
            if nameLower.contains(kwLower) {
                score += 0.8
                matched.append(keyword)
            } else if pathLower.contains(kwLower) {
                score += 0.5
                matched.append(keyword)
            } else if tagsLower.contains(where: { $0.contains(kwLower) }) {
                score += 0.3
                matched.append(keyword)
            } else if object.language?.lowercased().contains(kwLower) == true {
                score += 0.4
                matched.append(keyword)
            }
        }

        score += object.importance * 0.2
        score += Double(matched.count) * 0.3

        return ObjectScore(score: score, matchedKeywords: matched)
    }

    private func extractKeywords(from query: String) -> [String] {
        let stopwords: Set<String> = [
            "le", "la", "les", "un", "une", "des", "du", "de", "d", "l",
            "et", "ou", "mais", "donc", "car", "ni", "or",
            "est", "sont", "a", "ont", "dans", "pour", "sur", "avec",
            "ce", "cette", "ces", "mon", "ton", "son", "sa", "ses",
            "qui", "que", "quoi", "dont", "ou", "il", "elle", "on",
            "nous", "vous", "ils", "elles", "au", "aux", "en", "par",
            "the", "a", "an", "is", "are", "was", "were", "be", "been",
            "i", "you", "he", "she", "it", "we", "they", "this", "that",
            "these", "those", "in", "on", "at", "to", "for", "with",
            "from", "by", "of", "and", "or", "but", "not", "no",
            "what", "which", "who", "whom", "how", "where", "when",
            "exists", "there", "any", "all", "some", "each", "every",
            "file", "files", "project", "projects", "related", "linked",
            "old", "older", "version", "archive", "conversation", "document"
        ]

        let cleaned = query
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 && !stopwords.contains($0) }

        return Array(Set(cleaned))
    }

    private func buildReason(_ object: WorkspaceObject, score: Double) -> String {
        if score > 2.0 { return "Strong direct match for query keywords" }
        if score > 1.0 { return "Related to query context" }
        if score > 0.5 { return "Possible relevance" }
        return "Low relevance"
    }

    func findRelatedTo(_ objectId: String, in graph: WorkspaceGraph) -> [ContextResultItem] {
        let relatedObjects = index?.objects.filter { obj in
            graph.edges.contains { edge in
                (edge.source == objectId && edge.target == obj.id) ||
                (edge.target == objectId && edge.source == obj.id)
            }
        } ?? []

        return relatedObjects.map { obj in
            ContextResultItem(
                id: obj.id,
                name: obj.name,
                path: obj.path,
                type: obj.type,
                relevance: obj.importance,
                reason: "Related through knowledge graph",
                matchedKeywords: []
            )
        }
    }
}
