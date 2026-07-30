import Foundation
import Combine

@MainActor
final class TwinRegistry: ObservableObject {
    static let shared = TwinRegistry()

    @Published var twins: [TwinIdentity] = []
    @Published var isLoaded = false

    private lazy var lifecycleManager = TwinLifecycleManager()
    private lazy var bindings = TwinBindings()

    private init() {}

    func register(_ twin: TwinIdentity) {
        if let index = twins.firstIndex(where: { $0.id == twin.id }) {
            twins[index] = twin
        } else {
            twins.append(twin)
        }
        isLoaded = true
    }

    func registerBatch(_ newTwins: [TwinIdentity]) {
        for twin in newTwins {
            register(twin)
        }
    }

    func find(byId id: String) -> TwinIdentity? {
        twins.first { $0.id == id }
    }

    func find(byType type: TwinType) -> [TwinIdentity] {
        twins.filter { $0.type == type }
    }

    func find(byName name: String) -> [TwinIdentity] {
        twins.filter { $0.name.lowercased().contains(name.lowercased()) }
    }

    func find(bySourceId sourceId: String) -> TwinIdentity? {
        twins.first { $0.sourceId == sourceId }
    }

    func lifecycle(for twinId: String) -> TwinLifecycle? {
        lifecycleManager.lifecycle(for: twinId)
    }

    func bindings(for twinId: String) -> [TwinBinding] {
        bindings.bindings(for: twinId)
    }

    func typeSummary() -> [TwinType: Int] {
        Dictionary(grouping: twins, by: { $0.type }).mapValues(\.count)
    }

    func statusSummary() -> [TwinStatus: Int] {
        lifecycleManager.statusSummary()
    }

    func count() -> Int { twins.count }

    func clear() {
        twins = []
        isLoaded = false
    }
}
