import Foundation
import Combine

// MARK: - G4IntegrationService

@MainActor
final class G4IntegrationService: ObservableObject {
    @Published private(set) var snapshot: IntegrationDashboardSnapshot?

    private let gateway = RuntimeGateway.shared
    private let monitor = SUPRACompositionRoot.shared.runtimeMonitor
    private let providerRegistry = SUPRAProviderRegistry.shared
    private let memoryStore = CAnnoNicoSnapshotStore.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        observeAll()
        rebuild()
    }

    // MARK: - Observation

    private func observeAll() {
        gateway.$status.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        gateway.$isConnected.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        gateway.$events.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        monitor.$health.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        providerRegistry.$providers.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        providerRegistry.$activeProviderType.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
        memoryStore.$state.sink { [weak self] _ in self?.rebuild() }.store(in: &cancellables)
    }

    // MARK: - Rebuild

    func rebuild() {
        let services: [IntegrationServiceStatus] = [
            buildGatewayStatus(),
            buildRuntimeStatus(),
            buildProviderStatus(),
            buildMemoryStatus(),
            buildEventStatus()
        ]

        snapshot = IntegrationDashboardSnapshot(
            services: services,
            lastUpdated: Date()
        )
    }

    // MARK: - Service Status Builders

    private func buildGatewayStatus() -> IntegrationServiceStatus {
        let isConnected = gateway.isConnected
        let statusText = isConnected ? "Connected" : "Disconnected"
        let detail = gateway.status.map { "v\($0.version) | \($0.activeMissions) missions" }
        return IntegrationServiceStatus(
            type: .gateway,
            isConnected: isConnected,
            statusText: statusText,
            detailText: detail,
            lastUpdated: Date()
        )
    }

    private func buildRuntimeStatus() -> IntegrationServiceStatus {
        let health = monitor.health
        let isConnected = health.isConnected
        let statusText = health.connectionState.rawValue
        let detail = "\(health.agentCount) agents | \(health.activeMissionCount) missions"
        return IntegrationServiceStatus(
            type: .runtime,
            isConnected: isConnected,
            statusText: statusText,
            detailText: detail,
            lastUpdated: health.lastSyncDate
        )
    }

    private func buildProviderStatus() -> IntegrationServiceStatus {
        let providers = providerRegistry.providers
        let active = providerRegistry.activeProviderType
        let connected = !providers.isEmpty
        let statusText = "\(providers.count) registered | Active: \(active.rawValue)"
        let detail = "\(providers.count) providers available"
        return IntegrationServiceStatus(
            type: .providers,
            isConnected: connected,
            statusText: statusText,
            detailText: detail,
            lastUpdated: Date()
        )
    }

    private func buildMemoryStatus() -> IntegrationServiceStatus {
        let state = memoryStore.state
        let connected = state != nil
        let statusText = connected ? "Resolved" : "Unavailable"
        let detail = state.map { "\($0.sourceCount) sources | \($0.recoveredCount) recovered" }
        return IntegrationServiceStatus(
            type: .memory,
            isConnected: connected,
            statusText: statusText,
            detailText: detail,
            lastUpdated: Date()
        )
    }

    private func buildEventStatus() -> IntegrationServiceStatus {
        let events = gateway.events
        let connected = true
        let statusText = "\(events.count) events"
        let recent = events.prefix(3).map { $0.type }.joined(separator: ", ")
        let detail = recent.isEmpty ? nil : recent
        return IntegrationServiceStatus(
            type: .events,
            isConnected: connected,
            statusText: statusText,
            detailText: detail,
            lastUpdated: Date()
        )
    }
}
