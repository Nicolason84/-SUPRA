import Foundation
import Combine

@MainActor
final class KnowledgeGraph: ObservableObject {
    @Published var objects: [KnowledgeObject] = []
    @Published var relations: [KnowledgeRelation] = []
    @Published var isBuilt = false
    @Published var lastUpdate: Date?

    private var providers: [KnowledgeProvider] = []
    private var objectIndex: [String: KnowledgeObject] = [:]
    private var adjacency: [String: Set<String>] = [:]

    func registerProvider(_ provider: KnowledgeProvider) {
        providers.append(provider)
    }

    func build(sourceObjects: [KnowledgeObject] = [], sourceRelations: [KnowledgeRelation] = []) async {
        var allObjects = sourceObjects
        var allRelations = sourceRelations

        for provider in providers {
            let discovered = await provider.discover()
            allObjects.append(contentsOf: discovered)

            let providedRels = await provider.relations()
            allRelations.append(contentsOf: providedRels)
        }

        allObjects = deduplicate(allObjects)
        allRelations = deduplicateRelations(allRelations)
        allRelations = addInverseRelations(allRelations)

        objects = allObjects
        relations = allRelations
        objectIndex = Dictionary(uniqueKeysWithValues: allObjects.map { ($0.id, $0) })
        buildAdjacency()
        isBuilt = true
        lastUpdate = Date()
    }

    func object(by id: String) -> KnowledgeObject? { objectIndex[id] }

    func neighbors(of id: String) -> [KnowledgeObject] {
        guard let neighborIds = adjacency[id] else { return [] }
        return neighborIds.compactMap { objectIndex[$0] }
    }

    func objects(of type: KnowledgeObjectType) -> [KnowledgeObject] {
        objects.filter { $0.type == type }
    }

    func objects(from source: KnowledgeSourceType) -> [KnowledgeObject] {
        objects.filter { $0.source == source.rawValue }
    }

    func related(to id: String, via type: RelationType) -> [KnowledgeObject] {
        let targetIds = Set(relations.filter { $0.sourceId == id && $0.type == type }.map { $0.targetId })
        return targetIds.compactMap { objectIndex[$0] }
    }

    func path(from sourceId: String, to targetId: String) -> [KnowledgeObject] {
        var visited = Set<String>()
        var queue: [(String, [KnowledgeObject])] = [(sourceId, [])]

        while !queue.isEmpty {
            let (current, path) = queue.removeFirst()
            if current == targetId {
                var result = path
                if let obj = objectIndex[current] { result.append(obj) }
                return result
            }
            guard !visited.contains(current) else { continue }
            visited.insert(current)
            if let obj = objectIndex[current] {
                let nextPath = path + [obj]
                for neighbor in adjacency[current] ?? [] {
                    queue.append((neighbor, nextPath))
                }
            }
        }
        return []
    }

    func query(_ type: KnowledgeObjectType? = nil, source: KnowledgeSourceType? = nil, project: String? = nil, tag: String? = nil, status: String? = nil) -> [KnowledgeObject] {
        var result = objects
        if let t = type { result = result.filter { $0.type == t } }
        if let s = source { result = result.filter { $0.source == s.rawValue } }
        if let p = project { result = result.filter { $0.project == p } }
        if let t = tag { result = result.filter { $0.tags.contains(t) } }
        if let s = status { result = result.filter { $0.status == s } }
        return result
    }

    private func deduplicate(_ objects: [KnowledgeObject]) -> [KnowledgeObject] {
        var seen = Set<String>()
        return objects.filter { seen.insert($0.id).inserted }
    }

    private func deduplicateRelations(_ relations: [KnowledgeRelation]) -> [KnowledgeRelation] {
        var seen = Set<String>()
        return relations.filter { seen.insert($0.id).inserted }
    }

    private func addInverseRelations(_ relations: [KnowledgeRelation]) -> [KnowledgeRelation] {
        var all = relations
        var seen = Set<String>()
        for rel in relations where rel.bidirectional {
            let inverseId = "\(rel.targetId)->\(rel.sourceId)[\(rel.type.inverse.rawValue)]"
            if !seen.contains(inverseId) {
                seen.insert(inverseId)
                all.append(KnowledgeRelation(
                    sourceId: rel.targetId, targetId: rel.sourceId,
                    type: rel.type.inverse, weight: rel.weight,
                    bidirectional: rel.bidirectional
                ))
            }
        }
        return all
    }

    private func buildAdjacency() {
        adjacency.removeAll()
        for rel in relations {
            adjacency[rel.sourceId, default: []].insert(rel.targetId)
            adjacency[rel.targetId, default: []].insert(rel.sourceId)
        }
    }
}
