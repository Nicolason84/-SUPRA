import XCTest
@testable import SUPRA

@MainActor
final class SUPRARuntimeLoopTests: XCTestCase {
    private var missionStore: MissionStore!
    private var workspaceRoot: URL!
    private var memoryRoot: URL!
    private var missionRoot: URL!

    override func setUpWithError() throws {
        workspaceRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        memoryRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("SUPRA-Runtime-Memory-\(UUID().uuidString)", isDirectory: true)
        missionRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("SUPRA-Runtime-Missions-\(UUID().uuidString)", isDirectory: true)

        try FileManager.default.createDirectory(at: memoryRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: missionRoot, withIntermediateDirectories: true)
        missionStore = MissionStore(sourceURL: missionRoot)
    }

    override func tearDownWithError() throws {
        SUPRAProviderRegistry.shared.unregister(.ollama)
        if let memoryRoot {
            try? FileManager.default.removeItem(at: memoryRoot)
        }
        if let missionRoot {
            try? FileManager.default.removeItem(at: missionRoot)
        }
    }

    func testRuntimeLoopCompletesIterationAndUpdatesMemory() async throws {
        let provider = LoopTestProvider(
            type: .ollama,
            responseContent: "Execution report: repository analysed and next action prepared."
        )
        SUPRAProviderRegistry.shared.register(provider)
        SUPRAModelRegistry.shared.loadDefaults()

        let loop = SUPRARuntimeLoop(
            missionStore: missionStore,
            runtimeMonitor: RuntimeMonitor(dataService: RuntimeDataService.shared),
            workspaceMemoryStore: WorkspaceMemoryStore(baseURL: memoryRoot),
            validationRunner: TestValidationRunner(),
            projectRootURL: workspaceRoot
        )

        let result = await loop.runIteration()

        XCTAssertNotNil(result)
        XCTAssertTrue((result?.workspace.fileCount ?? 0) > 0)
        XCTAssertTrue((result?.workspace.swiftFileCount ?? 0) > 0)
        XCTAssertEqual(result?.executiveState.observation.workspace.rootPath, workspaceRoot.path)
        XCTAssertEqual(result?.executiveState.decision.priority, .closeEvidenceGap)
        XCTAssertFalse(result?.executiveState.mission.objective.isEmpty ?? true)
        XCTAssertFalse(result?.executiveState.mission.validationCriteria.isEmpty ?? true)
        XCTAssertTrue(result?.validation.buildSucceeded == true)
        XCTAssertTrue(result?.validation.testSucceeded == true)
        XCTAssertTrue(result?.memoryUpdated == true)
        XCTAssertEqual(result?.finalState, .ready)
        XCTAssertEqual(
            result?.generatedMission.state,
            "COMPLETED",
            "mission error: \(result?.generatedMission.error ?? "nil") report: \(result?.generatedMission.report ?? "nil")"
        )
        XCTAssertTrue(
            result?.generatedMission.report?.contains("Execution report") == true,
            "mission error: \(result?.generatedMission.error ?? "nil") report: \(result?.generatedMission.report ?? "nil")"
        )
        XCTAssertTrue(result?.executiveState.learning.lessonsLearned.contains(where: { $0.contains("Priority selected") }) == true)
        XCTAssertTrue(result?.executiveState.nextIterationPrepared == true)
        XCTAssertTrue(result?.nextExecutiveMission.contains("NEXT EXECUTIVE MISSION") == true)
        XCTAssertNotNil(InferenceSovereigntyRuntime.shared.lastDecision)
        XCTAssertEqual(InferenceSovereigntyRuntime.shared.lastResponse?.provider, .ollama)
        XCTAssertEqual(
            result?.transitions.map(\.state),
            [.boot, .observe, .understand, .decide, .prepare, .execute, .validate, .learn, .freeze, .ready]
        )
        XCTAssertTrue(result?.transitions.dropLast().allSatisfy { transition in
            guard let next = transition.nextState else { return false }
            return SUPRARuntimeLoop.isTransitionAllowed(from: transition.state, to: next)
        } == true)
        XCTAssertNil(result?.rootCause)
    }
}

private struct TestValidationRunner: SUPRABuildValidationRunning {
    func run(projectRoot: URL) async -> SUPRAValidationSummary {
        SUPRAValidationSummary(
            buildSucceeded: true,
            testSucceeded: true,
            buildOutput: "BUILD SUCCEEDED",
            testOutput: "TEST SUCCEEDED",
            validatedAt: Date()
        )
    }
}

private final class LoopTestProvider: SUPRAProvider {
    let type: SUPRAProviderType
    let configuration: SUPRAProviderConfiguration
    let responseContent: String

    init(type: SUPRAProviderType, responseContent: String) {
        self.type = type
        self.responseContent = responseContent
        self.configuration = SUPRAProviderConfiguration(
            type: type,
            baseURL: "http://test.local",
            isEnabled: true,
            priority: 0,
            timeoutSeconds: 5
        )
    }

    var isAvailable: Bool { true }
    var supportedCapabilities: [SUPRACapability] { SUPRACapability.allCases }

    func execute(request: SUPRAExecutionRequest) async throws -> SUPRAProviderResponse {
        SUPRAProviderResponse(
            requestID: request.id,
            content: responseContent,
            model: "loop-test-model",
            provider: type,
            durationMs: 1,
            tokensIn: request.prompt.count,
            tokensOut: responseContent.count,
            finishedNormally: true,
            error: nil
        )
    }

    func checkHealth() async -> Bool { true }
}
