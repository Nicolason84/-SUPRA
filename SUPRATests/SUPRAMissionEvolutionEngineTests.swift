import XCTest
@testable import SUPRA

@MainActor
final class SUPRAMissionEvolutionEngineTests: XCTestCase {
    func testMissionScoringEngineProducesBoundedScore() {
        let opportunity = MissionOpportunity(
            id: UUID(),
            title: "Reduce test failures",
            objective: "Stabilize the failing suite",
            businessContext: "Failing tests reduce mission reliability.",
            technicalContext: "Focused repair of a reproducible failing test target.",
            expectedValue: "Higher mission success rate",
            estimatedCost: "Low",
            expectedDurationMinutes: 20,
            dependencies: [],
            constraints: ["Preserve canonical runtime"],
            rollbackStrategy: "Revert the targeted patch",
            validationPlan: "Run the focused suite",
            expectedProof: "Passing tests",
            automationLevel: 0,
            priority: .high,
            risk: .medium,
            roi: 0.9,
            confidence: 0.85,
            evidenceSummary: "Failing tests observed",
            source: "TEST"
        )

        let score = MissionScoringEngine.score(opportunity)
        XCTAssertEqual(score.opportunityID, opportunity.id)
        XCTAssertGreaterThan(score.opportunityScore, 0)
        XCTAssertLessThanOrEqual(score.opportunityScore, 1)
    }

    func testAutonomyPolicyEngineRespectsHumanOnlyLevel() {
        let opportunity = MissionOpportunity(
            id: UUID(),
            title: "Strategic policy change",
            objective: "Change strategic direction",
            businessContext: "Business strategy decision",
            technicalContext: "Not reversible",
            expectedValue: "Unknown",
            estimatedCost: "High",
            expectedDurationMinutes: 120,
            dependencies: [],
            constraints: [],
            rollbackStrategy: "None",
            validationPlan: "Human review",
            expectedProof: "Decision record",
            automationLevel: 3,
            priority: .critical,
            risk: .critical,
            roi: 0.2,
            confidence: 0.6,
            evidenceSummary: "Human-only decision",
            source: "TEST"
        )

        let assessment = AutonomyPolicyEngine.assess(opportunity)
        XCTAssertEqual(assessment.level, 3)
        XCTAssertEqual(assessment.authority, .sovereignHumanOnly)
        XCTAssertFalse(assessment.executionAllowed)
    }

    func testMissionGeneratorCarriesExpectedMissionFields() {
        let opportunity = MissionOpportunity(
            id: UUID(),
            title: "Repair blocked mission",
            objective: "Fix the blocker",
            businessContext: "Blocked work must resume",
            technicalContext: "Mission failed with proof",
            expectedValue: "Restore throughput",
            estimatedCost: "Low",
            expectedDurationMinutes: 30,
            dependencies: ["Mission A"],
            constraints: ["No new runtime"],
            rollbackStrategy: "Keep original mission record",
            validationPlan: "Retry after repair",
            expectedProof: "Updated validation log",
            automationLevel: 1,
            priority: .high,
            risk: .medium,
            roi: 0.88,
            confidence: 0.91,
            evidenceSummary: "Mission blocked",
            source: "TEST"
        )

        let draft = MissionGenerator.generate(from: opportunity)
        XCTAssertEqual(draft.title, "Repair blocked mission")
        XCTAssertEqual(draft.authority, .supervised)
        XCTAssertFalse(draft.summary.isEmpty)
        XCTAssertGreaterThan(draft.priorityScore, 0)
    }

    func testExecutiveReviewerRejectsIncompleteDraft() {
        let draft = GeneratedMissionDraft(
            id: UUID(),
            title: "Incomplete",
            objective: "",
            businessContext: "Context",
            technicalContext: "Technical",
            expectedValue: "",
            estimatedCost: "Low",
            expectedDurationMinutes: 20,
            dependencies: [],
            constraints: [],
            rollbackStrategy: "",
            validationPlan: "",
            expectedProof: "",
            automationLevel: 0,
            authority: .autoExecute,
            priority: .medium,
            risk: .low,
            priorityScore: 0.2,
            roi: 0.1,
            confidence: 0.2,
            source: "TEST"
        )

        let review = ExecutiveReviewer.review(draft)
        XCTAssertFalse(review.passed)
        XCTAssertGreaterThanOrEqual(review.findings.count, 4)
    }

    func testMissionStoreCanCreateMissionFromGeneratedDraft() async throws {
        let testURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("SUPRA-MissionEvolution-Tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: testURL) }

        let store = MissionStore(sourceURL: testURL)
        let draft = GeneratedMissionDraft(
            id: UUID(),
            title: "Autogenerated mission",
            objective: "Improve queue determinism",
            businessContext: "Queue health affects automation.",
            technicalContext: "Observed duplicate planning work.",
            expectedValue: "Reduce manual intervention",
            estimatedCost: "Low",
            expectedDurationMinutes: 25,
            dependencies: [],
            constraints: ["No parallel runtime"],
            rollbackStrategy: "Revert queue patch",
            validationPlan: "Run mission queue tests",
            expectedProof: "Passing queue validation",
            automationLevel: 0,
            authority: .autoExecute,
            priority: .high,
            risk: .medium,
            priorityScore: 0.82,
            roi: 0.77,
            confidence: 0.9,
            source: "TEST"
        )

        let id = await store.createMission(from: draft)
        XCTAssertNotNil(id)
        store.refresh()

        let mission = store.missions.first(where: { $0.id == id })
        XCTAssertEqual(mission?.title, "Autogenerated mission")
        XCTAssertEqual(mission?.priority, .high)
        XCTAssertEqual(mission?.risk, .medium)
        XCTAssertTrue(mission?.summary.contains("Expected Value: Reduce manual intervention") ?? false)
    }
}
