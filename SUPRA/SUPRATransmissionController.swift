import Foundation
import Combine

@MainActor
public final class SUPRATransmissionController: ObservableObject {
    public static let shared = SUPRATransmissionController()

    @Published public private(set) var currentGear: PowerGear = .G1_ECO
    @Published public private(set) var currentDecision: TransmissionDecision?
    @Published public private(set) var isTransmitting = false
    @Published public private(set) var gearShiftCount = 0
    @Published public private(set) var fallbackCount = 0
    @Published public private(set) var failedTaskCount = 0
    @Published public private(set) var lastTelemetry: TransmissionTelemetry?

    private let routingPolicy = SUPRARoutingPolicy.shared
    private let scheduler = SUPRAScheduler.shared
    private let fallbackEngine = SUPRAFallbackEngine.shared
    private let providerRegistry = SUPRAProviderRegistry.shared
    private let events = SUPRARuntimeEvents.shared
    private let locks = SUPRATransmissionLocks.shared
    private let metrics = SUPRARuntimeMetrics.shared
    private let workerFabric = SUPRAWorkerFabric.shared

    private init() {}

    public func transmit(taskLabel: String, prompt: String,
                          writeRequired: Bool = false,
                          complexity: Int = 1,
                          risk: Double = 0.0,
                          pathOverlap: Bool = false) async -> TransmissionResult {
        isTransmitting = true
        defer { isTransmitting = false }

        let cpuPressure = await readCPUPressure()
        let memoryPressure = await readMemoryPressure()
        let diskPressure = await readDiskPressure()
        let providerHealth = await readProviderHealth()

        events.emit(.transmissionRequested,
                    "Transmission for '\(taskLabel)' (complexity=\(complexity), write=\(writeRequired))",
                    source: "SUPRATransmissionController",
                    metadata: ["task": taskLabel, "complexity": "\(complexity)"])

        let decision = await routingPolicy.selectGear(
            for: taskLabel,
            writeRequired: writeRequired,
            complexity: complexity,
            risk: risk,
            pathOverlap: pathOverlap,
            cpuPressure: cpuPressure,
            memoryPressure: memoryPressure,
            diskPressure: diskPressure,
            providerHealth: providerHealth,
            contextRequired: 4096
        )

        currentDecision = decision
        currentGear = decision.selectedGear

        for lockType in decision.lockRequirements {
            let acquired = locks.acquire(lockType, holder: "transmission-\(taskLabel)")
            if !acquired {
                events.emit(.transmissionReleased,
                            "Lock \(lockType.rawValue) not available — task deferred",
                            source: "SUPRATransmissionController")
                return TransmissionResult(
                    success: false, gear: decision.selectedGear,
                    message: "Lock \(lockType.rawValue) not available",
                    decision: decision
                )
            }
            events.emit(.lockAcquired,
                        "Lock \(lockType.rawValue) acquired",
                        source: "SUPRATransmissionController",
                        metadata: ["lock": lockType.rawValue])
        }

        events.emit(.clutchEngaged,
                    "\(decision.selectedGear.rawValue) engaged: \(decision.selectedProviderID)/\(decision.selectedModelID)",
                    source: "SUPRATransmissionController",
                    metadata: ["gear": decision.selectedGear.rawValue,
                               "provider": decision.selectedProviderID])

        let workerID = decision.selectedWorkerID
        if let wid = workerID {
            events.emit(.workerDispatched,
                        "Worker '\(wid)' dispatched for '\(taskLabel)'",
                        source: "SUPRATransmissionController",
                        metadata: ["worker": wid, "gear": decision.selectedGear.rawValue])
        }

        let startTime = Date()
        var result: String?
        var errorMessage: String?
        var finalGear = decision.selectedGear

        if writeRequired || decision.selectedGear >= .G2_STANDARD {
            result = try? await fallbackEngine.executeWithBoundedFallback(
                prompt: prompt,
                systemPrompt: "",
                requiredCapabilities: [decision.selectedGear.rawValue],
                providerID: decision.selectedProviderID,
                modelID: decision.selectedModelID,
                timeout: decision.selectedTimeout,
                maxRetries: decision.selectedGear == .G3_TORQUE ? 3 : 2,
                gear: decision.selectedGear
            )
        } else {
            result = try? await fallbackEngine.executeWithBoundedFallback(
                prompt: prompt,
                systemPrompt: "",
                requiredCapabilities: [decision.selectedGear.rawValue],
                providerID: decision.selectedProviderID,
                modelID: decision.selectedModelID,
                timeout: decision.selectedTimeout,
                maxRetries: 1,
                gear: decision.selectedGear
            )
        }

        if result == nil {
            failedTaskCount += 1
            errorMessage = "Execution failed in \(decision.selectedGear.rawValue)"

            if let fallback = decision.selectedFallback {
                events.emit(.fallbackSelected,
                            "Falling back to \(fallback.rawValue)",
                            source: "SUPRATransmissionController",
                            metadata: ["from": decision.selectedGear.rawValue,
                                       "to": fallback.rawValue])
                fallbackCount += 1

                let fallbackProfile = routingPolicy.profileForGear(fallback)
                result = try? await fallbackEngine.executeWithBoundedFallback(
                    prompt: prompt,
                    systemPrompt: "",
                    requiredCapabilities: [fallback.rawValue],
                    providerID: decision.selectedProviderID,
                    modelID: decision.selectedModelID,
                    timeout: fallbackProfile.timeout,
                    maxRetries: 1,
                    gear: fallback
                )
                finalGear = fallback

                if result != nil {
                    errorMessage = nil
                    events.emit(.gearShifted,
                                "Fallback \(decision.selectedGear.rawValue) → \(fallback.rawValue) succeeded",
                                source: "SUPRATransmissionController",
                                metadata: ["from": decision.selectedGear.rawValue,
                                           "to": fallback.rawValue])
                }
            }
        }

        let duration = Int(Date().timeIntervalSince(startTime) * 1000)

        if result != nil {
            gearShiftCount += decision.selectedGear != currentGear ? 1 : 0
            events.emit(.workerCompleted,
                        "Task '\(taskLabel)' completed in \(duration)ms via \(finalGear.rawValue)",
                        source: "SUPRATransmissionController",
                        metadata: ["gear": finalGear.rawValue, "duration": "\(duration)"])
        } else {
            events.emit(.workerFailed,
                        "Task '\(taskLabel)' failed after \(duration)ms",
                        source: "SUPRATransmissionController",
                        metadata: ["gear": finalGear.rawValue, "duration": "\(duration)"])
        }

        for lockType in decision.lockRequirements.reversed() {
            locks.release(lockType)
        }
        events.emit(.transmissionReleased,
                    "Transmission released after \(duration)ms",
                    source: "SUPRATransmissionController",
                    metadata: ["duration": "\(duration)"])

        let telemetry = TransmissionTelemetry(
            currentGear: finalGear,
            currentProviderID: decision.selectedProviderID,
            currentWorkerID: decision.selectedWorkerID,
            queueDepth: scheduler.scheduledCount,
            writerLockState: locks.developWriterLock ? "locked" : "free",
            buildLockState: locks.xcodebuildLocks.values.contains(true) ? "locked" : "free",
            cpuPressure: cpuPressure,
            memoryPressure: memoryPressure,
            diskPressure: diskPressure,
            contextUsage: 4096,
            contextLimit: decision.selectedGear == .G5_OVERDRIVE ? 32768 : 8192,
            taskDurationMs: duration,
            gearShiftCount: gearShiftCount,
            fallbackCount: fallbackCount,
            failedTaskCount: failedTaskCount
        )
        lastTelemetry = telemetry
        metrics.recordTelemetry(telemetry)

        currentGear = finalGear

        return TransmissionResult(
            success: result != nil,
            gear: finalGear,
            message: result ?? errorMessage ?? "Unknown failure",
            decision: decision,
            telemetry: telemetry
        )
    }

    public func downshift(reason: String) -> PowerGear {
        let newGear = fallbackEngine.downshift(from: currentGear, reason: reason)
        currentGear = newGear
        gearShiftCount += 1
        return newGear
    }

    public func upshift(reason: String) -> PowerGear {
        let newGear = fallbackEngine.upshift(from: currentGear, reason: reason)
        currentGear = newGear
        gearShiftCount += 1
        return newGear
    }

    public func snapshot() -> TransmissionTelemetry? {
        lastTelemetry
    }

    private func readCPUPressure() async -> Double {
        0.3
    }

    private func readMemoryPressure() async -> Double {
        0.4
    }

    private func readDiskPressure() async -> Double {
        0.2
    }

    private func readProviderHealth() async -> Double {
        let healths = await providerRegistry.healthCheck()
        let healthy = healths.values.filter { $0 }.count
        guard !healths.isEmpty else { return 0.0 }
        return Double(healthy) / Double(healths.count)
    }
}

public struct TransmissionResult: Sendable {
    public let success: Bool
    public let gear: PowerGear
    public let message: String
    public let decision: TransmissionDecision?
    public let telemetry: TransmissionTelemetry?

    public init(success: Bool, gear: PowerGear, message: String,
                decision: TransmissionDecision? = nil,
                telemetry: TransmissionTelemetry? = nil) {
        self.success = success
        self.gear = gear
        self.message = message
        self.decision = decision
        self.telemetry = telemetry
    }
}
