import Foundation
import Combine

struct TwinExplorerQuery: Codable {
    let types: [TwinType]?
    let status: TwinStatus?
    let text: String?
    let minConfidence: Double?
    let authority: KnowledgeAuthority?
    let sourceType: String?
    let maxResults: Int
}

struct TwinExplorerResult: Identifiable, Codable, Equatable {
    let id: String
    let twin: TwinIdentity
    let lifecycle: TwinLifecycle?
    let bindings: [TwinBinding]
    let sourceObjects: [CAnnoNicoObject]
    let neighbourTwins: [TwinIdentity]
    let relevanceScore: Double
    let explanation: String?

    static func == (lhs: TwinExplorerResult, rhs: TwinExplorerResult) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class TwinExplorer: ObservableObject {
    @Published var results: [TwinExplorerResult] = []
    @Published var isExploring = false

    private let kernel: NOVAKnowledgeKernel
    private let registry: TwinRegistry
    private let bindings: TwinBindings
    private let lifecycles: TwinLifecycleManager

    nonisolated init(kernel: NOVAKnowledgeKernel = MainActor.assumeIsolated { NOVAKnowledgeKernel.shared },
         registry: TwinRegistry = MainActor.assumeIsolated { TwinRegistry.shared },
         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
         lifecycles: TwinLifecycleManager = MainActor.assumeIsolated { TwinLifecycleManager() }) {
        self.kernel = kernel
        self.registry = registry
        self.bindings = bindings
        self.lifecycles = lifecycles
    }

    func explore(_ query: TwinExplorerQuery) {
        isExploring = true
        results = []

        var candidates = registry.twins

        if let types = query.types {
            candidates = candidates.filter { types.contains($0.type) }
        }
        if let text = query.text?.lowercased(), !text.isEmpty {
            candidates = candidates.filter {
                $0.name.lowercased().contains(text) ||
                $0.description.lowercased().contains(text)
            }
        }
        if let sourceType = query.sourceType {
            candidates = candidates.filter { $0.sourceType == sourceType }
        }
        if let authority = query.authority {
            candidates = candidates.filter { $0.authority == authority }
        }
        if let minConfidence = query.minConfidence {
            candidates = candidates.filter { $0.confidence >= minConfidence }
        }

        let allObjects = kernel.allObjectsSnapshot()
        let allTwins = registry.twins

        let scored = candidates.map { twin -> (TwinIdentity, Double) in
            var score = 0.5
            let twinBindings = bindings.bindings(for: twin.id)

            score += Double(twinBindings.count) * 0.05
            score += twin.confidence * 0.2

            if let lc = lifecycles.lifecycle(for: twin.id) {
                if lc.status == .active { score += 0.1 }
            }

            if query.status != nil {
                if let lc = lifecycles.lifecycle(for: twin.id), lc.status == query.status {
                    score += 0.15
                }
            }

            if let auth = twin.authority {
                score += Double(auth.rank) / 200.0
            }

            return (twin, min(score, 1.0))
        }

        let sorted = scored.sorted { $0.1 > $1.1 }
        let selected = sorted.prefix(query.maxResults)

        results = selected.map { twin, score in
            let twinBindings = bindings.bindings(for: twin.id)
            let sourceIds = Set(twinBindings.map(\.sourceId))
            let sourceObjects = allObjects.filter { sourceIds.contains($0.id) }

            let relatedTwinIds = Set(twinBindings.flatMap { b in
                bindings.bindings(forSourceId: b.sourceId).map(\.twinId)
            })
            let neighbourTwins = allTwins.filter { relatedTwinIds.contains($0.id) && $0.id != twin.id }

            return TwinExplorerResult(
                id: "exp_\(twin.id)",
                twin: twin,
                lifecycle: lifecycles.lifecycle(for: twin.id),
                bindings: twinBindings,
                sourceObjects: sourceObjects,
                neighbourTwins: neighbourTwins,
                relevanceScore: score,
                explanation: scoreExplanation(twin, score, twinBindings.count, neighbourTwins.count)
            )
        }

        isExploring = false
    }

    private func scoreExplanation(_ twin: TwinIdentity, _ score: Double, _ bindingCount: Int, _ neighbourCount: Int) -> String {
        "Twin \(twin.name) (\(twin.type.rawValue)): score \(String(format: "%.2f", score)), \(bindingCount) bindings, \(neighbourCount) voisins"
    }

    func neighbours(of twinId: String, maxDepth: Int = 2) -> [TwinExplorerResult] {
        explore(TwinExplorerQuery(types: nil, status: nil, text: nil, minConfidence: nil,
                                  authority: nil, sourceType: nil, maxResults: 50))
        return results
    }

    func clear() {
        results = []
    }
}
