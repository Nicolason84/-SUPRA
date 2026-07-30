import Foundation
import Combine

public enum SUPRAInferenceTaskCategory: String, Codable, Sendable, CaseIterable {
    case repositoryAnalysis
    case codeGeneration
    case architecture
    case documentation
    case summarization
    case reasoning
    case search
    case planning
    case validation
    case tests
    case buildAnalysis
    case knowledgeExtraction
    case conversation
    case memoryUpdate
    case missionGeneration
    case executiveDecision
}

public struct SUPRAInferenceTask: Sendable {
    public let missionID: UUID
    public let missionTitle: String
    public let prompt: String
    public let systemPrompt: String
    public let category: SUPRAInferenceTaskCategory?
    public let requiredCapabilities: [SUPRACapability]
    public let preferredProvider: SUPRAProviderType?
    public let preferredModel: String?
    public let maxTokens: Int
    public let temperature: Double
    public let confidentialityRequired: Bool
    public let offlineRequired: Bool
    public let missionPriority: Int
    public let confidence: Double
    public let evidenceQuality: Double
    public let repositoryHasChanges: Bool

    public init(
        missionID: UUID = UUID(),
        missionTitle: String,
        prompt: String,
        systemPrompt: String = "",
        category: SUPRAInferenceTaskCategory? = nil,
        requiredCapabilities: [SUPRACapability] = [],
        preferredProvider: SUPRAProviderType? = nil,
        preferredModel: String? = nil,
        maxTokens: Int = 2048,
        temperature: Double = 0.7,
        confidentialityRequired: Bool = false,
        offlineRequired: Bool = false,
        missionPriority: Int = 0,
        confidence: Double = 0.75,
        evidenceQuality: Double = 0.75,
        repositoryHasChanges: Bool = true
    ) {
        self.missionID = missionID
        self.missionTitle = missionTitle
        self.prompt = prompt
        self.systemPrompt = systemPrompt
        self.category = category
        self.requiredCapabilities = requiredCapabilities
        self.preferredProvider = preferredProvider
        self.preferredModel = preferredModel
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.confidentialityRequired = confidentialityRequired
        self.offlineRequired = offlineRequired
        self.missionPriority = missionPriority
        self.confidence = confidence
        self.evidenceQuality = evidenceQuality
        self.repositoryHasChanges = repositoryHasChanges
    }
}

public struct SUPRAInferencePolicyDecision: Codable, Sendable {
    public let category: SUPRAInferenceTaskCategory
    public let selectedProvider: SUPRAProviderType?
    public let selectedModel: String?
    public let configuredPriorities: [SUPRAProviderType]
    public let requiredCapabilities: [SUPRACapability]
    public let executionStrategy: String
    public let tokenBudget: Int
    public let estimatedCost: Double
    public let estimatedLatencyMs: Int
    public let qualityTarget: Double
    public let confidence: Double
    public let reasons: [String]
}

public struct SUPRAInferenceExecutionMetric: Codable, Sendable {
    public let missionID: UUID
    public let missionTitle: String
    public let category: SUPRAInferenceTaskCategory
    public let provider: String
    public let model: String
    public let strategy: String
    public let success: Bool
    public let retryCount: Int
    public let latencyMs: Int
    public let estimatedCost: Double
    public let tokensIn: Int
    public let tokensOut: Int
    public let tokenBudget: Int
    public let qualityScore: Double
    public let confidence: Double
    public let missionType: String
    public let repositoryImpact: String
    public let executionTime: Date
    public let memoryUsageMB: Double
    public let gpuUsage: Double
    public let cpuUsage: Double
}

public struct SUPRAProviderRegistryEntry: Codable, Sendable {
    public let providerID: String
    public let providerName: String
    public let isLocal: Bool
    public let priority: Int
    public let capabilities: [String]
    public let models: [String]
}

public struct SUPRAModelRegistryEntrySnapshot: Codable, Sendable {
    public let modelID: String
    public let modelName: String
    public let provider: String
    public let capabilities: [String]
    public let defaultMaxTokens: Int
    public let enabled: Bool
}

public struct SUPRARoutingPolicySnapshot: Codable, Sendable {
    public let localFirst: Bool
    public let lowLatencyPreferred: Bool
    public let lowCostPreferred: Bool
    public let maxRetries: Int
    public let lastCategory: String?
    public let lastProvider: String?
    public let lastModel: String?
    public let lastStrategy: String?
}

@MainActor
public final class InferenceSovereigntyRuntime: ObservableObject {
    public static let shared = InferenceSovereigntyRuntime()

    @Published public private(set) var lastDecision: SUPRAInferencePolicyDecision?
    @Published public private(set) var lastMetric: SUPRAInferenceExecutionMetric?
    @Published public private(set) var lastResponse: SUPRAProviderResponse?
    @Published public private(set) var lastError: String?
    @Published public private(set) var executionHistory: [SUPRAInferenceExecutionMetric] = []

    private let runtimeRegistry = SUPRARuntimeRegistry.shared
    private let providerRegistry = SUPRAProviderRegistry.shared
    private let providerRuntime = ProviderRuntime.shared
    private let routingPolicy = SUPRARoutingPolicy.shared
    private let learningEngine = SUPRALearningEngine.shared
    private let runtimeMetrics = SUPRARuntimeMetrics.shared
    private let logger = SUPRARuntimeLogger.shared

    private init() {}

    public func execute(task: SUPRAInferenceTask) async throws -> SUPRAProviderResponse {
        lastError = nil
        try await ensureRuntimeReady()

        let category = task.category ?? classify(prompt: task.prompt)
        let capabilities = task.requiredCapabilities.isEmpty ? inferredCapabilities(for: category, prompt: task.prompt) : task.requiredCapabilities
        let decision = await buildDecision(for: task, category: category, capabilities: capabilities)
        lastDecision = decision

        let request = SUPRAExecutionRequest(
            missionID: task.missionID,
            prompt: task.prompt,
            systemPrompt: task.systemPrompt,
            requiredCapabilities: decision.requiredCapabilities,
            preferredProvider: decision.selectedProvider,
            preferredModel: decision.selectedModel,
            maxTokens: decision.tokenBudget,
            temperature: clampedTemperature(task.temperature, category: category)
        )

        logger.log(.decision, "Inference sovereignty selected \(decision.selectedProvider?.rawValue ?? "auto")/\(decision.selectedModel ?? "auto") for \(category.rawValue)")

        let startedAt = Date()
        let response = try await providerRuntime.executeWithFallback(
            request: request,
            configuredPriorities: decision.configuredPriorities
        )
        let latencyMs = Int(Date().timeIntervalSince(startedAt) * 1000)

        let success = response.finishedNormally && (response.error?.isEmpty ?? true)
        if !success {
            lastError = response.error ?? "Inference execution failed"
            throw SUPRAProviderError.executionFailed(response.provider, lastError ?? "Inference execution failed")
        }

        let metric = SUPRAInferenceExecutionMetric(
            missionID: task.missionID,
            missionTitle: task.missionTitle,
            category: category,
            provider: response.provider.rawValue,
            model: response.model,
            strategy: decision.executionStrategy,
            success: true,
            retryCount: max(0, providerRuntime.metrics(for: response.provider)["fallbackCount"] as? Int ?? 0),
            latencyMs: latencyMs,
            estimatedCost: decision.estimatedCost,
            tokensIn: response.tokensIn,
            tokensOut: response.tokensOut,
            tokenBudget: decision.tokenBudget,
            qualityScore: qualityScore(for: response, decision: decision, latencyMs: latencyMs),
            confidence: decision.confidence,
            missionType: task.missionTitle,
            repositoryImpact: task.repositoryHasChanges ? "repository_changed" : "repository_stable",
            executionTime: Date(),
            memoryUsageMB: 0,
            gpuUsage: isLocal(response.provider) ? 1 : 0,
            cpuUsage: isLocal(response.provider) ? 1 : 0
        )

        await learningEngine.recordExecution(
            providerID: response.provider.rawValue,
            success: true,
            durationMs: latencyMs,
            tokensUsed: response.tokensIn + response.tokensOut,
            modelID: response.model
        )
        runtimeMetrics.recordExecution(
            providerID: response.provider.rawValue,
            success: true,
            durationMs: latencyMs,
            tokensUsed: response.tokensIn + response.tokensOut
        )
        runtimeMetrics.recordCustom(
            name: "inference.estimated_cost",
            value: decision.estimatedCost,
            unit: "usd",
            tags: ["provider": response.provider.rawValue, "category": category.rawValue]
        )

        lastMetric = metric
        lastResponse = response
        executionHistory.append(metric)
        if executionHistory.count > 500 {
            executionHistory = Array(executionHistory.suffix(250))
        }

        return response
    }

    public func providerRegistrySnapshot() -> [SUPRAProviderRegistryEntry] {
        runtimeRegistry.allProviderPlugins.values
            .sorted { $0.declaration.providerID < $1.declaration.providerID }
            .map { plugin in
                SUPRAProviderRegistryEntry(
                    providerID: plugin.declaration.providerID,
                    providerName: plugin.declaration.providerName,
                    isLocal: plugin.declaration.isLocal,
                    priority: plugin.declaration.priority,
                    capabilities: plugin.declaration.capabilities.sorted(),
                    models: plugin.models.map(\.modelID).sorted()
                )
            }
    }

    public func modelRegistrySnapshot() -> [SUPRAModelRegistryEntrySnapshot] {
        SUPRAModelRegistry.shared.models.values
            .sorted { $0.id < $1.id }
            .map { model in
                SUPRAModelRegistryEntrySnapshot(
                    modelID: model.id,
                    modelName: model.name,
                    provider: model.providerType.rawValue,
                    capabilities: model.capabilities.map(\.rawValue).sorted(),
                    defaultMaxTokens: model.defaultMaxTokens,
                    enabled: model.isEnabled
                )
            }
    }

    public func routingPolicySnapshot() -> SUPRARoutingPolicySnapshot {
        SUPRARoutingPolicySnapshot(
            localFirst: routingPolicy.preferLocal,
            lowLatencyPreferred: routingPolicy.preferLowLatency,
            lowCostPreferred: routingPolicy.preferLowCost,
            maxRetries: routingPolicy.maxRetries,
            lastCategory: lastDecision?.category.rawValue,
            lastProvider: lastDecision?.selectedProvider?.rawValue,
            lastModel: lastDecision?.selectedModel,
            lastStrategy: lastDecision?.executionStrategy
        )
    }

    private func ensureRuntimeReady() async throws {
        _ = await SUPRAPluginDiscovery.shared.discoverAll()
        await runtimeRegistry.initialize()
        runtimeRegistry.refresh()

        for (type, provider) in providerRegistry.providers {
            providerRuntime.register(provider)
            if providerRuntime.providers[type] == nil {
                providerRuntime.register(provider)
            }
        }

        if providerRegistry.providers.isEmpty {
            throw SUPRAProviderError.noProviderAvailable
        }
    }

    private func buildDecision(
        for task: SUPRAInferenceTask,
        category: SUPRAInferenceTaskCategory,
        capabilities: [SUPRACapability]
    ) async -> SUPRAInferencePolicyDecision {
        if let directDecision = directDecision(
            for: task,
            category: category,
            capabilities: capabilities
        ) {
            return directDecision
        }

        let requirements = routingRequirements(for: category, task: task, capabilities: capabilities)
        let selection = await routingPolicy.selectProvider(for: requirements)
        let selectedProvider = selection.flatMap { providerType(for: $0.providerID) } ?? task.preferredProvider
        let priorities = prioritizedProviders(selected: selectedProvider, offlineRequired: task.offlineRequired)
        let tokenBudget = min(task.maxTokens, cappedTokenBudget(for: category, requested: task.maxTokens))
        let strategy = executionStrategy(for: task, category: category, provider: selectedProvider)

        var reasons = selection?.reasons ?? []
        reasons.append("category=\(category.rawValue)")
        reasons.append(strategy)
        if task.confidentialityRequired {
            reasons.append("confidentiality=local_preferred")
        }
        if task.offlineRequired {
            reasons.append("offline=required")
        }

        return SUPRAInferencePolicyDecision(
            category: category,
            selectedProvider: selectedProvider,
            selectedModel: selection?.modelID ?? task.preferredModel,
            configuredPriorities: priorities,
            requiredCapabilities: capabilities,
            executionStrategy: strategy,
            tokenBudget: tokenBudget,
            estimatedCost: selection?.estimatedCost ?? estimatedCost(for: selectedProvider, tokenBudget: tokenBudget),
            estimatedLatencyMs: selection?.estimatedLatencyMs ?? estimatedLatency(for: selectedProvider),
            qualityTarget: qualityTarget(for: category),
            confidence: task.confidence,
            reasons: reasons
        )
    }

    private func directDecision(
        for task: SUPRAInferenceTask,
        category: SUPRAInferenceTaskCategory,
        capabilities: [SUPRACapability]
    ) -> SUPRAInferencePolicyDecision? {
        let availableProviders = providerRegistry.providers.values.filter { provider in
            let supported = Set(provider.supportedCapabilities)
            return capabilities.allSatisfy { supported.contains($0) }
        }

        let selectedProvider: SUPRAProviderType?
        if let preferred = task.preferredProvider,
           availableProviders.contains(where: { $0.type == preferred }) {
            selectedProvider = preferred
        } else if availableProviders.count == 1 {
            selectedProvider = availableProviders.first?.type
        } else {
            selectedProvider = nil
        }

        guard let selectedProvider else { return nil }

        let tokenBudget = min(task.maxTokens, cappedTokenBudget(for: category, requested: task.maxTokens))
        let strategy = executionStrategy(for: task, category: category, provider: selectedProvider)

        return SUPRAInferencePolicyDecision(
            category: category,
            selectedProvider: selectedProvider,
            selectedModel: task.preferredModel ?? defaultModel(for: selectedProvider),
            configuredPriorities: prioritizedProviders(selected: selectedProvider, offlineRequired: task.offlineRequired),
            requiredCapabilities: capabilities,
            executionStrategy: strategy,
            tokenBudget: tokenBudget,
            estimatedCost: estimatedCost(for: selectedProvider, tokenBudget: tokenBudget),
            estimatedLatencyMs: estimatedLatency(for: selectedProvider),
            qualityTarget: qualityTarget(for: category),
            confidence: task.confidence,
            reasons: [
                "provider_registry_direct",
                "category=\(category.rawValue)",
                strategy
            ]
        )
    }

    private func classify(prompt: String) -> SUPRAInferenceTaskCategory {
        let lower = prompt.lowercased()
        if lower.contains("build") || lower.contains("compile") { return .buildAnalysis }
        if lower.contains("test") { return .tests }
        if lower.contains("mission") && lower.contains("executive") { return .executiveDecision }
        if lower.contains("mission") { return .missionGeneration }
        if lower.contains("memory") { return .memoryUpdate }
        if lower.contains("document") || lower.contains("readme") || lower.contains("report") { return .documentation }
        if lower.contains("architect") { return .architecture }
        if lower.contains("search") || lower.contains("find") || lower.contains("lookup") { return .search }
        if lower.contains("summary") || lower.contains("summar") { return .summarization }
        if lower.contains("knowledge") || lower.contains("extract") { return .knowledgeExtraction }
        if lower.contains("plan") || lower.contains("strategy") { return .planning }
        if lower.contains("code") || lower.contains("implement") || lower.contains("swift") { return .codeGeneration }
        if lower.contains("repository") || lower.contains("workspace") { return .repositoryAnalysis }
        if lower.contains("chat") || lower.contains("conversation") { return .conversation }
        if lower.contains("validate") || lower.contains("verify") || lower.contains("audit") { return .validation }
        return .reasoning
    }

    private func inferredCapabilities(for category: SUPRAInferenceTaskCategory, prompt: String) -> [SUPRACapability] {
        switch category {
        case .repositoryAnalysis: return [.analysis, .search, .reasoning]
        case .codeGeneration: return [.coding, .reasoning, .analysis]
        case .architecture: return [.planning, .analysis, .reasoning]
        case .documentation: return [.conversation, .analysis, .reasoning]
        case .summarization: return [.conversation, .analysis]
        case .reasoning: return [.reasoning, .analysis]
        case .search: return [.search, .analysis]
        case .planning: return [.planning, .reasoning]
        case .validation: return [.analysis, .reasoning]
        case .tests: return [.analysis, .reasoning]
        case .buildAnalysis: return [.analysis, .reasoning]
        case .knowledgeExtraction: return [.analysis, .reasoning, .search]
        case .conversation: return [.conversation, .reasoning]
        case .memoryUpdate: return [.memory, .analysis]
        case .missionGeneration: return [.planning, .reasoning, .analysis]
        case .executiveDecision: return [.planning, .reasoning, .analysis]
        }
    }

    private func routingRequirements(
        for category: SUPRAInferenceTaskCategory,
        task: SUPRAInferenceTask,
        capabilities: [SUPRACapability]
    ) -> SUPRARoutingRequirements {
        let required = capabilities.map(\.rawValue)
        switch category {
        case .repositoryAnalysis, .knowledgeExtraction:
            return SUPRARoutingRequirements(requiredCapabilities: required, requiresLocal: true, minContextWindow: 4096, priority: task.missionPriority)
        case .codeGeneration, .architecture, .executiveDecision:
            return SUPRARoutingRequirements(requiredCapabilities: required, requiresHighQuality: true, requiresConfidentiality: task.confidentialityRequired, requiresOffline: task.offlineRequired, minContextWindow: 8192, priority: task.missionPriority)
        case .buildAnalysis, .tests, .validation:
            return SUPRARoutingRequirements(requiredCapabilities: required, requiresLocal: true, requiresLowLatency: true, minContextWindow: 4096, priority: task.missionPriority)
        case .conversation, .documentation, .summarization:
            return SUPRARoutingRequirements(requiredCapabilities: required, requiresLowLatency: true, requiresOffline: task.offlineRequired, minContextWindow: 2048, priority: task.missionPriority)
        case .memoryUpdate:
            return SUPRARoutingRequirements(requiredCapabilities: required, requiresLocal: true, requiresOffline: true, minContextWindow: 2048, priority: task.missionPriority)
        case .planning, .reasoning, .missionGeneration, .search:
            return SUPRARoutingRequirements(requiredCapabilities: required, requiresConfidentiality: task.confidentialityRequired, requiresOffline: task.offlineRequired, minContextWindow: 4096, priority: task.missionPriority)
        }
    }

    private func prioritizedProviders(selected: SUPRAProviderType?, offlineRequired: Bool) -> [SUPRAProviderType] {
        var priorities: [SUPRAProviderType] = []
        if let selected {
            priorities.append(selected)
        }

        let localProviders: [SUPRAProviderType] = [.ollama, .lmStudio, .vLLM, .codex]
        let remoteProviders: [SUPRAProviderType] = [.openAI, .anthropic, .gemini, .openRouter]

        for provider in offlineRequired ? localProviders : (localProviders + remoteProviders) {
            if providerRegistry.providers[provider] != nil && !priorities.contains(provider) {
                priorities.append(provider)
            }
        }

        return priorities.isEmpty ? Array(providerRegistry.providers.keys).sorted { $0.rawValue < $1.rawValue } : priorities
    }

    private func executionStrategy(for task: SUPRAInferenceTask, category: SUPRAInferenceTaskCategory, provider: SUPRAProviderType?) -> String {
        if task.offlineRequired { return "offline_only" }
        if task.confidentialityRequired { return "local_first_confidential" }
        if let provider, isLocal(provider) { return "local_first" }
        switch category {
        case .buildAnalysis, .tests, .validation: return "low_latency_validation"
        case .codeGeneration, .architecture, .executiveDecision: return "quality_first_with_fallback"
        default: return "balanced_local_preferred"
        }
    }

    private func cappedTokenBudget(for category: SUPRAInferenceTaskCategory, requested: Int) -> Int {
        switch category {
        case .buildAnalysis, .tests, .validation: return min(requested, 2048)
        case .repositoryAnalysis, .knowledgeExtraction, .missionGeneration, .executiveDecision: return min(requested, 8192)
        case .codeGeneration, .architecture, .planning: return min(requested, 4096)
        default: return min(requested, 3072)
        }
    }

    private func clampedTemperature(_ requested: Double, category: SUPRAInferenceTaskCategory) -> Double {
        switch category {
        case .buildAnalysis, .tests, .validation, .executiveDecision:
            return min(requested, 0.2)
        case .architecture, .planning, .missionGeneration:
            return min(requested, 0.4)
        default:
            return requested
        }
    }

    private func qualityTarget(for category: SUPRAInferenceTaskCategory) -> Double {
        switch category {
        case .buildAnalysis, .tests, .validation, .executiveDecision: return 0.95
        case .codeGeneration, .architecture, .planning: return 0.9
        default: return 0.8
        }
    }

    private func qualityScore(for response: SUPRAProviderResponse, decision: SUPRAInferencePolicyDecision, latencyMs: Int) -> Double {
        var score = decision.qualityTarget
        if latencyMs > decision.estimatedLatencyMs && decision.estimatedLatencyMs > 0 {
            score -= 0.1
        }
        if response.tokensOut == 0 {
            score -= 0.2
        }
        return max(0, min(1, score))
    }

    private func estimatedCost(for provider: SUPRAProviderType?, tokenBudget: Int) -> Double {
        guard let provider else { return 0 }
        if isLocal(provider) { return 0 }
        return Double(tokenBudget) / 1000.0 * 0.01
    }

    private func estimatedLatency(for provider: SUPRAProviderType?) -> Int {
        guard let provider else { return 5000 }
        return isLocal(provider) ? 800 : 2500
    }

    private func defaultModel(for provider: SUPRAProviderType) -> String {
        SUPRAModelRegistry.shared.models(for: provider)
            .sorted { $0.id < $1.id }
            .first?.id ?? "\(provider.rawValue)-default"
    }

    private func providerType(for providerID: String) -> SUPRAProviderType? {
        switch providerID.lowercased() {
        case "ollama": .ollama
        case "openai": .openAI
        case "anthropic": .anthropic
        case "gemini": .gemini
        case "codex": .codex
        case "lmstudio": .lmStudio
        case "openrouter": .openRouter
        case "vllm": .vLLM
        default: nil
        }
    }

    private func isLocal(_ provider: SUPRAProviderType) -> Bool {
        switch provider {
        case .ollama, .lmStudio, .vLLM, .codex:
            return true
        case .openAI, .anthropic, .gemini, .openRouter, .fallback:
            return false
        }
    }
}
