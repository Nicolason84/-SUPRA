import Foundation
import Combine

@MainActor
public final class SUPRAFallbackEngine: ObservableObject {
    public static let shared = SUPRAFallbackEngine()

    @Published public private(set) var fallbackCount = 0
    @Published public private(set) var lastFallbackChain: [String] = []

    private let providerPluginRegistry = SUPRAProviderPluginRegistry.shared
    private let learningEngine = SUPRALearningEngine.shared

    private init() {}

    public func executeWithFallback(prompt: String, systemPrompt: String,
                                     requiredCapabilities: [String],
                                     preferredProviderID: String? = nil,
                                     preferredModelID: String? = nil,
                                     maxTokens: Int = 2048,
                                     temperature: Double = 0.7) async throws -> String {
        let startTime = Date()
        var errors: [String] = []
        var attemptedProviders: [String] = []

        if let providerID = preferredProviderID,
           let plugin = providerPluginRegistry.plugin(providerID) {
            do {
                let result = try await plugin.execute(
                    prompt: prompt, systemPrompt: systemPrompt,
                    modelID: preferredModelID ?? plugin.models.first?.modelID ?? "default",
                    maxTokens: maxTokens, temperature: temperature
                )
                await recordSuccess(providerID: providerID, duration: Date().timeIntervalSince(startTime))
                lastFallbackChain = [providerID]
                return result
            } catch {
                errors.append("\(providerID): \(error.localizedDescription)")
                attemptedProviders.append(providerID)
            }
        }

        let providerCandidates = providerPluginRegistry.providerPlugins.values
            .filter { !attemptedProviders.contains($0.pluginID) }
            .sorted { $0.declaration.priority < $1.declaration.priority }

        for plugin in providerCandidates {
            guard !attemptedProviders.contains(plugin.pluginID) else { continue }
            guard plugin.declaration.capabilities.contains(where: { requiredCapabilities.contains($0) })
            else { continue }

            for model in plugin.models {
                do {
                    let result = try await plugin.execute(
                        prompt: prompt, systemPrompt: systemPrompt,
                        modelID: model.modelID,
                        maxTokens: maxTokens, temperature: temperature
                    )
                    fallbackCount += 1
                    lastFallbackChain = attemptedProviders + [plugin.pluginID]
                    await recordSuccess(providerID: plugin.pluginID, duration: Date().timeIntervalSince(startTime))
                    return result
                } catch {
                    errors.append("\(plugin.pluginID)/\(model.modelID): \(error.localizedDescription)")
                }
            }
            attemptedProviders.append(plugin.pluginID)
        }

        lastFallbackChain = attemptedProviders
        await recordFailure(errors: errors)
        throw SUPRAProviderError.allProvidersFailed
    }

    private func recordSuccess(providerID: String, duration: TimeInterval) async {
        await learningEngine.recordExecution(
            providerID: providerID,
            success: true,
            durationMs: Int(duration * 1000),
            tokensUsed: 0
        )
    }

    private func recordFailure(errors: [String]) async {
        for error in errors {
            let parts = error.split(separator: ":", maxSplits: 1)
            if let providerID = parts.first.map(String.init) {
                await learningEngine.recordExecution(
                    providerID: providerID,
                    success: false,
                    durationMs: 0,
                    tokensUsed: 0
                )
            }
        }
    }

    public func executeWithBoundedFallback(prompt: String, systemPrompt: String,
                                            requiredCapabilities: [String],
                                            providerID: String, modelID: String,
                                            maxTokens: Int = 2048,
                                            temperature: Double = 0.7,
                                            timeout: Int = 60,
                                            maxRetries: Int = 2,
                                            gear: PowerGear = .G2_STANDARD) async throws -> String {
        let events = SUPRARuntimeEvents.shared

        events.emit(.executionStarted,
                    "Bounded execution via \(providerID)/\(modelID) [\(gear.rawValue)]",
                    source: "SUPRAFallbackEngine")

        var lastError: Error?
        var attempt = 0

        while attempt <= maxRetries {
            attempt += 1
            do {
                guard let plugin = providerPluginRegistry.plugin(providerID) else {
                    throw SUPRAProviderError.providerNotRegistered(.fallback)
                }
                let result = try await withThrowingTaskGroup(of: String.self) { group in
                    group.addTask {
                        try await plugin.execute(
                            prompt: prompt, systemPrompt: systemPrompt,
                            modelID: modelID, maxTokens: maxTokens,
                            temperature: temperature
                        )
                    }
                    group.addTask {
                        try await Task.sleep(nanoseconds: UInt64(timeout) * 1_000_000_000)
                        throw SUPRAProviderError.timeout(.fallback)
                    }
                    let result = try await group.next()!
                    group.cancelAll()
                    return result
                }
                fallbackCount = max(0, fallbackCount - 1)
                events.emit(.executionCompleted,
                            "Bounded execution succeeded on attempt \(attempt)",
                            source: "SUPRAFallbackEngine")
                return result
            } catch {
                lastError = error
                events.emit(.fallbackTriggered,
                            "Attempt \(attempt)/\(maxRetries) failed: \(error.localizedDescription)",
                            source: "SUPRAFallbackEngine",
                            metadata: ["attempt": "\(attempt)", "gear": gear.rawValue])

                if attempt <= maxRetries {
                    let delay = UInt64(min(attempt, 5)) * 500_000_000
                    try? await Task.sleep(nanoseconds: delay)
                }
            }
        }

        fallbackCount += 1
        lastFallbackChain = providerID.isEmpty ? [] : [providerID]

        events.emit(.executionFailed,
                    "Bounded execution exhausted after \(maxRetries) retries",
                    source: "SUPRAFallbackEngine")

        throw lastError ?? SUPRAProviderError.allProvidersFailed
    }

    public func downshift(from currentGear: PowerGear, reason: String) -> PowerGear {
        let events = SUPRARuntimeEvents.shared
        let downshifted: PowerGear

        switch currentGear {
        case .G5_OVERDRIVE: downshifted = .G3_TORQUE
        case .G4_REVIEW: downshifted = .G2_STANDARD
        case .G3_TORQUE: downshifted = .G2_STANDARD
        case .G2_STANDARD: downshifted = .G1_ECO
        case .G1_ECO: downshifted = .G0_MECHANICAL
        case .G0_MECHANICAL: downshifted = .G0_MECHANICAL
        }

        events.emit(.gearShifted,
                    "Downshift \(currentGear.rawValue) → \(downshifted.rawValue): \(reason)",
                    source: "SUPRAFallbackEngine",
                    metadata: ["from": currentGear.rawValue, "to": downshifted.rawValue, "reason": reason])

        return downshifted
    }

    public func upshift(from currentGear: PowerGear, reason: String) -> PowerGear {
        let events = SUPRARuntimeEvents.shared
        let upshifted: PowerGear

        switch currentGear {
        case .G0_MECHANICAL: upshifted = .G1_ECO
        case .G1_ECO: upshifted = .G2_STANDARD
        case .G2_STANDARD: upshifted = .G3_TORQUE
        case .G3_TORQUE: upshifted = .G4_REVIEW
        case .G4_REVIEW: upshifted = .G5_OVERDRIVE
        case .G5_OVERDRIVE: upshifted = .G5_OVERDRIVE
        }

        events.emit(.gearShifted,
                    "Upshift \(currentGear.rawValue) → \(upshifted.rawValue): \(reason)",
                    source: "SUPRAFallbackEngine",
                    metadata: ["from": currentGear.rawValue, "to": upshifted.rawValue, "reason": reason])

        return upshifted
    }

    public func reduceContext(for gear: PowerGear) -> Int {
        switch gear {
        case .G0_MECHANICAL: return 1024
        case .G1_ECO: return 2048
        case .G2_STANDARD: return 4096
        case .G3_TORQUE: return 8192
        case .G4_REVIEW: return 8192
        case .G5_OVERDRIVE: return 16384
        }
    }

    public func releaseLocks(for holder: String) {
        SUPRATransmissionLocks.shared.releaseAll(by: holder)
    }

    public func shouldDownshift(cpuPressure: Double, memoryPressure: Double,
                                 diskPressure: Double, providerDegraded: Bool,
                                 timeoutNear: Bool) -> Bool {
        if cpuPressure > 0.8 || memoryPressure > 0.8 { return true }
        if diskPressure > 0.9 { return true }
        if providerDegraded || timeoutNear { return true }
        return false
    }

    public func shouldUpshift(queueDepth: Int, resourcesAvailable: Bool,
                               tasksIndependent: Bool, providerHealthy: Bool) -> Bool {
        guard resourcesAvailable && providerHealthy else { return false }
        if queueDepth > 5 && tasksIndependent { return true }
        return false
    }
}
