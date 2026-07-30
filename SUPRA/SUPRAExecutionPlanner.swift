import Foundation
import Combine

public struct SUPRAExecutionTask: Identifiable, Codable, Sendable {
    public let id: UUID
    public let stepID: UUID
    public let order: Int
    public let action: SUPRAOrchestrationAction
    public let requiredCapabilities: [String]
    public let providerID: String?
    public let modelID: String?
    public let prompt: String
    public let systemPrompt: String
    public let maxTokens: Int
    public let temperature: Double
    public let timeoutSeconds: Int
    public let dependencies: [UUID]
    public let isCritical: Bool

    public init(id: UUID = UUID(), stepID: UUID, order: Int,
                action: SUPRAOrchestrationAction,
                requiredCapabilities: [String],
                providerID: String? = nil, modelID: String? = nil,
                prompt: String, systemPrompt: String = "",
                maxTokens: Int = 2048, temperature: Double = 0.7,
                timeoutSeconds: Int = 30, dependencies: [UUID] = [],
                isCritical: Bool = false) {
        self.id = id
        self.stepID = stepID
        self.order = order
        self.action = action
        self.requiredCapabilities = requiredCapabilities
        self.providerID = providerID
        self.modelID = modelID
        self.prompt = prompt
        self.systemPrompt = systemPrompt
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.timeoutSeconds = timeoutSeconds
        self.dependencies = dependencies
        self.isCritical = isCritical
    }
}

public struct SUPRAOrchestrationPlan: Codable, Sendable {
    public let decisionID: UUID
    public let tasks: [SUPRAExecutionTask]
    public let executionGraph: [UUID: [UUID]]
    public let estimatedTotalTokens: Int
    public let estimatedDurationMs: Int
    public let requiresMultipleProviders: Bool

    public init(decisionID: UUID, tasks: [SUPRAExecutionTask],
                executionGraph: [UUID: [UUID]],
                estimatedTotalTokens: Int = 0,
                estimatedDurationMs: Int = 0,
                requiresMultipleProviders: Bool = false) {
        self.decisionID = decisionID
        self.tasks = tasks
        self.executionGraph = executionGraph
        self.estimatedTotalTokens = estimatedTotalTokens
        self.estimatedDurationMs = estimatedDurationMs
        self.requiresMultipleProviders = requiresMultipleProviders
    }
}

@MainActor
public final class SUPRAExecutionPlanner: ObservableObject {
    public static let shared = SUPRAExecutionPlanner()

    @Published public private(set) var lastPlan: SUPRAOrchestrationPlan?
    @Published public private(set) var isPlanning = false

    private init() {}

    public func plan(decision: SUPRAOrchestrationDecision,
                     prompt: String, systemPrompt: String) async -> SUPRAOrchestrationPlan {
        isPlanning = true
        defer { isPlanning = false }

        var tasks: [SUPRAExecutionTask] = []
        var graph: [UUID: [UUID]] = [:]
        var totalTokens = 0
        var requiresMulti = false

        for step in decision.steps {
            let task = SUPRAExecutionTask(
                stepID: step.id,
                order: step.order,
                action: step.action,
                requiredCapabilities: step.requiredCapabilities,
                prompt: prompt,
                systemPrompt: systemPrompt,
                maxTokens: step.action == .generate ? 4096 : 2048,
                temperature: step.action == .reason ? 0.3 : 0.7,
                timeoutSeconds: step.timeoutSeconds,
                dependencies: step.dependencies,
                isCritical: step.isCritical
            )
            tasks.append(task)
            graph[task.id] = step.dependencies
            totalTokens += task.maxTokens
        }

        let uniqueProviders = Set(tasks.compactMap(\.providerID))
        requiresMulti = uniqueProviders.count > 1

        let plan = SUPRAOrchestrationPlan(
            decisionID: decision.missionID,
            tasks: tasks,
            executionGraph: graph,
            estimatedTotalTokens: totalTokens,
            estimatedDurationMs: tasks.count * 2000,
            requiresMultipleProviders: requiresMulti
        )

        lastPlan = plan
        return plan
    }

    public func executionOrder(for plan: SUPRAOrchestrationPlan) -> [SUPRAExecutionTask] {
        var ordered: [SUPRAExecutionTask] = []
        var visited = Set<UUID>()

        func visit(_ taskID: UUID) {
            guard !visited.contains(taskID) else { return }
            visited.insert(taskID)
            if let deps = plan.executionGraph[taskID] {
                for depID in deps {
                    if let depTask = plan.tasks.first(where: { $0.id == depID }) {
                        visit(depTask.id)
                    }
                }
            }
            if let task = plan.tasks.first(where: { $0.id == taskID }) {
                ordered.append(task)
            }
        }

        for task in plan.tasks.sorted(by: { $0.order < $1.order }) {
            visit(task.id)
        }

        return ordered
    }
}
