import Foundation
import Combine

struct KnowledgeExplorerQuery: Codable {
    let types: [CAnnoNicoType]?
    let sources: [CAnnoNicoSource]?
    let tags: [String]?
    let query: String?
    let project: String?
    let module: String?
    let authority: KnowledgeAuthority?
    let minAuthority: Int?
    let maxResults: Int
    let includeRelations: Bool
    let includeLineage: Bool
}

struct KnowledgeExplorerResult: Identifiable, Codable, Equatable {
    let id: String
    let object: CAnnoNicoObject
    let score: Double
    let matchedTags: [String]
    let matchedTerms: [String]
    let explanation: String?

    static func == (lhs: KnowledgeExplorerResult, rhs: KnowledgeExplorerResult) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class KnowledgeExplorer: ObservableObject {
    @Published var results: [KnowledgeExplorerResult] = []
    @Published var isSearching = false
    @Published var lastQuery: KnowledgeExplorerQuery?

    private var objects: [CAnnoNicoObject] = []

    func load(_ objects: [CAnnoNicoObject]) {
        self.objects = objects
    }

    func search(_ query: KnowledgeExplorerQuery) {
        lastQuery = query
        isSearching = true
        results = []

        var candidates = objects

        if let types = query.types {
            candidates = candidates.filter { types.contains($0.type) }
        }
        if let sources = query.sources {
            candidates = candidates.filter { sources.contains($0.source) }
        }
        if let project = query.project {
            candidates = candidates.filter { $0.project == project }
        }
        if let module = query.module {
            candidates = candidates.filter { $0.module == module }
        }
        if let authority = query.authority {
            candidates = candidates.filter { $0.authority == authority }
        }
        if let minAuthority = query.minAuthority {
            candidates = candidates.filter { ($0.authority?.rank ?? 0) >= minAuthority }
        }
        if let tags = query.tags, !tags.isEmpty {
            candidates = candidates.filter { obj in
                tags.allSatisfy { obj.tags.contains($0) }
            }
        }
        if let q = query.query?.lowercased(), !q.isEmpty {
            candidates = candidates.filter { obj in
                obj.name.lowercased().contains(q) ||
                obj.description.lowercased().contains(q) ||
                obj.tags.contains { $0.lowercased().contains(q) }
            }
        }

        let scored = candidates.map { obj -> (CAnnoNicoObject, Double, [String], [String]) in
            var score = 0.5
            var matchedTags: [String] = []
            var matchedTerms: [String] = []

            if let q = query.query?.lowercased(), !q.isEmpty {
                if obj.name.lowercased().contains(q) {
                    score += 0.3
                    matchedTerms.append(q)
                }
                if obj.description.lowercased().contains(q) {
                    score += 0.2
                    if !matchedTerms.contains(q) { matchedTerms.append(q) }
                }
                for tag in obj.tags {
                    if tag.lowercased().contains(q) {
                        score += 0.1
                        matchedTags.append(tag)
                    }
                }
            }

            if let auth = obj.authority {
                score += Double(auth.rank) / 200.0
            }

            if let _ = query.types {
                score += 0.1
            }

            return (obj, min(score, 1.0), matchedTags, matchedTerms)
        }

        let sorted = scored.sorted { $0.1 > $1.1 }
        let limited = sorted.prefix(query.maxResults)

        results = limited.enumerated().map { i, item in
            KnowledgeExplorerResult(
                id: "result_\(i)_\(item.0.id)",
                object: item.0,
                score: item.1,
                matchedTags: item.2,
                matchedTerms: item.3,
                explanation: scoreExplanation(item.1, item.2, item.3)
            )
        }

        isSearching = false
    }

    private func scoreExplanation(_ score: Double, _ tags: [String], _ terms: [String]) -> String {
        var parts: [String] = []
        if !terms.isEmpty { parts.append("matched \"\(terms.joined(separator: ", "))\"") }
        if !tags.isEmpty { parts.append("tagged \(tags.joined(separator: ", "))") }
        if parts.isEmpty { parts.append("authority score") }
        return parts.joined(separator: ", ")
    }

    func searchByType(_ type: CAnnoNicoType) {
        search(KnowledgeExplorerQuery(
            types: [type], sources: nil, tags: nil, query: nil,
            project: nil, module: nil, authority: nil, minAuthority: nil,
            maxResults: 50, includeRelations: false, includeLineage: false
        ))
    }

    func searchBySource(_ source: CAnnoNicoSource) {
        search(KnowledgeExplorerQuery(
            types: nil, sources: [source], tags: nil, query: nil,
            project: nil, module: nil, authority: nil, minAuthority: nil,
            maxResults: 50, includeRelations: false, includeLineage: false
        ))
    }
}
