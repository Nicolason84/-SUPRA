import Foundation
import Combine

// MARK: - Ω7 — Executive Event Bus
//
// The central nervous communication channel of SUPRA's living runtime.
// All engines publish events here. No engine talks directly to SwiftUI.
// Views subscribe to event streams through dedicated adapters.
//
// This is NOT a NotificationCenter replacement.
// This is an architectural event backbone with:
// - Typed events
// - Source tracking
// - Metadata enrichment
// - Filtered subscriptions
// - Performance metrics

public enum ExecutiveEventType: String, Sendable, Codable, CaseIterable {
    // Runtime lifecycle
    case runtimeBooting = "runtime.booting"
    case runtimeActive = "runtime.active"
    case runtimeHalting = "runtime.halting"
    case runtimeRegenerating = "runtime.regenerating"
    case runtimeSleeping = "runtime.sleeping"

    // Engine lifecycle
    case engineRegistered = "engine.registered"
    case engineBooted = "engine.booted"
    case engineDegraded = "engine.degraded"
    case engineFailed = "engine.failed"
    case engineRecovering = "engine.recovering"
    case engineShutdown = "engine.shutdown"

    // Vision events
    case visionStarted = "vision.started"
    case visionObserving = "vision.observing"
    case visionDetectedChange = "vision.detected.change"
    case visionFileChanged = "vision.file.changed"
    case visionGitChanged = "vision.git.changed"
    case visionHealthChanged = "vision.health.changed"
    case visionSnapshotCreated = "vision.snapshot.created"
    case visionDegraded = "vision.degraded"
    case visionRecovered = "vision.recovered"

    // Presence events
    case presenceAwakened = "presence.awakened"
    case presenceActive = "presence.active"
    case presenceWatching = "presence.watching"
    case presenceThinking = "presence.thinking"
    case presencePreparing = "presence.preparing"
    case presenceDeciding = "presence.deciding"
    case presenceWaiting = "presence.waiting"
    case presenceIdle = "presence.idle"
    case presenceSleeping = "presence.sleeping"

    // Context events
    case contextUpdated = "context.updated"
    case contextEngineDegraded = "context.engine.degraded"

    // Snapshot events
    case snapshotPublished = "snapshot.published"
    case snapshotConsumed = "snapshot.consumed"

    // Digital Twin events
    case twinSyncing = "twin.syncing"
    case twinSynced = "twin.synced"
    case twinDesyncDetected = "twin.desync.detected"

    // Identity events
    case identityEstablished = "identity.established"
    case identityChanged = "identity.changed"

    // Distance Engine events (Ω11 — Executive Distance Engine)
    case distanceEngineBooting = "distance.engine.booting"
    case distanceEngineActive = "distance.engine.active"
    case distanceEngineShutdown = "distance.engine.shutdown"
    case distanceEngineDegraded = "distance.engine.degraded"
    case ecuRegistered = "ecu.registered"
    case ecuMaturityUpdated = "ecu.maturity.updated"
    case ecuGovernanceUpdated = "ecu.governance.updated"
    case ecuCompleted = "ecu.completed"
    case transitionRecorded = "transition.recorded"
    case dashboardUpdated = "dashboard.updated"

    // System
    case warning = "system.warning"
    case error = "system.error"
    case info = "system.info"
}

public struct ExecutiveEvent: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let type: ExecutiveEventType
    public let source: String
    public let timestamp: Date
    public let detail: String
    public let metadata: [String: String]

    public init(type: ExecutiveEventType, source: String, detail: String, metadata: [String: String] = [:], timestamp: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.source = source
        self.detail = detail
        self.metadata = metadata
        self.timestamp = timestamp
    }

    public static func == (lhs: ExecutiveEvent, rhs: ExecutiveEvent) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Event Subscription

public final class ExecutiveEventSubscription: Hashable, Sendable {
    public let id: UUID
    public let filter: ((ExecutiveEvent) -> Bool)?
    private let handler: @Sendable (ExecutiveEvent) -> Void

    public init(id: UUID = UUID(), filter: ((ExecutiveEvent) -> Bool)? = nil, handler: @escaping @Sendable (ExecutiveEvent) -> Void) {
        self.id = id
        self.filter = filter
        self.handler = handler
    }

    public func handle(_ event: ExecutiveEvent) {
        if filter?(event) ?? true {
            handler(event)
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ExecutiveEventSubscription, rhs: ExecutiveEventSubscription) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Event Bus

@MainActor
public final class ExecutiveEventBus: ObservableObject {
    public static let shared = ExecutiveEventBus()

    @Published public private(set) var recentEvents: [ExecutiveEvent] = []
    @Published public private(set) var eventCount: Int = 0
    @Published public private(set) var isEnabled: Bool = true

    public var onEvent: ((ExecutiveEvent) -> Void)?

    private var subscriptions: [ExecutiveEventSubscription] = []
    private let maxRecentEvents: Int = 500
    private var eventCounts: [ExecutiveEventType: Int] = [:]

    private init() {}

    // MARK: - Publishing

    public func emit(_ event: ExecutiveEvent) {
        guard isEnabled else { return }

        eventCount += 1
        eventCounts[event.type, default: 0] += 1

        recentEvents.insert(event, at: 0)
        if recentEvents.count > maxRecentEvents {
            recentEvents = Array(recentEvents.prefix(maxRecentEvents))
        }

        // Notify subscriptions
        for subscription in subscriptions {
            subscription.handle(event)
        }

        // Notify global listener
        onEvent?(event)

        #if DEBUG
        if event.type != .snapshotPublished && event.type != .contextUpdated {
            // Only log non-chatty events in debug
        }
        #endif
    }

    public func emit(_ type: ExecutiveEventType, source: String, detail: String, metadata: [String: String] = [:]) {
        let event = ExecutiveEvent(type: type, source: source, detail: detail, metadata: metadata)
        emit(event)
    }

    // MARK: - Subscription

    public func subscribe(filter: ((ExecutiveEvent) -> Bool)? = nil, handler: @escaping @Sendable (ExecutiveEvent) -> Void) -> ExecutiveEventSubscription {
        let subscription = ExecutiveEventSubscription(filter: filter, handler: handler)
        subscriptions.append(subscription)
        return subscription
    }

    public func subscribe(to type: ExecutiveEventType, handler: @escaping @Sendable (ExecutiveEvent) -> Void) -> ExecutiveEventSubscription {
        subscribe(filter: { $0.type == type }, handler: handler)
    }

    public func unsubscribe(_ subscription: ExecutiveEventSubscription) {
        subscriptions.removeAll { $0.id == subscription.id }
    }

    public func unsubscribeAll() {
        subscriptions.removeAll()
    }

    // MARK: - Queries

    public func events(of type: ExecutiveEventType) -> [ExecutiveEvent] {
        recentEvents.filter { $0.type == type }
    }

    public func events(from source: String) -> [ExecutiveEvent] {
        recentEvents.filter { $0.source == source }
    }

    public func count(for type: ExecutiveEventType) -> Int {
        eventCounts[type, default: 0]
    }

    public func clear() {
        recentEvents.removeAll()
        eventCounts.removeAll()
        eventCount = 0
    }

    // MARK: - Control

    public func enable() {
        isEnabled = true
    }

    public func disable() {
        isEnabled = false
    }

    // MARK: - Summary

    public func summary() -> String {
        let sorted = eventCounts.sorted { $0.value > $1.value }
        return sorted.prefix(10).map { "\($0.key.rawValue): \($0.value)" }.joined(separator: "\n")
    }
}
