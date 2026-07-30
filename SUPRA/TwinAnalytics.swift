import Foundation
import Combine

struct TwinAnalyticsSnapshot: Identifiable, Codable, Equatable {
    let id: String
    let timestamp: String
    let totalTwins: Int
    let byType: [String: Int]
    let byStatus: [String: Int]
    let totalBindings: Int
    let averageConfidence: Double
    let averageAuthority: Double
    let totalSourceObjects: Int
    let coverage: Double

    static func == (lhs: TwinAnalyticsSnapshot, rhs: TwinAnalyticsSnapshot) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class TwinAnalytics: ObservableObject {
    @Published var snapshots: [TwinAnalyticsSnapshot] = []
    @Published var currentSnapshot: TwinAnalyticsSnapshot?

    private let registry: TwinRegistry
    private let bindings: TwinBindings
    private let lifecycles: TwinLifecycleManager
    private let kernel: NOVAKnowledgeKernel

    nonisolated init(registry: TwinRegistry = MainActor.assumeIsolated { TwinRegistry.shared },
         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
         lifecycles: TwinLifecycleManager = MainActor.assumeIsolated { TwinLifecycleManager() },
         kernel: NOVAKnowledgeKernel = MainActor.assumeIsolated { NOVAKnowledgeKernel.shared }) {
        self.registry = registry
        self.bindings = bindings
        self.lifecycles = lifecycles
        self.kernel = kernel
    }

    func capture() {
        let twins = registry.twins
        let allBindings = bindings.bindings
        let objects = kernel.allObjectsSnapshot()

        let byType = Dictionary(grouping: twins, by: { $0.type.rawValue }).mapValues(\.count)
        let byStatus = lifecycles.statusSummary().mapKeys { $0.rawValue }

        let avgConfidence = twins.isEmpty ? 0 : twins.map(\.confidence).reduce(0, +) / Double(twins.count)
        let avgAuthority: Double = {
            let ranks = twins.compactMap { $0.authority?.rank }
            guard !ranks.isEmpty else { return 0 }
            return Double(ranks.reduce(0, +)) / Double(ranks.count)
        }()

        let coverage = objects.isEmpty ? 0 : Double(allBindings.count) / Double(objects.count)

        let snapshot = TwinAnalyticsSnapshot(
            id: "snap_\(snapshots.count + 1)",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            totalTwins: twins.count,
            byType: byType,
            byStatus: byStatus,
            totalBindings: allBindings.count,
            averageConfidence: avgConfidence,
            averageAuthority: avgAuthority / 100.0,
            totalSourceObjects: objects.count,
            coverage: coverage
        )

        snapshots.append(snapshot)
        currentSnapshot = snapshot
    }

    func summary() -> String {
        guard let s = currentSnapshot else { return "Aucun snapshot" }
        return """
        Twin Analytics: \(s.totalTwins) twins, \(s.totalBindings) bindings
        Confiance: \(String(format: "%.2f", s.averageConfidence)), Autorité: \(String(format: "%.2f", s.averageAuthority))
        Couverture: \(String(format: "%.1f", s.coverage * 100))% du Knowledge Graph
        Types: \(s.byType.keys.sorted().joined(separator: ", "))
        """
    }
}

extension Dictionary {
    func mapKeys<T>(_ transform: (Key) -> T) -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            result[transform(key)] = value
        }
        return result
    }
}
