import Foundation

@MainActor
final class SUPRAPluginBackedProvider: SUPRAProvider {
    let type: SUPRAProviderType
    let configuration: SUPRAProviderConfiguration

    private let plugin: SUPRAProviderPlugin
    private let defaultModelID: String
    private let capabilities: [SUPRACapability]

    init?(plugin: SUPRAProviderPlugin) {
        guard let type = Self.providerType(for: plugin.declaration.providerID) else {
            return nil
        }

        self.type = type
        self.plugin = plugin
        self.defaultModelID = plugin.models.first?.modelID ?? plugin.declaration.providerID
        self.capabilities = plugin.declaration.capabilities.compactMap(Self.capability(for:))
        self.configuration = SUPRAProviderConfiguration(
            type: type,
            baseURL: plugin.declaration.healthEndpoint?
                .replacingOccurrences(of: "/api/tags", with: "")
                ?? "http://localhost:11434",
            isEnabled: true,
            priority: plugin.declaration.priority,
            timeoutSeconds: 60
        )
    }

    var isAvailable: Bool {
        get async {
            await plugin.healthCheck()
        }
    }

    var supportedCapabilities: [SUPRACapability] {
        capabilities.isEmpty ? [.reasoning] : capabilities
    }

    func execute(request: SUPRAExecutionRequest) async throws -> SUPRAProviderResponse {
        let startedAt = Date()
        let modelID = request.preferredModel ?? defaultModelID
        let content = try await plugin.execute(
            prompt: request.prompt,
            systemPrompt: request.systemPrompt,
            modelID: modelID,
            maxTokens: request.maxTokens,
            temperature: request.temperature
        )
        let durationMs = Int(Date().timeIntervalSince(startedAt) * 1000)

        return SUPRAProviderResponse(
            requestID: request.id,
            content: content,
            model: modelID,
            provider: type,
            durationMs: durationMs,
            tokensIn: request.prompt.count,
            tokensOut: content.count,
            finishedNormally: true,
            error: nil
        )
    }

    func checkHealth() async -> Bool {
        await plugin.healthCheck()
    }

    private static func providerType(for providerID: String) -> SUPRAProviderType? {
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

    private static func capability(for rawValue: String) -> SUPRACapability? {
        switch rawValue.lowercased() {
        case "reasoning": .reasoning
        case "coding": .coding
        case "vision": .vision
        case "search": .search
        case "memory": .memory
        case "planning": .planning
        case "streaming": .streaming
        case "embeddings": .embeddings
        case "conversation": .conversation
        case "analysis": .analysis
        default: nil
        }
    }
}
