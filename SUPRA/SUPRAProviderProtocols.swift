import Foundation

public enum SUPRAProviderType: String, Codable, Sendable, CaseIterable {
    case ollama
    case openAI
    case anthropic
    case gemini
    case codex
    case lmStudio
    case openRouter
    case vLLM
    case fallback
}

public enum SUPRACapability: String, Codable, Sendable, CaseIterable {
    case reasoning
    case coding
    case vision
    case search
    case memory
    case planning
    case streaming
    case embeddings
    case conversation
    case analysis
}

public struct SUPRAProviderConfiguration: Codable, Sendable {
    public let type: SUPRAProviderType
    public var baseURL: String
    public var apiKey: String?
    public var isEnabled: Bool
    public var priority: Int
    public var timeoutSeconds: Int

    public init(type: SUPRAProviderType, baseURL: String, apiKey: String? = nil,
                isEnabled: Bool = true, priority: Int = 0, timeoutSeconds: Int = 30) {
        self.type = type
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.isEnabled = isEnabled
        self.priority = priority
        self.timeoutSeconds = timeoutSeconds
    }
}

public struct SUPRAExecutionRequest: Codable, Sendable {
    public let id: UUID
    public let missionID: UUID
    public let prompt: String
    public let systemPrompt: String
    public let requiredCapabilities: [SUPRACapability]
    public let preferredProvider: SUPRAProviderType?
    public let preferredModel: String?
    public let maxTokens: Int
    public let temperature: Double

    public init(id: UUID = UUID(), missionID: UUID, prompt: String, systemPrompt: String = "",
                requiredCapabilities: [SUPRACapability] = [.reasoning],
                preferredProvider: SUPRAProviderType? = nil,
                preferredModel: String? = nil,
                maxTokens: Int = 2048, temperature: Double = 0.7) {
        self.id = id
        self.missionID = missionID
        self.prompt = prompt
        self.systemPrompt = systemPrompt
        self.requiredCapabilities = requiredCapabilities
        self.preferredProvider = preferredProvider
        self.preferredModel = preferredModel
        self.maxTokens = maxTokens
        self.temperature = temperature
    }
}

public struct SUPRAProviderResponse: Codable, Sendable {
    public let requestID: UUID
    public let content: String
    public let model: String
    public let provider: SUPRAProviderType
    public let durationMs: Int
    public let tokensIn: Int
    public let tokensOut: Int
    public let finishedNormally: Bool
    public let error: String?

    public init(requestID: UUID, content: String, model: String, provider: SUPRAProviderType,
                durationMs: Int, tokensIn: Int = 0, tokensOut: Int = 0,
                finishedNormally: Bool = true, error: String? = nil) {
        self.requestID = requestID
        self.content = content
        self.model = model
        self.provider = provider
        self.durationMs = durationMs
        self.tokensIn = tokensIn
        self.tokensOut = tokensOut
        self.finishedNormally = finishedNormally
        self.error = error
    }
}

public struct SUPRAExecutionContext: Codable, Sendable {
    public let missionID: UUID
    public let missionTitle: String
    public let request: SUPRAExecutionRequest
    public let response: SUPRAProviderResponse?
    public let decision: String?
    public let startedAt: Date
    public let completedAt: Date?

    public init(missionID: UUID, missionTitle: String, request: SUPRAExecutionRequest,
                response: SUPRAProviderResponse? = nil, decision: String? = nil,
                startedAt: Date = Date(), completedAt: Date? = nil) {
        self.missionID = missionID
        self.missionTitle = missionTitle
        self.request = request
        self.response = response
        self.decision = decision
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}

public protocol SUPRAProvider: AnyObject {
    var type: SUPRAProviderType { get }
    var configuration: SUPRAProviderConfiguration { get }
    var isAvailable: Bool { get async }
    var supportedCapabilities: [SUPRACapability] { get }

    func execute(request: SUPRAExecutionRequest) async throws -> SUPRAProviderResponse
    func checkHealth() async -> Bool
}

public protocol SUPRAExecutor: AnyObject {
    func execute(context: SUPRAExecutionContext) async throws -> SUPRAExecutionContext
    func canExecute(request: SUPRAExecutionRequest) async -> Bool
}
