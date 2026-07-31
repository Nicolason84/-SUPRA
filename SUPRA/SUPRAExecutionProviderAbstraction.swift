import Foundation
import Combine

// MARK: - IAL Environment Configuration

public struct IALEnvironmentConfig: Codable, Sendable {
    public let providerType: SUPRAProviderType
    public let baseURL: String
    public var apiKey: String?
    public var isEnabled: Bool
    public var priority: Int
    public var timeoutSeconds: Int
    public var maxRetries: Int
    public let capabilities: [SUPRACapability]
    public var model: String?
    public var localExecution: Bool

    public init(providerType: SUPRAProviderType, baseURL: String, apiKey: String? = nil,
                isEnabled: Bool = true, priority: Int = 0, timeoutSeconds: Int = 30,
                maxRetries: Int = 3, capabilities: [SUPRACapability] = [.reasoning],
                model: String? = nil, localExecution: Bool = false) {
        self.providerType = providerType
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.isEnabled = isEnabled
        self.priority = priority
        self.timeoutSeconds = timeoutSeconds
        self.maxRetries = maxRetries
        self.capabilities = capabilities
        self.model = model
        self.localExecution = localExecution
    }
}

// MARK: - IAL Bridge Protocol

public protocol IALBridgeProtocol: AnyObject {
    var activeProvider: SUPRAProviderType { get }
    var isExecuting: Bool { get }
    var lastResponse: SUPRAProviderResponse? { get }
    var registeredProviders: [SUPRAProviderType] { get }

    func registerProvider(_ config: IALEnvironmentConfig) async
    func unregisterProvider(_ type: SUPRAProviderType) async
    func setActiveProvider(_ type: SUPRAProviderType) async throws
    func executeMission(
        title: String,
        prompt: String,
        systemPrompt: String,
        requiredCapabilities: [SUPRACapability],
        preferredProvider: SUPRAProviderType?
    ) async throws -> SUPRAProviderResponse
    func availableProviders() async -> [SUPRAProviderType]
    func healthCheck() async -> [SUPRAProviderType: Bool]
    func canExecute(capabilities: [SUPRACapability]) async -> Bool
}

// MARK: - IAL Bridge Implementation

@MainActor
public final class IALBridge: IALBridgeProtocol, ObservableObject {
    public static let shared = IALBridge()

    @Published public private(set) var activeProvider: SUPRAProviderType = .fallback
    @Published public private(set) var isExecuting = false
    @Published public private(set) var lastResponse: SUPRAProviderResponse?
    @Published public private(set) var registeredProviders: [SUPRAProviderType] = []
    @Published public private(set) var lastError: String?

    private let providerRegistry = SUPRAProviderRegistry.shared
    private let providerBroker = SUPRAProviderBroker.shared
    private let logger = SUPRARuntimeLogger.shared

    private var environmentConfigs: [SUPRAProviderType: IALEnvironmentConfig] = [:]

    private init() {}

    // MARK: - Provider Registration

    public func registerProvider(_ config: IALEnvironmentConfig) async {
        environmentConfigs[config.providerType] = config

        // Delegate registration to the existing plugin discovery system.
        // SUPRAProviderPluginRegistry already registers the Ollama builtin
        // on init; additional providers are expected to register themselves
        // through the PluginDiscovery mechanism.
        let available = await providerRegistry.availableProviders()
        let newlyAvailable = available.filter { provider in
            !registeredProviders.contains(provider.type)
        }

        for provider in newlyAvailable {
            registeredProviders.append(provider.type)
        }

        if activeProvider == .fallback, !registeredProviders.isEmpty {
            activeProvider = registeredProviders[0]
        }

        logger.log(.executor, "IAL: Registered provider \(config.providerType.rawValue)")
    }

    public func unregisterProvider(_ type: SUPRAProviderType) async {
        providerRegistry.unregister(type)
        environmentConfigs.removeValue(forKey: type)
        registeredProviders.removeAll { $0 == type }

        if activeProvider == type {
            activeProvider = .fallback
        }

        logger.log(.executor, "IAL: Unregistered provider \(type.rawValue)")
    }

    public func setActiveProvider(_ type: SUPRAProviderType) async throws {
        guard environmentConfigs[type] != nil else {
            throw IALBridgeError.providerNotRegistered(type)
        }
        providerRegistry.setActive(type)
        activeProvider = type
        logger.log(.executor, "IAL: Active provider set to \(type.rawValue)")
    }

    // MARK: - Mission Execution

    public func executeMission(
        title: String,
        prompt: String,
        systemPrompt: String,
        requiredCapabilities: [SUPRACapability],
        preferredProvider: SUPRAProviderType?
    ) async throws -> SUPRAProviderResponse {
        isExecuting = true
        lastError = nil
        defer { isExecuting = false }

        let providerType = preferredProvider ?? activeProvider

        guard environmentConfigs[providerType] != nil else {
            let available = await self.availableProviders()
            guard let fallback = available.first else {
                throw IALBridgeError.noProviderAvailable
            }
            return try await executeWithProvider(
                type: fallback,
                title: title,
                prompt: prompt,
                systemPrompt: systemPrompt,
                requiredCapabilities: requiredCapabilities
            )
        }

        return try await executeWithProvider(
            type: providerType,
            title: title,
            prompt: prompt,
            systemPrompt: systemPrompt,
            requiredCapabilities: requiredCapabilities
        )
    }

    private func executeWithProvider(
        type: SUPRAProviderType,
        title: String,
        prompt: String,
        systemPrompt: String,
        requiredCapabilities: [SUPRACapability]
    ) async throws -> SUPRAProviderResponse {
        let request = SUPRAExecutionRequest(
            id: UUID(),
            missionID: UUID(),
            prompt: prompt,
            systemPrompt: systemPrompt,
            requiredCapabilities: requiredCapabilities,
            preferredProvider: type,
            preferredModel: environmentConfigs[type]?.model,
            maxTokens: 4096,
            temperature: 0.7
        )

        let response = try await providerBroker.execute(request: request)
        lastResponse = response

        logger.log(.executor, "IAL: Execution completed via \(type.rawValue)")

        return response
    }

    // MARK: - Provider Discovery

    public func availableProviders() async -> [SUPRAProviderType] {
        let available = await providerRegistry.availableProviders()
        return available.compactMap { provider in
            registeredProviders.first { $0 == provider.type }
        }
    }

    public func healthCheck() async -> [SUPRAProviderType: Bool] {
        let results = await providerRegistry.healthCheck()
        return results.filter { registeredProviders.contains($0.key) }
    }

    public func canExecute(capabilities: [SUPRACapability]) async -> Bool {
        let available = await providerRegistry.availableProviders()
        return available.contains { provider in
            provider.supportedCapabilities.contains { capabilities.contains($0) }
        }
    }
}

// MARK: - IAL Bridge Errors

public enum IALBridgeError: LocalizedError {
    case noProviderAvailable
    case providerNotRegistered(SUPRAProviderType)
    case providerUnavailable(SUPRAProviderType)
    case configurationInvalid(SUPRAProviderType)
    case executionFailed(SUPRAProviderType, String)

    public var errorDescription: String? {
        switch self {
        case .noProviderAvailable:
            return "Aucun provider IAL disponible"
        case .providerNotRegistered(let type):
            return "Provider \(type.rawValue) non enregistré dans l'IAL"
        case .providerUnavailable(let type):
            return "Provider \(type.rawValue) indisponible"
        case .configurationInvalid(let type):
            return "Configuration invalide pour \(type.rawValue)"
        case .executionFailed(let type, let detail):
            return "Échec d'exécution \(type.rawValue): \(detail)"
        }
    }
}

// MARK: - IAL Support

public extension IALBridge {
    var activeProviderType: SUPRAProviderType { activeProvider }
    var registeredProviderCount: Int { registeredProviders.count }
    var isReady: Bool { !registeredProviders.isEmpty && !isExecuting }
}