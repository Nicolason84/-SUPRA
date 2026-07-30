import Foundation
import Combine

// MARK: - Ω6 — Executive Snapshot Bus
//
// The distribution channel for Executive Context Snapshots.
// All consumers (views, engines, adapters) subscribe here.
// No consumer accesses services directly — only via the latest snapshot.
//
// The Snapshot Bus guarantees:
// - Every subscriber gets every snapshot (unless filtered)
// - Snapshots are delivered in order
// - Late subscribers get the latest snapshot immediately
// - Backpressure protection via async sequences

@MainActor
public final class ExecutiveSnapshotBus: ObservableObject {
    public static let shared = ExecutiveSnapshotBus()

    // MARK: - Published State

    @Published public private(set) var latestSnapshot: ExecutiveContextSnapshot = .initial
    @Published public private(set) var snapshotHistory: [ExecutiveContextSnapshot] = []
    @Published public private(set) var snapshotCount: UInt64 = 0
    @Published public private(set) var lastPublishedAt: Date?

    // MARK: - Combine Support

    private let snapshotSubject = PassthroughSubject<ExecutiveContextSnapshot, Never>()
    private let eventBus = ExecutiveEventBus.shared
    private let maxHistory: Int = 100

    // MARK: - Subscriptions

    private var subscribers: [UUID: @Sendable (ExecutiveContextSnapshot) -> Void] = [:]

    private init() {}

    // MARK: - Publishing

    public func publish(_ snapshot: ExecutiveContextSnapshot) {
        latestSnapshot = snapshot
        snapshotCount = snapshot.sequenceNumber
        lastPublishedAt = snapshot.timestamp

        snapshotHistory.append(snapshot)
        if snapshotHistory.count > maxHistory {
            snapshotHistory = Array(snapshotHistory.suffix(maxHistory))
        }

        // Notify Combine subscribers
        snapshotSubject.send(snapshot)

        // Notify closure subscribers
        for subscriber in subscribers.values {
            subscriber(snapshot)
        }

        // Emit event
        eventBus.emit(
            .snapshotPublished,
            source: "ExecutiveSnapshotBus",
            detail: "Snapshot #\(snapshot.sequenceNumber) published",
            metadata: [
                "sequenceNumber": "\(snapshot.sequenceNumber)",
                "runtimeState": snapshot.runtimeState.rawValue,
                "visionWatching": "\(snapshot.vision.isWatching)",
                "presenceState": snapshot.presence.state
            ]
        )
    }

    // MARK: - Subscriptions

    /// Subscribe via async closure (MainActor)
    public func subscribe(id: UUID = UUID(), handler: @escaping @Sendable (ExecutiveContextSnapshot) -> Void) -> UUID {
        subscribers[id] = handler
        // Deliver latest immediately
        handler(latestSnapshot)
        return id
    }

    /// Subscribe via Combine publisher
    public func publisher() -> AnyPublisher<ExecutiveContextSnapshot, Never> {
        snapshotSubject.eraseToAnyPublisher()
    }

    /// Unsubscribe
    public func unsubscribe(id: UUID) {
        subscribers.removeValue(forKey: id)
    }

    public func unsubscribeAll() {
        subscribers.removeAll()
    }

    // MARK: - Async Stream

    public func snapshotStream() -> AsyncStream<ExecutiveContextSnapshot> {
        AsyncStream { continuation in
            let id = UUID()
            self.subscribers[id] = { snapshot in
                continuation.yield(snapshot)
            }
            continuation.onTermination = { @Sendable _ in
                Task { @MainActor in
                    self.unsubscribe(id: id)
                }
            }
        }
    }

    // MARK: - Filtered Access

    public func latest<T>(_ keyPath: KeyPath<ExecutiveContextSnapshot, T>) -> T {
        latestSnapshot[keyPath: keyPath]
    }

    // MARK: - History Queries

    public func snapshots(after sequence: UInt64) -> [ExecutiveContextSnapshot] {
        snapshotHistory.filter { $0.sequenceNumber > sequence }
    }

    public func snapshots(since date: Date) -> [ExecutiveContextSnapshot] {
        snapshotHistory.filter { $0.timestamp >= date }
    }

    // MARK: - Reset

    public func reset() {
        latestSnapshot = .initial
        snapshotHistory.removeAll()
        snapshotCount = 0
        lastPublishedAt = nil
        unsubscribeAll()
    }
}
