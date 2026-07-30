import Foundation
import Combine

public struct SUPRAProviderPowerMetadata: Codable, Sendable {
    public let powerClass: PowerGear
    public let contextCapacity: Int
    public let toolCapability: [String]
    public let localOrRemote: String
    public let paidOrFree: String
    public var health: Double
    public var currentLoad: Double
    public let keepAlivePolicy: String
    public let maxConcurrency: Int

    public init(powerClass: PowerGear, contextCapacity: Int, toolCapability: [String],
                localOrRemote: String, paidOrFree: String, health: Double = 1.0,
                currentLoad: Double = 0.0, keepAlivePolicy: String = "always",
                maxConcurrency: Int = 1) {
        self.powerClass = powerClass
        self.contextCapacity = contextCapacity
        self.toolCapability = toolCapability
        self.localOrRemote = localOrRemote
        self.paidOrFree = paidOrFree
        self.health = health
        self.currentLoad = currentLoad
        self.keepAlivePolicy = keepAlivePolicy
        self.maxConcurrency = maxConcurrency
    }
}

@MainActor
public final class SUPRAProviderRegistry: ObservableObject {
    public static let shared = SUPRAProviderRegistry()

    @Published public private(set) var providers: [SUPRAProviderType: SUPRAProvider] = [:]
    @Published public private(set) var activeProviderType: SUPRAProviderType = .fallback
    @Published public private(set) var powerMetadata: [SUPRAProviderType: SUPRAProviderPowerMetadata] = [:]

    private init() {}

    public func register(_ provider: SUPRAProvider) {
        providers[provider.type] = provider
        if powerMetadata[provider.type] == nil {
            let isLocal = provider.type == .ollama || provider.type == .lmStudio
            let isPaid = provider.type == .openAI || provider.type == .anthropic || provider.type == .gemini || provider.type == .openRouter
            let meta = SUPRAProviderPowerMetadata(
                powerClass: provider.type == .ollama ? .G2_STANDARD : .G3_TORQUE,
                contextCapacity: 8192,
                toolCapability: provider.supportedCapabilities.map(\.rawValue),
                localOrRemote: isLocal ? "local" : "remote",
                paidOrFree: isPaid ? "paid" : "free",
                keepAlivePolicy: isLocal ? "always" : "ondemand",
                maxConcurrency: isLocal ? 2 : 5
            )
            powerMetadata[provider.type] = meta
        }
    }

    public func provider(for type: SUPRAProviderType) -> SUPRAProvider? { providers[type] }

    public func availableProviders() async -> [SUPRAProvider] {
        var result: [SUPRAProvider] = []
        for provider in providers.values {
            if await provider.isAvailable { result.append(provider) }
        }
        return result
    }

    public func setActive(_ type: SUPRAProviderType) {
        guard providers[type] != nil else { return }
        activeProviderType = type
    }

    public func healthCheck() async -> [SUPRAProviderType: Bool] {
        var results: [SUPRAProviderType: Bool] = [:]
        for (type, provider) in providers {
            let healthy = await provider.checkHealth()
            results[type] = healthy
            if var meta = powerMetadata[type] {
                meta.health = healthy ? 1.0 : 0.0
                powerMetadata[type] = meta
            }
        }
        return results
    }

    public var hasAvailableProvider: Bool {
        !providers.isEmpty
    }

    public func unregister(_ type: SUPRAProviderType) {
        providers.removeValue(forKey: type)
        powerMetadata.removeValue(forKey: type)
        if activeProviderType == type {
            activeProviderType = .fallback
        }
    }

    public func providers(for gear: PowerGear) -> [SUPRAProviderType] {
        powerMetadata.filter { $0.value.powerClass == gear }.map(\.key)
    }

    public func updateLoad(_ type: SUPRAProviderType, load: Double) {
        guard var meta = powerMetadata[type] else { return }
        meta.currentLoad = load
        powerMetadata[type] = meta
    }

    public func canAcceptTask(_ type: SUPRAProviderType) -> Bool {
        guard let meta = powerMetadata[type] else { return false }
        return meta.health > 0.5 && meta.currentLoad < Double(meta.maxConcurrency)
    }
}
