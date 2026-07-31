import XCTest
@testable import SUPRA

final class SUPRA_SmokeTests: XCTestCase {
    func testModuleImports() {
        XCTAssertTrue(true, "SUPRA module imports successfully")
    }

    // Runtime Hang Investigation — regression guard.
    // Proves the Executive boot pipeline runs end-to-end within a bounded time
    // (no blocking subprocess wait on the main actor path).
    @MainActor
    func testBootPipelineCompletesWithoutHang() async {
        let bootManager = ExecutiveBootManager.shared
        bootManager.resetBoot()

        let completed = expectation(description: "boot pipeline completed")

        let observer = Task { @MainActor in
            while !bootManager.isBootComplete {
                try? await Task.sleep(for: .milliseconds(100))
            }
            completed.fulfill()
        }

        bootManager.executeBoot()

        await fulfillment(of: [completed], timeout: 15)
        observer.cancel()

        XCTAssertTrue(bootManager.isBootComplete, "Boot pipeline did not complete within 15s")
        XCTAssertFalse(bootManager.bootState == .idle, "Boot state should leave idle")
    }
}
