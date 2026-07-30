import Foundation
import Combine

public enum ComponentHealth: String, Sendable, Codable, CaseIterable {
    case healthy
    case degraded
    case unhealthy
    case unknown
    case inactive
}

public enum ComponentLifecycleState: String, Sendable, Codable, CaseIterable {
    case loaded
    case instantiated
    case active
    case degraded
    case error
}

public struct ComponentInstance: Sendable, Identifiable {
    public let component: PlatformComponent
    public private(set) var lifecycleState: ComponentLifecycleState
    public private(set) var health: ComponentHealth
    public private(set) var lastChecked: Date
    public private(set) var dependenciesResolved: Bool
    public private(set) var contractsValid: Bool
    public private(set) var message: String

    public var id: String { component.id }
    public var isExecutable: Bool { component.runtime.executable }
    public var isStateful: Bool { component.runtime.stateful }

    public init(component: PlatformComponent) {
        self.component = component
        self.lifecycleState = .loaded
        self.health = .unknown
        self.lastChecked = Date()
        self.dependenciesResolved = false
        self.contractsValid = false
        self.message = "Loaded from manifest"
    }

    public mutating func transition(to state: ComponentLifecycleState, message: String = "") {
        self.lifecycleState = state
        self.message = message
        self.lastChecked = Date()
    }

    public mutating func setHealth(_ health: ComponentHealth, message: String = "") {
        self.health = health
        self.message = message
        self.lastChecked = Date()
    }

    public mutating func resolveDependencies() {
        self.dependenciesResolved = true
        self.lastChecked = Date()
    }

    public mutating func markDependencyBroken() {
        self.dependenciesResolved = false
        self.lastChecked = Date()
    }

    public mutating func setContractsValid(_ valid: Bool) {
        self.contractsValid = valid
        self.lastChecked = Date()
    }
}

public struct DependencyEdge: Sendable, Identifiable {
    public let sourceID: String
    public let targetID: String
    public let broken: Bool

    public var id: String { "\(sourceID)->\(targetID)" }
}

public struct ContractValidationResult: Sendable, Identifiable {
    public let contractID: String
    public let consumerID: String
    public let publisherID: String?
    public let satisfied: Bool

    public var id: String { "\(contractID)-\(consumerID)" }
}

public struct PlatformHealthSummary: Sendable {
    public let totalComponents: Int
    public let healthy: Int
    public let degraded: Int
    public let unhealthy: Int
    public let inactive: Int
    public let unknown: Int
    public let overall: ComponentHealth
    public let executableCount: Int
    public let statefulCount: Int
}

public struct PlatformDependencySummary: Sendable {
    public let totalDependencies: Int
    public let resolved: Int
    public let broken: Int
    public let cycleDetected: Bool
    public let topologicalOrder: [String]
}

public struct PlatformContractSummary: Sendable {
    public let totalContracts: Int
    public let satisfied: Int
    public let missing: Int
    public let publishedContracts: [String: [String]]
}

public struct PlatformState: Sendable {
    public let manifestVersion: String
    public let manifestDate: String
    public let loadedAt: Date
    public let components: [String: ComponentInstance]
    public let edges: [DependencyEdge]
    public let healthSummary: PlatformHealthSummary
    public let dependencySummary: PlatformDependencySummary
    public let contractSummary: PlatformContractSummary
    public let layerBreakdown: [(String, Int)]
    public let domainBreakdown: [(String, Int)]
    public let ownerBreakdown: [(String, Int)]

    public var componentCount: Int { components.count }

    public func component(named id: String) -> ComponentInstance? { components[id] }

    public func components(inLayer layer: String) -> [ComponentInstance] {
        components.values.filter { $0.component.layer == layer }
    }

    public func components(ownedBy owner: String) -> [ComponentInstance] {
        components.values.filter { $0.component.owner == owner }
    }

    public func components(health: ComponentHealth) -> [ComponentInstance] {
        components.values.filter { $0.health == health }
    }

    public func components(dependingOn targetID: String) -> [ComponentInstance] {
        let depIDs = Set(edges.filter { $0.targetID == targetID && !$0.broken }.map(\.sourceID))
        return components.values.filter { depIDs.contains($0.id) }
    }

    public var brokenDependencies: [DependencyEdge] {
        edges.filter(\.broken)
    }

    public var degradedComponents: [ComponentInstance] {
        components(health: .degraded) + components(health: .unhealthy)
    }

    public var activeComponents: [ComponentInstance] {
        components.values.filter { $0.lifecycleState == .active }
    }
}

@MainActor
public final class SUPRARuntimeKernel: ObservableObject {
    public static let shared = SUPRARuntimeKernel()

    @Published public private(set) var state: PlatformState?
    @Published public private(set) var isLoaded = false
    @Published public private(set) var isLoading = false
    @Published public private(set) var lastError: String?
    @Published public private(set) var loadDuration: TimeInterval = 0

    private let events = SUPRARuntimeEvents.shared

    private init() {}

    public func load() {
        load(from: PlatformManifest.defaultRegistryURL())
    }

    public func load(from url: URL) {
        isLoading = true
        lastError = nil
        let start = Date()

        defer {
            loadDuration = Date().timeIntervalSince(start)
            isLoading = false
            events.emit(.modelLoaded, "Runtime kernel loaded in \(String(format: "%.2f", loadDuration))s",
                        source: "SUPRARuntimeKernel",
                        metadata: ["components": "\(state?.componentCount ?? 0)",
                                   "duration": "\(loadDuration)"])
        }

        do {
            let manifest = try PlatformManifest.load(from: url)
            events.emit(.modelLoaded, "Manifest loaded: \(manifest.components.count) components from \(manifest.registry.id)",
                        source: "SUPRARuntimeKernel")
            buildState(from: manifest)
        } catch {
            lastError = "Failed to load manifest: \(error.localizedDescription)"
            events.emit(.executionFailed, lastError!, source: "SUPRARuntimeKernel")
            isLoaded = false
        }
    }

    public func reload() {
        isLoaded = false
        state = nil
        load()
    }

    private func buildState(from manifest: PlatformManifest) {
        var components = instantiateComponents(manifest.components)
        let edges = buildDependencyGraph(components: components)
        let resolved = resolveInstances(&components, edges: edges)
        let order = topologicalSort(components: components, edges: edges)
        let contracts = validateContracts(components: components)
        let health = evaluateHealth(components: components)

        let layerBreakdown = Dictionary(grouping: manifest.components, by: \.layer)
            .map { ($0.key, $0.value.count) }
            .sorted { $0.0 < $1.0 }

        let domainBreakdown = Dictionary(grouping: manifest.components, by: \.domain)
            .map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }

        let ownerBreakdown = Dictionary(grouping: manifest.components, by: \.owner)
            .map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }

        let componentCount = components.count
        let healthyCount = components.values.filter { $0.health == .healthy }.count
        let degradedCount = components.values.filter { $0.health == .degraded }.count
        let unhealthyCount = components.values.filter { $0.health == .unhealthy }.count
        let inactiveCount = components.values.filter { $0.health == .inactive }.count
        let unknownCount = components.values.filter { $0.health == .unknown }.count
        let executableCount = components.values.filter(\.isExecutable).count
        let statefulCount = components.values.filter(\.isStateful).count

        let overallHealth: ComponentHealth = {
            if unhealthyCount > 0 { return .unhealthy }
            if degradedCount > 0 { return .degraded }
            if unknownCount > healthyCount { return .degraded }
            return .healthy
        }()

        let totalDeps = edges.count
        let brokenDeps = edges.filter(\.broken).count
        let resolvedDeps = totalDeps - brokenDeps
        let cycleDetected = order.isEmpty && !components.isEmpty

        let totalContracts = contracts.count
        let satisfiedContracts = contracts.filter(\.satisfied).count
        let missingContracts = totalContracts - satisfiedContracts
        let publishedBy = Dictionary(grouping: contracts.compactMap { $0.publisherID.map { ($0, $0) } }, by: \.0)
            .mapValues { $0.map(\.1) }

        state = PlatformState(
            manifestVersion: manifest.registry.version,
            manifestDate: manifest.registry.date,
            loadedAt: Date(),
            components: components,
            edges: edges,
            healthSummary: PlatformHealthSummary(
                totalComponents: componentCount,
                healthy: healthyCount,
                degraded: degradedCount,
                unhealthy: unhealthyCount,
                inactive: inactiveCount,
                unknown: unknownCount,
                overall: overallHealth,
                executableCount: executableCount,
                statefulCount: statefulCount
            ),
            dependencySummary: PlatformDependencySummary(
                totalDependencies: totalDeps,
                resolved: resolvedDeps,
                broken: brokenDeps,
                cycleDetected: cycleDetected,
                topologicalOrder: order
            ),
            contractSummary: PlatformContractSummary(
                totalContracts: totalContracts,
                satisfied: satisfiedContracts,
                missing: missingContracts,
                publishedContracts: publishedBy
            ),
            layerBreakdown: layerBreakdown,
            domainBreakdown: domainBreakdown,
            ownerBreakdown: ownerBreakdown
        )

        isLoaded = true
    }

    private func instantiateComponents(_ entries: [PlatformComponent]) -> [String: ComponentInstance] {
        var instances: [String: ComponentInstance] = [:]
        for entry in entries {
            var instance = ComponentInstance(component: entry)
            let health = initialHealth(for: entry)
            instance.setHealth(health, message: health == .inactive ? "Not yet active (state: \(entry.state))" : "Loaded from manifest")
            if health == .healthy || health == .inactive {
                instance.transition(to: .loaded)
            } else {
                instance.transition(to: .error, message: "Initial state indicates issue")
            }
            instances[entry.id] = instance
        }
        return instances
    }

    private func initialHealth(for component: PlatformComponent) -> ComponentHealth {
        switch component.state {
        case "CANONICAL", "PRODUCTION", "ACTIVE":
            return .healthy
        case "GOVERNANCE", "ULTIMATE":
            return .healthy
        case "FOUNDATION", "CONSTITUTION":
            return .healthy
        case "SPECIFIED":
            return .inactive
        case "PLANNED", "PARTIAL", "NOT_STARTED":
            return .inactive
        default:
            return .unknown
        }
    }

    private func buildDependencyGraph(components: [String: ComponentInstance]) -> [DependencyEdge] {
        var edges: [DependencyEdge] = []
        for instance in components.values {
            for depID in instance.component.dependencies {
                let broken = components[depID] == nil
                edges.append(DependencyEdge(sourceID: instance.id, targetID: depID, broken: broken))
            }
        }
        return edges
    }

    private func resolveInstances(_ components: inout [String: ComponentInstance], edges: [DependencyEdge]) -> Bool {
        let brokenDeps = Set(edges.filter(\.broken).map(\.sourceID))
        var allResolved = true
        for id in components.keys {
            let hasBroken = brokenDeps.contains(id)
            if hasBroken {
                components[id]?.markDependencyBroken()
                components[id]?.setHealth(.degraded, message: "Has broken dependencies")
                components[id]?.transition(to: .degraded)
                allResolved = false
            } else {
                components[id]?.resolveDependencies()
                components[id]?.transition(to: .instantiated, message: "Dependencies resolved")
            }
        }
        return allResolved
    }

    private func topologicalSort(components: [String: ComponentInstance], edges: [DependencyEdge]) -> [String] {
        var inDegree: [String: Int] = [:]
        var adjacency: [String: [String]] = [:]

        for id in components.keys {
            inDegree[id] = 0
            adjacency[id] = []
        }

        for edge in edges where !edge.broken {
            adjacency[edge.targetID, default: []].append(edge.sourceID)
            inDegree[edge.sourceID, default: 0] += 1
        }

        var queue: [String] = inDegree.filter { $0.value == 0 }.map(\.key)
        var sorted: [String] = []

        while !queue.isEmpty {
            let node = queue.removeFirst()
            sorted.append(node)
            for neighbor in adjacency[node, default: []] {
                inDegree[neighbor, default: 0] -= 1
                if inDegree[neighbor] == 0 {
                    queue.append(neighbor)
                }
            }
        }

        if sorted.count != components.count {
            return []
        }
        return sorted
    }

    private func validateContracts(components: [String: ComponentInstance]) -> [ContractValidationResult] {
        let publishedBy: [String: String] = components.values
            .flatMap { instance in
                instance.component.contractsPublished.map { ($0, instance.id) }
            }
            .reduce(into: [:]) { result, pair in
                result[pair.0] = result[pair.0] ?? pair.1
            }

        var results: [ContractValidationResult] = []
        for instance in components.values {
            for contractID in instance.component.contractsConsumed {
                let publisherID = publishedBy[contractID]
                let satisfied = publisherID != nil
                results.append(ContractValidationResult(
                    contractID: contractID,
                    consumerID: instance.id,
                    publisherID: publisherID,
                    satisfied: satisfied
                ))
            }
        }
        return results
    }

    private func evaluateHealth(components: [String: ComponentInstance]) -> ComponentHealth {
        var hasUnhealthy = false
        var hasDegraded = false
        for instance in components.values {
            if instance.health == .unhealthy { hasUnhealthy = true }
            if instance.health == .degraded { hasDegraded = true }
        }
        if hasUnhealthy { return .unhealthy }
        if hasDegraded { return .degraded }
        return .healthy
    }
}
