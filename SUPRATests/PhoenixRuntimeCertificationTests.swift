import XCTest
@testable import SUPRA

// MARK: - Ω1 Diagnostic: Absolute minimum

final class Omega1DiagnosticTests: XCTestCase {

    // NO setUp/tearDown — just raw access
    // This tests if the singleton initialization chain itself causes issues

    func test_justAccessCoreState() throws {
        let core = ExecutiveRuntimeCore.shared
        print("CORE STATE: \(core.state.rawValue)")
        print("WARNINGS: \(core.warnings)")
        // Don't assert — just read
    }

    func test_justAccessSnapshotBus() throws {
        let bus = ExecutiveSnapshotBus.shared
        print("SNAPSHOT STATE: \(bus.latestSnapshot.runtimeState)")
    }

    func test_justAccessEventBus() throws {
        let bus = ExecutiveEventBus.shared
        print("EVENT COUNT: \(bus.eventCount)")
    }

    func test_accessAllSingletons() throws {
        let _ = ExecutiveSnapshotBus.shared
        print("1 snapshot OK")
        let _ = ExecutiveEventBus.shared
        print("2 event OK")
        let core = ExecutiveRuntimeCore.shared
        print("3 core OK — state: \(core.state.rawValue)")
        XCTAssertEqual(core.state, .dormant)
    }
}
