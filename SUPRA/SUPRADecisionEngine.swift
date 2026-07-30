import Foundation
import Combine

public struct SUPRAUnderstanding: Codable, Sendable {
    public let missionTitle: String
    public let prompt: String
    public let systemPrompt: String
    public let intent: String
    public let requiresTools: Bool
    public let requiresVision: Bool
    public let requiresStreaming: Bool
    public let requiresJSON: Bool
    public let requiresEmbeddings: Bool
    public let requiresLargeContext: Bool
    public let requiresReasoning: Bool
    public let requiresPlanning: Bool
    public let requiresMemory: Bool
    public let requiresSearch: Bool
    public let priority: Int
    public let isTimeSensitive: Bool

    public init(missionTitle: String, prompt: String, systemPrompt: String = "",
                intent: String = "", requiresTools: Bool = false,
                requiresVision: Bool = false, requiresStreaming: Bool = false,
                requiresJSON: Bool = false, requiresEmbeddings: Bool = false,
                requiresLargeContext: Bool = false, requiresReasoning: Bool = true,
                requiresPlanning: Bool = false, requiresMemory: Bool = false,
                requiresSearch: Bool = false, priority: Int = 0,
                isTimeSensitive: Bool = false) {
        self.missionTitle = missionTitle
        self.prompt = prompt
        self.systemPrompt = systemPrompt
        self.intent = intent
        self.requiresTools = requiresTools
        self.requiresVision = requiresVision
        self.requiresStreaming = requiresStreaming
        self.requiresJSON = requiresJSON
        self.requiresEmbeddings = requiresEmbeddings
        self.requiresLargeContext = requiresLargeContext
        self.requiresReasoning = requiresReasoning
        self.requiresPlanning = requiresPlanning
        self.requiresMemory = requiresMemory
        self.requiresSearch = requiresSearch
        self.priority = priority
        self.isTimeSensitive = isTimeSensitive
    }
}

public enum SUPRAOrchestrationAction: String, Codable, Sendable {
    case analyze
    case generate
    case plan
    case search
    case remember
    case reason
    case transform
    case validate
    case execute
    case delegate
}

public struct SUPRAOrchestrationStep: Identifiable, Codable, Sendable {
    public let id: UUID
    public let order: Int
    public let action: SUPRAOrchestrationAction
    public let requiredCapabilities: [String]
    public let description: String
    public let isCritical: Bool
    public let timeoutSeconds: Int
    public let dependencies: [UUID]

    public init(id: UUID = UUID(), order: Int, action: SUPRAOrchestrationAction,
                requiredCapabilities: [String], description: String = "",
                isCritical: Bool = false, timeoutSeconds: Int = 30,
                dependencies: [UUID] = []) {
        self.id = id
        self.order = order
        self.action = action
        self.requiredCapabilities = requiredCapabilities
        self.description = description
        self.isCritical = isCritical
        self.timeoutSeconds = timeoutSeconds
        self.dependencies = dependencies
    }
}

public struct SUPRAOrchestrationDecision: Codable, Sendable {
    public let missionID: UUID
    public let understanding: SUPRAUnderstanding
    public let steps: [SUPRAOrchestrationStep]
    public let reasoning: String
    public let estimatedComplexity: Int
    public let requiresFallback: Bool
    public let requiresLearning: Bool

    public init(missionID: UUID, understanding: SUPRAUnderstanding,
                steps: [SUPRAOrchestrationStep], reasoning: String = "",
                estimatedComplexity: Int = 1, requiresFallback: Bool = true,
                requiresLearning: Bool = true) {
        self.missionID = missionID
        self.understanding = understanding
        self.steps = steps
        self.reasoning = reasoning
        self.estimatedComplexity = estimatedComplexity
        self.requiresFallback = requiresFallback
        self.requiresLearning = requiresLearning
    }
}

@MainActor
public final class SUPRADecisionEngine: ObservableObject {
    public static let shared = SUPRADecisionEngine()

    @Published public private(set) var lastDecision: SUPRAOrchestrationDecision?
    @Published public private(set) var isDeciding = false
    @Published public private(set) var decisionCount = 0

    private init() {}

    public func decide(missionTitle: String, prompt: String,
                       systemPrompt: String = "") async -> SUPRAOrchestrationDecision {
        isDeciding = true
        defer { isDeciding = false }

        let understanding = await understand(missionTitle: missionTitle,
                                              prompt: prompt,
                                              systemPrompt: systemPrompt)
        let steps = await planSteps(for: understanding)
        let complexity = calculateComplexity(steps: steps)

        let decision = SUPRAOrchestrationDecision(
            missionID: UUID(),
            understanding: understanding,
            steps: steps,
            reasoning: "Decided \(steps.count) orchestration steps",
            estimatedComplexity: complexity,
            requiresFallback: true,
            requiresLearning: true
        )

        lastDecision = decision
        decisionCount += 1
        return decision
    }

    private func understand(missionTitle: String, prompt: String,
                            systemPrompt: String) async -> SUPRAUnderstanding {
        let lower = prompt.lowercased()
        return SUPRAUnderstanding(
            missionTitle: missionTitle,
            prompt: prompt,
            systemPrompt: systemPrompt,
            intent: extractIntent(from: lower),
            requiresTools: lower.contains("tool") || lower.contains("function"),
            requiresVision: lower.contains("image") || lower.contains("vision") || lower.contains("see"),
            requiresStreaming: lower.contains("stream") || lower.contains("real-time"),
            requiresJSON: lower.contains("json") || lower.contains("structur"),
            requiresEmbeddings: lower.contains("embed") || lower.contains("vector") || lower.contains("semantic"),
            requiresLargeContext: prompt.count > 2000,
            requiresReasoning: lower.contains("why") || lower.contains("explain") || lower.contains("reason") || lower.contains("analyse"),
            requiresPlanning: lower.contains("plan") || lower.contains("strategy") || lower.contains("schedule"),
            requiresMemory: lower.contains("remember") || lower.contains("memory") || lower.contains("recall"),
            requiresSearch: lower.contains("search") || lower.contains("find") || lower.contains("lookup"),
            priority: lower.contains("urgent") || lower.contains("critical") ? 10 : 0,
            isTimeSensitive: lower.contains("now") || lower.contains("quick") || lower.contains("fast")
        )
    }

    private func extractIntent(from lower: String) -> String {
        if lower.contains("code") || lower.contains("program") { return "coding" }
        if lower.contains("explain") || lower.contains("what") || lower.contains("how") { return "analysis" }
        if lower.contains("hello") || lower.contains("hi") || lower.contains("bonjour") { return "conversation" }
        if lower.contains("plan") || lower.contains("project") { return "planning" }
        if lower.contains("search") || lower.contains("find") { return "search" }
        return "conversation"
    }

    private func planSteps(for understanding: SUPRAUnderstanding) async -> [SUPRAOrchestrationStep] {
        var steps: [SUPRAOrchestrationStep] = []
        var order = 0

        if understanding.requiresReasoning || understanding.requiresPlanning {
            order += 1
            steps.append(SUPRAOrchestrationStep(
                order: order, action: .reason,
                requiredCapabilities: ["reasoning"],
                description: "Analyze and reason about the request",
                isCritical: true, timeoutSeconds: 60
            ))
        }

        order += 1
        let capabilities = resolveCapabilities(from: understanding)
        steps.append(SUPRAOrchestrationStep(
            order: order, action: .generate,
            requiredCapabilities: capabilities,
            description: "Generate response based on understanding",
            isCritical: true, timeoutSeconds: 60
        ))

        if understanding.requiresSearch {
            order += 1
            steps.append(SUPRAOrchestrationStep(
                order: order, action: .search,
                requiredCapabilities: ["search"],
                description: "Search for relevant information",
                timeoutSeconds: 30
            ))
        }

        if understanding.requiresMemory {
            order += 1
            steps.append(SUPRAOrchestrationStep(
                order: order, action: .remember,
                requiredCapabilities: ["memory"],
                description: "Recall relevant context from memory",
                timeoutSeconds: 15
            ))
        }

        order += 1
        steps.append(SUPRAOrchestrationStep(
            order: order, action: .validate,
            requiredCapabilities: ["reasoning"],
            description: "Validate the generated output",
            isCritical: true, timeoutSeconds: 15,
            dependencies: [steps.last { $0.action == .generate }?.id ?? UUID()]
        ))

        return steps
    }

    private func resolveCapabilities(from understanding: SUPRAUnderstanding) -> [String] {
        var caps: [String] = ["conversation"]
        if understanding.requiresReasoning { caps.append("reasoning") }
        if understanding.requiresPlanning { caps.append("planning") }
        if understanding.requiresSearch { caps.append("search") }
        if understanding.requiresMemory { caps.append("memory") }
        if understanding.requiresTools { caps.append("tools") }
        if understanding.requiresVision { caps.append("vision") }
        if understanding.requiresStreaming { caps.append("streaming") }
        if understanding.requiresJSON { caps.append("json") }
        if understanding.requiresEmbeddings { caps.append("embeddings") }
        if understanding.requiresLargeContext { caps.append("large_context") }
        if understanding.prompt.count > 100 || understanding.requiresReasoning { caps.append("analysis") }
        caps.append("coding")
        return Array(Set(caps))
    }

    private func calculateComplexity(steps: [SUPRAOrchestrationStep]) -> Int {
        let base = steps.count
        let critical = steps.filter(\.isCritical).count
        return base + critical
    }

    static func evaluate(_ evidence: DecisionEvidence) -> DecisionVerdict {
        let combined = (evidence.confidenceScore + evidence.evidenceScore) / 2.0
        if evidence.impact == .critical || evidence.category.isSovereign {
            return DecisionVerdict(
                authority: .sovereignHumanOnly,
                reason: "Critical impact or sovereign category requires human authority",
                confidence: combined,
                requiredAction: "human_approval",
                rollbackAvailable: evidence.isReversible
            )
        }
        if combined >= 0.9 && evidence.permissionsAvailable {
            return DecisionVerdict(
                authority: .autoExecute,
                reason: "High confidence with available permissions",
                confidence: combined,
                requiredAction: "execute",
                rollbackAvailable: evidence.isReversible
            )
        }
        if combined >= 0.7 && evidence.isReversible {
            return DecisionVerdict(
                authority: .supervised,
                reason: "Moderate confidence, reversible action",
                confidence: combined,
                requiredAction: "supervise",
                rollbackAvailable: true
            )
        }
        if evidence.impact == .high {
            return DecisionVerdict(
                authority: .humanRequired,
                reason: "High impact requires human review",
                confidence: combined,
                requiredAction: "human_review",
                rollbackAvailable: evidence.isReversible
            )
        }
        return DecisionVerdict(
            authority: .supervised,
            reason: "Default supervised execution",
            confidence: combined,
            requiredAction: "supervise",
            rollbackAvailable: evidence.isReversible
        )
    }
}
