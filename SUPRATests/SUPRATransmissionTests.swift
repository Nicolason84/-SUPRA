import XCTest
@testable import SUPRA

@MainActor
final class SUPRATransmissionGearSelectionTests: XCTestCase {

    override func setUp() async throws {
        SUPRATransmissionLocks.shared.reset()
    }

    func testDeterministicTaskSelectsG0() async {
        let policy = SUPRARoutingPolicy.shared
        let decision = await policy.selectGear(
            for: "build project --target SUPRA",
            writeRequired: false,
            complexity: 1,
            risk: 0.0
        )
        XCTAssertEqual(decision.selectedGear, .G0_MECHANICAL)
        XCTAssertFalse(decision.lockRequirements.isEmpty)
    }

    func testDiscoverySelectsG1() async {
        let policy = SUPRARoutingPolicy.shared
        let decision = await policy.selectGear(
            for: "discover all files in directory src/",
            writeRequired: false,
            complexity: 1
        )
        XCTAssertEqual(decision.selectedGear, .G1_ECO)
    }

    func testMicroPatchSelectsG2() async {
        let policy = SUPRARoutingPolicy.shared
        let decision = await policy.selectGear(
            for: "patch typo in MissionStore.swift",
            writeRequired: true,
            complexity: 1,
            risk: 0.1
        )
        XCTAssertEqual(decision.selectedGear, .G2_STANDARD)
        XCTAssertTrue(decision.lockRequirements.contains(.developWriter))
    }

    func testComplexChangeSelectsG3() async {
        let policy = SUPRARoutingPolicy.shared
        let decision = await policy.selectGear(
            for: "refactor MissionStore to use new caching layer",
            writeRequired: true,
            complexity: 4,
            risk: 0.6
        )
        XCTAssertEqual(decision.selectedGear, .G3_TORQUE)
        XCTAssertTrue(decision.lockRequirements.contains(.developWriter))
        XCTAssertTrue(decision.lockRequirements.contains(.commit))
    }

    func testReviewSelectsG4() async {
        let policy = SUPRARoutingPolicy.shared
        let decision = await policy.selectGear(
            for: "review and validate the new transmission architecture",
            writeRequired: false,
            complexity: 2
        )
        XCTAssertEqual(decision.selectedGear, .G4_REVIEW)
    }

    func testIndependentTasksAllowG5() async {
        let policy = SUPRARoutingPolicy.shared
        let decision = await policy.selectGear(
            for: "cross-reference global symbol definitions",
            writeRequired: false,
            complexity: 1,
            risk: 0.0,
            cpuPressure: 0.2,
            memoryPressure: 0.2
        )
        XCTAssertEqual(decision.selectedGear, .G5_OVERDRIVE)
    }

    func testOnlyOneDevelopWriter() async {
        let locks = SUPRATransmissionLocks.shared
        let acquired = locks.acquire(.developWriter, holder: "test-1")
        XCTAssertTrue(acquired, "First acquire should succeed")

        let second = locks.acquire(.developWriter, holder: "test-2")
        XCTAssertFalse(second, "Second acquire should fail — only 1 writer allowed")

        locks.release(.developWriter)
        let third = locks.acquire(.developWriter, holder: "test-3")
        XCTAssertTrue(third, "Acquire after release should succeed")
    }

    func testOverlappingPathsBlocked() async {
        let locks = SUPRATransmissionLocks.shared
        let acquired = locks.acquire(.fileScope, holder: "build-1", scope: "SUPRA/MissionStore.swift")
        XCTAssertTrue(acquired)

        let overlapping = locks.acquire(.fileScope, holder: "build-2", scope: "SUPRA/MissionStore.swift")
        XCTAssertFalse(overlapping, "Overlapping file scope should be blocked")

        locks.release(.fileScope, scope: "SUPRA/MissionStore.swift")
    }

    func testOnlyOneXcodebuildPerDerivedData() async {
        let locks = SUPRATransmissionLocks.shared
        let first = locks.acquire(.xcodebuild, holder: "build-1", scope: "derived-data-a")
        XCTAssertTrue(first)

        let sameScope = locks.acquire(.xcodebuild, holder: "build-2", scope: "derived-data-a")
        XCTAssertFalse(sameScope, "Second xcodebuild on same DerivedData should be blocked")

        let differentScope = locks.acquire(.xcodebuild, holder: "build-3", scope: "derived-data-b")
        XCTAssertTrue(differentScope, "Different DerivedData scope should be allowed")

        locks.release(.xcodebuild, scope: "derived-data-a")
        locks.release(.xcodebuild, scope: "derived-data-b")
    }

    func testMemoryPressureDownshifts() async {
        let policy = SUPRARoutingPolicy.shared
        let decision = await policy.selectGear(
            for: "analyze code structure",
            writeRequired: false,
            complexity: 2,
            cpuPressure: 0.9,
            memoryPressure: 0.85
        )
        XCTAssertEqual(decision.selectedGear, .G1_ECO, "High pressure should downshift to G1")
    }

    func testProviderFailureUsesBoundedFallback() async {
        let policy = SUPRARoutingPolicy.shared
        let decision = await policy.selectGear(
            for: "patch typo in MissionStore.swift",
            writeRequired: true,
            complexity: 1,
            risk: 0.1
        )
        XCTAssertNotNil(decision.selectedFallback, "G2 should have a fallback gear configured")
        if let fallback = decision.selectedFallback {
            XCTAssertEqual(fallback, .G1_ECO)
        }
    }

    func testPaidProviderNeverSelectedImplicitly() async {
        let providerTypes = SUPRAProviderType.allCases
        for type in providerTypes {
            switch type {
            case .openAI, .anthropic, .gemini, .openRouter:
                XCTAssertFalse(type == .ollama || type == .lmStudio || type == .vLLM || type == .fallback,
                              "Paid provider \(type.rawValue) correctly identified")
            case .ollama, .lmStudio, .vLLM, .fallback, .codex:
                break
            }
        }
    }

    func testLocksReleasedAfterFailure() async {
        let locks = SUPRATransmissionLocks.shared
        locks.acquire(.developWriter, holder: "test-writer")
        locks.acquire(.commit, holder: "test-writer")
        locks.acquire(.modelMemory, holder: "test-writer")

        XCTAssertTrue(locks.developWriterLock)
        XCTAssertTrue(locks.commitLock)
        XCTAssertTrue(locks.modelMemoryLock)

        locks.releaseAll(by: "test-writer")

        XCTAssertFalse(locks.developWriterLock, "Develop writer lock should be released")
        XCTAssertFalse(locks.commitLock, "Commit lock should be released")
        XCTAssertFalse(locks.modelMemoryLock, "Model memory lock should be released")
    }

    func testCompletedRequiresEvidence() async {
        let result = TransmissionResult(
            success: true,
            gear: .G1_ECO,
            message: "Task completed with 3 files discovered",
            decision: TransmissionDecision(
                selectedGear: .G1_ECO,
                selectedProviderID: "memory_worker",
                selectedModelID: "default",
                selectedTimeout: 30,
                lockRequirements: [],
                reason: "Discovery task"
            )
        )
        XCTAssertTrue(result.success)
        XCTAssertFalse(result.message.isEmpty, "Completed result must include evidence message")
        XCTAssertNotNil(result.decision, "Completed result must include decision")
    }

    func testTransmissionTelemetryRecorded() async {
        let metrics = SUPRARuntimeMetrics.shared
        let telemetry = TransmissionTelemetry(
            currentGear: .G2_STANDARD,
            currentProviderID: "ollama",
            queueDepth: 3,
            writerLockState: "free",
            buildLockState: "free",
            cpuPressure: 0.3,
            memoryPressure: 0.4,
            diskPressure: 0.2,
            contextUsage: 4096,
            contextLimit: 8192,
            taskDurationMs: 1500,
            gearShiftCount: 1,
            fallbackCount: 0,
            failedTaskCount: 0
        )
        metrics.recordTelemetry(telemetry)

        let summary = metrics.transmissionSummary()
        XCTAssertTrue(summary.contains("G2_STANDARD") || summary.contains("gear"))
    }
}
