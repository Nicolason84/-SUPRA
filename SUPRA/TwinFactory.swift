import Foundation
import Combine

struct TwinBlueprint: Codable {
    let type: TwinType
    let name: String
    let description: String
    let sourceType: String
    let sourceId: String
    let authority: KnowledgeAuthority?
    let confidence: Double
}

@MainActor
final class TwinFactory: ObservableObject {
    @Published var isBuilding = false
    @Published var lastBuildDate: Date?

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

    func buildAll() {
        isBuilding = true
        let objects = kernel.allObjectsSnapshot()

        buildProjectTwin(objects)
        buildWorkspaceTwin(objects)
        buildMissionTwins(objects)
        buildDecisionTwins(objects)
        buildKnowledgeTwin(objects)
        buildRuntimeTwin(objects)

        lastBuildDate = Date()
        isBuilding = false
    }

    func buildTwin(from blueprint: TwinBlueprint) -> TwinIdentity? {
        let now = ISO8601DateFormatter().string(from: Date())
        let twinId = "twin_\(blueprint.type.rawValue)_\(blueprint.sourceId.prefix(16))"

        let identity = TwinIdentity(
            id: twinId,
            type: blueprint.type,
            name: blueprint.name,
            description: blueprint.description,
            sourceId: blueprint.sourceId,
            sourceType: blueprint.sourceType,
            createdAt: now,
            updatedAt: now,
            version: 1,
            hash: nil,
            authority: blueprint.authority,
            confidence: blueprint.confidence
        )

        let lifecycle = TwinLifecycle(
            id: "lc_\(twinId)",
            twinId: twinId,
            status: .active,
            createdBy: "TwinFactory",
            createdAt: now,
            updatedAt: now,
            lastSyncAt: now,
            lastVerifiedAt: now,
            versionHistory: [
                TwinVersionRecord(id: "ver_1", version: 1, status: .active,
                                  changeDescription: "Création automatique depuis blueprint",
                                  changedBy: "TwinFactory", changedAt: now, hash: nil)
            ],
            transitionHistory: [
                TwinTransitionRecord(id: "trans_1", fromStatus: .creating, toStatus: .active,
                                     reason: "Création initiale", triggeredBy: "TwinFactory", triggeredAt: now)
            ]
        )

        registry.register(identity)
        lifecycles.register(lifecycle)

        return identity
    }

    private func buildProjectTwin(_ objects: [CAnnoNicoObject]) {
        let byProject = Dictionary(grouping: objects, by: { $0.project ?? "unknown" })
        for (project, objs) in byProject where project != "unknown" {
            let auth = objs.compactMap(\.authority).max { $0.rank < $1.rank }
            let blueprint = TwinBlueprint(
                type: .project,
                name: project,
                description: "Project Twin pour \(project) — \(objs.count) objets associés",
                sourceType: "workspace",
                sourceId: "project_\(project)",
                authority: auth,
                confidence: 0.85
            )
            if let twin = buildTwin(from: blueprint) {
                for obj in objs.prefix(10) {
                    let binding = TwinBindings.createBinding(twinId: twin.id, object: obj, strength: 0.9)
                    bindings.register(binding)
                }
            }
        }
    }

    private func buildWorkspaceTwin(_ objects: [CAnnoNicoObject]) {
        let sources = Set(objects.map(\.source.rawValue))
        let blueprint = TwinBlueprint(
            type: .workspace,
            name: "SUPRA Workspace",
            description: "Workspace Twin — \(objects.count) objets, \(sources.count) sources",
            sourceType: "workspace",
            sourceId: "workspace_supra",
            authority: .founder,
            confidence: 1.0
        )
        if let twin = buildTwin(from: blueprint) {
            for obj in objects.prefix(20) {
                let binding = TwinBindings.createBinding(twinId: twin.id, object: obj, strength: 0.7)
                bindings.register(binding)
            }
        }
    }

    private func buildMissionTwins(_ objects: [CAnnoNicoObject]) {
        let missions = objects.filter { $0.type == .mission || $0.type == .decision || $0.type == .evidence }
        let groups = Dictionary(grouping: missions, by: { $0.project ?? "unknown" })
        for (project, group) in groups where project != "unknown" {
            let blueprint = TwinBlueprint(
                type: .mission,
                name: "Missions — \(project)",
                description: "Mission Twin: \(group.count) missions/décisions/preuves dans \(project)",
                sourceType: "knowledge",
                sourceId: "missions_\(project)",
                authority: .executive,
                confidence: 0.9
            )
            if let twin = buildTwin(from: blueprint) {
                for obj in group {
                    let binding = TwinBindings.createBinding(twinId: twin.id, object: obj, strength: 1.0)
                    bindings.register(binding)
                }
            }
        }
    }

    private func buildDecisionTwins(_ objects: [CAnnoNicoObject]) {
        let decisions = objects.filter { $0.type == .decision || $0.type == .evidence }
        for decision in decisions {
            let blueprint = TwinBlueprint(
                type: .decision,
                name: "Decision: \(decision.name)",
                description: decision.description,
                sourceType: decision.source.rawValue,
                sourceId: decision.id,
                authority: decision.authority,
                confidence: 0.9
            )
            if let twin = buildTwin(from: blueprint) {
                let binding = TwinBindings.createBinding(twinId: twin.id, object: decision, strength: 1.0)
                bindings.register(binding)
            }
        }
    }

    private func buildKnowledgeTwin(_ objects: [CAnnoNicoObject]) {
        let typeCount = Dictionary(grouping: objects, by: { $0.type.rawValue }).count
        let blueprint = TwinBlueprint(
            type: .knowledge,
            name: "Knowledge Graph",
            description: "Knowledge Twin — \(objects.count) objects, \(typeCount) types",
            sourceType: "knowledge_graph",
            sourceId: "knowledge_graph_v2",
            authority: .architect,
            confidence: 0.95
        )
        if let twin = buildTwin(from: blueprint) {
            let topTypes = Dictionary(grouping: objects, by: { $0.type.rawValue })
                .sorted { $0.value.count > $1.value.count }
                .prefix(5)
            for (_, group) in topTypes {
                if let first = group.first {
                    let binding = TwinBindings.createBinding(twinId: twin.id, object: first, strength: 0.8)
                    bindings.register(binding)
                }
            }
        }
    }

    private func buildRuntimeTwin(_ objects: [CAnnoNicoObject]) {
        let runtimeObjects = objects.filter { $0.name.lowercased().contains("runtime") || $0.module == "Runtime" }
        let blueprint = TwinBlueprint(
            type: .runtime,
            name: "SUPRA Runtime",
            description: "Runtime Twin — \(runtimeObjects.count) objets liés au runtime",
            sourceType: "workspace",
            sourceId: "runtime_supra",
            authority: .builder,
            confidence: 0.85
        )
        if let twin = buildTwin(from: blueprint) {
            for obj in runtimeObjects.prefix(10) {
                let binding = TwinBindings.createBinding(twinId: twin.id, object: obj, strength: 0.9)
                bindings.register(binding)
            }
        }
    }

    func summary() -> String {
        return "TwinFactory: \(registry.count()) twins, dernier build: \(lastBuildDate?.ISO8601Format() ?? "jamais")"
    }
}
