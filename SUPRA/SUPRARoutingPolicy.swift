import Foundation
import Combine

public struct SUPRARoutingRequirements: Codable, Sendable {
    public let requiredCapabilities: [String]
    public let requiresLocal: Bool
    public let requiresLowLatency: Bool
    public let requiresHighQuality: Bool
    public let requiresConfidentiality: Bool
    public let requiresOffline: Bool
    public let requiresGPU: Bool
    public let requiresCPU: Bool
    public let minContextWindow: Int
    public let maxCostPer1KTokens: Double
    public let maxLatencyMs: Int
    public let priority: Int

    public init(requiredCapabilities: [String], requiresLocal: Bool = false,
                requiresLowLatency: Bool = false, requiresHighQuality: Bool = false,
                requiresConfidentiality: Bool = false, requiresOffline: Bool = false,
                requiresGPU: Bool = false, requiresCPU: Bool = false,
                minContextWindow: Int = 4096, maxCostPer1KTokens: Double = .infinity,
                maxLatencyMs: Int = 30000, priority: Int = 0) {
        self.requiredCapabilities = requiredCapabilities
        self.requiresLocal = requiresLocal
        self.requiresLowLatency = requiresLowLatency
        self.requiresHighQuality = requiresHighQuality
        self.requiresConfidentiality = requiresConfidentiality
        self.requiresOffline = requiresOffline
        self.requiresGPU = requiresGPU
        self.requiresCPU = requiresCPU
        self.minContextWindow = minContextWindow
        self.maxCostPer1KTokens = maxCostPer1KTokens
        self.maxLatencyMs = maxLatencyMs
        self.priority = priority
    }
}

public struct SUPRAProviderSelection: Codable, Sendable {
    public let providerID: String
    public let modelID: String
    public let score: Double
    public let reasons: [String]
    public let estimatedCost: Double
    public let estimatedLatencyMs: Int
    public let isLocal: Bool

    public init(providerID: String, modelID: String, score: Double,
                reasons: [String], estimatedCost: Double = 0,
                estimatedLatencyMs: Int = 0, isLocal: Bool = true) {
        self.providerID = providerID
        self.modelID = modelID
        self.score = score
        self.reasons = reasons
        self.estimatedCost = estimatedCost
        self.estimatedLatencyMs = estimatedLatencyMs
        self.isLocal = isLocal
    }
}

@MainActor
public final class SUPRARoutingPolicy: ObservableObject {
    public static let shared = SUPRARoutingPolicy()

    @Published public private(set) var lastSelection: SUPRAProviderSelection?
    @Published public private(set) var routingCount = 0

    public var preferLocal: Bool = true
    public var preferLowLatency: Bool = true
    public var preferLowCost: Bool = true
    public var maxRetries: Int = 3

    private let providerPluginRegistry = SUPRAProviderPluginRegistry.shared
    private let learningEngine = SUPRALearningEngine.shared
    private lazy var scheduler = SUPRAScheduler.shared

    private init() {}

    public func selectGear(for taskLabel: String, writeRequired: Bool,
                            complexity: Int = 1, risk: Double = 0.0,
                            pathOverlap: Bool = false,
                            cpuPressure: Double = 0.0,
                            memoryPressure: Double = 0.0,
                            diskPressure: Double = 0.0,
                            providerHealth: Double = 1.0,
                            contextRequired: Int = 4096) async -> TransmissionDecision {
        let gear = classifyGear(taskLabel: taskLabel, writeRequired: writeRequired,
                                complexity: complexity, risk: risk,
                                pathOverlap: pathOverlap, cpuPressure: cpuPressure,
                                memoryPressure: memoryPressure, diskPressure: diskPressure,
                                contextRequired: contextRequired)
        let profile = profileForGear(gear)
        let requirements = SUPRARoutingRequirements(
            requiredCapabilities: [profile.providerCapability],
            requiresLocal: gear != .G5_OVERDRIVE,
            requiresLowLatency: gear == .G0_MECHANICAL || gear == .G1_ECO,
            requiresHighQuality: gear == .G3_TORQUE || gear == .G4_REVIEW,
            minContextWindow: profile.contextLimit
        )
        let selection = await selectProvider(for: requirements)
        let locks = locksForGear(gear, writeRequired: writeRequired, pathOverlap: pathOverlap)

        let decision = TransmissionDecision(
            selectedGear: gear,
            selectedProviderID: selection?.providerID ?? "none",
            selectedModelID: selection?.modelID ?? "default",
            selectedWorkerID: workerForGear(gear),
            selectedTimeout: profile.timeout,
            selectedFallback: profile.fallbackGear,
            lockRequirements: locks,
            reason: decisionReason(gear: gear, providerID: selection?.providerID, taskLabel: taskLabel)
        )

        SUPRARuntimeEvents.shared.emit(.gearSelected,
            "Gear \(gear.rawValue) selected for '\(taskLabel)' → provider \(selection?.providerID ?? "none")",
            source: "SUPRARoutingPolicy",
            metadata: ["gear": gear.rawValue, "provider": selection?.providerID ?? "none",
                       "reason": decision.reason])

        return decision
    }

    private func classifyGear(taskLabel: String, writeRequired: Bool,
                               complexity: Int, risk: Double,
                               pathOverlap: Bool, cpuPressure: Double,
                               memoryPressure: Double, diskPressure: Double,
                               contextRequired: Int) -> PowerGear {
        let lower = taskLabel.lowercased()

        if lower.contains("build") || lower.contains("compile") || lower.contains("test:"),
           !writeRequired, complexity <= 1, risk < 0.3 {
            return .G0_MECHANICAL
        }

        if complexity <= 1, !writeRequired, !pathOverlap,
           cpuPressure < 0.6, memoryPressure < 0.6,
           !lower.contains("discover"), !lower.contains("search"), !lower.contains("find"),
           !lower.contains("list"), !lower.contains("explore") {
            return .G5_OVERDRIVE
        }

        if lower.contains("review") || lower.contains("audit") || lower.contains("verify")
            || lower.contains("validate"), !writeRequired {
            return .G4_REVIEW
        }

        if complexity >= 3 || risk >= 0.5 || pathOverlap {
            return .G3_TORQUE
        }

        if writeRequired {
            if risk < 0.5, complexity <= 2, !pathOverlap { return .G2_STANDARD }
            return .G3_TORQUE
        }

        if lower.contains("discover") || lower.contains("search") || lower.contains("read")
            || lower.contains("find") || lower.contains("list") || lower.contains("explore"),
           complexity <= 2 {
            return .G1_ECO
        }

        if cpuPressure > 0.8 || memoryPressure > 0.8 || diskPressure > 0.8 {
            return .G1_ECO
        }

        return .G2_STANDARD
    }

    func profileForGear(_ gear: PowerGear) -> PowerProfile {
        switch gear {
        case .G0_MECHANICAL:
            return PowerProfile(gear: .G0_MECHANICAL, providerCapability: "reasoning",
                                contextLimit: 2048, maxParallelTasks: 1,
                                writePermission: false, allowedTools: ["build", "test"],
                                timeout: 120, retryLimit: 0, fallbackGear: nil,
                                memoryBudget: 0.3, cpuBudget: 0.5)
        case .G1_ECO:
            return PowerProfile(gear: .G1_ECO, providerCapability: "search",
                                contextLimit: 4096, maxParallelTasks: 3,
                                writePermission: false, allowedTools: ["read", "search"],
                                timeout: 30, retryLimit: 1, fallbackGear: nil,
                                memoryBudget: 0.3, cpuBudget: 0.2)
        case .G2_STANDARD:
            return PowerProfile(gear: .G2_STANDARD, providerCapability: "reasoning",
                                contextLimit: 8192, maxParallelTasks: 1,
                                writePermission: true, allowedTools: ["read", "search", "write"],
                                timeout: 60, retryLimit: 2, fallbackGear: .G1_ECO,
                                memoryBudget: 0.5, cpuBudget: 0.4)
        case .G3_TORQUE:
            return PowerProfile(gear: .G3_TORQUE, providerCapability: "coding",
                                contextLimit: 16384, maxParallelTasks: 1,
                                writePermission: true, allowedTools: ["read", "search", "write", "refactor"],
                                timeout: 180, retryLimit: 3, fallbackGear: .G2_STANDARD,
                                memoryBudget: 0.7, cpuBudget: 0.7)
        case .G4_REVIEW:
            return PowerProfile(gear: .G4_REVIEW, providerCapability: "analysis",
                                contextLimit: 16384, maxParallelTasks: 1,
                                writePermission: false, allowedTools: ["read", "search", "compare"],
                                timeout: 120, retryLimit: 2, fallbackGear: .G2_STANDARD,
                                memoryBudget: 0.6, cpuBudget: 0.5)
        case .G5_OVERDRIVE:
            return PowerProfile(gear: .G5_OVERDRIVE, providerCapability: "reasoning",
                                contextLimit: 32768, maxParallelTasks: 5,
                                writePermission: false, allowedTools: ["read", "search"],
                                timeout: 60, retryLimit: 1, fallbackGear: .G2_STANDARD,
                                memoryBudget: 0.8, cpuBudget: 0.8)
        }
    }

    private func locksForGear(_ gear: PowerGear, writeRequired: Bool,
                               pathOverlap: Bool) -> [TransmissionLockType] {
        var locks: [TransmissionLockType] = []
        if writeRequired || gear == .G3_TORQUE {
            locks.append(.developWriter)
        }
        if writeRequired && pathOverlap {
            locks.append(.fileScope)
        }
        if gear == .G0_MECHANICAL {
            locks.append(.xcodebuild)
            locks.append(.derivedData)
        }
        if gear == .G3_TORQUE {
            locks.append(.commit)
        }
        if gear == .G5_OVERDRIVE {
            locks.append(.modelMemory)
        }
        return locks
    }

    private func workerForGear(_ gear: PowerGear) -> String {
        switch gear {
        case .G0_MECHANICAL: return "runtime_worker"
        case .G1_ECO: return "memory_worker"
        case .G2_STANDARD: return "business_worker"
        case .G3_TORQUE: return "optimization_worker"
        case .G4_REVIEW: return "memory_worker"
        case .G5_OVERDRIVE: return "runtime_worker"
        }
    }

    private func decisionReason(gear: PowerGear, providerID: String?, taskLabel: String) -> String {
        var parts: [String] = ["Gear \(gear.rawValue)"]
        if let pid = providerID { parts.append("provider=\(pid)") }
        parts.append("task='\(taskLabel)'")
        return parts.joined(separator: ", ")
    }

    public func selectProvider(for requirements: SUPRARoutingRequirements) async -> SUPRAProviderSelection? {
        var candidates: [(SUPRAProviderPlugin, SUPRAProviderModelDeclaration, Double)] = []

        for (_, plugin) in providerPluginProviderPlugins {
            let decl = plugin.declaration
            guard matchesCapabilities(decl: decl, requirements: requirements) else { continue }
            guard decl.contextWindow >= requirements.minContextWindow else { continue }
            guard decl.costPer1KTokens <= requirements.maxCostPer1KTokens else { continue }
            if requirements.requiresLocal && !decl.isLocal { continue }
            if requirements.requiresOffline && !decl.isLocal { continue }
            if requirements.requiresConfidentiality && !decl.isLocal { continue }

            for model in plugin.models {
                guard matchesModelCapabilities(model: model, requirements: requirements) else { continue }
                guard model.contextWindow >= requirements.minContextWindow else { continue }

                let score = await calculateScore(plugin: plugin, model: model, requirements: requirements)
                candidates.append((plugin, model, score))
            }
        }

        guard !candidates.isEmpty else { return nil }

        candidates.sort { $0.2 > $1.2 }

        if let best = candidates.first {
            let selection = SUPRAProviderSelection(
                providerID: best.0.pluginID,
                modelID: best.1.modelID,
                score: best.2,
                reasons: scoringReasons(plugin: best.0, model: best.1, score: best.2, requirements: requirements),
                estimatedCost: best.1.costPer1KTokens,
                estimatedLatencyMs: 1000 / max(best.1.speed, 1),
                isLocal: best.1.isLocal
            )
            lastSelection = selection
            routingCount += 1
            return selection
        }

        return nil
    }

    private var providerPluginProviderPlugins: [(String, SUPRAProviderPlugin)] {
        providerPluginRegistry.providerPlugins.map { ($0, $1) }
    }

    private func matchesCapabilities(decl: SUPRAProviderPluginDeclaration,
                                      requirements: SUPRARoutingRequirements) -> Bool {
        for cap in requirements.requiredCapabilities {
            guard decl.capabilities.contains(cap) else { return false }
        }
        if requirements.requiredCapabilities.contains("vision") && !decl.supportsVision { return false }
        if requirements.requiresOffline && !decl.isLocal { return false }
        return true
    }

    private func matchesModelCapabilities(model: SUPRAProviderModelDeclaration,
                                           requirements: SUPRARoutingRequirements) -> Bool {
        for cap in requirements.requiredCapabilities {
            guard model.capabilities.contains(cap) else { return false }
        }
        if requirements.requiredCapabilities.contains("vision") && !model.supportsVision { return false }
        return true
    }

    private func calculateScore(plugin: SUPRAProviderPlugin, model: SUPRAProviderModelDeclaration,
                                 requirements: SUPRARoutingRequirements) async -> Double {
        var score = 50.0

        if model.isLocal && preferLocal { score += 20 }
        if !model.isLocal && !preferLocal { score += 10 }

        let health = await plugin.healthCheck()
        if health { score += 15 }

        if model.speed > 70 { score += 10 }
        else if model.speed > 40 { score += 5 }

        if model.costPer1KTokens == 0 { score += 10 }
        else if model.costPer1KTokens < 0.01 { score += 5 }

        if model.contextWindow >= 32000 { score += 10 }
        else if model.contextWindow >= 16000 { score += 5 }

        if requirements.requiresLowLatency && model.speed > 60 { score += 10 }
        if requirements.requiresHighQuality && model.speed < 50 { score += 5 }
        if requirements.requiresConfidentiality && model.isLocal { score += 15 }

        let historyScore = await learningEngine.scoreForProvider(plugin.pluginID, modelID: model.modelID)
        score += historyScore

        score += Double(plugin.declaration.priority)

        return score
    }

    private func scoringReasons(plugin: SUPRAProviderPlugin, model: SUPRAProviderModelDeclaration,
                                 score: Double, requirements: SUPRARoutingRequirements) -> [String] {
        var reasons: [String] = []
        reasons.append("Score: \(String(format: "%.1f", score))")
        if model.isLocal { reasons.append("Local provider") }
        reasons.append("Speed: \(model.speed), Cost: \(model.costPer1KTokens)")
        reasons.append("Context: \(model.contextWindow)")
        return reasons
    }
}
