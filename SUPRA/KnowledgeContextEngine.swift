import Foundation
import Combine

@MainActor
final class KnowledgeContextEngine: ObservableObject {
    @Published var lastResult: KnowledgeContextResult?
    @Published var isProcessing = false

    private var graph: KnowledgeGraph?

    func connect(to graph: KnowledgeGraph) {
        self.graph = graph
    }

    func query(_ question: String, maxResults: Int = 20) -> KnowledgeContextResult {
        isProcessing = true
        let startTime = CFAbsoluteTimeGetCurrent()

        guard let graph = graph else {
            isProcessing = false
            return KnowledgeContextResult.empty(question: question)
        }

        let keywords = extractKeywords(from: question)
        let contextType = inferContextType(from: question)

        var candidates: [ScoredObject] = []

        let targets = findTargetCandidates(graph: graph, contextType: contextType, keywords: keywords)
        candidates.append(contentsOf: targets)

        if let type = contextType {
            let typeFiltered = graph.objects(of: type).map { obj in
                ScoredObject(object: obj, score: score(obj, keywords: keywords, contextType: contextType),
                             matched: matchedKeywords(obj, keywords: keywords), reason: "Matched type: \(type.rawValue)")
            }
            candidates.append(contentsOf: typeFiltered)
        }

        if !keywords.isEmpty {
            let keywordFiltered = graph.objects.filter { obj in
                let matches = matchedKeywords(obj, keywords: keywords)
                return !matches.isEmpty
            }.map { obj in
                let matches = matchedKeywords(obj, keywords: keywords)
                return ScoredObject(object: obj, score: 0.5 + Double(matches.count) * 0.3,
                                    matched: matches, reason: "Keyword match: \(matches.joined(separator: ", "))")
            }
            candidates.append(contentsOf: keywordFiltered)
        }

        let deduplicated = deduplicate(candidates)
        let sorted = deduplicated.sorted { $0.score > $1.score }.prefix(maxResults)
        let totalWeight = sorted.reduce(0.0) { $0 + $1.score }

        let items = sorted.map { scored in
            KnowledgeContextItem(
                id: scored.object.id,
                title: scored.object.title,
                summary: scored.object.summary,
                type: scored.object.type,
                source: scored.object.source,
                path: scored.object.path,
                project: scored.object.project,
                module: scored.object.module,
                tags: scored.object.tags,
                relevance: min(scored.score / max(totalWeight, 0.01), 1.0),
                confidence: scored.object.confidence,
                reason: scored.reason,
                matchedKeywords: scored.matched
            )
        }

        let elapsed = Int((CFAbsoluteTimeGetCurrent() - startTime) * 1000)
        let confidence = items.isEmpty ? 0 : min(items.prefix(5).reduce(0.0) { $0 + $1.confidence } / Double(min(5, items.count)), 1.0)

        let result = KnowledgeContextResult(
            question: question,
            timestamp: Date(),
            items: items,
            totalMatches: candidates.count,
            totalWeight: totalWeight,
            confidence: confidence,
            responseTimeMs: elapsed,
            explanation: buildExplanation(contextType: contextType, keywords: keywords, itemCount: items.count)
        )

        lastResult = result
        isProcessing = false
        return result
    }

    private struct ScoredObject {
        let object: KnowledgeObject
        let score: Double
        let matched: [String]
        let reason: String
    }

    private func findTargetCandidates(graph: KnowledgeGraph, contextType: KnowledgeObjectType?, keywords: [String]) -> [ScoredObject] {
        guard let type = contextType else { return [] }
        var candidates: [ScoredObject] = []

        let possibleTypes: [KnowledgeObjectType] = {
            switch type {
            case .file, .script, .document, .report, .pdf:
                return [.file, .script, .document, .report, .pdf, .audit, .validation]
            case .gitCommit, .gitBranch, .gitRepository:
                return [.gitCommit, .gitBranch, .gitRepository, .gitTag]
            case .decision, .evidence:
                return [.decision, .evidence, .mission]
            case .conversation, .message:
                return [.conversation, .message]
            case .freeze, .freezeManifest:
                return [.freeze, .freezeManifest]
            case .artifact, .artifactResult:
                return [.artifact, .artifactResult]
            default:
                return [type]
            }
        }()

        for t in possibleTypes {
            for obj in graph.objects(of: t) {
                let matches = matchedKeywords(obj, keywords: keywords)
                let score = score(obj, keywords: keywords, contextType: t)
                if score > 0 || !matches.isEmpty {
                    candidates.append(ScoredObject(object: obj, score: score, matched: matches, reason: "Related to \(t.rawValue): \(obj.title)"))
                }
            }
        }

        return candidates
    }

    private func score(_ obj: KnowledgeObject, keywords: [String], contextType: KnowledgeObjectType?) -> Double {
        var score: Double = obj.authority * 0.3 + obj.confidence * 0.2
        let matches = matchedKeywords(obj, keywords: keywords)
        score += Double(matches.count) * 0.4

        if let t = contextType, obj.type == t { score += 0.5 }
        if obj.status == "active" { score += 0.2 }
        if obj.status == "frozen" { score -= 0.1 }
        if obj.source == "git" && obj.type == .gitCommit { score += 0.1 }
        if obj.authority > 0.9 { score += 0.2 }

        return score
    }

    private func matchedKeywords(_ obj: KnowledgeObject, keywords: [String]) -> [String] {
        var matched: [String] = []
        let searchText = "\(obj.title) \(obj.summary) \(obj.tags.joined(separator: " ")) \(obj.path) \(obj.module ?? "") \(obj.project ?? "")".lowercased()

        for kw in keywords {
            if searchText.contains(kw.lowercased()) {
                matched.append(kw)
            }
        }
        return matched
    }

    private func extractKeywords(from question: String) -> [String] {
        let stopwords: Set<String> = [
            "le", "la", "les", "un", "une", "des", "du", "de", "d", "l",
            "et", "ou", "mais", "donc", "car", "ni", "or", "est", "sont",
            "a", "ont", "dans", "pour", "sur", "avec", "ce", "cette", "ces",
            "qui", "que", "quoi", "dont", "ou", "il", "elle", "on", "nous",
            "vous", "ils", "elles", "au", "aux", "en", "par", "the", "a",
            "an", "is", "are", "was", "were", "be", "been", "i", "you", "he",
            "she", "it", "we", "they", "this", "that", "these", "those", "in",
            "on", "at", "to", "for", "with", "from", "by", "of", "and", "or",
            "but", "not", "no", "what", "which", "who", "whom", "how", "where",
            "when", "exists", "there", "any", "all", "some", "each", "every",
            "réparer", "trouver", "chercher", "donner", "préparer", "mission"
        ]

        return question
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 && !stopwords.contains($0) }
    }

    private func inferContextType(from question: String) -> KnowledgeObjectType? {
        let q = question.lowercased()
        if q.contains("runtime") || q.contains("runtime") { return .file }
        if q.contains("cockpit") || q.contains("cockpit") { return .file }
        if q.contains("commit") || q.contains("git") { return .gitCommit }
        if q.contains("conversation") || q.contains("chat") { return .conversation }
        if q.contains("rapport") || q.contains("report") || q.contains("audit") { return .report }
        if q.contains("pdf") || q.contains("document") { return .pdf }
        if q.contains("décision") || q.contains("decision") { return .decision }
        if q.contains("freeze") || q.contains("gel") { return .freeze }
        if q.contains("archive") { return .archive }
        if q.contains("projet") || q.contains("project") { return .project }
        return nil
    }

    private func deduplicate(_ candidates: [ScoredObject]) -> [ScoredObject] {
        var seen = Set<String>()
        return candidates.filter { seen.insert($0.object.id).inserted }
    }

    private func buildExplanation(contextType: KnowledgeObjectType?, keywords: [String], itemCount: Int) -> String {
        var parts: [String] = ["Context Engine V2 selected \(itemCount) relevant items"]
        if let type = contextType { parts.append("focused on \(type.rawValue)") }
        if !keywords.isEmpty { parts.append("matching keywords: \(keywords.joined(separator: ", "))") }
        parts.append("with confidence scoring based on authority, freshness, and semantic relevance")
        return parts.joined(separator: ", ")
    }
}

struct KnowledgeContextItem: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let summary: String
    let type: KnowledgeObjectType
    let source: String
    let path: String
    let project: String?
    let module: String?
    let tags: [String]
    let relevance: Double
    let confidence: Double
    let reason: String
    let matchedKeywords: [String]
}

struct KnowledgeContextResult: Codable {
    let question: String
    let timestamp: Date
    let items: [KnowledgeContextItem]
    let totalMatches: Int
    let totalWeight: Double
    let confidence: Double
    let responseTimeMs: Int
    let explanation: String

    static func empty(question: String) -> KnowledgeContextResult {
        KnowledgeContextResult(
            question: question, timestamp: Date(), items: [],
            totalMatches: 0, totalWeight: 0, confidence: 0,
            responseTimeMs: 0, explanation: "No context available"
        )
    }
}
