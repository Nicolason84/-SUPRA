import Foundation
import Combine

@MainActor
final class UniverseSearch: ObservableObject {
    @Published var query: String = ""
    @Published var results: [UniverseSearchResult] = []
    @Published var isSearching = false
    @Published var scope: UniverseSearchScope = .all

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

    func search(_ text: String) {
        query = text
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        isSearching = true
        results = []

        let lower = text.lowercased()
        var allResults: [UniverseSearchResult] = []

        if scope == .all || scope == .objects {
            allResults += searchObjects(lower)
        }
        if scope == .all || scope == .twins {
            allResults += searchTwins(lower)
        }
        if scope == .all || scope == .projects {
            allResults += searchProjects(lower)
        }

        allResults.sort { $0.score > $1.score }
        results = Array(allResults.prefix(30))
        isSearching = false
    }

    private func searchObjects(_ text: String) -> [UniverseSearchResult] {
        kernel.allObjectsSnapshot().compactMap { obj -> UniverseSearchResult? in
            var score = 0.0
            var matchType = ""

            if obj.name.lowercased().contains(text) { score += 0.8; matchType = "nom" }
            else if obj.description.lowercased().contains(text) { score += 0.5; matchType = "description" }
            else if obj.tags.contains(where: { $0.lowercased().contains(text) }) { score += 0.3; matchType = "tags" }
            else if let proj = obj.project, proj.lowercased().contains(text) { score += 0.4; matchType = "projet" }
            else { return nil }

            if let auth = obj.authority { score += Double(auth.rank) / 200.0 }

            return UniverseSearchResult(
                id: "obj_\(obj.id)",
                type: "object",
                subtype: obj.type.rawValue,
                title: obj.name,
                description: obj.description,
                source: obj.source.rawValue,
                path: obj.path,
                score: min(score, 1.0),
                context: "Objet \(matchType) — \(obj.project ?? "inconnu")"
            )
        }
    }

    private func searchTwins(_ text: String) -> [UniverseSearchResult] {
        registry.twins.compactMap { twin -> UniverseSearchResult? in
            var score = 0.0

            if twin.name.lowercased().contains(text) { score += 0.9 }
            else if twin.description.lowercased().contains(text) { score += 0.6 }
            else { return nil }

            score += twin.confidence * 0.15
            if let auth = twin.authority { score += Double(auth.rank) / 200.0 }

            let lc = lifecycles.lifecycle(for: twin.id)

            return UniverseSearchResult(
                id: "twin_\(twin.id)",
                type: "twin",
                subtype: twin.type.rawValue,
                title: twin.name,
                description: twin.description,
                source: twin.sourceType,
                path: nil,
                score: min(score, 1.0),
                context: "Twin \(twin.type.rawValue) — \(lc?.status.rawValue ?? "inconnu")"
            )
        }
    }

    private func searchProjects(_ text: String) -> [UniverseSearchResult] {
        let byProject = Dictionary(grouping: kernel.allObjectsSnapshot(), by: { $0.project ?? "unknown" })
        return byProject.compactMap { project, objs -> UniverseSearchResult? in
            guard project.lowercased().contains(text) else { return nil }
            let types = Set(objs.map(\.type.rawValue))
            return UniverseSearchResult(
                id: "proj_\(project)",
                type: "project",
                subtype: "workspace",
                title: project,
                description: "\(objs.count) objets, \(types.count) types",
                source: "workspace",
                path: nil,
                score: 0.8,
                context: "Projet — \(types.sorted().joined(separator: ", "))"
            )
        }
    }

    func clear() {
        query = ""
        results = []
    }
}

enum UniverseSearchScope: String, Codable, CaseIterable, Identifiable {
    case all, objects, twins, projects

    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

struct UniverseSearchResult: Identifiable, Codable, Equatable {
    let id: String
    let type: String
    let subtype: String
    let title: String
    let description: String
    let source: String?
    let path: String?
    let score: Double
    let context: String?

    static func == (lhs: UniverseSearchResult, rhs: UniverseSearchResult) -> Bool {
        lhs.id == rhs.id
    }
}
