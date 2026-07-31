import Foundation
import Combine

@MainActor
final class SUPRAPassiveRefreshCoordinator: ObservableObject {
    static let shared = SUPRAPassiveRefreshCoordinator()

    @Published private(set) var lastRefresh: Date?
    @Published private(set) var isRefreshing = false
    @Published private(set) var isSuspended = false
    @Published private(set) var statusMessage: String?
    @Published private(set) var refreshCount = 0

    private var timer: Timer?
    private let interval: TimeInterval = 90
    private var statusDismissTask: Task<Void, Never>?

    private init() {}

    func start() {
        guard timer == nil else { return }
        performLightRefresh()
        scheduleNext()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        statusDismissTask?.cancel()
        statusDismissTask = nil
    }

    func refreshNow() {
        statusMessage = nil
        statusDismissTask?.cancel()
        performLightRefresh()
    }

    private func scheduleNext() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.onTimerTick()
            }
        }
    }

    private func onTimerTick() {
        let governor = SUPRAResourceGovernor.shared
        if governor.isHighLoad || governor.isCritical {
            isSuspended = true
            statusMessage = "Refresh différé — ressources occupées"
            statusDismissTask?.cancel()
            statusDismissTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                guard !Task.isCancelled else { return }
                self.statusMessage = nil
            }
            scheduleNext()
            return
        }
        isSuspended = false
        performLightRefresh()
    }

    private func performLightRefresh() {
        isRefreshing = true
        lastRefresh = Date()
        refreshCount += 1
        isRefreshing = false

        statusMessage = "Actualisation légère effectuée"
        statusDismissTask?.cancel()
        statusDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            self.statusMessage = nil
        }

        scheduleNext()
    }
}
