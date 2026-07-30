import Foundation
import Combine
import SwiftUI

@MainActor
final class RuntimeMonitor: ObservableObject {
    @Published var health = RuntimeHealth.initial
    @Published var events: [RuntimeEvent] = []
    @Published var selectedMissionId: String?
    @Published private(set) var metricsSnapshot: RuntimeMetricsSnapshot = .empty
    @Published private(set) var runtimeStatus: RuntimeStatus = .initial
    @Published private(set) var healthAlerts: [AlertModel] = []

    private let dataService: RuntimeDataService
    private let metricsCollector: MetricsCollector
    private let healthMonitor: HealthMonitor
    private var cancellables = Set<AnyCancellable>()
    private let maxEvents = 200

    init(dataService: RuntimeDataService) {
        self.dataService = dataService
        self.metricsCollector = MetricsCollector()
        self.healthMonitor = HealthMonitor()
    }

    func start() {
        stop()
        addEvent(.info, title: "Runtime Monitor started", detail: "Delegating to OpenCodeClient")

        OpenCodeClient.shared.configure(dataService: dataService)
        OpenCodeClient.shared.start()

        OpenCodeClient.shared.$events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newEvents in
                self?.events = newEvents
                self?.refreshStabilityState()
            }
            .store(in: &cancellables)

        OpenCodeClient.shared.$health
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newHealth in
                self?.health = newHealth
                self?.refreshStabilityState()
            }
            .store(in: &cancellables)
    }

    func stop() {
        OpenCodeClient.shared.stop()
        cancellables.removeAll()
    }

    func addEvent(_ type: RuntimeEventType, title: String, detail: String = "", file: String? = nil, missionId: String? = nil) {
        let event = RuntimeEvent(type: type, title: title, detail: detail, sourceFile: file, missionId: missionId)
        events.insert(event, at: 0)
        if events.count > maxEvents {
            events = Array(events.prefix(maxEvents))
        }
        refreshStabilityState()
    }

    private func refreshStabilityState() {
        metricsCollector.ingest(health: health, events: events)
        metricsSnapshot = metricsCollector.snapshot

        healthMonitor.evaluate(health: health, metrics: metricsSnapshot)
        runtimeStatus = healthMonitor.status
        healthAlerts = healthMonitor.alerts
    }

    deinit {
        MainActor.assumeIsolated {
            stop()
        }
    }
}
