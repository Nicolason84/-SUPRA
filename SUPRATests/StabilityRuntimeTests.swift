import XCTest
@testable import SUPRA

@MainActor
final class StabilityRuntimeTests: XCTestCase {
    func testMetricsCollectorBuildsSnapshotFromHealthAndEvents() {
        let collector = MetricsCollector(runtimeMetrics: .shared)
        SUPRARuntimeMetrics.shared.clear()

        var health = RuntimeHealth.initial
        health.isConnected = true
        health.agentCount = 3
        health.activeProviderCount = 2
        health.totalProviderCount = 4
        health.activeMissionCount = 1
        health.fileCount = 5
        health.lastSyncDurationMs = 120
        health.connectionState = .connected

        let events = [
            RuntimeEvent(type: .info, title: "Started"),
            RuntimeEvent(type: .validationPassed, title: "Validated"),
            RuntimeEvent(type: .error, title: "Failure")
        ]

        collector.ingest(health: health, events: events)

        XCTAssertEqual(collector.snapshot.totalEvents, 3)
        XCTAssertEqual(collector.snapshot.errorEvents, 1)
        XCTAssertEqual(collector.snapshot.validationPasses, 1)
        XCTAssertEqual(collector.snapshot.activeMissions, 1)
        XCTAssertEqual(collector.snapshot.activeProviders, 2)
        XCTAssertEqual(collector.snapshot.agentCount, 3)
    }

    func testHealthMonitorProducesHealthyStatusForConnectedRuntime() {
        let monitor = HealthMonitor()
        var health = RuntimeHealth.initial
        health.isConnected = true
        health.connectionState = .connected
        health.agentCount = 1
        health.activeProviderCount = 1
        health.totalProviderCount = 1
        health.activeMissionCount = 1

        let snapshot = RuntimeMetricsSnapshot(
            totalEvents: 2,
            errorEvents: 0,
            validationFailures: 0,
            validationPasses: 1,
            activeMissions: 1,
            activeProviders: 1,
            totalProviders: 1,
            agentCount: 1,
            fileCount: 2,
            lastSyncDurationMs: 20,
            connectionState: .connected,
            isConnected: true,
            lastUpdated: Date()
        )

        monitor.evaluate(health: health, metrics: snapshot)

        XCTAssertEqual(monitor.status.level, .healthy)
        XCTAssertTrue(monitor.status.isHealthy)
    }

    func testRuntimeMonitorPublishesStabilityState() {
        let runtimeMonitor = RuntimeMonitor(dataService: RuntimeDataService.shared)
        runtimeMonitor.addEvent(.error, title: "Test error")

        XCTAssertEqual(runtimeMonitor.metricsSnapshot.errorEvents, 1)
        XCTAssertEqual(runtimeMonitor.runtimeStatus.level, .critical)
        XCTAssertFalse(runtimeMonitor.healthAlerts.isEmpty)
    }
}
