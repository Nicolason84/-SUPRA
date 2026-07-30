import Foundation
import Combine

public struct SUPRAModelEntry: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let providerType: SUPRAProviderType
    public let capabilities: [SUPRACapability]
    public let defaultMaxTokens: Int
    public let defaultTemperature: Double
    public let isEnabled: Bool

    public init(id: String, name: String, providerType: SUPRAProviderType,
                capabilities: [SUPRACapability], defaultMaxTokens: Int = 2048,
                defaultTemperature: Double = 0.7, isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.providerType = providerType
        self.capabilities = capabilities
        self.defaultMaxTokens = defaultMaxTokens
        self.defaultTemperature = defaultTemperature
        self.isEnabled = isEnabled
    }
}

@MainActor
public final class SUPRAModelRegistry: ObservableObject {
    public static let shared = SUPRAModelRegistry()

    @Published public private(set) var models: [String: SUPRAModelEntry] = [:]
    @Published public private(set) var isLoaded = false

    private init() {}

    public func register(_ entry: SUPRAModelEntry) {
        models[entry.id] = entry
    }

    public func registerMany(_ entries: [SUPRAModelEntry]) {
        for entry in entries { models[entry.id] = entry }
    }

    public func find(id: String) -> SUPRAModelEntry? { models[id] }

    public func find(name: String) -> SUPRAModelEntry? {
        models.values.first { $0.name == name }
    }

    public func models(for capability: SUPRACapability) -> [SUPRAModelEntry] {
        models.values.filter { $0.capabilities.contains(capability) && $0.isEnabled }
    }

    public func models(for provider: SUPRAProviderType) -> [SUPRAModelEntry] {
        models.values.filter { $0.providerType == provider && $0.isEnabled }
    }

    public func loadDefaults() {
        registerMany([
            SUPRAModelEntry(id: "deepseek-r1", name: "deepseek-r1",
                            providerType: .ollama,
                            capabilities: [.reasoning, .conversation, .analysis],
                            defaultMaxTokens: 4096, defaultTemperature: 0.7),
            SUPRAModelEntry(id: "qwen2.5", name: "qwen2.5",
                            providerType: .ollama,
                            capabilities: [.reasoning, .coding, .conversation],
                            defaultMaxTokens: 4096, defaultTemperature: 0.7),
            SUPRAModelEntry(id: "llama3.2", name: "llama3.2",
                            providerType: .ollama,
                            capabilities: [.conversation, .analysis],
                            defaultMaxTokens: 4096, defaultTemperature: 0.7),
            SUPRAModelEntry(id: "gemma3", name: "gemma3",
                            providerType: .ollama,
                            capabilities: [.reasoning, .conversation],
                            defaultMaxTokens: 4096, defaultTemperature: 0.7),
            SUPRAModelEntry(id: "mistral", name: "mistral",
                            providerType: .ollama,
                            capabilities: [.reasoning, .conversation, .analysis],
                            defaultMaxTokens: 4096, defaultTemperature: 0.7),
            SUPRAModelEntry(id: "gpt-4", name: "gpt-4",
                            providerType: .openAI,
                            capabilities: [.reasoning, .coding, .analysis, .planning],
                            defaultMaxTokens: 8192, defaultTemperature: 0.7),
            SUPRAModelEntry(id: "gpt-4o", name: "gpt-4o",
                            providerType: .openAI,
                            capabilities: [.reasoning, .coding, .vision, .analysis, .planning],
                            defaultMaxTokens: 16384, defaultTemperature: 0.7),
            SUPRAModelEntry(id: "claude-sonnet-4-6", name: "claude-sonnet-4-6",
                            providerType: .anthropic,
                            capabilities: [.reasoning, .coding, .analysis, .conversation],
                            defaultMaxTokens: 8192, defaultTemperature: 0.7),
            SUPRAModelEntry(id: "gemini-2.0-flash", name: "gemini-2.0-flash",
                            providerType: .gemini,
                            capabilities: [.reasoning, .vision, .analysis],
                            defaultMaxTokens: 8192, defaultTemperature: 0.7),
        ])
        isLoaded = true
    }
}
