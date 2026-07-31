import Foundation
import Combine

public struct SUPRAExecutionSlot: Identifiable, Sendable {
    public let id: UUID
    public let task: SUPRAExecutionTask
    public let providerID: String
    public let modelID: String
    public let status: SlotStatus
    public let startedAt: Date?
    public let completedAt: Date?

    public enum SlotStatus: String, Sendable {
        case pending
        case running
        case completed
        case failed
        case skipped
    }

    public init(id: UUID = UUID(), task: SUPRAExecutionTask, providerID: String,
                modelID: String, status: SlotStatus = .pending,
                startedAt: Date? = nil, completedAt: Date? = nil) {
        self.id = id
        self.task = task
        self.providerID = providerID
        self.modelID = modelID
        self.status = status
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}

@MainActor
public final class SUPRAScheduler: ObservableObject {
    public static let shared = SUPRAScheduler()

    @Published public private(set) var slots: [SUPRAExecutionSlot] = []
    @Published public private(set) var isScheduling = false
    @Published public private(set) var scheduledCount = 0
    @Published public private(set) var isPaused = false
    @Published public private(set) var activeTaskCount = 0
    @Published public private(set) var pendingTasks: [String] = []

    private let providerPluginRegistry = SUPRAProviderPluginRegistry.shared
    private let routingPolicy = SUPRARoutingPolicy.shared
    private let learningEngine = SUPRALearningEngine.shared

    private init() {}

    public func schedule(plan: SUPRAOrchestrationPlan,
                          requirements: SUPRARoutingRequirements) async -> [SUPRAExecutionSlot] {
        isScheduling = true
        defer { isScheduling = false }

        var slots: [SUPRAExecutionSlot] = []
        let orderedTasks = SUPRAExecutionPlanner.shared.executionOrder(for: plan)

        for task in orderedTasks {
            guard let selection = await routingPolicy.selectProvider(for: requirements) else {
                let slot = SUPRAExecutionSlot(task: task, providerID: "none", modelID: "none", status: .skipped)
                slots.append(slot)
                continue
            }

            let slot = SUPRAExecutionSlot(
                task: task,
                providerID: selection.providerID,
                modelID: selection.modelID,
                status: .pending
            )
            slots.append(slot)
        }

        self.slots = slots
        scheduledCount += slots.count
        return slots
    }

    public func executeSlot(_ slot: SUPRAExecutionSlot) async throws -> String {
        guard let plugin = providerPluginRegistry.plugin(slot.providerID) else {
            throw NSError(domain: "SUPRA", code: 404,
                         userInfo: [NSLocalizedDescriptionKey: "Plugin not registered: \(slot.providerID)"])
        }

        let result = try await plugin.execute(
            prompt: slot.task.prompt,
            systemPrompt: slot.task.systemPrompt,
            modelID: slot.task.modelID ?? slot.modelID,
            maxTokens: slot.task.maxTokens,
            temperature: slot.task.temperature
        )

        await learningEngine.recordExecution(
            providerID: slot.providerID,
            success: true,
            durationMs: 0,
            tokensUsed: slot.task.maxTokens
        )

        return result
    }

    public func start() {}
    public func stop() {}

    public func register(id: String, priority: TaskPriority, label: String, cooldown: Int, task: @escaping () -> Void) {
        task()
    }

    public func scheduleWithTransmission(plan: SUPRAOrchestrationPlan,
                                          requirements: SUPRARoutingRequirements,
                                          decision: TransmissionDecision) async -> [SUPRAExecutionSlot] {
        let locks = SUPRATransmissionLocks.shared
        let events = SUPRARuntimeEvents.shared
        let holder = "scheduler-\(UUID().uuidString.prefix(8))"

        events.emit(.transmissionRequested,
                    "Transmission requested for \(plan.tasks.count) tasks",
                    source: "SUPRAScheduler",
                    metadata: ["gear": decision.selectedGear.rawValue, "tasks": "\(plan.tasks.count)"])

        for lockType in decision.lockRequirements {
            guard locks.acquire(lockType, holder: holder, scope: decision.selectedProviderID) else {
                events.emit(.transmissionReleased,
                            "Lock \(lockType.rawValue) denied — transmission aborted",
                            source: "SUPRAScheduler",
                            metadata: ["lock": lockType.rawValue])
                return []
            }
            events.emit(.lockAcquired,
                        "Lock \(lockType.rawValue) acquired by \(holder)",
                        source: "SUPRAScheduler",
                        metadata: ["lock": lockType.rawValue, "holder": holder])
        }

        events.emit(.clutchEngaged,
                    "Gear \(decision.selectedGear.rawValue) engaged for transmission",
                    source: "SUPRAScheduler",
                    metadata: ["gear": decision.selectedGear.rawValue])

        isScheduling = true
        defer {
            isScheduling = false
            for lockType in decision.lockRequirements.reversed() {
                locks.release(lockType, scope: decision.selectedProviderID)
            }
            events.emit(.transmissionReleased,
                        "Transmission released — \(decision.selectedGear.rawValue) disengaged",
                        source: "SUPRAScheduler")
        }

        var resultSlots: [SUPRAExecutionSlot] = []
        let orderedTasks = SUPRAExecutionPlanner.shared.executionOrder(for: plan)
        let profile = PowerProfile.default
        let maxParallel = min(profile.maxParallelTasks, orderedTasks.count)

        let taskGroups = stride(from: 0, to: orderedTasks.count, by: maxParallel).map {
            Array(orderedTasks[$0..<min($0 + maxParallel, orderedTasks.count)])
        }

        for group in taskGroups {
            var groupSlots: [SUPRAExecutionSlot] = []
            for task in group {
                let slot = SUPRAExecutionSlot(
                    task: task,
                    providerID: decision.selectedProviderID,
                    modelID: decision.selectedModelID,
                    status: .pending
                )
                groupSlots.append(slot)
            }

            let runningGroup = groupSlots.map { slot -> SUPRAExecutionSlot in
                let s = slot
                return SUPRAExecutionSlot(
                    id: s.id, task: s.task,
                    providerID: s.providerID, modelID: s.modelID,
                    status: .running, startedAt: Date()
                )
            }
            resultSlots.append(contentsOf: runningGroup)
        }

        self.slots = resultSlots
        scheduledCount += resultSlots.count
        return resultSlots
    }

    public func scheduleWithGear(plan: SUPRAOrchestrationPlan,
                                  requirements: SUPRARoutingRequirements,
                                  gear: PowerGear) async -> [SUPRAExecutionSlot] {
        let decision = await SUPRARoutingPolicy.shared.selectGear(
            for: plan.tasks.first?.prompt ?? "unknown",
            writeRequired: gear.rank >= 2,
            complexity: gear.rank > 2 ? 3 : 1
        )
        return await scheduleWithTransmission(plan: plan, requirements: requirements, decision: decision)
    }

    public func reserveWriterLock() -> Bool {
        SUPRATransmissionLocks.shared.acquire(.developWriter, holder: "scheduler")
    }

    public func reserveBuildLock(scope: String) -> Bool {
        SUPRATransmissionLocks.shared.acquire(.xcodebuild, holder: "scheduler", scope: scope)
    }

    public func limitReaders(max: Int) -> Bool {
        true
    }

    public func canSchedule(gear: PowerGear, cpuPressure: Double = 0.0,
                             memoryPressure: Double = 0.0) -> Bool {
        let profile = PowerProfile.default
        if cpuPressure > profile.cpuBudget { return false }
        if memoryPressure > profile.memoryBudget { return false }
        if gear >= .G3_TORQUE && SUPRATransmissionLocks.shared.developWriterLock { return false }
        return true
    }

    public func clear() {
        slots = []
        scheduledCount = 0
    }
}
