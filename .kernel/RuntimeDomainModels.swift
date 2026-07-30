import Foundation

// MARK: - Runtime Domain Models - Canonical Runtime Abstractions
// These are the core Runtime models required by the Provider Registry

// These models are owned by Runtime and provide unified interfaces for all Providers

// MARK: - Provider Type Definitions

enum ProviderType: String, CaseIterable, Sendable {
    case ollama = "ollama"
    case openai = "openai"
    case anthropic = "anthropic"
    case gemini = "gemini"
    case groq = "groq"
    case together = "together"
    case mistral = "mistral"
    case deepseek = "deepseek"
    case local = "local"
    case cloud = "cloud"
    case hybrid = "hybrid"
}

enum ProviderStatus: String, CaseIterable, Sendable {
    case healthy = "healthy"
    case degraded = "degraded"
    case unhealthy = "unhealthy"
    case offline = "offline"
    case maintenance = "maintenance"
    case unknown = "unknown"
}

// MARK: - Capability Definitions

struct ProviderCapabilities: Sendable {
    let supportsCompletion: Bool
    let supportsChat: Bool
    let supportsCodeGeneration: Bool
    let supportsCodeReview: Bool
    let supportsRefactoring: Bool
    let supportsAnalysis: Bool
    let supportsArchitecture: Bool
    let supportsDocumentation: Bool
    let customCapabilities: [String]
    \n    var allCapabilities: [String] {
        var caps: [String] = []
        if supportsCompletion { caps.append(\"completion\") }
        if supportsChat { caps.append(\"chat\") }
        if supportsCodeGeneration { caps.append(\"code_generation\") }
        if supportsCodeReview { caps.append(\"code_review\") }
        if supportsRefactoring { caps.append(\"refactor\") }
        if supportsAnalysis { caps.append(\"analysis\") }
        if supportsArchitecture { caps.append(\"architecture\") }
        if supportsDocumentation { caps.append(\"documentation\") }
        caps.append(contentsOf: customCapabilities)
        return caps
    }
}\n
// MARK: - Request/Response Models

struct RuntimeRequest: Sendable {\n    let id: UUID\n    let task: CapabilityTask\n    let context: RuntimeContext\n    let parameters: [String: Any]\n    let timestamp: Date\n    let authentication: AuthenticationConfig\n    let options: RequestOptions\n\n    struct RequestOptions: Sendable {\n        let temperature: Double\n        let maxTokens: Int\n        let topP: Double\n        let topK: Int\n        let stopSequences: [String]\n        let presencePenalty: Double\n        let frequencyPenalty: Double\n        let seed: Int?\n        let stream: Bool\n    }\n}\n
struct ProviderResponse: Sendable {\n    let id: String\n    let content: String\n    let metadata: ResponseMetadata\n    let finishReason: FinishReason\n    let usage: TokenUsage\n    let timing: ResponseTiming\n    let modelInfo: ModelInfo\n\n    struct ResponseMetadata: Sendable {\n        let model: String\n        let created: Date\n        let serviceTier: String?\n        let object: String\n        let systemFingerprint: String?\n    }\n
    struct TokenUsage: Sendable {\n        let promptTokens: Int\n        let completionTokens: Int\n        let totalTokens: Int\n        let promptTokenDetails: TokenDetails\n        let completionTokenDetails: TokenDetails\n    }\n
    struct TokenDetails: Sendable {\n        let textTokens: Int\n        let imageTokens: Int\n        let audioTokens: Int\n    }\n
    struct ResponseTiming: Sendable {\n        let creationTimeMs: Int\n        let firstByteTimeMs: Int\n        let completeTimeMs: Int\n    }\n
    struct ModelInfo: Sendable {\n        let id: String\n        let name: String\n        let version: String\n        let provider: String\n        let capabilities: [String]\n        let maxContextLength: Int\n    }\n}

// MARK: - Context Models

struct CapabilityTask: Sendable {\n    let type: TaskType\n    let taskType: TaskType { get { return type } }\n    let description: String\n    let parameters: [String: Any]\n    let expectedOutput: TaskOutputType\n    let contextLength: Int\n    let complexity: TaskComplexity\n    let urgency: UrgencyLevel\n}\n
struct TaskOutputType: String, CaseIterable, Sendable {\n    case text = \"text\"\n    case code = \"code\"\n    case explanation = \"explanation\"\n    case summary = \"summary\"\n    case report = \"report\"\n}\n
struct TaskType: String, CaseIterable, Sendable {\n    case completion = \"completion\"\n    case chat = \"chat\"\n    case codeGeneration = \"code_generation\"\n    case codeReview = \"code_review\"\n    case refactor = \"refactor\"\n    case analysis = \"analysis\"\n    case architecture = \"architecture\"\n    case documentation = \"documentation\"\n}\n
struct UrgencyLevel: String, CaseIterable, Sendable {\n    case low = \"low\"\n    case medium = \"medium\"\n    case high = \"high\"\n    case critical = \"critical\"\n}\n
struct TaskComplexity: String, CaseIterable, Sendable {\n    case simple = \"simple\"\n    case medium = \"medium\"\n    case complex = \"complex\"\n    case sophisticated = \"sophisticated\"\n}\n
struct RuntimeContext: Sendable {\n    let runtimeId: String\n    let executionId: UUID\n    let userId: String\n    let sessionId: String\n    let missionId: String\n    let executiveDecision: ExecutiveDecision\n    let proofRequirement: ProofRequirement\n    let startTime: Date\n    let timeout: TimeInterval\n}\n
struct ProofRequirement: Sendable {\n    let required: Bool\n    let type: ProofType\n    let source: ProofSource\n    let validation: ValidationCriteria\n\n    enum ProofType: String, CaseIterable, Sendable {\n        case evidence\n        case certification\n        case audit\n        case verification\n    }\n
    enum ProofSource: String, CaseIterable, Sendable {\n        case direct\n        case chain\n        case delegate\n        case inherited\n    }\n}\n
struct ValidationCriteria: Sendable {\n    let validator: String\n    let confidence: Double\n    let thresholds: [String: Double]\n    let rules: [ValidationRule]\n}\n
struct ValidationRule: Sendable {\n    let ruleId: String\n    let description: String\n    let criteria: [String: Any]\n    let weight: Double\n    let required: Bool\n}\n\n// MARK: - Model Definitions\n\nstruct ModelInfo: Sendable {\n    let id: String\n    let name: String\n    let version: String\n    let provider: String\n    let capabilities: [String]\n    let maxContextLength: Int\n}

// MARK: - Authentication Models

struct AuthenticationConfig: Sendable {\n    let type: AuthType\n    let apiKey: String\n    let organizationId: String?\n    let projectId: String?\n    let baseURL: URL?\n\n    enum AuthType: String, CaseIterable, Sendable {\n        case bearer\n        case apiKey\n        case oauth2\n        case none\n        case custom\n    }\n}\n
struct ValidationResult: Sendable {\n    let valid: Bool\n    let errors: [String]\n    let warnings: [String]\n    let confidence: Double\n    let validator: String\n    let timestamp: Date\n}\n
struct ResponseMetadata: Sendable {\n    let model: String\n    let created: Date\n    let serviceTier: String?\n    let object: String\n    let systemFingerprint: String?\n}

struct TokenUsage: Sendable {\n    let promptTokens: Int\n    let completionTokens: Int\n    let totalTokens: Int\n    let promptTokenDetails: TokenDetails\n    let completionTokenDetails: TokenDetails\n}\n
struct TokenDetails: Sendable {\n    let textTokens: Int\n    let imageTokens: Int\n    let audioTokens: Int\n}\n
struct ResponseTiming: Sendable {\n    let creationTimeMs: Int\n    let firstByteTimeMs: Int\n    let completeTimeMs: Int\n}\n\n// MARK: - Executive Models\n\nstruct ExecutiveDecision: Sendable {\n    let decisionId: UUID\n    let executive: String\n    let decisionType: ExecutiveDecisionType\n    let validity: TimeInterval\n    let conditions: [String]\n    let escalationPath: [String]\n    let evidenceRequirement: EvidenceRequirement\n}\n\nstruct EvidenceRequirement: Sendable {\n    let required: Bool\n    let type: ProofType\n    let source: ProofSource\n    let validation: ValidationCriteria\n}\n\nenum ExecutiveDecisionType: String, CaseIterable, Sendable {\n    case approval\n    case rejection\n    case modification\n    case delegation\n    case escalation\n}\n
// MARK: - Error Models

enum RuntimeError: Error, Sendable {\n    case providerNotFound(String)\n    case taskNotCompliant(String)\n    case taskExecutionNotPossible(String)\n    case providerNotCompliant(String)\n    case noAvailableProviders\n    case executionFailed(String)\n    case healthCheckFailed(String)\n    case configurationError(String)\n    case validationError(String)\n    case fallbackError(String)\n\n    var localizedDescription: String {\n        switch self {\n        case .providerNotFound(let id): return \"Provider not found: \\(id)\"\n        case .taskNotCompliant(let msg): return \"Task not compliant: \\(msg)\"\n        case .taskExecutionNotPossible(let msg): return \"Task execution not possible: \\(msg)\"\n        case .providerNotCompliant(let msg): return \"Provider not compliant: \\(msg)\"\n        case .noAvailableProviders: return \"No available providers for the task\"\n        case .executionFailed(let msg): return \"Execution failed: \\(msg)\"\n        case .healthCheckFailed(let msg): return \"Health check failed: \\(msg)\"\n        case .configurationError(let msg): return \"Configuration error: \\(msg)\"\n        case .validationError(let msg): return \"Validation error: \\(msg)\"\n        case .fallbackError(let msg): return \"Fallback error: \\(msg)\"\n        }\n    }\n}\n
// MARK: - Health Models
\n\nstruct ProviderHealth: Sendable {\n    let status: ProviderStatus\n    let responseTime: TimeInterval\n    let throughput: Int\n    let errorRate: Double\n    let lastCheck: Date\n    let healthCheckCount: Int\n}\n\nstruct ProviderHealthStatus: Sendable {\n    let providers: [String: Bool]\n    let timestamp: Date\n    let overallHealth: ProviderStatus\n    let unhealthyProviders: [String]\n    let recoveryActionsRequired: Int\n}\n
// MARK: - Metrics Models
\nstruct ProviderMetrics: Sendable {\n    let providerId: String\n    let latency: TimeInterval\n    let throughput: Int\n    let errorRate: Double\n    let qualityScore: Double\n    let costEfficiency: Double\n    let userSatisfaction: Double\n\n    let timestamp: Date\n    let executionCount: Int\n    let successfulExecutions: Int\n    let failedExecutions: Int\n    let averageResponseTime: TimeInterval\n    let p95ResponseTime: TimeInterval\n    let currentLoad: Double\n}\n\nstruct ExecutionCost: Sendable {\n    let inputCost: Double\n    let outputCost: Double\n    let currency: String\n    let exchangeRate: Double\n    let totalCost: Double\n    let costBreakdown: [String: Double]\n}

// MARK: - Supporting Types
\n\nstruct ProviderCapabilities: Sendable {\n    let supportsCompletion: Bool\n    let supportsChat: Bool\n    let supportsCodeGeneration: Bool\n    let supportsCodeReview: Bool\n    let supportsRefactoring: Bool\n    let supportsAnalysis: Bool\n    let supportsArchitecture: Bool\n    let supportsDocumentation: Bool\n    let customCapabilities: [String]\n\n    var allCapabilities: [String] {\n        var caps: [String] = []\n        if supportsCompletion { caps.append(\"completion\") }\n        if supportsChat { caps.append(\"chat\") }\n        if supportsCodeGeneration { caps.append(\"code_generation\") }\n        if supportsCodeReview { caps.append(\"code_review\") }\n        if supportsRefactoring { caps.append(\"refactor\") }\n        if supportsAnalysis { caps.append(\"analysis\") }\n        if supportsArchitecture { caps.append(\"architecture\") }\n        if supportsDocumentation { caps.append(\"documentation\") }\n        caps.append(contentsOf: customCapabilities)\n        return caps\n    }\n}\n\nstruct CostConfig: Sendable {\n    let inputPrice: Double\n    let outputPrice: Double\n    let currency: String\n    let exchangeRate: Double\n    let pricingModel: PricingModel\n\n    enum PricingModel: String, CaseIterable, Sendable {\n        case perInputToken\n        case perOutputToken\n        case perRequest\n        case subscription\n        case free\n    }\n}\n\nstruct RegistryConfiguration: Sendable {\n    let maxProviders: Int\n    let maxFailures: Int\n    let healthCheckInterval: TimeInterval\n    let maxContextWindow: Int\n    let maxRetries: Int\n    let executiveTimeout: TimeInterval\n    let autoRecovery: Bool\n    let optimizeOnFailure: Bool\n    let logLevel: LogLevel\n    let cacheSize: Int\n    let maxExecutionHistory: Int\n    let enableMetricsCollection: Bool\n    let defaultFallbackStrategy: FallbackStrategy\n    let maxFallbackProhibits: Int\n    let enableHealthBasedFallback: Bool\n\n    init() {\n        self.maxProviders = 50\n        self.maxFailures = 3\n        self.healthCheckInterval = 30.0\n        self.maxContextWindow = 32768\n        self.maxRetries = 3\n        self.executiveTimeout = 300.0\n        self.autoRecovery = true\n        self.optimizeOnFailure = true\n        self.logLevel = .info\n        self.cacheSize = 1000\n        self.maxExecutionHistory = 1000\n        self.enableMetricsCollection = true\n        self.defaultFallbackStrategy = .automatic\n        self.maxFallbackProhibits = 5\n        self.enableHealthBasedFallback = true\n    }\n
    static let `default` = RegistryConfiguration()\n}\n\nenum LogLevel: String, CaseIterable, Sendable {\n    case debug\n    case info\n    case warning\n    case error\n    case critical\n}\n\nstruct RequestOptions: Sendable {\n    let temperature: Double\n    let maxTokens: Int\n    let topP: Double\n    let topK: Int\n    let stopSequences: [String]\n    let presencePenalty: Double\n    let frequencyPenalty: Double\n    let seed: Int?\n    let stream: Bool\n}\n\nstruct ValidationRule: Sendable {\n    let ruleId: String\n    let description: String\n    let criteria: [String: Any]\n    let weight: Double\n    let required: Bool\n}\n\nstruct Adjustment: Sendable {\n    let traceId: String\n    let change: String\n    let reason: String\n    let tick: Int64\n}\n\nstruct FeedbackLoop: Sendable {\n    let enabled: Bool\n    let iterations: Int\n    let lastAdjustment: String?\n    let adjustments: [Adjustment]\n}\n\nstruct TaskOutput: Sendable {\n    let type: TaskOutputType\n    let content: String\n    let metadata: [String: Any]\n}\n
// MARK: - Configuration Models\n\nstruct ProviderConfig: Sendable {\n    let id: String\n    let name: String\n    let version: String\n    let type: ProviderType\n\n    let endpoint: URL\n    let authentication: AuthenticationConfig\n    let timeout: TimeInterval\n    let maxRetries: Int\n\n    let capabilities: [String]\n    let contextWindow: Int\n    let maxOutputTokens: Int\n    let costConfiguration: CostConfig\n\n    let qualityScore: Double\n    let latency: TimeInterval\n    let reliability: Double\n\n    let executivePriority: Int\n    let backupProviders: [String]\n    let fallbackStrategy: FallbackStrategy\n\n    var status: ProviderStatus\n    var health: ProviderHealth\n    var consecutiveFailures: Int\n    var totalExecutions: Int\n    var lastSuccessfulExecution: Date\n}\n\nstruct RateLimitConfig: Sendable {\n    let requestsPerMinute: Int\n    let requestsPerHour: Int\n    let requestsPerDay: Int\n    let tokensPerMinute: Int\n    let tokensPerHour: Int\n    let tokensPerDay: Int\n    let burstLimit: Int\n    let spreadInterval: TimeInterval\n}

// MARK: - Domain Types
\n\nstruct ProviderHealth: Sendable {\n    let status: ProviderStatus\n    let responseTime: TimeInterval\n    let throughput: Int\n    let errorRate: Double\n    let lastCheck: Date\n    let healthCheckCount: Int\n}

struct ValidationCriteria: Sendable {\n    let validator: String\n    let confidence: Double\n    let thresholds: [String: Double]\n    let rules: [ValidationRule]\n}

struct TokenUsage: Sendable {\n    let promptTokens: Int\n    let completionTokens: Int\n    let totalTokens: Int\n    let promptTokenDetails: TokenDetails\n    let completionTokenDetails: TokenDetails\n}\n\nstruct TokenDetails: Sendable {\n    let textTokens: Int\n    let imageTokens: Int\n    let audioTokens: Int\n}\n\nstruct ResponseTiming: Sendable {\n    let creationTimeMs: Int\n    let firstByteTimeMs: Int\n    let completeTimeMs: Int\n}