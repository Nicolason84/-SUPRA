import Foundation
import Combine

@MainActor
final class UniverseEngine: ObservableObject {
    static let shared = UniverseEngine()

    @Published var isRunning = false
    @Published var mode: UniverseMode = .idle
    @Published var activeTask: String?

    let universe: TwinUniverse
    let knowledge: NOVAKnowledgeKernel
    let bridge: OpenCodeBridge
    let gateway: RuntimeGateway

    private init() {
        universe = .shared
        knowledge = .shared
        bridge = .shared
        gateway = .shared
    }

    func start() {
        isRunning = true
        mode = .initializing
        activeTask = "Initialisation de l'Univers..."

        knowledge.build()
        universe.initialize()

        mode = .active
        activeTask = nil
    }

    func stop() {
        isRunning = false
        mode = .idle
        activeTask = nil
    }

    func buildTwins() async {
        mode = .building
        activeTask = "Construction des Twins..."
        universe.buildAllTwins()
        mode = .active
        activeTask = nil
    }

    func syncTwins() async {
        mode = .syncing
        activeTask = "Synchronisation des Twins..."
        universe.syncAll()
        mode = .active
        activeTask = nil
    }

    func searchUniverse(query: String) async -> [TwinExplorerResult] {
        mode = .searching
        activeTask = "Recherche dans l'Univers: \(query)"

        universe.explorerInstance.explore(TwinExplorerQuery(
            types: nil, status: nil, text: query,
            minConfidence: nil, authority: nil,
            sourceType: nil, maxResults: 20
        ))

        mode = .active
        activeTask = nil
        return universe.explorerInstance.results
    }

    func dispatchMission(_ missionId: String, description: String) async {
        _ = await bridge.startMission(missionId, description: description)
    }

    func universeState() -> UniverseState? {
        universe.state
    }

    func summary() -> String {
        """
        Universe Engine: \(mode.rawValue)
        Knowledge: \(knowledge.objectCount) objects
        Twins: \(universe.state?.twinCount ?? 0)
        Bridge: \(bridge.isConnected ? "connecté" : "déconnecté")
        """
    }
}

enum UniverseMode: String, Codable, CaseIterable, Identifiable {
    case idle, initializing, active, building, syncing, searching, error

    var id: String { rawValue }
}
