import Foundation

enum RuntimeConnectionState: String, Codable, CaseIterable {
    case disconnected = "Disconnected"
    case connecting = "Connecting"
    case connected = "Connected"
    case degraded = "Degraded"
    case offline = "Offline"

    var icon: String {
        switch self {
        case .disconnected: "circle.dashed"
        case .connecting: "arrow.triangle.2.circlepath"
        case .connected: "circle.fill"
        case .degraded: "exclamationmark.triangle"
        case .offline: "xmark.octagon"
        }
    }

    var color: String {
        switch self {
        case .disconnected: "gray"
        case .connecting: "blue"
        case .connected: "green"
        case .degraded: "orange"
        case .offline: "red"
        }
    }
}
