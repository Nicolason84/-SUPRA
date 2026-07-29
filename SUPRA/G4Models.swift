import Foundation
import SwiftUI

// MARK: - IntegrationServiceType

enum IntegrationServiceType: String, CaseIterable, Identifiable {
    case gateway
    case runtime
    case providers
    case memory
    case events

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gateway:   return "Gateway"
        case .runtime:   return "Runtime"
        case .providers: return "Providers"
        case .memory:    return "Memory"
        case .events:    return "Events"
        }
    }

    var icon: String {
        switch self {
        case .gateway:   return "network"
        case .runtime:   return "cpu"
        case .providers: return "brain.head.profile"
        case .memory:    return "memorychip.fill"
        case .events:    return "list.bullet"
        }
    }
}

// MARK: - ServiceConnectionStatus

enum ServiceConnectionStatus: String, CaseIterable {
    case connected
    case disconnected
    case degraded
    case unknown

    var icon: String {
        switch self {
        case .connected:    return "circle.fill"
        case .disconnected: return "circle.dashed"
        case .degraded:     return "exclamationmark.triangle"
        case .unknown:      return "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .connected:    return .supraGreen
        case .disconnected: return .supraRed
        case .degraded:     return .supraOrange
        case .unknown:      return .supraTextTertiary
        }
    }
}

// MARK: - IntegrationServiceStatus

struct IntegrationServiceStatus: Identifiable {
    let type: IntegrationServiceType
    let isConnected: Bool
    let statusText: String
    let detailText: String?
    let lastUpdated: Date?

    var id: String { type.rawValue }

    var connectionStatus: ServiceConnectionStatus {
        if isConnected { return .connected }
        return .disconnected
    }
}

// MARK: - IntegrationDashboardSnapshot

struct IntegrationDashboardSnapshot {
    let services: [IntegrationServiceStatus]
    let lastUpdated: Date

    var overallHealth: String {
        let connected = services.filter { $0.isConnected }.count
        return "\(connected)/\(services.count) connected"
    }

    var allConnected: Bool {
        services.allSatisfy { $0.isConnected }
    }
}
