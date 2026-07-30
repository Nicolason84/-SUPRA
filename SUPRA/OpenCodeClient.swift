import Foundation
import Combine
import SwiftUI

@MainActor
final class OpenCodeClient: ObservableObject {
    static let shared = OpenCodeClient()

    @Published var sourceMode: RuntimeSourceMode = .json
    @Published var events: [RuntimeEvent] = []
    @Published var health = RuntimeHealth.initial
    @Published var connectionState: RuntimeConnectionState = .disconnected
    @Published var lastEventTimestamp: Date?
    @Published var lastSyncTimestamp: Date?

    weak var dataService: RuntimeDataService?

    private var jsonSource: JSONRuntimeSource?
    private var opencodeSource: OpenCodeRuntimeSource?
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    func configure(dataService: RuntimeDataService) {
        self.dataService = dataService
    }

    func start() {
        events.removeAll()
        health = .initial
        connectionState = .disconnected
        stop()

        switch sourceMode {
        case .json, .auto:
            let source = JSONRuntimeSource()
            source.dataService = dataService
            jsonSource = source
            subscribe(to: source)
            source.start()
        case .opencode:
            let source = OpenCodeRuntimeSource()
            opencodeSource = source
            source.$connectionState
                .receive(on: DispatchQueue.main)
                .assign(to: &$connectionState)
            source.start()
        }
    }

    func stop() {
        jsonSource?.stop()
        jsonSource = nil
        opencodeSource?.stop()
        opencodeSource = nil
    }

    func refresh() {
        jsonSource?.refresh()
        opencodeSource?.refresh()
    }

    func setMode(_ mode: RuntimeSourceMode) {
        guard mode != sourceMode else { return }
        sourceMode = mode
        start()
    }

    private func subscribe(to source: JSONRuntimeSource) {
        cancellables.removeAll()

        source.$events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newEvents in
                self?.events = newEvents
                if let first = newEvents.first {
                    self?.lastEventTimestamp = first.timestamp
                }
            }
            .store(in: &cancellables)

        source.$health
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newHealth in
                self?.health = newHealth
                self?.lastSyncTimestamp = newHealth.lastSyncDate
            }
            .store(in: &cancellables)

        source.$connectionState
            .receive(on: DispatchQueue.main)
            .assign(to: &$connectionState)
    }
}
