import XCTest
@testable import SUPRAAST

final class SUPRAASTTests: XCTestCase {
    func testVersionIsPresent() {
        XCTAssertFalse(SUPRAAST.version.isEmpty)
    }
}
