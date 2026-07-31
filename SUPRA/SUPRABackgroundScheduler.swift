import Foundation
import Combine
import CoreGraphics

struct BackgroundTask {
    let id: String
    let label: String
    let interval: TimeInterval
    let action: () async -> Void
    var lastRun: Date?
    var isRunning = false
    var consecutiveFailures = 0

    var canRun: Bool {
        guard !isRunning else { return false }
        guard let last = lastRun else { return true }
        return Date().timeIntervalSince(last) >= interval
    }
}

@MainActor
final class SUPRABackgroundScheduler: ObservableObject {
    static let shared = SUPRABackgroundScheduler()

    @Published private(set) var isRunning = false
    @Published private(set) var activeTaskCount = 0
    @Published private(set) var userIsActive = false
    @Published private(set) var cpuBudgetUsed: Double = 0
    @Published private(set) var lastTick: Date?
    @Published private(set) var registeredTaskCount = 0

    private let governor = SUPRAResourceGovernor.shared
    private var tasks: [String: BackgroundTask] = [:]
    private var timer: Timer?
    private var userActivityTimer: Timer?
    private let maxCPUBudget: Double = 0.05
    private var budgetResetDate: Date = Date()
    private let eventQueue = DispatchQueue(label: "supra.bg", qos: .utility)

    private init() {}

    func start() {
        guard !isRunning else { return }
        isRunning = true
        monitorUserActivity()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.tick()
            }
        }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        userActivityTimer?.invalidate()
        userActivityTimer = nil
    }

    func register(id: String, label: String, interval: TimeInterval = 120, action: @escaping () async -> Void) {
        tasks[id] = BackgroundTask(id: id, label: label, interval: interval, action: action)
        registeredTaskCount = tasks.count
    }

    func unregister(id: String) {
        tasks.removeValue(forKey: id)
        registeredTaskCount = tasks.count
    }

    func requestRun(id: String) {
        guard var task = tasks[id], task.canRun else { return }
        guard canProceed() else { return }

        task.isRunning = true
        tasks[id] = task
        activeTaskCount += 1

        Task {
            let startCPU = governor.cpuUsage
            await task.action()
            let elapsedCPU = max(0, governor.cpuUsage - startCPU)
            await MainActor.run {
                var t = self.tasks[id]
                t?.isRunning = false
                t?.lastRun = Date()
                if elapsedCPU > 0.05 { t?.consecutiveFailures += 1 }
                else { t?.consecutiveFailures = 0 }
                self.tasks[id] = t
                self.activeTaskCount -= 1
                self.cpuBudgetUsed += elapsedCPU
            }
        }
    }

    func trigger(event: String) {
        guard isRunning else { return }
        for (id, task) in tasks where task.canRun {
            if canProceed() {
                requestRun(id: id)
            }
        }
        lastTick = Date()
    }

    private func tick() {
        guard isRunning else { return }
        resetBudgetIfNeeded()

        if userIsActive {
            return
        }

        for (id, task) in tasks where task.canRun {
            guard canProceed() else { break }
            requestRun(id: id)
        }

        lastTick = Date()
    }

    private func canProceed() -> Bool {
        guard !governor.isCritical else { return false }
        guard !governor.isHighLoad else { return false }
        guard cpuBudgetUsed < maxCPUBudget else { return false }
        guard !userIsActive else { return false }
        return true
    }

    private func resetBudgetIfNeeded() {
        if Date().timeIntervalSince(budgetResetDate) >= 60 {
            cpuBudgetUsed = 0
            budgetResetDate = Date()
        }
    }

    private func monitorUserActivity() {
        userActivityTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.checkUserActivity()
            }
        }
    }

    private func checkUserActivity() {
        let idleTime = CGEventSource.secondsSinceLastEventType(
            .combinedSessionState,
            eventType: CGEventType(rawValue: ~0)!
        )
        userIsActive = idleTime < 60
    }

    var summary: String {
        """
        Background Scheduler: \(activeTaskCount) actifs, \(tasks.count) enregistrés
        Utilisateur: \(userIsActive ? "actif" : "inactif")
        Budget CPU: \(Int(cpuBudgetUsed * 100))% / \(Int(maxCPUBudget * 100))%
        Dernier tick: \(lastTick?.formatted(date: .omitted, time: .standard) ?? "—")
        """
    }
}
