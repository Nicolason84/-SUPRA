import Foundation
import Combine

// MARK: - ProviderDiscoveryInfo

private struct ProviderDiscoveryInfo: Sendable {
    let type: SUPRAProviderType
    let lastDiscovered: Date
    let isAvailable: Bool
    let discoveryMetadata: [String: Any]
}

// MARK: - ProviderRuntime.swift
// Canonical AI provider runtime for SUPRA Forge Kernel

@MainActor
public final class ProviderRuntime: ObservableObject {
    public static let shared = ProviderRuntime()
    
    // MARK: - Core Properties
    @Published public private(set) var providers: [SUPRAProviderType: SUPRAProvider] = [:]
    @Published public private(set) var activeProviderType: SUPRAProviderType = .fallback
    @Published public private(set) var isInitialized = false
    @Published public private(set) var lastError: String?
    @Published public private(set) var isExecuting = false
    
    // MARK: - Caching Layer
    private var discoveryCache: [SUPRAProviderType: ProviderDiscoveryInfo] = [:]
    private var capabilitiesCache: [SUPRAProviderType: Set<SUPRACapability>] = [:]
    private var healthCache: [SUPRAProviderType: Bool] = [:]
    private var metricsCache: [SUPRAProviderType: [String: Any]] = [:]
    
    // Performance Metrics
    private var initializationTime: TimeInterval = 0
    private var executionCount: Int64 = 0
    private var fallbackCount: Int64 = 0
    private var cacheHitCount: Int64 = 0
    private var errorCount: Int64 = 0
    
    // MARK: - Initialization
    private init() {
        self.initializationTime = CFAbsoluteTimeGetCurrent()
        self.isInitialized = true
    }
    
    // MARK: - Provider Registration
    public func register(_ provider: SUPRAProvider) {
        providers[provider.type] = provider
        clearCache(for: provider.type)
        performHealthCheck(for: provider.type)
    }
    
    public func unregister(_ providerType: SUPRAProviderType) {
        providers.removeValue(forKey: providerType)
        clearCache(for: providerType)
    }
    
    // MARK: - Provider Discovery
    public func discoverProviders() async -> [SUPRAProviderType] {
        var discovered: [SUPRAProviderType] = []
        
        for type in SUPRAProviderType.allCases {
            if type == .fallback { continue }
            
            let isAvailable = await isProviderAvailable(type)
            if isAvailable {
                discovered.append(type)
                discoveryCache[type] = ProviderDiscoveryInfo(
                    type: type,
                    lastDiscovered: Date(),
                    isAvailable: true,
                    discoveryMetadata: [:]
                )
            } else {
                discoveryCache[type] = ProviderDiscoveryInfo(
                    type: type,
                    lastDiscovered: Date(),
                    isAvailable: false,
                    discoveryMetadata: [:]
                )
            }
        }
        
        return discovered
    }
    
    public func isProviderAvailable(_ type: SUPRAProviderType) async -> Bool {
        if let cached = healthCache[type] { return cached }
        
        guard let provider = providers[type] else {
            healthCache[type] = false
            return false
        }
        
        let available = await provider.isAvailable
        healthCache[type] = available
        return available
    }
    
    // MARK: - Provider Selection
    public func selectProvider(
        for request: SUPRAExecutionRequest,
        configuredPriorities: [SUPRAProviderType] = []
    ) async throws -> SUPRAProvider {
        
        let priorities = configuredPriorities.isEmpty ? providerPriorityOrder : configuredPriorities
        executionCount += 1
        
        for providerType in priorities {
            guard let provider = providers[providerType] else { continue }

            let available = await isProviderAvailable(providerType)
            guard available else { continue }

            let canExecute = await canProviderExecute(provider: provider, request: request)
            guard canExecute else { continue }

            activeProviderType = providerType
            lastError = nil
            return provider
        }
        
        let error = SUPRAProviderError.noProviderAvailable
        lastError = error.errorDescription
        throw error
    }
    
    // MARK: - Automatic Fallback
    public func executeWithFallback(
        request: SUPRAExecutionRequest,
        configuredPriorities: [SUPRAProviderType] = []
    ) async throws -> SUPRAProviderResponse {
        
        fallbackCount += 1
        
        do {
            return try await execute(request: request, configuredPriorities: configuredPriorities)
        } catch {
            let error = error as? SUPRAProviderError ?? .allProvidersFailed
            lastError = error.errorDescription
            
            let fallbackResponse = await performFallback(
                for: request,
                configuredPriorities: configuredPriorities
            )
            
            return fallbackResponse
        }
    }
    
    // MARK: - Provider Capabilities
    public func capabilities(for providerType: SUPRAProviderType) -> Set<SUPRACapability> {
        if let cached = capabilitiesCache[providerType] { return cached }
        
        guard let provider = providers[providerType] else { return [] }
        
        let capabilities = Set(provider.supportedCapabilities)
        capabilitiesCache[providerType] = capabilities
        return capabilities
    }
    
    public func canProviderExecute(provider: SUPRAProvider, request: SUPRAExecutionRequest) async -> Bool {
        let required = request.requiredCapabilities
        let provided = Set(provider.supportedCapabilities)
        
        return required.allSatisfy { provided.contains($0) }
    }
    
    // MARK: - Provider Metrics
    public func metrics(for providerType: SUPRAProviderType) -> [String: Any] {
        if let cached = metricsCache[providerType] { return cached }
        
        let metrics: [String: Any] = [
            "availability": availability(for: providerType),
            "executionCount": executionCount,
            "fallbackCount": fallbackCount,
            "cacheHitRatio": Double(cacheHitCount) / max(1, Double(executionCount + fallbackCount)),
            "errorCount": errorCount,
            "lastError": lastError ?? "",
            "initializationTime": initializationTime,
            "lastUsed": discoveryCache[providerType]?.lastDiscovered ?? Date(),
            "isAvailable": isProviderAvailableCached(for: providerType)
        ]
        
        metricsCache[providerType] = metrics
        return metrics
    }
    
    public func availability(for providerType: SUPRAProviderType) -> Double {
        guard providers[providerType] != nil else { return 0.0 }
        
        let health = healthCache[providerType] ?? false
        let isAvailable = isProviderAvailableCached(for: providerType)
        
        return health && isAvailable ? 1.0 : 0.0
    }
    
    // MARK: - Cache Management
    private func clearCache(for providerType: SUPRAProviderType) {
        discoveryCache.removeValue(forKey: providerType)
        capabilitiesCache.removeValue(forKey: providerType)
        healthCache.removeValue(forKey: providerType)
        metricsCache.removeValue(forKey: providerType)
        cacheHitCount += 1
    }
    
    public func clearAllCache() {
        discoveryCache.removeAll()
        capabilitiesCache.removeAll()
        healthCache.removeAll()
        metricsCache.removeAll()
        cacheHitCount = 0
    }
    
    // MARK: - Provider Selection Priority
    private var providerPriorityOrder: [SUPRAProviderType] {
        var order: [SUPRAProviderType] = []
        
        if providers[.ollama] != nil { order.append(.ollama) }
        if providers[.openAI] != nil { order.append(.openAI) }
        if providers[.anthropic] != nil { order.append(.anthropic) }
        if providers[.gemini] != nil { order.append(.gemini) }
        
        return order.isEmpty ? [.fallback] : order
    }
    
    // MARK: - Private Helpers
    private func performHealthCheck(for providerType: SUPRAProviderType) {
        Task.detached { [weak self] in
            guard let self = self else { return }
            let isHealthy = await self.healthCheck(for: providerType)
            if !isHealthy {
                await MainActor.run {
                    self.lastError = "Provider \(providerType.rawValue) is unhealthy"
                }
            }
        }
    }
    
    private func healthCheck(for providerType: SUPRAProviderType) async -> Bool {
        guard let provider = providers[providerType] else { return false }
        return await provider.checkHealth()
    }
    
    private func isProviderAvailableCached(for providerType: SUPRAProviderType) -> Bool {
        healthCache[providerType] ?? false
    }
    
    private func performFallback(
        for request: SUPRAExecutionRequest,
        configuredPriorities: [SUPRAProviderType]
    ) async -> SUPRAProviderResponse {
        
        let fallbackPriorities = configuredPriorities.isEmpty ? providerPriorityOrder : configuredPriorities
        
        for providerType in fallbackPriorities {
            guard providerType != request.preferredProvider else { continue }
            guard let provider = providers[providerType] else { continue }
            
            do {
                let response = try await provider.execute(request: request)
                lastError = nil
                return response
            } catch {
                continue
            }
        }
        
        let errorResponse = SUPRAProviderResponse(
            requestID: request.id,
            content: "All providers failed",
            model: "fallback",
            provider: .fallback,
            durationMs: 0,
            finishedNormally: false,
            error: lastError ?? "All providers failed"
        )
        
        return errorResponse
    }
    
    private func execute(
        request: SUPRAExecutionRequest,
        configuredPriorities: [SUPRAProviderType]
    ) async throws -> SUPRAProviderResponse {
        
        let provider = try await selectProvider(
            for: request,
            configuredPriorities: configuredPriorities
        )
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let response = try await provider.execute(request: request)
        
        let durationMs = Int((CFAbsoluteTimeGetCurrent() - startTime) * 1000)
        
        metricsCache[provider.type]?["lastExecutionDuration"] = durationMs
        
        return response
    }
}