import Foundation
import Combine

enum ScanMode: String, Codable {
    case quick
    case standard
    case deep
}

struct EnvironmentSnapshotProgress {
    let status: String
    let phase: String
    let progress: Double
    let startedAt: Date
    let completedAt: Date?
    let changedDomains: [String]
    let errors: [String]
    let warnings: [String]
    let cacheHitCount: Int
    let cacheMissCount: Int
    let domainFreshness: [String: Date]
}

@MainActor
final class SUPRAEnvironmentSnapshotStore: ObservableObject {
    static let shared = SUPRAEnvironmentSnapshotStore()

    @Published private(set) var status: String = "idle"
    @Published private(set) var phase: String = "—"
    @Published private(set) var progress: Double = 0
    @Published private(set) var startedAt: Date?
    @Published private(set) var completedAt: Date?
    @Published private(set) var isRunning = false
    @Published private(set) var errors: [String] = []
    @Published private(set) var warnings: [String] = []
    @Published private(set) var changedDomains: [String] = []
    @Published private(set) var cacheHitCount = 0
    @Published private(set) var cacheMissCount = 0

    private let envModel = SUPRAEnvironmentWorldModel.shared
    private let hardwareTwin = SUPRAHardwareTwin.shared
    private let softwareTwin = SUPRASoftwareTwin.shared
    private let dataTwin = SUPRADataTwin.shared
    private let developerTwin = SUPRADeveloperTwin.shared
    private let copilot = SUPRAOptimizationCopilot.shared
    private let governor = SUPRAResourceGovernor.shared

    private var activeTask: Task<Void, Never>?
    private var domainHashes: [String: Int] = [:]
    private var domainTimestamps: [String: Date] = [:]

    private init() {}

    func quickRefresh() {
        guard !isRunning else { return }
        guard canRun() else { return }
        activeTask = Task { await run(.quick) }
    }

    func standardRefresh() {
        guard !isRunning else { return }
        guard canRun() else { return }
        activeTask = Task { await run(.standard) }
    }

    func deepRefresh() {
        guard !isRunning else { return }
        activeTask = Task { await run(.deep) }
    }

    func pause() {
        activeTask?.cancel()
        isRunning = false
        status = "paused"
    }

    func resume() {
        guard status == "paused" else { return }
        status = "resuming"
        activeTask = Task { await run(.standard) }
    }

    func cancel() {
        activeTask?.cancel()
        activeTask = nil
        isRunning = false
        status = "cancelled"
        phase = "—"
        progress = 0
    }

    private func canRun() -> Bool {
        let s = governor.snapshot
        if s.isCritical || s.throttleLevel < .reduced {
            warnings.append("System load too high — deferring (throttle: \(s.throttleLevel.rawValue))")
            return false
        }
        return true
    }

    private func run(_ mode: ScanMode) async {
        isRunning = true
        status = "running"
        startedAt = Date()
        completedAt = nil
        errors = []
        warnings = []
        changedDomains = []
        phase = "initializing"
        progress = 0

        let totalSteps: Double
        switch mode {
        case .quick: totalSteps = 3
        case .standard: totalSteps = 6
        case .deep: totalSteps = 8
        }

        await trackPhase("Hardware", step: 1, total: totalSteps) {
            hardwareTwin.refresh()
            let hash = hardwareTwin.snapshot.hashValue
            if domainHashes["hardware"] != hash {
                changedDomains.append("hardware")
                cacheMissCount += 1
                domainHashes["hardware"] = hash
                domainTimestamps["hardware"] = Date()
            } else {
                cacheHitCount += 1
            }
        }

        if mode == .standard || mode == .deep {
            await trackPhase("Software", step: 2, total: totalSteps) {
                softwareTwin.refresh()
                cacheMissCount += 1
                changedDomains.append("software")
                domainTimestamps["software"] = Date()
            }
        } else {
            cacheHitCount += 1
        }

        if mode == .standard || mode == .deep {
            await trackPhase("Data", step: 3, total: totalSteps) {
                dataTwin.refresh()
                cacheMissCount += 1
                changedDomains.append("data")
                domainTimestamps["data"] = Date()
            }
        } else {
            cacheHitCount += 1
        }

        if mode == .deep {
            await trackPhase("Developer", step: 4, total: totalSteps) {
                developerTwin.refresh()
                cacheMissCount += 1
                changedDomains.append("developer")
                domainTimestamps["developer"] = Date()
            }
        } else {
            cacheHitCount += 1
        }

        await trackPhase("World Model", step: mode == .deep ? 5 : 4, total: totalSteps) {
            envModel.refresh()
            changedDomains.append("world")
            domainTimestamps["world"] = Date()
        }

        await trackPhase("Optimization", step: mode == .deep ? 6 : 5, total: totalSteps) {
            copilot.analyze()
            changedDomains.append("optimization")
            domainTimestamps["optimization"] = Date()
        }

        if mode == .deep {
            await trackPhase("Verification", step: 7, total: totalSteps) {
                verifySources()
            }
        }

        await trackPhase("Finalizing", step: mode == .deep ? 8 : 6, total: totalSteps) {
            complete()
        }
    }

    private func trackPhase(_ name: String, step: Double, total: Double, action: () -> Void) async {
        guard !Task.isCancelled else { return }
        phase = name
        action()
        progress = step / total
        try? await Task.sleep(nanoseconds: 50_000_000)
    }

    private func verifySources() {
        let resolver = SUPRAEnvironmentResolver.shared
        for source in resolver.sources {
            if source.state != .resolved {
                warnings.append("Source \(source.label): \(source.state.rawValue)")
            }
        }
    }

    private func complete() {
        completedAt = Date()
        isRunning = false
        status = errors.isEmpty ? "complete" : "complete_with_errors"
        phase = "done"
        progress = 1.0
    }
}
