import Foundation
import Combine

struct UniverseState: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let version: String
    let twinCount: Int
    let bindingCount: Int
    let relationCount: Int
    let objectCount: Int
    let sourceCount: Int
    let healthScore: Double
    let lastBuildDate: String?
    let uptime: String

    static func == (lhs: UniverseState, rhs: UniverseState) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class TwinUniverse: ObservableObject {
    static let shared = TwinUniverse()

    @Published var state: UniverseState?
    @Published var isInitialized = false
    @Published var startDate: Date?

    private let kernel: NOVAKnowledgeKernel
    private let registry: TwinRegistry
    private lazy var bindings = TwinBindings()
    private lazy var lifecycles = TwinLifecycleManager()
    private let factory: TwinFactory
    private let synchronizer: TwinSynchronizer
    private let explorer: TwinExplorer
    private let analytics: TwinAnalytics
    private let comparison: TwinComparisonEngine
    private let renderer: TwinRenderer

    private init() {
        kernel = .shared
        registry = .shared
        factory = TwinFactory()
        synchronizer = TwinSynchronizer()
        explorer = TwinExplorer()
        analytics = TwinAnalytics()
        comparison = TwinComparisonEngine()
        renderer = TwinRenderer()
    }

    func initialize() {
        startDate = Date()
        isInitialized = true

        factory.buildAll()
        synchronizer.sync()
        analytics.capture()
        renderer.render()

        refreshState()
    }

    func buildAllTwins() {
        factory.buildAll()
        refreshState()
    }

    func syncAll() {
        synchronizer.sync()
        synchronizer.applyAll()
        refreshState()
    }

    func captureAnalytics() {
        analytics.capture()
        refreshState()
    }

    func renderAll() {
        renderer.render()
    }

    func compareAll() {
        comparison.compareAll()
    }

    var kernelInstance: NOVAKnowledgeKernel { kernel }
    var registryInstance: TwinRegistry { registry }
    var bindingsInstance: TwinBindings { bindings }
    var lifecycleInstance: TwinLifecycleManager { lifecycles }
    var factoryInstance: TwinFactory { factory }
    var synchronizerInstance: TwinSynchronizer { synchronizer }
    var explorerInstance: TwinExplorer { explorer }
    var analyticsInstance: TwinAnalytics { analytics }
    var comparisonInstance: TwinComparisonEngine { comparison }
    var rendererInstance: TwinRenderer { renderer }

    private func refreshState() {
        let objects = kernel.allObjectsSnapshot()
        let now = Date()
        let interval = startDate.map { now.timeIntervalSince($0) } ?? 0
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        state = UniverseState(
            id: "universe_v1",
            name: "NOVA Universe",
            version: "1.0.0",
            twinCount: registry.count(),
            bindingCount: bindings.bindings.count,
            relationCount: 0,
            objectCount: objects.count,
            sourceCount: Set(objects.map(\.source.rawValue)).count,
            healthScore: 9.0,
            lastBuildDate: ISO8601DateFormatter().string(from: now),
            uptime: "\(hours)h \(minutes)m"
        )
    }

    func summary() -> String {
        guard let s = state else { return "Univers non initialisé" }
        return """
        NOVA Universe Engine
        Version: \(s.version)
        Twins: \(s.twinCount) | Bindings: \(s.bindingCount)
        Objets: \(s.objectCount) | Sources: \(s.sourceCount)
        Santé: \(s.healthScore)/10
        Uptime: \(s.uptime)
        """
    }
}
