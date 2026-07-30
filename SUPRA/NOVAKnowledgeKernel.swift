import Foundation
import Combine

@MainActor
final class NOVAKnowledgeKernel: ObservableObject {
    static let shared = NOVAKnowledgeKernel()

    @Published var isInitialized = false
    @Published var objectCount = 0
    @Published var sourceCount = 0
    @Published var relationshipCount = 0
    @Published var lastBuildDate: Date?

    var explorer: KnowledgeExplorer { _explorer }
    var governance: WorkspaceGovernor { _governance }
    var memory: ExecutiveMemory { _memory }
    var bridge: OpenCodeBridge { _bridge }
    var gateway: RuntimeGateway { _gateway }

    private lazy var _explorer = KnowledgeExplorer()
    private lazy var _governance = WorkspaceGovernor()
    private lazy var _memory = ExecutiveMemory()
    private lazy var _bridge = OpenCodeBridge.shared
    private lazy var _gateway = RuntimeGateway.shared

    private var allObjects: [CAnnoNicoObject] = []
    private var allRelations: [KnowledgeRelationship] = []
    private var allSources: [KnowledgeSource] = []

    private init() {}

    func build() {
        allObjects = []
        allRelations = []
        allSources = []
        isInitialized = false

        objectCount = allObjects.count
        sourceCount = allSources.count
        relationshipCount = allRelations.count
        lastBuildDate = Date()

        isInitialized = true
    }

    func registerObjects(_ objects: [CAnnoNicoObject]) {
        let existing = Set(allObjects.map(\.id))
        let new = objects.filter { !existing.contains($0.id) }
        allObjects.append(contentsOf: new)
        objectCount = allObjects.count
        _explorer.load(allObjects)
    }

    func registerRelations(_ relations: [KnowledgeRelationship]) {
        allRelations.append(contentsOf: relations)
        relationshipCount = allRelations.count
    }

    func registerSources(_ sources: [KnowledgeSource]) {
        allSources.append(contentsOf: sources)
        sourceCount = allSources.count
    }

    func allObjectsSnapshot() -> [CAnnoNicoObject] { allObjects }
    func allRelationsSnapshot() -> [KnowledgeRelationship] { allRelations }
    func allSourcesSnapshot() -> [KnowledgeSource] { allSources }

    func findObject(byId id: String) -> CAnnoNicoObject? {
        allObjects.first { $0.id == id }
    }

    func findObjects(byProject project: String) -> [CAnnoNicoObject] {
        allObjects.filter { $0.project == project }
    }

    func findObjects(byType type: CAnnoNicoType) -> [CAnnoNicoObject] {
        allObjects.filter { $0.type == type }
    }

    func findObjects(bySource source: CAnnoNicoSource) -> [CAnnoNicoObject] {
        allObjects.filter { $0.source == source }
    }

    func findRelations(forObjectId id: String) -> [KnowledgeRelationship] {
        allRelations.filter { $0.sourceId == id || $0.targetId == id }
    }

    func lineage(for objectId: String) -> KnowledgeLineage? {
        allObjects.first { $0.id == objectId }?.lineage
    }

    func query(_ query: KnowledgeExplorerQuery) {
        _explorer.search(query)
    }

    func summary() -> [String: Any] {
        [
            "initialized": isInitialized,
            "objects": objectCount,
            "sources": sourceCount,
            "relations": relationshipCount,
            "lastBuild": lastBuildDate?.ISO8601Format() ?? "never",
            "typesBreakdown": Dictionary(grouping: allObjects, by: { $0.type.rawValue }).mapValues(\.count),
            "sourcesBreakdown": Dictionary(grouping: allObjects, by: { $0.source.rawValue }).mapValues(\.count)
        ]
    }
}
