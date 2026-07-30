import Foundation
import Combine

public struct SUPRAProviderPluginDeclaration: Sendable {
    public let pluginID: String
    public let providerID: String
    public let providerName: String
    public let providerVersion: String
    public let capabilities: [String]
    public let supportsVision: Bool
    public let supportsTools: Bool
    public let supportsStreaming: Bool
    public let supportsJSON: Bool
    public let supportsEmbeddings: Bool
    public let contextWindow: Int
    public let maxTokens: Int
    public let isLocal: Bool
    public let costPer1KTokens: Double
    public let priority: Int
    public let healthEndpoint: String?

    public init(pluginID: String, providerID: String, providerName: String,
                providerVersion: String, capabilities: [String],
                supportsVision: Bool = false, supportsTools: Bool = false,
                supportsStreaming: Bool = false, supportsJSON: Bool = false,
                supportsEmbeddings: Bool = false, contextWindow: Int = 4096,
                maxTokens: Int = 2048, isLocal: Bool = true,
                costPer1KTokens: Double = 0.0, priority: Int = 0,
                healthEndpoint: String? = nil) {
        self.pluginID = pluginID
        self.providerID = providerID
        self.providerName = providerName
        self.providerVersion = providerVersion
        self.capabilities = capabilities
        self.supportsVision = supportsVision
        self.supportsTools = supportsTools
        self.supportsStreaming = supportsStreaming
        self.supportsJSON = supportsJSON
        self.supportsEmbeddings = supportsEmbeddings
        self.contextWindow = contextWindow
        self.maxTokens = maxTokens
        self.isLocal = isLocal
        self.costPer1KTokens = costPer1KTokens
        self.priority = priority
        self.healthEndpoint = healthEndpoint
    }
}

public struct SUPRAProviderModelDeclaration: Sendable {
    public let modelID: String
    public let modelName: String
    public let providerID: String
    public let capabilities: [String]
    public let contextWindow: Int
    public let maxTokens: Int
    public let supportsVision: Bool
    public let supportsTools: Bool
    public let supportsJSON: Bool
    public let supportsStreaming: Bool
    public let supportsEmbeddings: Bool
    public let isLocal: Bool
    public let speed: Int
    public let costPer1KTokens: Double

    public init(modelID: String, modelName: String, providerID: String,
                capabilities: [String], contextWindow: Int = 4096,
                maxTokens: Int = 2048, supportsVision: Bool = false,
                supportsTools: Bool = false, supportsJSON: Bool = false,
                supportsStreaming: Bool = false, supportsEmbeddings: Bool = false,
                isLocal: Bool = true, speed: Int = 50, costPer1KTokens: Double = 0.0) {
        self.modelID = modelID
        self.modelName = modelName
        self.providerID = providerID
        self.capabilities = capabilities
        self.contextWindow = contextWindow
        self.maxTokens = maxTokens
        self.supportsVision = supportsVision
        self.supportsTools = supportsTools
        self.supportsJSON = supportsJSON
        self.supportsStreaming = supportsStreaming
        self.supportsEmbeddings = supportsEmbeddings
        self.isLocal = isLocal
        self.speed = speed
        self.costPer1KTokens = costPer1KTokens
    }
}

@MainActor
public protocol SUPRAProviderPlugin: SUPRAPlugin {
    var declaration: SUPRAProviderPluginDeclaration { get }
    var models: [SUPRAProviderModelDeclaration] { get }
    func execute(prompt: String, systemPrompt: String, modelID: String,
                 maxTokens: Int, temperature: Double) async throws -> String
}

@MainActor
public final class SUPRAProviderPluginRegistry: ObservableObject {
    public static let shared = SUPRAProviderPluginRegistry()

    @Published public private(set) var providerPlugins: [String: SUPRAProviderPlugin] = [:]
    @Published public private(set) var declarations: [SUPRAProviderPluginDeclaration] = []

    private init() {
        let builtin = SUPRAOllamaProvider()
        providerPlugins[builtin.pluginID] = builtin
        declarations = [builtin.declaration]
    }

    public func register(_ plugin: SUPRAProviderPlugin) {
        providerPlugins[plugin.pluginID] = plugin
        declarations.removeAll { $0.pluginID == plugin.pluginID }
        declarations.append(plugin.declaration)
    }

    public func unregister(_ id: String) {
        providerPlugins.removeValue(forKey: id)
        declarations.removeAll { $0.pluginID == id }
    }

    public func plugin(_ id: String) -> SUPRAProviderPlugin? { providerPlugins[id] }

    public func plugins(capability: String) -> [SUPRAProviderPlugin] {
        providerPlugins.values.filter { $0.declaration.capabilities.contains(capability) }
    }

    public func plugins(local: Bool) -> [SUPRAProviderPlugin] {
        providerPlugins.values.filter { $0.declaration.isLocal == local }
    }

    public func clear() {
        providerPlugins.removeAll()
        declarations.removeAll()
    }
}

@MainActor
public final class SUPRAPluginDiscovery: ObservableObject {
    public static let shared = SUPRAPluginDiscovery()

    @Published public private(set) var isDiscovering = false
    @Published public private(set) var discoveredCount = 0

    private let pluginRegistry = SUPRAPluginRegistry.shared
    private let providerPluginRegistry = SUPRAProviderPluginRegistry.shared

    private init() {}

    public enum DiscoverySource: String, Sendable {
        case builtin
        case bundle
        case network
        case configuration
    }

    public struct DiscoveryResult: Sendable {
        public let source: DiscoverySource
        public let pluginID: String
        public let success: Bool
        public let message: String
    }

    public func discoverAll() async -> [DiscoveryResult] {
        isDiscovering = true
        discoveredCount = 0
        defer { isDiscovering = false }

        var results: [DiscoveryResult] = []

        let builtinResults = await discoverBuiltin()
        results.append(contentsOf: builtinResults)

        return results
    }

    private func discoverBuiltin() async -> [DiscoveryResult] {
        var results: [DiscoveryResult] = []

        let ollamaPlugin = SUPRAOllamaProvider()
        let pluginID = ollamaPlugin.pluginID
        providerPluginRegistry.register(ollamaPlugin)
        pluginRegistry.register(ollamaPlugin)
        discoveredCount += 1
        results.append(DiscoveryResult(
            source: .builtin,
            pluginID: pluginID,
            success: true,
            message: "Ollama provider plugin registered (localhost:11434)"
        ))

        return results
    }
}
