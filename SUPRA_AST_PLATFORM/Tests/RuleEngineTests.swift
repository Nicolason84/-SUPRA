import XCTest
@testable import SUPRAAST

final class RuleEngineTests: XCTestCase {
    func testLoadsBundledRules() throws {
        let rules = try RuleEngine.loadBundledRules()
        XCTAssertTrue(rules.rules.contains { $0.declaration == "SUPRASection" && $0.destination == "Models" })
    }
}
