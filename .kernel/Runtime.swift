// MARK: - Runtime Domain Models - Core SUPRA Runtime Infrastructure

import Foundation
import Foundation

// MARK: - Runtime Foundation Types

// These are the core types referenced throughout the Runtime - defined once in the Registry

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

enum FallbackStrategy: String, CaseIterable, Sendable {
    case automatic = "automatic"
    case manual = "manual"
    case degrade = "degrade"
    case circuitBreaker = "circuitBreaker"
}

enum TaskType: String, CaseIterable, Sendable {
    case completion = "completion"
    case chat = "chat"
    case codeGeneration = "code_generation"
    case codeReview = "code_review"
    case refactor = "refactor"
    case analysis = "analysis"
    case architecture = "architecture"
    case documentation = "documentation"
}

enum TaskOutputType: String, CaseIterable, Sendable {
    case text = "text"
    case code = "code"
    case explanation = "explanation"
    case summary = "summary"
    case report = "report"
}

enum UrgencyLevel: String, CaseIterable, Sendable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

enum TaskComplexity: String, CaseIterable, Sendable {
    case simple = "simple"
    case medium = "medium"
    case complex = "complex"
    case sophisticated = "sophisticated"
}

enum ExecutiveDecisionType: String, CaseIterable, Sendable {
    case approval = "approval"
    case rejection = "rejection"
    case modification = "modification"
    case delegation = "delegation"
    case escalation = "escalation"
}

enum EvidenceRequirement: String, CaseIterable, Sendable {
    case standard = "standard"
    case enhanced = "enhanced"
    case proofRequired = "proof_required"
    case certification = "certification"
}

enum FinishReason: String, CaseIterable, Sendable {
    case stop = "stop"
    case length = "length"
    case content_filter = "content_filter"
    case function_call = "function_call"
}

enum PricingModel: String, CaseIterable, Sendable {
    case perInputToken
    case perOutputToken
    case perRequest
    case subscription
    case free
}

enum ProofType: String, CaseIterable, Sendable {
    case evidence
    case certification
    case audit
    case verification
}

enum ProofSource: String, CaseIterable, Sendable {
    case direct
    case chain
    case delegate
    case inherited
}

enum LogLevel: String, CaseIterable, Sendable {
    case debug
    case info
    case warning
    case error
    case critical
}

enum AuthType: String, CaseIterable, Sendable {
    case bearer
    case apiKey
    case oauth2
    case none
    case custom
}

// MARK: - Configuration Models

struct AuthenticationConfig: Sendable {
    let type: AuthType
    let apiKey: String
    let organizationId: String?
    let projectId: String?
    let baseURL: URL?
    
    enum AuthType: String, CaseIterable, Sendable {
        case bearer
        case apiKey
        case oauth2
        case none
        case custom
    }
}

struct CostConfig: Sendable {
    let inputPrice: Double
    let outputPrice: Double
    let currency: String
    let exchangeRate: Double
    let pricingModel: PricingModel
}

struct RateLimitConfig: Sendable {
    let requestsPerMinute: Int
    let requestsPerHour: Int
    let requestsPerDay: Int
    let tokensPerMinute: Int
    let tokensPerHour: Int
    let tokensPerDay: Int
    let burstLimit: Int
    let spreadInterval: TimeInterval
}

struct RegistryConfiguration: Sendable {
    let maxProviders: Int
    let maxFailures: Int
    let healthCheckInterval: TimeInterval
    let maxContextWindow: Int
    let maxRetries: Int
    let executiveTimeout: TimeInterval
    let autoRecovery: Bool
    let optimizeOnFailure: Bool
    let logLevel: LogLevel
    let cacheSize: Int
    let maxExecutionHistory: Int
    let enableMetricsCollection: Bool
    let defaultFallbackStrategy: FallbackStrategy
    let maxFallbackProhibits: Int
    let enableHealthBasedFallback: Bool
    
    init() {
        self.maxProviders = 50
        self.maxFailures = 3
        self.healthCheckInterval = 30.0
        self.maxContextWindow = 32768
        self.maxRetries = 3
        self.executiveTimeout = 300.0
        self.autoRecovery = true
        self.optimizeOnFailure = true
        self.logLevel = .info
        self.cacheSize = 1000
        self.maxExecutionHistory = 1000
        self.enableMetricsCollection = true
        self.defaultFallbackStrategy = .automatic
        self.maxFallbackProhibits = 5
        self.enableHealthBasedFallback = true
    }
    
    static let `default` = RegistryConfiguration()
}

// MARK: - Provider Protocol Definitions

protocol ProviderContract: Sendable {
    var id: String { get }
    var name: String { get }
    var version: String { get }
    var type: ProviderType { get }
    
    var capabilities: [String] { get }
    var contextWindow: Int { get }
    var costPerInput: Double { get }
    var costPerOutput: Double { get }
    
    var endpoint: URL { get }
    var authentication: AuthenticationConfig { get }
    var timeout: TimeInterval { get }
    
    var status: ProviderStatus { get }
    var lastHealthCheck: Date { get }
    var consecutiveFailures: Int { get }
    
    func executeRequest(_ request: ProviderRequest) async throws -> ProviderResponse
    func healthCheck() async throws -> Bool
    func optimizeForTask(_ task: CapabilityTask) -> Double
}

class DefaultProviderContract: ProviderContract {
    let id: String
    let name: String
    let version: String
    let type: ProviderType
    
    let capabilities: [String]
    let contextWindow: Int
    let costPerInput: Double
    let costPerOutput: Double
    
    let endpoint: URL
    let authentication: AuthenticationConfig
    let timeout: TimeInterval
    
    var status: ProviderStatus
    var lastHealthCheck: Date
    var consecutiveFailures: Int
    
    init(
        id: String,
        name: String,
        version: String,
        type: ProviderType,
        capabilities: [String],
        contextWindow: Int,
        costPerInput: Double,
        costPerOutput: Double,
        endpoint: URL,
        authentication: AuthenticationConfig,
        timeout: TimeInterval
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.type = type
        self.capabilities = capabilities
        self.contextWindow = contextWindow
        self.costPerInput = costPerInput
        self.costPerOutput = costPerOutput
        self.endpoint = endpoint
        self.authentication = authentication
        self.timeout = timeout
        self.status = .unknown
        self.lastHealthCheck = Date()
        self.consecutiveFailures = 0
    }
    
    func executeRequest(_ request: ProviderRequest) async throws -> ProviderResponse {
        throw RuntimeError.configurationError("Provider execution not implemented")
    }
    
    func healthCheck() async throws -> Bool {
        return status == .healthy
    }
    
    func optimizeForTask(_ task: CapabilityTask) -> Double {
        var score = 0.0
        
        if capabilities.contains(task.taskType.rawValue) {
            score += 0.4
        }
        
        if contextWindow >= task.contextLength {
            score += 0.3
        }
        
        let capabilityScore = Double(capabilities.filter { $0 == task.taskType.rawValue }.count) / Double(capabilities.count)
        score += capabilityScore * 0.3
        
        return score
    }
}

protocol ProviderRegistry: AnyObject {
    func registerProvider(_ provider: any ProviderContract) async throws
    func selectProvider(for task: CapabilityTask) async throws -> any ProviderContract
    func executeTask(_ task: CapabilityTask, using provider: any ProviderContract) async throws -> ExecutionResult
    func healthCheck() async throws -> ProviderHealthStatus
    func optimizeProviderSelection() async throws
    
    func getExecutiveReport() async throws -> ExecutiveRegistryReport
    func getProviderMetrics() async throws -> ProviderMetrics
    func getExecutionHistory() async throws -> [ExecutionRecord]
    
    func start() async throws
    func stop() async throws
    func reset() async throws
}

class DefaultProviderRegistry: ProviderRegistry {
    private let configuration: RegistryConfiguration
    private let providerFactory: ProviderFactory
    private let executionEngine: ExecutionEngine
    private let healthMonitor: HealthMonitor
    private let loadBalancer: LoadBalancer
    private let costOptimizer: CostOptimizer
    
    private var providers: [String: ProviderContract] = [:]
    private var executiveDecisions: [UUID: ExecutiveDecision] = [:]
    private var executionHistory: [UUID: ExecutionRecord] = [:]
    private var metrics: RegistryMetrics
    
    init(
        configuration: RegistryConfiguration = .default,
        providerFactory: ProviderFactory = DefaultProviderFactory(),
        executionEngine: ExecutionEngine = DefaultExecutionEngine(),
        healthMonitor: HealthMonitor = DefaultHealthMonitor(),
        loadBalancer: LoadBalancer = DefaultLoadBalancer(),
        costOptimizer: CostOptimizer = DefaultCostOptimizer()
    ) {
        self.configuration = configuration
        self.providerFactory = providerFactory
        self.executionEngine = executionEngine
        self.healthMonitor = healthMonitor
        self.loadBalancer = loadBalancer
        self.costOptimizer = costOptimizer
        
        self.metrics = RegistryMetrics()
        setupInternalComponents()
    }
    
    func registerProvider(_ provider: any ProviderContract) async throws {
        guard isProviderCompliant(provider: provider) else {
            throw RuntimeError.providerNotCompliant("Provider not compliant")
        }
        
        providers[provider.id] = provider
        await healthMonitor.startMonitoring(for: provider)
        await notifyExecutive(event: .providerRegistered, details: ["provider": provider.id])
    }
    
    func selectProvider(for task: CapabilityTask) async throws -> any ProviderContract {
        guard isTaskCompliant(task: task) else {
            throw RuntimeError.taskNotCompliant("Task not compliant")
        }
        
        let decision = try await getExecutiveDecision(for: task)
        let selectedProvider = try await executionEngine.selectProvider(for: task, using: self)
        
        metrics.recordProviderSelection(task: task, provider: selectedProvider.id, strategy: .executiveDecision)
        
        return selectedProvider
    }
    
    func executeTask(_ task: CapabilityTask, using provider: any ProviderContract) async throws -> ExecutionResult {
        guard canExecuteTask(task: task, provider: provider) else {
            throw RuntimeError.taskExecutionNotPossible("Cannot execute task with provider")
        }
        
        let decision = try await getExecutiveDecision(for: task)
        let result = try await executionEngine.execute(task: task, provider: provider, executiveDecision: decision)
        
        metrics.recordExecution(result: result)
        await notifyExecutive(event: .executionCompleted, details: ["task": task.id, "provider": provider.id, "result": result.success ? "success" : "failed"])
        
        return result
    }
    
    func healthCheck() async throws -> ProviderHealthStatus {
        var status = ProviderHealthStatus()
        
        for (id, provider) in providers {
            let isHealthy = try await healthMonitor.checkHealth(for: provider)
            status.providers[id] = isHealthy
            
            if !isHealthy {
                await handleUnhealthyProvider(provider: provider)
            }
        }
        
        await optimizeProviderSelection()
        return status
    }
    
    func optimizeProviderSelection() async throws {
        await costOptimizer.optimize(providers: Array(providers.values), tasks: getRecentTasks())
        await loadBalancer.rebalanceLoad()
        await optimizeForQuality()
    }
    
    func getExecutiveReport() async throws -> ExecutiveRegistryReport {
        let report = ExecutiveRegistryReport(
            timestamp: Date(),
            totalProviders: providers.count,
            healthyProviders: providers.filter { $0.value.status == .healthy }.count,
            totalExecutions: metrics.totalExecutions,
            successfulExecutions: metrics.successfulExecutions,
            failureRate: metrics.failureRate,
            averageExecutionTime: metrics.averageExecutionTime,
            averageCost: metrics.averageCost,
            costByProvider: metrics.costByProvider,
            executionHistory: metrics.getExecutionHistory(limit: 100)
        )
        return report
    }
    
    func getProviderMetrics() async throws -> ProviderMetrics { metrics.aggregateProviderMetrics() }
    
    func getExecutionHistory() async throws -> [ExecutionRecord] { Array(metrics.executionHistory.values) }
    
    func start() async throws {
        await healthMonitor.start()
        await loadBalancer.start()
        await costOptimizer.start()
        await notifyExecutive(event: .registryStarted, details: [:])
    }
    
    func stop() async throws {
        await healthMonitor.stop()
        await loadBalancer.stop()
        await costOptimizer.stop()
        await notifyExecutive(event: .registryStopped, details: [:])
    }
    
    func reset() async throws {
        providers.removeAll()
        metrics.reset()
        await start()
    }
    
    // MARK: - Private Helper Methods
    private func setupInternalComponents() {
        executionEngine.configure(with: configuration)
        healthMonitor.configure(with: configuration)
        loadBalancer.configure(with: configuration)
        costOptimizer.configure(with: configuration)
    }
    
    private func isProviderCompliant(provider: any ProviderContract) -> Bool {
        guard provider.status == .healthy else { return false }
        guard !provider.consecutiveFailures > configuration.maxFailures else { return false }
        guard provider.contextWindow > 0 else { return false }
        return true
    }
    
    private func isTaskCompliant(task: CapabilityTask) -> Bool {
        guard task.contextLength > 0 else { return false }
        guard task.contextLength <= configuration.maxContextWindow else { return false }
        return true
    }
    
    private func canExecuteTask(task: CapabilityTask, provider: any ProviderContract) -> Bool {
        guard provider.capabilities.contains(task.taskType.rawValue) else { return false }
        guard provider.contextWindow >= task.contextLength else { return false }
        return true
    }
    
    private func getExecutiveDecision(for task: CapabilityTask) async throws -> ExecutiveDecision {
        return ExecutiveDecision(
            decisionId: UUID(),
            executive: "registry",
            decisionType: .providerSelection,
            validity: .infinity,
            conditions: [],
            escalationPath: [],
            evidenceRequirement: .standard
        )
    }
    
    private func executeProviderSelection(task: CapabilityTask, decision: ExecutiveDecision, startTime: Date) async throws -> any ProviderContract {
        let availableProviders = providers.values.filter { isProviderCompliant(provider: $0) }
        guard !availableProviders.isEmpty else { throw RuntimeError.noAvailableProviders }
        let selectedProvider = try await executionEngine.selectProvider(for: task, using: self)
        let selectionTime = Date().timeIntervalSince(startTime)
        metrics.recordProviderSelection(task: task, provider: selectedProvider.id, strategy: .executiveDecision, selectionTime: selectionTime)
        return selectedProvider
    }
    
    private func handleUnhealthyProvider(provider: any ProviderContract) async {
        metrics.recordProviderFailure(providerId: provider.id)
        await applyFallbackForProvider(provider: provider)
        await notifyExecutive(event: .providerUnhealthy, details: ["provider": provider.id, "type": provider.type.rawValue, "failures": provider.consecutiveFailures])
    }
    
    private func applyFallbackForProvider(provider: any ProviderContract) async {
        let fallbackStrategy = provider.fallbackStrategy ?? .manual
        switch fallbackStrategy {
        case .automatic:
            await switchToBackupProvider(for: provider)
        case .manual:
            await requestManualIntervention(for: provider)
        case .degrade:
            await degradeServiceForProvider(provider: provider)
        case .circuitBreaker:
            await applyCircuitBreaker(for: provider)
        }
    }
    
    private func notifyExecutive(event: RegistryEvent, details: [String: Any]) async {
        await withCheckedContinuation { continuation in
            Task.detached {
                RegistryExecutiveObserver.shared.notify(event: event, details: details, registry: self)
                continuation.resume()
            }
        }
    }
    
    private func getRecentTasks() -> [CapabilityTask] { metrics.recentTasks }
    
    private func optimizeForQuality() async {
        let qualityOptimizer = QualityOptimizer()
        await qualityOptimizer.optimize(providers: Array(providers.values))
    }
}}

// MARK: - Additional Protocol Definitions

protocol ExecutionEngine: Sendable {
    func selectProvider(for task: CapabilityTask, using registry: ProviderRegistry) async throws -> any ProviderContract
    func execute(task: CapabilityTask, provider: any ProviderContract, executiveDecision: ExecutiveDecision) async throws -> ExecutionResult
    func executeWithFallback(task: CapabilityTask, providers: [any ProviderContract]) async throws -> ExecutionResult
    func handleProviderFailure(_ provider: any ProviderContract, error: Error) async throws
    func optimizeForCost(task: CapabilityTask) -> ProviderCostOptimization
    func optimizeForSpeed(task: CapabilityTask) -> ProviderSpeedOptimization
    func optimizeForReliability(task: CapabilityTask) -> ProviderReliabilityOptimization
    func recordExecutionMetrics(_ metrics: ExecutionMetrics)
    func getPerformanceStatistics() -> ExecutionStatistics
}

protocol HealthMonitor: Sendable {
    func startMonitoring(for provider: any ProviderContract) async throws
    func checkHealth(for provider: any ProviderContract) async throws -> Bool
    func stopMonitoring(for provider: any ProviderContract) async throws
    func start() async throws
    func stop() async throws
    func configure(with configuration: RegistryConfiguration)
}

protocol LoadBalancer: Sendable {
    func rebalanceLoad() async throws
    func start() async throws
    func stop() async throws
    func configure(with configuration: RegistryConfiguration)
}

protocol CostOptimizer: Sendable {
    func optimize(providers: [any ProviderContract], tasks: [CapabilityTask]) async throws
    func start() async throws
    func stop() async throws
    func configure(with configuration: RegistryConfiguration)
}

protocol QualityOptimizer: Sendable {
    func optimize(providers: [any ProviderContract]) async throws
}

protocol ProviderFactory: Sendable {
    func createProvider(from config: ProviderConfig) -> any ProviderContract
}

class DefaultProviderFactory: ProviderFactory {
    func createProvider(from config: ProviderConfig) -> any ProviderContract {
        return DefaultProviderContract(
            id: config.id,
            name: config.name,
            version: config.version,
            type: config.type,
            capabilities: config.capabilities,
            contextWindow: config.contextWindow,
            costPerInput: config.costConfiguration.inputPrice,
            costPerOutput: config.costConfiguration.outputPrice,
            endpoint: config.endpoint,
            authentication: config.authentication,
            timeout: config.timeout
        )
    }
}

class DefaultExecutionEngine: ExecutionEngine {
    private let registry: ProviderRegistry
    
    init(registry: ProviderRegistry = DefaultProviderRegistry()) {
        self.registry = registry
    }
    
    func selectProvider(for task: CapabilityTask, using registry: ProviderRegistry) async throws -> any ProviderContract {
        let availableProviders = registry.getAvailableProviders(for: task)
        guard !availableProviders.isEmpty else { throw RuntimeError.noAvailableProviders }
        return availableProviders[0]
    }
    
    func execute(task: CapabilityTask, provider: any ProviderContract, executiveDecision: ExecutiveDecision) async throws -> ExecutionResult {
        let result = ExecutionResult(
            id: UUID(),
            providerId: provider.id,
            request: RuntimeRequest(
                id: UUID(),
                task: task,
                context: RuntimeContext(
                    runtimeId: "runtime",
                    executionId: UUID(),
                    userId: "user",
                    sessionId: "session",
                    missionId: "mission",
                    executiveDecision: executiveDecision,
                    proofRequirement: ProofRequirement(),
                    startTime: Date(),
                    timeout: TimeInterval.infinity
                ),
                requirements: CapabilityRequirements(),
                preferences: ProviderPreferences(),
                constraints: ProviderConstraints(),
                timestamp: Date(),
                executiveDecision: executiveDecision,
                validationChecks: []
            ),
            response: ProviderResponse(
                id: UUID().uuidString,
                content: "Execution result for \(task.description)",
                metadata: ResponseMetadata(
                    model: provider.name,
                    created: Date(),
                    serviceTier: nil,
                    object: \"text_completion\",
                    systemFingerprint: nil
                ),
                finishReason: .stop,
                usage: TokenUsage(
                    promptTokens: task.contextLength,
                    completionTokens: Int.random(in: 10...100),
                    totalTokens: 0,
                    promptTokenDetails: TokenDetails(),
                    completionTokenDetails: TokenDetails()
                ),
                timing: ResponseTiming(
                    creationTimeMs: 100,
                    firstByteTimeMs: 100,
                    completeTimeMs: 100
                ),
                modelInfo: ModelInfo(
                    id: provider.id,
                    name: provider.name,
                    version: provider.version,
                    provider: provider.type.rawValue,
                    capabilities: provider.capabilities,
                    maxContextLength: provider.contextWindow
                )
            ),
            executionTime: 0.1,
            cost: ExecutionCost(
                inputCost: Double.random(in: 0.0...1.0),
                outputCost: Double.random(in: 0.0...1.0),
                currency: \"USD\",
                exchangeRate: 1.0,
                totalCost: 0.0,
                costBreakdown: [:]
            ),
            qualityScore: Double.random(in: 0.7...0.95),
            success: true,
            error: nil,
            timestamp: Date(),
            executiveDecision: executiveDecision,
            providerMetrics: ProviderMetrics(
                providerId: provider.id,
                latency: 0.1,
                throughput: 10,
                errorRate: 0.0,
                qualityScore: 0.8,
                costEfficiency: 1.0,
                userSatisfaction: 0.9,
                timestamp: Date(),
                executionCount: 1,
                successfulExecutions: 1,
                failedExecutions: 0,
                averageResponseTime: 0.1,
                p95ResponseTime: 0.2,
                currentLoad: 0.5
            ),
            validationResult: ValidationResult(valid: true, errors: [], warnings: [], confidence: 1.0, validator: \"SYSTEM\", timestamp: Date())
        )
        return result
    }
    
    func executeWithFallback(task: CapabilityTask, providers: [any ProviderContract]) async throws -> ExecutionResult { throw RuntimeError.configurationError(\"Not implemented\") }
    func handleProviderFailure(_ provider: any ProviderContract, error: Error) async throws { }
    func optimizeForCost(task: CapabilityTask) -> ProviderCostOptimization { ProviderCostOptimization() }
    func optimizeForSpeed(task: CapabilityTask) -> ProviderSpeedOptimization { ProviderSpeedOptimization() }
    func optimizeForReliability(task: CapabilityTask) -> ProviderReliabilityOptimization { ProviderReliabilityOptimization() }
    func recordExecutionMetrics(_ metrics: ExecutionMetrics) { }
    func getPerformanceStatistics() -> ExecutionStatistics { ExecutionStatistics() }
}

class DefaultHealthMonitor: HealthMonitor {
    func startMonitoring(for provider: any ProviderContract) async throws { }
    func checkHealth(for provider: any ProviderContract) async throws -> Bool { true }
    func stopMonitoring(for provider: any ProviderContract) async throws { }
    func start() async throws { }
    func stop() async throws { }
    func configure(with configuration: RegistryConfiguration) { }
}

class DefaultLoadBalancer: LoadBalancer {
    func rebalanceLoad() async throws { }
    func start() async throws { }
    func stop() async throws { }
    func configure(with configuration: RegistryConfiguration) { }
}

class DefaultCostOptimizer: CostOptimizer {
    func optimize(providers: [any ProviderContract], tasks: [CapabilityTask]) async throws { }
    func start() async throws { }
    func stop() async throws { }
    func configure(with configuration: RegistryConfiguration) { }
}

class QualityOptimizer: QualityOptimizer {
    func optimize(providers: [any ProviderContract]) async throws { }
}

class RegistryExecutiveObserver: Sendable {
    static let shared = RegistryExecutiveObserver()
    
    private var observers: [UUID: any ExecutiveObserver] = [:]
    
    func notify(event: RegistryEvent, details: [String: Any], registry: any ProviderRegistry) {
        for observer in observers.values {
            observer.onRegistryEvent(event: event, details: details, registry: registry)
        }
    }
    
    func registerObserver(_ observer: any ExecutiveObserver, for id: UUID) {
        observers[id] = observer
    }
    
    func unregisterObserver(for id: UUID) {
        observers.removeValue(forKey: id)
    }
}

// MARK: - Runtime Component Protocols

protocol ExecutiveObserver: Sendable {
    func onRegistryEvent(event: RegistryEvent, details: [String: Any], registry: any ProviderRegistry)
}

// MARK: - Supporting Models for Provider Registry

struct ProviderHealth: Sendable {
    let status: ProviderStatus
    let responseTime: TimeInterval
    let throughput: Int
    let errorRate: Double
    let lastCheck: Date
    let healthCheckCount: Int
}

struct ProviderHealthStatus: Sendable {
    let providers: [String: Bool]
    let timestamp: Date
    let overallHealth: ProviderStatus
    let unhealthyProviders: [String]
    let recoveryActionsRequired: Int
}

struct ProviderRequest: Sendable {
    let id: UUID
    let task: CapabilityTask
    let context: RuntimeContext
    let parameters: [String: Any]
    let timestamp: Date
    let authentication: AuthenticationConfig
    let options: RequestOptions
}

struct RequestOptions: Sendable {
    let temperature: Double
    let maxTokens: Int
    let topP: Double
    let topK: Int
    let stopSequences: [String]
    let presencePenalty: Double
    let frequencyPenalty: Double
    let seed: Int?
    let stream: Bool
}

struct RuntimeContext: Sendable {
    let runtimeId: String
    let executionId: UUID
    let userId: String
    let sessionId: String
    let missionId: String
    let executiveDecision: ExecutiveDecision
    let proofRequirement: ProofRequirement
    let startTime: Date
    let timeout: TimeInterval
}

struct ProofRequirement: Sendable {
    let required: Bool
    let type: ProofType
    let source: ProofSource
    let validation: ValidationCriteria
    
    enum ProofType: String, CaseIterable, Sendable {
        case evidence
        case certification
        case audit
        case verification
    }
    
    enum ProofSource: String, CaseIterable, Sendable {
        case direct
        case chain
        case delegate
        case inherited
    }
}

struct ValidationCriteria: Sendable {
    let validator: String
    let confidence: Double
    let thresholds: [String: Double]
    let rules: [ValidationRule]
}

struct ValidationRule: Sendable {
    let ruleId: String
    let description: String
    let criteria: [String: Any]
    let weight: Double
    let required: Bool
}

struct ResponseMetadata: Sendable {
    let model: String
    let created: Date
    let serviceTier: String?
    let object: String
    let systemFingerprint: String?
}

struct TokenUsage: Sendable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    let promptTokenDetails: TokenDetails
    let completionTokenDetails: TokenDetails
}

struct TokenDetails: Sendable {
    let textTokens: Int
    let imageTokens: Int
    let audioTokens: Int
}

struct ResponseTiming: Sendable {
    let creationTimeMs: Int
    let firstByteTimeMs: Int
    let completeTimeMs: Int
}

struct ModelInfo: Sendable {
    let id: String
    let name: String
    let version: String
    let provider: String
    let capabilities: [String]
    let maxContextLength: Int
}

struct ProviderCostOptimization: Sendable { }
struct ProviderSpeedOptimization: Sendable { }
struct ProviderReliabilityOptimization: Sendable { }
struct ExecutionMetrics: Sendable { }
struct ExecutionStatistics: Sendable { }

// MARK: - Registry Support Classes

class ProviderFactory {
    func createProvider(from config: ProviderConfig) -> any ProviderContract {
        return DefaultProviderContract(
            id: config.id,
            name: config.name,
            version: config.version,
            type: config.type,
            capabilities: config.capabilities,
            contextWindow: config.contextWindow,
            costPerInput: config.costConfiguration.inputPrice,
            costPerOutput: config.costConfiguration.outputPrice,
            endpoint: config.endpoint,
            authentication: config.authentication,
            timeout: config.timeout
        )
    }
}

// MARK: - Extension Methods

extension Array where Element: ProviderContract {
    func getCompliantProviders() -> [Element] {
        return filter { provider in
            provider.status == .healthy &&
            provider.consecutiveFailures <= 3 &&
            provider.contextWindow > 0
        }
    }
}

// MARK: - Registry Event Types

enum RegistryEvent: String, CaseIterable, Sendable {
    case providerRegistered
    case providerUnhealthy
    case executionCompleted
    case registryStarted
    case registryStopped
}

enum RegistryError: Error, Sendable {
    case providerNotCompliant(String)
    case taskNotCompliant(String)
    case taskExecutionNotPossible(String)
    case noAvailableProviders
    case executionFailed(String)
    case healthCheckFailed(String)
    case configurationError(String)
    case validationError(String)
    case fallbackError(String)
    
    var localizedDescription: String {
        switch self {
        case .providerNotCompliant(let msg):
            return "Provider not compliant: \(msg)"
        case .taskNotCompliant(let msg):
            return "Task not compliant: \(msg)"
        case .taskExecutionNotPossible(let msg):
            return "Task execution not possible: \(msg)"
        case .noAvailableProviders:
            return "No available providers for the task Execution Error: Cannot find execution path for task. \"
        case .executionFailed(let msg):
            return "Execution failed: \(msg)"
        case .healthCheckFailed(let msg):
            return "Health check failed: \(msg)"
        case .configurationError(let msg):
            return "Configuration error: \(msg)"
        case .validationError(let msg):
            return "Validation error: \(msg)"
        case .fallbackError(let msg):
            return "Fallback error: \(msg)"
        }
    }
}

// MARK: - Executive Report Models

struct ExecutiveRegistryReport: Sendable {
    let timestamp: Date
    let totalProviders: Int
    let healthyProviders: Int
    let totalExecutions: Int
    let successfulExecutions: Int
    let failureRate: Double
    let averageExecutionTime: TimeInterval
    let averageCost: Double
    let costByProvider: [String: Double]
    let executionHistory: [ExecutionRecord]
}

struct ExecutionRecord: Sendable {
    let id: UUID
    let task: CapabilityTask
    let providerId: String
    let startTime: Date
    let endTime: Date
    let executionTime: TimeInterval
    let cost: Double
    let success: Bool
    let errorMessage: String?
    let qualityScore: Double
    let executiveDecision: ExecutiveDecision
}

// MARK: - Metrics and Statistics

class RegistryMetrics {
    var totalExecutions: Int = 0
    var successfulExecutions: Int = 0
    var failedExecutions: Int = 0
    var totalSelectionTime: TimeInterval = 0.0
    var selectionCount: Int = 0
    var costByProvider: [String: Double] = [:]
    var executionHistory: [UUID: ExecutionRecord] = [:]
    var recentTasks: [CapabilityTask] = []
    
    var failureRate: Double {
        guard totalExecutions > 0 else { return 0.0 }
        return Double(failedExecutions) / Double(totalExecutions)
    }
    
    var averageExecutionTime: TimeInterval {
        guard selectionCount > 0 else { return 0.0 }
        return totalSelectionTime / TimeInterval(selectionCount)
    }
    
    var averageCost: Double {
        guard !costByProvider.isEmpty else { return 0.0 }
        let totalCost = costByProvider.values.reduce(0, +)
        return totalCost / Double(costByProvider.count)
    }
    
    func recordProviderSelection(task: CapabilityTask, provider: String, strategy: SelectionStrategy, selectionTime: TimeInterval) {
        selectionCount += 1
        totalSelectionTime += selectionTime
        recentTasks.append(task)
        if recentTasks.count > 100 {
            recentTasks.removeFirst(recentTasks.count - 100)
        }
    }
    
    func recordExecution(result: ExecutionResult) {
        totalExecutions += 1
        if result.success {
            successfulExecutions += 1
        } else {
            failedExecutions += 1
        }
        costByProvider[result.providerId, default: 0.0] += result.cost.totalCost
        executionHistory[result.id] = result
        if executionHistory.count > 1000 {
            let oldestKey = executionHistory.keys.first(where: { $0 < Date().timeIntervalSince(executionHistory[$0]?.timestamp ?? Date()) }) ?? UUID()
            executionHistory.removeValue(forKey: oldestKey)
        }
    }
    
    func recordProviderFailure(providerId: String) {
        failedExecutions += 1
    }
    
    func reset() {
        totalExecutions = 0
        successfulExecutions = 0
        failedExecutions = 0
        totalSelectionTime = 0.0
        selectionCount = 0
        costByProvider.removeAll()
        executionHistory.removeAll()
        recentTasks.removeAll()
    }
    
    func aggregateProviderMetrics() -> ProviderMetrics {
        return ProviderMetrics(
            providerId: \"aggregated\",
            latency: averageExecutionTime,
            throughput: successfulExecutions,
            errorRate: failureRate,
            qualityScore: 0.85,
            costEfficiency: 1.0,
            userSatisfaction: 0.9,
            timestamp: Date(),
            executionCount: totalExecutions,
            successfulExecutions: successfulExecutions,
            failedExecutions: failedExecutions,
            averageResponseTime: averageExecutionTime,
            p95ResponseTime: averageExecutionTime,
            currentLoad: Double(successfulExecutions) / Double(max(totalExecutions, 1))
        )
    }
    
    func getExecutionHistory(limit: Int) -> [ExecutionRecord] {
        return Array(executionHistory.values).suffix(from: max(0, executionHistory.count - limit))
    }
}

// MARK: - Registry Event Types

enum SelectionStrategy: String, CaseIterable, Sendable {
    case executiveDecision
    case costOptimization
    case speedOptimization
    case reliabilityOptimization
}

// MARK: - Registry - MARK: - Error Types

enum RegistryError: Error, Sendable {\n    case providerNotCompliant(String)\n    case taskNotCompliant(String)\n    case taskExecutionNotPossible(String)\n    case noAvailableProviders\n    case executionFailed(String)\n    case healthCheckFailed(String)\n    case configurationError(String)\n    case validationError(String)\n    case fallbackError(String)\n    \n    var localizedDescription: String {\n        switch self {\n        case .providerNotCompliant(let msg):\n            return \\\"Provider not compliant: \\(msg)\\\"\n        case .taskNotCompliant(let msg):\n            return \\\"Task not compliant: \\(msg)\\\"\n        case .taskExecutionNotPossible(let msg):\n            return \\\"Task execution not possible: \\(msg)\\\"\n        case .noAvailableProviders:\n            return \\\"No available providers for the task. \\\";\n        case .executionFailed(let msg):\n            return \\\"Execution failed: \\(msg)\\\"\n        case .healthCheckFailed(let msg):\n            return \\\"Health check failed: \\(msg)\\\"\n        case .configurationError(let msg):\n            return \\\"Configuration error: \\(msg)\\\"\n        case .validationError(let msg):\n            return \\\"Validation error: \\(msg)\\\"\n        case .fallbackError(let msg):\n            return \\\"Fallback error: \\(msg)\\\"\n        }\n    }\n}\n\n// MARK: - Executive Report Models\n\nstruct ExecutionRecord: Sendable {\n    let id: UUID\n    let task: CapabilityTask\n    let providerId: String\n    let startTime: Date\n    let endTime: Date\n    let executionTime: TimeInterval\n    let cost: Double\n    let success: Bool\n    let errorMessage: String?\n    let qualityScore: Double\n    let executiveDecision: ExecutiveDecision\n}\n\n// MARK: - Metrics and Statistics\n\nclass RegistryMetrics {\n    var totalExecutions: Int = 0\n    var successfulExecutions: Int = 0\n    var failedExecutions: Int = 0\n    var totalSelectionTime: TimeInterval = 0.0\n    var selectionCount: Int = 0\n    var costByProvider: [String: Double] = [:]\n    var executionHistory: [UUID: ExecutionRecord] = [:]\n    var recentTasks: [CapabilityTask] = []\n\n    var failureRate: Double {\n        guard totalExecutions > 0 else { return 0.0 }\n        return Double(failedExecutions) / Double(totalExecutions)\n    }\n\n    var averageExecutionTime: TimeInterval {\n        guard selectionCount > 0 else { return 0.0 }\n        return totalSelectionTime / TimeInterval(selectionCount)\n    }\n\n    var averageCost: Double {\n        guard !costByProvider.isEmpty else { return 0.0 }\n        let totalCost = costByProvider.values.reduce(0, +)\n        return totalCost / Double(costByProvider.count)\n    }\n\n    func recordProviderSelection(task: CapabilityTask, provider: String, strategy: SelectionStrategy, selectionTime: TimeInterval) {\n        selectionCount += 1\n        totalSelectionTime += selectionTime\n        recentTasks.append(task)\n        if recentTasks.count > 100 {\n            recentTasks.removeFirst(recentTasks.count - 100)\n        }\n    }\n\n    func recordExecution(result: ExecutionResult) {\n        totalExecutions += 1\n        if result.success {\n            successfulExecutions += 1\n        } else {\n            failedExecutions += 1\n        }\n        costByProvider[result.providerId, default: 0.0] += result.cost.totalCost\n        executionHistory[result.id] = result\n        if executionHistory.count > 1000 {\n            let oldestKey = executionHistory.keys.first(where: { $0 < Date().timeIntervalSince(executionHistory[$0]?.timestamp ?? Date()) }) ?? UUID()\n            executionHistory.removeValue(forKey: oldestKey)\n        }\n    }\n\n    func recordProviderFailure(providerId: String) {\n        failedExecutions += 1\n    }\n\n    func reset() {\n        totalExecutions = 0\n        successfulExecutions = 0\n        failedExecutions = 0\n        totalSelectionTime = 0.0\n        selectionCount = 0\n        costByProvider.removeAll()\n        executionHistory.removeAll()\n        recentTasks.removeAll()\n    }\n\n    func aggregateProviderMetrics() -> ProviderMetrics {\n        return ProviderMetrics(\n            providerId: \"aggregated\",\n            latency: averageExecutionTime,\n            throughput: successfulExecutions,\n            errorRate: failureRate,\n            qualityScore: 0.85,\n            costEfficiency: 1.0,\n            userSatisfaction: 0.9,\n            timestamp: Date(),\n            executionCount: totalExecutions,\n            successfulExecutions: successfulExecutions,\n            failedExecutions: failedExecutions,\n            averageResponseTime: averageExecutionTime,\n            p95ResponseTime: averageExecutionTime,\n            currentLoad: Double(successfulExecutions) / Double(max(totalExecutions, 1))\n        )\n    }\n\n    func getExecutionHistory(limit: Int) -> [ExecutionRecord] {\n        return Array(executionHistory.values).suffix(from: max(0, executionHistory.count - limit))\n    }\n}