import Foundation
import Combine

struct SearchQuery: Codable {
    let text: String
    let scope: SearchScope
    let filters: [String: String]
    let maxResults: Int
    let includeMemory: Bool
    let includeKnowledge: Bool
    let includeGovernance: Bool
}

enum SearchScope: String, Codable, CaseIterable, Identifiable {
    case all, objects, projects, modules, missions
    case conversations, decisions, reports, commits
    case freezes, artifacts, files, media

    var id: String { rawValue }
}

struct SearchResult: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let type: String
    let source: String
    let path: String?
    let score: Double
    let context: String?

    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class ExecutiveSearch: ObservableObject {
    @Published var results: [SearchResult] = []
    @Published var isSearching = false
    @Published var lastQuery: SearchQuery?

    private let kernel: NOVAKnowledgeKernel
    private let memory: ExecutiveMemory

    init(kernel: NOVAKnowledgeKernel = .shared, memory: ExecutiveMemory) {
        self.kernel = kernel
        self.memory = memory
    }

    func search(_ query: SearchQuery) {
        lastQuery = query
        isSearching = true
        results = []

        var allResults: [SearchResult] = []

        if query.includeKnowledge {
            allResults.append(contentsOf: searchKnowledge(query))
        }

        if query.includeMemory {
            allResults.append(contentsOf: searchMemory(query))
        }

        if query.includeGovernance {
            allResults.append(contentsOf: searchGovernance(query))
        }

        let sorted = allResults.sorted { $0.score > $1.score }
        results = Array(sorted.prefix(query.maxResults))
        isSearching = false
    }

    private func searchKnowledge(_ query: SearchQuery) -> [SearchResult] {
        let objects = kernel.allObjectsSnapshot()
        let lower = query.text.lowercased()
        var results: [SearchResult] = []

        for obj in objects {
            var score = 0.0
            var context: String?

            if obj.name.lowercased().contains(lower) {
                score += 0.8
                context = "Nom correspond"
            }
            if obj.description.lowercased().contains(lower) {
                score += 0.5
                context = "Description correspond"
            }
            if obj.tags.contains(where: { $0.lowercased().contains(lower) }) {
                score += 0.3
                context = "Tags correspondent"
            }
            if let proj = obj.project, proj.lowercased().contains(lower) {
                score += 0.4
                context = "Projet correspond"
            }
            if let mod = obj.module, mod.lowercased().contains(lower) {
                score += 0.3
            }

            if score > 0 {
                if let auth = obj.authority {
                    score += Double(auth.rank) / 200.0
                }

                results.append(SearchResult(
                    id: "search_kg_\(obj.id)",
                    title: obj.name,
                    description: obj.description,
                    type: obj.type.rawValue,
                    source: obj.source.rawValue,
                    path: obj.path,
                    score: min(score, 1.0),
                    context: context
                ))
            }
        }

        return results
    }

    private func searchMemory(_ query: SearchQuery) -> [SearchResult] {
        let memQuery = MemoryQuery(
            text: query.text,
            maxResults: query.maxResults,
            minConfidence: nil,
            authority: nil
        )
        let memResults = memory.query(memQuery)

        return memResults.map { entry in
            SearchResult(
                id: "search_mem_\(entry.id)",
                title: entry.question,
                description: entry.answer,
                type: "memory",
                source: "executive_memory",
                path: nil,
                score: entry.confidence,
                context: "Mémoire exécutive"
            )
        }
    }

    private func searchGovernance(_ query: SearchQuery) -> [SearchResult] {
        let issues = kernel.governance.issues
        let lower = query.text.lowercased()

        return issues.filter { issue in
            issue.description.lowercased().contains(lower) ||
            issue.objectName.lowercased().contains(lower) ||
            issue.recommendation?.lowercased().contains(lower) ?? false
        }.map { issue in
            SearchResult(
                id: "search_gov_\(issue.id)",
                title: issue.objectName,
                description: issue.description,
                type: issue.type.rawValue,
                source: "governance",
                path: nil,
                score: Double(issue.severity.rank) / 3.0,
                context: issue.recommendation
            )
        }
    }

    func clear() {
        results = []
        lastQuery = nil
    }
}
