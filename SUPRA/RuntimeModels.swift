import Foundation

struct RuntimeTrace: Codable {
    let version: String
    let mission: String
    let totalDurationSeconds: Int
    let traces: [TraceStep]

    enum CodingKeys: String, CodingKey {
        case version, mission, traces
        case totalDurationSeconds = "total_duration_seconds"
    }
}

struct TraceStep: Codable, Identifiable {
    let id = UUID()
    let step: Int
    let name: String
    let system: String
    let action: String
    let result: String
    let durationMs: Int?

    enum CodingKeys: String, CodingKey {
        case step, name, system, action, result
        case durationMs = "duration_ms"
    }
}

struct DelegationTrace: Codable {
    let version: String
    let mission: String
    let totalDelegations: Int
    let delegations: [Delegation]

    enum CodingKeys: String, CodingKey {
        case version, mission
        case totalDelegations = "total_delegations"
        case delegations
    }
}

struct Delegation: Codable, Identifiable {
    let id = UUID()
    let taskId: String
    let taskName: String
    let agent: String
    let provider: String
    let model: String
    let status: String
    let durationSeconds: Int?
    let dispatchMode: String?

    enum CodingKeys: String, CodingKey {
        case agent, provider, model, status
        case taskId = "task_id"
        case taskName = "task_name"
        case durationSeconds = "duration_seconds"
        case dispatchMode = "dispatch_mode"
    }
}

struct RuntimeMetrics: Codable {
    let version: String
    let pipelinePerformance: PipelineMetrics
    let agentPerformance: AgentPerformanceSummary

    enum CodingKeys: String, CodingKey {
        case version
        case pipelinePerformance = "pipeline_performance"
        case agentPerformance = "agent_performance"
    }
}

struct PipelineMetrics: Codable {
    let totalPipelineDurationSeconds: Int

    enum CodingKeys: String, CodingKey {
        case totalPipelineDurationSeconds = "total_pipeline_duration_seconds"
    }
}

struct AgentPerformanceSummary: Codable {
    let totalDispatched: Int
    let totalCompleted: Int
    let totalFailed: Int
    let avgDurationPerAgent: Int?

    enum CodingKeys: String, CodingKey {
        case totalDispatched = "total_agents_dispatched"
        case totalCompleted = "total_completed"
        case totalFailed = "total_failed"
        case avgDurationPerAgent = "avg_duration_per_agent"
    }
}

struct AgentExecution: Codable {
    let version: String
    let totalAgents: Int
    let agents: [AgentResult]

    enum CodingKeys: String, CodingKey {
        case version, agents
        case totalAgents = "total_agents"
    }
}

struct AgentResult: Codable, Identifiable {
    let id = UUID()
    let agent: String
    let task: String
    let provider: String
    let model: String
    let state: String
    let durationSeconds: Int?
    let phase: String?

    enum CodingKeys: String, CodingKey {
        case agent, task, provider, model, state, phase
        case durationSeconds = "duration_seconds"
    }
}

struct ExecutionGraphNode: Codable, Identifiable {
    let id: String
    let type: String?
    let label: String?
    let agent: String?
    let provider: String?
    let model: String?
    let duration: String?
    let result: String?
}

struct ExecutionGraphEdge: Codable, Identifiable {
    var id: String { "\(from)->\(to)" }
    let from: String
    let to: String
}

struct ExecutionGraphSummary: Codable {
    let totalNodes: Int
    let totalEdges: Int
    let parallelPaths: Int?
    let singleWriterVerified: Bool?
    let multiJobVerified: Bool?

    enum CodingKeys: String, CodingKey {
        case totalNodes = "total_nodes"
        case totalEdges = "total_edges"
        case parallelPaths = "parallel_paths"
        case singleWriterVerified = "single_writer_verified"
        case multiJobVerified = "multi_job_verified"
    }
}

struct ExecutionGraph: Codable {
    let version: String
    let mission: String?
    let graphType: String?
    let nodes: [ExecutionGraphNode]
    let edges: [ExecutionGraphEdge]
    let summary: ExecutionGraphSummary?

    enum CodingKeys: String, CodingKey {
        case version, mission, nodes, edges, summary
        case graphType = "graph_type"
    }
}

struct MissionGraphMetrics: Codable {
    let version: String
    let mission: String
    let graphMetrics: GraphMetrics
    let parallelizationMetrics: ParallelizationMetrics
    let criticalPathMetrics: CriticalPathMetrics
    let resourceMetrics: ResourceMetrics
    let levelAssessment: LevelAssessment

    enum CodingKeys: String, CodingKey {
        case version, mission
        case graphMetrics = "graph_metrics"
        case parallelizationMetrics = "parallelization_metrics"
        case criticalPathMetrics = "critical_path_metrics"
        case resourceMetrics = "resource_metrics"
        case levelAssessment = "level_assessment"
    }
}

struct GraphMetrics: Codable {
    let totalNodes: Int
    let totalEdges: Int
    let graphDensity: Double
    let avgDegree: Double
    let maxDegree: Int
    let diameter: Int
    let width: Int

    enum CodingKeys: String, CodingKey {
        case totalNodes = "total_nodes"
        case totalEdges = "total_edges"
        case graphDensity = "graph_density"
        case avgDegree = "avg_degree"
        case maxDegree = "max_degree"
        case diameter, width
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalNodes = try container.decode(Int.self, forKey: .totalNodes)
        totalEdges = try container.decode(Int.self, forKey: .totalEdges)
        graphDensity = try container.decode(Double.self, forKey: .graphDensity)
        avgDegree = try container.decode(Double.self, forKey: .avgDegree)
        maxDegree = try container.decode(Int.self, forKey: .maxDegree)
        diameter = try container.decode(Int.self, forKey: .diameter)
        width = try container.decode(Int.self, forKey: .width)
    }
}

struct ParallelizationMetrics: Codable {
    let sequentialDuration: Int
    let optimizedDuration: Int
    let speedupFactor: Double
    let parallelEfficiency: Double
    let maxParallelism: Int
    let avgParallelism: Double

    enum CodingKeys: String, CodingKey {
        case sequentialDuration = "sequential_duration"
        case optimizedDuration = "optimized_duration"
        case speedupFactor = "speedup_factor"
        case parallelEfficiency = "parallel_efficiency"
        case maxParallelism = "max_parallelism"
        case avgParallelism = "avg_parallelism"
    }
}

struct CriticalPathMetrics: Codable {
    let criticalPathDuration: Int
    let shortestPathDuration: Int
    let bottleneckTask: String
    let bottleneckContributionPct: Double

    enum CodingKeys: String, CodingKey {
        case criticalPathDuration = "critical_path_duration"
        case shortestPathDuration = "shortest_path_duration"
        case bottleneckTask = "bottleneck_task"
        case bottleneckContributionPct = "bottleneck_contribution_pct"
    }
}

struct ResourceMetrics: Codable {
    let opencodeZenUtilization: ProviderUtilization
    let ollamaUtilization: ProviderUtilization

    enum CodingKeys: String, CodingKey {
        case opencodeZenUtilization = "opencode_zen_utilization"
        case ollamaUtilization = "ollama_utilization"
    }
}

struct ProviderUtilization: Codable {
    let tasksAssigned: Int
    let totalDuration: Int
    let parallelTasksPeak: Int
    let utilizationPct: Double

    enum CodingKeys: String, CodingKey {
        case tasksAssigned = "tasks_assigned"
        case totalDuration = "total_duration"
        case parallelTasksPeak = "parallel_tasks_peak"
        case utilizationPct = "utilization_pct"
    }
}

struct LevelAssessment: Codable {
    let dagRuntime: Bool
    let dependencyEngine: Bool
    let criticalPathAnalysis: Bool
    let automaticParallelization: Bool
    let optimizedScheduling: Bool

    enum CodingKeys: String, CodingKey {
        case dagRuntime = "dag_runtime"
        case dependencyEngine = "dependency_engine"
        case criticalPathAnalysis = "critical_path_analysis"
        case automaticParallelization = "automatic_parallelization"
        case optimizedScheduling = "optimized_scheduling"
    }
}

struct ProviderMetricsEntry: Codable {
    let providerId: String
    let providerName: String
    let type: String
    let status: String
    let modelsAvailable: Int
    let modelsTotal: Int
    let availabilityPct: Double
    let agentsAssigned: Int
    let agentsExecuted: Int
    let agentsCompleted: Int
    let agentsFailed: Int
    let successRate: Double?
    let totalExecutionTimeSeconds: Int
    let avgExecutionTimeSeconds: Double?
    let healthCheckResult: String?

    enum CodingKeys: String, CodingKey {
        case providerId = "provider_id"
        case providerName = "provider_name"
        case type, status
        case modelsAvailable = "models_available"
        case modelsTotal = "models_total"
        case availabilityPct = "availability_pct"
        case agentsAssigned = "agents_assigned"
        case agentsExecuted = "agents_executed"
        case agentsCompleted = "agents_completed"
        case agentsFailed = "agents_failed"
        case successRate = "success_rate"
        case totalExecutionTimeSeconds = "total_execution_time_seconds"
        case avgExecutionTimeSeconds = "avg_execution_time_seconds"
        case healthCheckResult = "health_check_result"
    }
}

struct ProviderMetricsAggregate: Codable {
    let totalProviders: Int
    let activeProviders: Int
    let totalAgentsExecuted: Int
    let overallSuccessRate: Double
    let totalExecutionTimeSeconds: Int
    let multiProviderDemonstrated: Bool
    let multiModelDemonstrated: Bool

    enum CodingKeys: String, CodingKey {
        case totalProviders = "total_providers"
        case activeProviders = "active_providers"
        case totalAgentsExecuted = "total_agents_executed"
        case overallSuccessRate = "overall_success_rate"
        case totalExecutionTimeSeconds = "total_execution_time_seconds"
        case multiProviderDemonstrated = "multi_provider_demonstrated"
        case multiModelDemonstrated = "multi_model_demonstrated"
    }
}

struct ProviderMetrics: Codable {
    let metricsPerProvider: [String: ProviderMetricsEntry]
    let aggregate: ProviderMetricsAggregate

    enum CodingKeys: String, CodingKey {
        case metricsPerProvider = "metrics_per_provider"
        case aggregate
    }
}

struct DashboardSnapshot: Codable {
    let systemStatus: String
    let missionCounts: MissionCounts
    let workers: WorkerSummary
    let providers: [String: ProviderStatus]
    let topBottlenecks: [BottleneckEntry]
    let healthIndicators: HealthIndicators

    enum CodingKeys: String, CodingKey {
        case systemStatus = "system_status"
        case missionCounts = "mission_counts"
        case workers, providers
        case topBottlenecks = "top_bottlenecks"
        case healthIndicators = "health_indicators"
    }
}

struct MissionCounts: Codable {
    let total: Int
    let queued: Int
    let ready: Int
    let planned: Int
    let running: Int
    let waiting: Int
    let blocked: Int
    let failed: Int
    let success: Int
    let archived: Int
    var active: Int? = nil
    var completed: Int? = nil
}

struct WorkerSummary: Codable {
    let total: Int
    let busy: Int
    let idle: Int
}

struct ProviderStatus: Codable {
    let status: String
    let loadPct: Double?
    let missionsTotal: Int?

    enum CodingKeys: String, CodingKey {
        case status
        case loadPct = "load_pct"
        case missionsTotal = "missions_total"
    }
}

struct BottleneckEntry: Codable, Identifiable {
    var id: String { name }
    let rank: Int
    let name: String
    let avgDuration: Int
    let missionsPending: Int

    enum CodingKeys: String, CodingKey {
        case rank, name
        case avgDuration = "avg_duration"
        case missionsPending = "missions_pending"
    }
}

struct HealthIndicators: Codable {
    let completionRate: String
    let failureRate: String
    let queueHealth: String
    let workerHealth: Double
    let providerHealth: Double
    let systemHealthScore: Double

    enum CodingKeys: String, CodingKey {
        case completionRate = "completion_rate"
        case failureRate = "failure_rate"
        case queueHealth = "queue_health"
        case workerHealth = "worker_health"
        case providerHealth = "provider_health"
        case systemHealthScore = "system_health_score"
    }
}

struct RuntimeData: Codable {
    let runtimeTrace: RuntimeTrace?
    let delegationTrace: DelegationTrace?
    let runtimeMetrics: RuntimeMetrics?
    let agentExecution: AgentExecution?
    let executionGraph: ExecutionGraph?
    let missionGraphMetrics: MissionGraphMetrics?
    let providerMetrics: ProviderMetrics?
    let dashboardSnapshot: DashboardSnapshot?

    static let empty = RuntimeData(runtimeTrace: nil, delegationTrace: nil, runtimeMetrics: nil, agentExecution: nil, executionGraph: nil, missionGraphMetrics: nil, providerMetrics: nil, dashboardSnapshot: nil)
}

// MARK: - System Metrics

enum SystemMetricState<T>: Equatable where T: Equatable {
    case loading
    case available(T)
    case unavailable(reason: String)
}

struct CPUMetrics: Equatable {
    let totalPercent: Double
    let userPercent: Double
    let systemPercent: Double
    let idlePercent: Double
    let sampleState: SampleState

    enum SampleState: String, Equatable {
        case warmingUp
        case valid
        case unavailable
    }
}

struct HeavyProcess: Identifiable, Equatable {
    let id: Int
    let name: String
    let cpuPercent: Double
    let memoryPercent: Double
}

struct ServicesInfo: Equatable {
    let total: Int
    let active: Int
    let unavailable: Int
}

struct ProjectsInfo: Equatable {
    let discovered: Int
    let active: Int
    let validated: Int
    let unavailable: Int
}

struct GitReposInfo: Equatable {
    let total: Int
    let dirty: Int
    let clean: Int
    let unavailable: Int
}

struct StorageInfo: Equatable {
    let totalBytes: Int64
    let availableBytes: Int64
    let usedBytes: Int64
    let recoverableBytes: Int64
    let recoverableConfidence: RecoverableConfidence

    enum RecoverableConfidence: String, Equatable {
        case measured
        case estimated
        case unavailable
    }
}

struct XcodeInfo: Equatable {
    let installed: Bool
    let version: String
    let buildVersion: String
    let developerDir: String
    let swiftVersion: String
    let status: XcodeStatus

    enum XcodeStatus: String, Equatable {
        case available
        case missing
        case commandFailure
    }
}

struct SystemMetricsSnapshot: Equatable {
    let cpu: SystemMetricState<CPUMetrics>
    let heavyProcesses: SystemMetricState<[HeavyProcess]>
    let services: SystemMetricState<ServicesInfo>
    let projects: SystemMetricState<ProjectsInfo>
    let gitRepos: SystemMetricState<GitReposInfo>
    let storage: SystemMetricState<StorageInfo>
    let xcode: SystemMetricState<XcodeInfo>
    let timestamp: Date
    let refreshDuration: TimeInterval?
    let failedMetrics: [String]
    let refreshState: RefreshState

    enum RefreshState: String, Equatable {
        case idle
        case refreshing
    }
}
