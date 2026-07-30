import Foundation
import Combine

// MARK: - PhoenixRuntime
//
// The unified bootstrap and coordinator for PROJECT PHOENIX.
// Wires all Ω components together and starts the living runtime.
// Provides a single entry point for SUPRA's executive system.

@MainActor
public final class PhoenixRuntime: ObservableObject {
    public static let shared = PhoenixRuntime()

    // MARK: - Published State

    @Published public private(set) var isBooted: Bool = false
    @Published public private(set) var bootProgress: Double = 0
    @Published public private(set) var bootMessage: String = "Preparing..."
    @Published public private(set) var lastSnapshotSequence: UInt64 = 0

    // MARK: - Component Accessors

    public let runtimeCore = ExecutiveRuntimeCore.shared
    public let visionEngine = VisionEngine.shared
    public let presenceEngine = PresenceEngine.shared
    public let contextEngine = ContextEngine.shared
    public let snapshotBus = ExecutiveSnapshotBus.shared
    public let eventBus = ExecutiveEventBus.shared
    public let digitalTwin = DigitalTwinRuntime.shared
    public let identity = IdentityRuntime.shared
    public let oeil = OeilPerceptionLayer.shared

    // MARK: - Snapshot Pipeline

    private let snapshotBuilder = ExecutiveSnapshotBuilder()
    private var snapshotTimer: Timer?
    private var snapshotSubscription: UUID?

    // MARK: - Private

    private var hasBooted = false

    private init() {}

    // MARK: - Boot Sequence

    public func boot() async {
        guard !hasBooted else { return }
        hasBooted = true
        isBooted = false

        eventBus.emit(.runtimeBooting, source: "PhoenixRuntime", detail: "PROJECT PHOENIX bootstrap initiated")

        // Phase 1: Register all engines with the runtime core
        bootProgress = 0.1
        bootMessage = "Registering engines..."
        runtimeCore.registerEngine(visionEngine)
        runtimeCore.registerEngine(presenceEngine)
        runtimeCore.registerEngine(contextEngine)
        runtimeCore.registerEngine(digitalTwin)
        runtimeCore.registerEngine(identity)
        runtimeCore.registerEngine(oeil)

        // Phase 2: Boot the runtime core
        bootProgress = 0.2
        bootMessage = "Booting Executive Runtime Core..."
        await runtimeCore.boot()

        // Phase 3: Start snapshot publishing pipeline
        bootProgress = 0.5
        bootMessage = "Starting snapshot pipeline..."
        startSnapshotPipeline()

        // Phase 4: Verify all engines are active
        bootProgress = 0.7
        bootMessage = "Verifying engine health..."
        await runtimeCore.performHealthCheck()

        // Phase 5: First snapshot
        bootProgress = 0.9
        bootMessage = "Publishing initial snapshot..."
        publishSnapshot()

        // Phase 6: Complete
        bootProgress = 1.0
        bootMessage = "SUPRA est vivant."
        isBooted = true

        eventBus.emit(.runtimeActive, source: "PhoenixRuntime", detail: "PROJECT PHOENIX — Executive Runtime is alive")

        // Notify ŒIL
        oeil.directGaze(.horizon)
    }

    public func shutdown() async {
        snapshotTimer?.invalidate()
        snapshotTimer = nil

        if let id = snapshotSubscription {
            snapshotBus.unsubscribe(id: id)
        }

        await runtimeCore.shutdown()

        isBooted = false
        bootProgress = 0
        bootMessage = "Dormant"

        eventBus.emit(.runtimeHalting, source: "PhoenixRuntime", detail: "Phoenix Runtime shutdown")
    }

    // MARK: - Snapshot Pipeline

    private func startSnapshotPipeline() {
        // Publish snapshots on a regular cadence
        snapshotTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.publishSnapshot()
            }
        }

        // Also publish on significant events
        snapshotSubscription = eventBus.subscribe { [weak self] event in
            let significantEvents: [ExecutiveEventType] = [
                .visionDetectedChange,
                .visionGitChanged,
                .contextUpdated,
                .twinSynced,
                .engineBooted,
                .engineFailed
            ]
            if significantEvents.contains(event.type) {
                Task { @MainActor [weak self] in
                    self?.publishSnapshot()
                }
            }
        }
    }

    private func publishSnapshot() {
        let snapshot = snapshotBuilder.build(
            runtimeCore: runtimeCore,
            vision: visionEngine,
            presence: presenceEngine,
            context: contextEngine,
            digitalTwin: digitalTwin,
            identity: identity
        )

        snapshotBus.publish(snapshot)
        lastSnapshotSequence = snapshot.sequenceNumber
    }

    // MARK: - Force Refresh

    public func forceRefresh() {
        publishSnapshot()
        visionEngine.observeNow()
    }

    // MARK: - Status

    public func statusReport() -> String {
        """
        ╔══════════════════════════════════════╗
        ║     PROJECT PHOENIX — STATUS         ║
        ╠══════════════════════════════════════╣
        ║ Booted:   \(isBooted ? "✓ YES" : "✗ NO")                         ║
        ║ Snapshots: \(lastSnapshotSequence)                                ║
        ║ Runtime:  \(runtimeCore.state.rawValue)                          ║
        ║ ŒIL:      \(oeil.isAlive ? "✓ Alive" : "✗ Dormant")                      ║
        ║ Présence: \(presenceEngine.isPresent ? "✓ Present" : "✗ Absent")                      ║
        ╚══════════════════════════════════════╝
        \(oeil.statusReport())
        """
    }
}
