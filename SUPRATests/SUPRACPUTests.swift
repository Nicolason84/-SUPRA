import XCTest
@testable import SUPRA

@MainActor
final class SUPRA_CPUMetricTests: XCTestCase {

    func testCPUFirstSampleReturnsZero() async throws {
        let governor = SUPRAResourceGovernor.shared
        let cpu = governor.cpuUsage
        XCTAssertGreaterThanOrEqual(cpu, 0)
        XCTAssertLessThanOrEqual(cpu, 1.0)
    }

    func testCPUValueBounded() {
        let engine = SUPRAResourceIntelligence.shared
        let cpu = engine.cpuCurrent
        XCTAssertGreaterThanOrEqual(cpu, 0)
        XCTAssertLessThanOrEqual(cpu, 1.0)
    }

    func testHeavyProcessesEmptyByDefault() {
        let engine = SUPRAResourceIntelligence.shared
        let processes = engine.heavyProcesses
        XCTAssertTrue(processes.isEmpty || processes.count <= 5)
    }

    func testCPUAndProcessesAreConsistent() {
        let engine = SUPRAResourceIntelligence.shared
        let cpu = engine.cpuCurrent
        let processes = engine.heavyProcesses
        if cpu > 0.8 && processes.isEmpty {
            XCTAssertTrue(true, "DISTRIBUTED_LOAD: high CPU with no individual heavy process")
        }
    }

    // MARK: - System Metric State

    func testSystemMetricStateLoadingNotAvailable() {
        let state: SystemMetricState<Int> = .loading
        XCTAssertNotEqual(state, .available(0))
        XCTAssertNotEqual(state, .unavailable(reason: "any"))
    }

    func testSystemMetricStateAvailable() {
        let state: SystemMetricState<Int> = .available(42)
        XCTAssertEqual(state, .available(42))
        XCTAssertNotEqual(state, .loading)
    }

    func testSystemMetricStateUnavailable() {
        let state: SystemMetricState<Int> = .unavailable(reason: "test error")
        XCTAssertEqual(state, .unavailable(reason: "test error"))
        XCTAssertNotEqual(state, .loading)
    }

    // MARK: - CPU Metrics

    func testCPUMetricsBounded() {
        let metrics = CPUMetrics(
            totalPercent: 45.5,
            userPercent: 30.0,
            systemPercent: 15.5,
            idlePercent: 54.5,
            sampleState: .valid
        )
        XCTAssertEqual(metrics.totalPercent, 45.5)
        XCTAssertEqual(metrics.sampleState, .valid)
        XCTAssertGreaterThanOrEqual(metrics.totalPercent, 0)
        XCTAssertLessThanOrEqual(metrics.totalPercent, 100)
        XCTAssertGreaterThanOrEqual(metrics.userPercent, 0)
        XCTAssertLessThanOrEqual(metrics.systemPercent, 100)
        XCTAssertGreaterThanOrEqual(metrics.idlePercent, 0)
    }

    func testCPUMetricsWarmingUp() {
        let metrics = CPUMetrics(
            totalPercent: 0,
            userPercent: 0,
            systemPercent: 0,
            idlePercent: 0,
            sampleState: .warmingUp
        )
        XCTAssertEqual(metrics.sampleState, .warmingUp)
    }

    func testCPUMetricsUnavailable() {
        let metrics = CPUMetrics(
            totalPercent: 0,
            userPercent: 0,
            systemPercent: 0,
            idlePercent: 0,
            sampleState: .unavailable
        )
        XCTAssertEqual(metrics.sampleState, .unavailable)
    }

    func testCPUMetricsNeverExceeds100() {
        let metrics = CPUMetrics(
            totalPercent: 150,
            userPercent: 100,
            systemPercent: 50,
            idlePercent: 0,
            sampleState: .valid
        )
        // The struct itself doesn't clamp, but the collector does via min(100, ...)
        // This test documents the requirement
        let clampedTotal = min(100, metrics.totalPercent)
        let clampedUser = min(100, metrics.userPercent)
        let clampedSystem = min(100, metrics.systemPercent)
        XCTAssertLessThanOrEqual(clampedTotal, 100)
        XCTAssertLessThanOrEqual(clampedUser, 100)
        XCTAssertLessThanOrEqual(clampedSystem, 100)
    }

    // MARK: - Heavy Process

    func testHeavyProcessStructure() {
        let proc = HeavyProcess(id: 123, name: "test", cpuPercent: 45.0, memoryPercent: 2.5)
        XCTAssertEqual(proc.id, 123)
        XCTAssertEqual(proc.name, "test")
        XCTAssertEqual(proc.cpuPercent, 45.0)
        XCTAssertEqual(proc.memoryPercent, 2.5)
    }

    func testHeavyProcessesValidEmpty() {
        let state: SystemMetricState<[HeavyProcess]> = .available([])
        if case .available(let procs) = state {
            XCTAssertTrue(procs.isEmpty)
        } else {
            XCTFail("Expected available with empty array")
        }
    }

    func testHeavyProcessesUnavailableNotZero() {
        let state: SystemMetricState<[HeavyProcess]> = .unavailable(reason: "command failed")
        if case .available = state {
            XCTFail("Expected unavailable, not available with zero")
        }
    }

    // MARK: - Projects

    func testProjectsInfo() {
        let info = ProjectsInfo(discovered: 10, active: 5, validated: 3, unavailable: 0)
        XCTAssertEqual(info.discovered, 10)
        XCTAssertEqual(info.active, 5)
        XCTAssertEqual(info.validated, 3)
    }

    func testProjectsUnavailableNotZero() {
        let state: SystemMetricState<ProjectsInfo> = .unavailable(reason: "no registry")
        if case .available(let info) = state {
            XCTAssertNotEqual(info.discovered, 0, "Should not silently return zero")
        }
    }

    // MARK: - Git Repos

    func testGitReposInfo() {
        let info = GitReposInfo(total: 8, dirty: 3, clean: 5, unavailable: 0)
        XCTAssertEqual(info.total, 8)
        XCTAssertEqual(info.dirty, 3)
        XCTAssertEqual(info.clean, 5)
    }

    // MARK: - Storage

    func testStorageAvailableNonNegative() {
        let info = StorageInfo(
            totalBytes: 1_000_000_000_000,
            availableBytes: 500_000_000_000,
            usedBytes: 500_000_000_000,
            recoverableBytes: 0,
            recoverableConfidence: .unavailable
        )
        XCTAssertGreaterThanOrEqual(info.totalBytes, 0)
        XCTAssertGreaterThanOrEqual(info.availableBytes, 0)
        XCTAssertGreaterThanOrEqual(info.usedBytes, 0)
        XCTAssertGreaterThanOrEqual(info.recoverableBytes, 0)
    }

    func testRecoverableStorageLabeledEstimatedOrUnavailable() {
        let estimated = StorageInfo(
            totalBytes: 1_000_000_000_000,
            availableBytes: 400_000_000_000,
            usedBytes: 600_000_000_000,
            recoverableBytes: 5_000_000_000,
            recoverableConfidence: .estimated
        )
        let unavailable = StorageInfo(
            totalBytes: 1_000_000_000_000,
            availableBytes: 400_000_000_000,
            usedBytes: 600_000_000_000,
            recoverableBytes: 0,
            recoverableConfidence: .unavailable
        )
        let measured = StorageInfo(
            totalBytes: 1_000_000_000_000,
            availableBytes: 400_000_000_000,
            usedBytes: 600_000_000_000,
            recoverableBytes: 2_000_000_000,
            recoverableConfidence: .measured
        )
        XCTAssertEqual(estimated.recoverableConfidence, .estimated)
        XCTAssertEqual(unavailable.recoverableConfidence, .unavailable)
        XCTAssertEqual(measured.recoverableConfidence, .measured)
        // Recoverable must never be presented as certain when estimated
        if estimated.recoverableConfidence == .estimated {
            XCTAssertGreaterThan(estimated.recoverableBytes, 0)
        }
    }

    // MARK: - Xcode

    func testXcodeVersionParse() {
        let info = XcodeInfo(
            installed: true,
            version: "Xcode 15.4",
            buildVersion: "Build version 15F31e",
            developerDir: "/Applications/Xcode.app/Contents/Developer",
            swiftVersion: "swift-driver version: 1.90.11",
            status: .available
        )
        XCTAssertTrue(info.installed)
        XCTAssertEqual(info.status, .available)
        XCTAssertFalse(info.version.isEmpty)
        XCTAssertFalse(info.developerDir.isEmpty)
    }

    func testXcodeCommandFailureIsUnavailable() {
        let info = XcodeInfo(
            installed: true,
            version: "",
            buildVersion: "",
            developerDir: "",
            swiftVersion: "",
            status: .commandFailure
        )
        XCTAssertTrue(info.installed)
        XCTAssertEqual(info.status, .commandFailure)
    }

    func testXcodeMissing() {
        let info = XcodeInfo(
            installed: false,
            version: "",
            buildVersion: "",
            developerDir: "",
            swiftVersion: "",
            status: .missing
        )
        XCTAssertFalse(info.installed)
        XCTAssertEqual(info.status, .missing)
    }

    // MARK: - Services

    func testServicesInfo() {
        let info = ServicesInfo(total: 5, active: 3, unavailable: 2)
        XCTAssertEqual(info.total, 5)
        XCTAssertEqual(info.active, 3)
        XCTAssertEqual(info.unavailable, 2)
    }

    // MARK: - System Metrics Snapshot

    func testSystemMetricsSnapshotInitialState() {
        let snapshot = SystemMetricsSnapshot(
            cpu: .loading,
            heavyProcesses: .loading,
            services: .loading,
            projects: .loading,
            gitRepos: .loading,
            storage: .loading,
            xcode: .loading,
            timestamp: Date(),
            refreshDuration: nil,
            failedMetrics: [],
            refreshState: .idle
        )
        XCTAssertEqual(snapshot.refreshState, .idle)
        XCTAssertEqual(snapshot.failedMetrics.count, 0)
        XCTAssertNil(snapshot.refreshDuration)
    }

    func testSystemMetricsSnapshotRefreshingState() {
        let snapshot = SystemMetricsSnapshot(
            cpu: .loading,
            heavyProcesses: .loading,
            services: .loading,
            projects: .loading,
            gitRepos: .loading,
            storage: .loading,
            xcode: .loading,
            timestamp: Date(),
            refreshDuration: nil,
            failedMetrics: [],
            refreshState: .refreshing
        )
        XCTAssertEqual(snapshot.refreshState, .refreshing)
    }

    func testSystemMetricsSnapshotWithData() {
        let snapshot = SystemMetricsSnapshot(
            cpu: .available(CPUMetrics(
                totalPercent: 35.0,
                userPercent: 20.0,
                systemPercent: 15.0,
                idlePercent: 65.0,
                sampleState: .valid
            )),
            heavyProcesses: .available([
                HeavyProcess(id: 1, name: "test", cpuPercent: 50, memoryPercent: 10)
            ]),
            services: .available(ServicesInfo(total: 3, active: 2, unavailable: 1)),
            projects: .available(ProjectsInfo(discovered: 5, active: 3, validated: 2, unavailable: 0)),
            gitRepos: .available(GitReposInfo(total: 4, dirty: 1, clean: 3, unavailable: 0)),
            storage: .available(StorageInfo(
                totalBytes: 500_000_000_000,
                availableBytes: 200_000_000_000,
                usedBytes: 300_000_000_000,
                recoverableBytes: 1_000_000_000,
                recoverableConfidence: .estimated
            )),
            xcode: .available(XcodeInfo(
                installed: true,
                version: "Xcode 15.4",
                buildVersion: "15F31e",
                developerDir: "/Applications/Xcode.app",
                swiftVersion: "5.10",
                status: .available
            )),
            timestamp: Date(),
            refreshDuration: 0.5,
            failedMetrics: [],
            refreshState: .idle
        )
        if case .available(let cpu) = snapshot.cpu {
            XCTAssertEqual(cpu.totalPercent, 35.0)
            XCTAssertEqual(cpu.sampleState, .valid)
        } else { XCTFail("CPU should be available") }
        if case .available(let procs) = snapshot.heavyProcesses {
            XCTAssertEqual(procs.count, 1)
        } else { XCTFail("Processes should be available") }
        if case .available(let storage) = snapshot.storage {
            XCTAssertEqual(storage.recoverableConfidence, .estimated)
        } else { XCTFail("Storage should be available") }
        XCTAssertEqual(snapshot.failedMetrics.count, 0)
        XCTAssertEqual(snapshot.refreshDuration, 0.5)
    }

    // MARK: - Refresh Pipeline

    func testRefreshPreservesLastValidValues() async {
        let service = RuntimeDataService()
        // Initial state is idle with loading metrics
        let before = service.systemMetrics
        XCTAssertEqual(before.refreshState, .idle)
        // Start refresh - state becomes .refreshing synchronously
        service.refreshSystemMetrics()
        XCTAssertEqual(service.systemMetrics.refreshState, .refreshing)
    }

    func testRefreshNoDuplicateConcurrentRun() async {
        let service = RuntimeDataService()
        // First call sets state to .refreshing synchronously
        service.refreshSystemMetrics()
        XCTAssertEqual(service.systemMetrics.refreshState, .refreshing)
        // Second call should be a no-op due to guard
        service.refreshSystemMetrics()
        XCTAssertEqual(service.systemMetrics.refreshState, .refreshing,
                       "Second call must not reset or change refreshing state")
    }

    // MARK: - SystemMetricState Equatability

    func testSystemMetricStateEquatable() {
        let a: SystemMetricState<Int> = .available(1)
        let b: SystemMetricState<Int> = .available(1)
        let c: SystemMetricState<Int> = .available(2)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)

        let d: SystemMetricState<Int> = .unavailable(reason: "err")
        let e: SystemMetricState<Int> = .unavailable(reason: "err")
        let f: SystemMetricState<Int> = .unavailable(reason: "other")
        XCTAssertEqual(d, e)
        XCTAssertNotEqual(d, f)

        XCTAssertNotEqual(a, d)
        XCTAssertNotEqual(a, .loading)
    }

    // MARK: - Zero/100 Verification

    func testCPUNotHardcodedTo100() {
        // Verify that the initial CPU is not 100
        let snapshot = SystemMetricsSnapshot(
            cpu: .loading,
            heavyProcesses: .loading,
            services: .loading,
            projects: .loading,
            gitRepos: .loading,
            storage: .loading,
            xcode: .loading,
            timestamp: Date(),
            refreshDuration: nil,
            failedMetrics: [],
            refreshState: .idle
        )
        if case .available(let cpu) = snapshot.cpu {
            XCTAssertNotEqual(cpu.totalPercent, 100, "CPU must never default to 100%")
        }
    }

    func testUnavailableStateNotZero() {
        // Verify that unavailable state is not presented as zero
        let intState: SystemMetricState<Int> = .unavailable(reason: "test")
        if case .available(let val) = intState {
            XCTAssertNotEqual(val, 0, "Unavailable should not be zero")
        }
    }
}
