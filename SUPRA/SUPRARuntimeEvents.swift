import Foundation
import Combine

public enum SUPRARuntimeEventType: String, Codable, Sendable {
    case providerRegistered = "PROVIDER_REGISTERED"
    case modelLoaded = "MODEL_LOADED"
    case capabilityResolved = "CAPABILITY_RESOLVED"
    case executionStarted = "EXECUTION_STARTED"
    case executionCompleted = "EXECUTION_COMPLETED"
    case executionFailed = "EXECUTION_FAILED"
    case fallbackTriggered = "FALLBACK_TRIGGERED"
    case decisionCreated = "DECISION_CREATED"
    case learningUpdated = "LEARNING_UPDATED"
    case pluginDiscovered = "PLUGIN_DISCOVERED"
    case providerHealthChanged = "PROVIDER_HEALTH_CHANGED"
    case routingSelected = "ROUTING_SELECTED"
    case schedulerScheduled = "SCHEDULER_SCHEDULED"
    case validationPassed = "VALIDATION_PASSED"
    case validationFailed = "VALIDATION_FAILED"
    case transmissionRequested = "TRANSMISSION_REQUESTED"
    case gearSelected = "GEAR_SELECTED"
    case clutchEngaged = "CLUTCH_ENGAGED"
    case lockAcquired = "LOCK_ACQUIRED"
    case workerDispatched = "WORKER_DISPATCHED"
    case gearShifted = "GEAR_SHIFTED"
    case fallbackSelected = "FALLBACK_SELECTED"
    case workerCompleted = "WORKER_COMPLETED"
    case workerFailed = "WORKER_FAILED"
    case transmissionReleased = "TRANSMISSION_RELEASED"
}

public struct SUPRARuntimeEvent: Identifiable, Sendable {
    public let id: UUID
    public let type: SUPRARuntimeEventType
    public let message: String
    public let timestamp: Date
    public let source: String
    public let metadata: [String: String]

    public init(type: SUPRARuntimeEventType, message: String,
                source: String = "", metadata: [String: String] = [:],
                timestamp: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.message = message
        self.timestamp = timestamp
        self.source = source
        self.metadata = metadata
    }
}

@MainActor
public final class SUPRARuntimeEvents: ObservableObject {
    public static let shared = SUPRARuntimeEvents()

    @Published public private(set) var events: [SUPRARuntimeEvent] = []
    @Published public private(set) var isLoggingEnabled = true

    private let maxEvents = 2000

    public var onEvent: ((SUPRARuntimeEvent) -> Void)?

    private init() {}

    public func emit(_ type: SUPRARuntimeEventType, _ message: String,
                      source: String = "", metadata: [String: String] = [:]) {
        guard isLoggingEnabled else { return }

        let event = SUPRARuntimeEvent(
            type: type, message: message,
            source: source, metadata: metadata
        )
        events.append(event)

        if events.count > maxEvents {
            events = Array(events.suffix(maxEvents / 2))
        }

        #if DEBUG
        print("[SUPRA:\(type.rawValue)] \(message)")
        #endif

        onEvent?(event)
    }

    public func events(of type: SUPRARuntimeEventType) -> [SUPRARuntimeEvent] {
        events.filter { $0.type == type }
    }

    public func clear() { events = [] }

    public func summary() -> String {
        let counts = Dictionary(grouping: events, by: \.type).mapValues(\.count)
        return counts.sorted { $0.key.rawValue < $1.key.rawValue }
            .map { "\($0.key.rawValue): \($0.value)" }
            .joined(separator: ", ")
    }
}
