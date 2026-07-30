import Foundation
import Combine

struct TwinComparison: Identifiable, Codable, Equatable {
    let id: String
    let twinAId: String
    let twinBId: String
    let twinAName: String
    let twinBName: String
    let typeMatch: Bool
    let statusMatch: Bool
    let authorityMatch: Bool
    let sourceOverlap: Double
    let bindingOverlap: Double
    let confidenceDifference: Double
    let descriptionSimilarity: Double
    let overallSimilarity: Double
    let differences: [String: TwinDifference]

    static func == (lhs: TwinComparison, rhs: TwinComparison) -> Bool {
        lhs.id == rhs.id
    }
}

struct TwinDifference: Codable, Equatable {
    let from: String
    let to: String

    init(_ from: String, _ to: String) {
        self.from = from
        self.to = to
    }
}

@MainActor
final class TwinComparisonEngine: ObservableObject {
    @Published var comparisons: [TwinComparison] = []

    private let registry: TwinRegistry
    private let bindings: TwinBindings
    private let lifecycles: TwinLifecycleManager

    nonisolated init(registry: TwinRegistry = MainActor.assumeIsolated { TwinRegistry.shared },
         bindings: TwinBindings = MainActor.assumeIsolated { TwinBindings() },
         lifecycles: TwinLifecycleManager = MainActor.assumeIsolated { TwinLifecycleManager() }) {
        self.registry = registry
        self.bindings = bindings
        self.lifecycles = lifecycles
    }

    func compare(_ twinA: TwinIdentity, _ twinB: TwinIdentity) -> TwinComparison {
        let bindingsA = Set(bindings.bindings(for: twinA.id).map(\.sourceId))
        let bindingsB = Set(bindings.bindings(for: twinB.id).map(\.sourceId))

        let bindingOverlap = bindingsA.isEmpty && bindingsB.isEmpty ? 0 :
            Double(bindingsA.intersection(bindingsB).count) / Double(max(bindingsA.union(bindingsB).count, 1))

        let lcA = lifecycles.lifecycle(for: twinA.id)
        let lcB = lifecycles.lifecycle(for: twinB.id)

        let descA = Set(twinA.description.lowercased().split(separator: " "))
        let descB = Set(twinB.description.lowercased().split(separator: " "))
        let descOverlap = descA.isEmpty || descB.isEmpty ? 0 :
            Double(descA.intersection(descB).count) / Double(descA.union(descB).count)

        let typeMatch = twinA.type == twinB.type
        let statusMatch = lcA?.status == lcB?.status
        let authorityMatch = twinA.authority == twinB.authority
        let confDiff = abs(twinA.confidence - twinB.confidence)

        let nameWordsA = Set(twinA.name.lowercased().split(separator: " "))
        let nameWordsB = Set(twinB.name.lowercased().split(separator: " "))
        let nameOverlap = nameWordsA.isEmpty || nameWordsB.isEmpty ? 0 :
            Double(nameWordsA.intersection(nameWordsB).count) / Double(nameWordsA.union(nameWordsB).count)

        let overall = (bindingOverlap * 0.3) + (descOverlap * 0.2) + (nameOverlap * 0.2) +
            (typeMatch ? 0.15 : 0) + (statusMatch ? 0.1 : 0) + (authorityMatch ? 0.05 : 0)

        var differences: [String: TwinDifference] = [:]
        if twinA.type != twinB.type { differences["type"] = TwinDifference(twinA.type.rawValue, twinB.type.rawValue) }
        if twinA.authority != twinB.authority {
            differences["authority"] = TwinDifference(twinA.authority?.rawValue ?? "nil", twinB.authority?.rawValue ?? "nil")
        }
        if lcA?.status != lcB?.status {
            differences["status"] = TwinDifference(lcA?.status.rawValue ?? "nil", lcB?.status.rawValue ?? "nil")
        }

        return TwinComparison(
            id: "comp_\(twinA.id)_\(twinB.id)",
            twinAId: twinA.id, twinBId: twinB.id,
            twinAName: twinA.name, twinBName: twinB.name,
            typeMatch: typeMatch, statusMatch: statusMatch,
            authorityMatch: authorityMatch,
            sourceOverlap: Double(bindingsA.intersection(bindingsB).count),
            bindingOverlap: bindingOverlap,
            confidenceDifference: confDiff,
            descriptionSimilarity: descOverlap,
            overallSimilarity: min(overall, 1.0),
            differences: differences
        )
    }

    func compareAll(threshold: Double = 0.5) {
        let twins = registry.twins
        comparisons = []

        for i in 0..<twins.count {
            for j in (i + 1)..<twins.count {
                let comparison = compare(twins[i], twins[j])
                if comparison.overallSimilarity >= threshold {
                    comparisons.append(comparison)
                }
            }
        }

        comparisons.sort { $0.overallSimilarity > $1.overallSimilarity }
    }

    func similarTwins(to twinId: String, threshold: Double = 0.3) -> [TwinComparison] {
        comparisons.filter { ($0.twinAId == twinId || $0.twinBId == twinId) && $0.overallSimilarity >= threshold }
    }

    func summary() -> String {
        return "TwinComparison: \(comparisons.count) paires comparées"
    }
}
