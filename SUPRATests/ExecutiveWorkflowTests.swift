import XCTest
@testable import SUPRA

@MainActor
final class ExecutiveWorkflowTests: XCTestCase {
    private let expectedWorkflowIDs: Set<String> = [
        "business_health",
        "decision_audit",
        "monetization_report",
        "environment_assessment",
        "opportunity_discovery"
    ]

    func testRegistryContainsExactlyFiveUniqueReadyWorkflows() {
        let workflows = ExecutiveWorkflowRegistry.shared.workflows
        let workflowIDs = Set(workflows.map(\.id))

        XCTAssertEqual(workflows.count, 5)
        XCTAssertEqual(workflowIDs.count, workflows.count)
        XCTAssertEqual(workflowIDs, expectedWorkflowIDs)
        XCTAssertTrue(workflows.allSatisfy { $0.status == .ready })
    }

    func testExecutiveSpaceWorkflowsMetadata() {
        XCTAssertEqual(ExecutiveSpace.workflows.rawValue, "Workflows")
        XCTAssertEqual(ExecutiveSpace.workflows.icon, "square.grid.2x2.fill")
        XCTAssertTrue(ExecutiveSpace.allCases.contains(.workflows))
    }
}
