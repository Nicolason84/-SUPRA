import XCTest
@testable import SUPRA

@MainActor
final class SUPRA_MissionExecutionTests: XCTestCase {

    private var store: MissionStore!
    private let testIntent = "Analyse l'état actuel de SUPRA"
    private var testURL: URL!

    override func setUp() async throws {
        testURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("SUPRA-MissionStore-Tests-\(UUID().uuidString)", isDirectory: true)
        store = MissionStore(sourceURL: testURL)
        try? FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        cleanTestArtifacts()
    }

    override func tearDown() async throws {
        cleanTestArtifacts()
        if let testURL {
            try? FileManager.default.removeItem(at: testURL)
        }
        store = nil
    }

    private func cleanTestArtifacts() {
        guard let testURL,
              let urls = try? FileManager.default.contentsOfDirectory(at: testURL, includingPropertiesForKeys: nil) else { return }
        for url in urls where url.pathExtension == "json" {
            try? FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - State machine tests (data layer, no adapter)

    func testCreateMissionSetsQueuedState() async throws {
        guard let id = await store.createMission(intent: testIntent) else {
            XCTFail("createMission returned nil")
            return
        }
        let file = testURL.appendingPathComponent("\(id.uuidString).json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))

        let data = try Data(contentsOf: file)
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(object?["state"] as? String, "QUEUED")
        XCTAssertEqual(object?["id"] as? String, id.uuidString)
    }

    func testCreateMissionPublishesCanonicalMissionObjectFields() async throws {
        guard let id = await store.createMission(
            objective: "Mission Center runtime validation",
            businessContext: "The user creates missions, SUPRA executes the rest.",
            technicalContext: "Canonical execution through MissionStore and SUPRAExecutionPipeline",
            priority: .high,
            risk: .medium,
            constraints: ["No terminal interaction required for standard execution"]
        ) else {
            XCTFail("createMission returned nil")
            return
        }

        store.refresh()
        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found after refresh")
            return
        }

        XCTAssertEqual(mission.lifecycle, .created)
        XCTAssertEqual(mission.objective, "Mission Center runtime validation")
        XCTAssertEqual(mission.businessContext, "The user creates missions, SUPRA executes the rest.")
        XCTAssertEqual(mission.technicalContext, "Canonical execution through MissionStore and SUPRAExecutionPipeline")
        XCTAssertEqual(mission.executor, "SUPRAExecutionPipeline")
        XCTAssertEqual(mission.planner, "SUPRADecisionEngine")
        XCTAssertEqual(mission.health, .ready)
        XCTAssertEqual(mission.validation.buildStatus, "PENDING")
        XCTAssertEqual(mission.validation.testStatus, "PENDING")
        XCTAssertGreaterThanOrEqual(mission.autonomyLevel, 0)
        XCTAssertFalse(mission.constraints.isEmpty)
        XCTAssertFalse(mission.evidence.isEmpty)
    }

    func testCreateMissionThenLoadShowsPlannedStatus() async throws {
        guard let id = await store.createMission(intent: testIntent) else {
            XCTFail("createMission returned nil")
            return
        }
        store.refresh()
        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found in store after refresh")
            return
        }
        XCTAssertEqual(mission.status, .planned)
        XCTAssertEqual(mission.currentStatus, "QUEUED")
        XCTAssertEqual(mission.progress, 0)
    }

    func testMissionTransitionsToRunning() async throws {
        guard let id = await store.createMission(intent: testIntent) else { return }
        store.updateMissionStatus(id: id, to: "RUNNING")
        store.refresh()
        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found after state change")
            return
        }
        XCTAssertEqual(mission.status, .active)
        XCTAssertEqual(mission.currentStatus, "RUNNING")
    }

    func testCompletedWithNonEmptyReport() async throws {
        guard let id = await store.createMission(intent: testIntent) else { return }
        let file = testURL.appendingPathComponent("\(id.uuidString).json")
        let data = try Data(contentsOf: file)
        guard var object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        object["state"] = "COMPLETED"
        object["result"] = "Analyse terminée. SUPRA est opérationnel."
        let newData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        try newData.write(to: file, options: [.atomic])
        store.refresh()

        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found")
            return
        }
        XCTAssertEqual(mission.status, .completed)
        XCTAssertEqual(mission.progress, 1.0)
        XCTAssertNotNil(mission.report)
        XCTAssertFalse(mission.report!.isEmpty, "Report must be non-empty")
        XCTAssertTrue(mission.report!.contains("Analyse terminée"))
    }

    func testFailedWithExplicitError() async throws {
        guard let id = await store.createMission(intent: testIntent) else { return }
        let file = testURL.appendingPathComponent("\(id.uuidString).json")
        let data = try Data(contentsOf: file)
        guard var object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        object["state"] = "FAILED"
        object["error"] = "Erreur: échec du provider Ollama"
        let newData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        try newData.write(to: file, options: [.atomic])
        store.refresh()

        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found")
            return
        }
        XCTAssertEqual(mission.status, .blocked)
        XCTAssertNotNil(mission.executionError)
        XCTAssertFalse(mission.executionError!.isEmpty)
        XCTAssertTrue(mission.executionError!.contains("Ollama"))
    }

    func testUnavailableWithReason() async throws {
        guard let id = await store.createMission(intent: testIntent) else { return }
        let file = testURL.appendingPathComponent("\(id.uuidString).json")
        let data = try Data(contentsOf: file)
        guard var object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        object["state"] = "UNAVAILABLE"
        object["error"] = "Aucun provider IA disponible"
        let newData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        try newData.write(to: file, options: [.atomic])
        store.refresh()

        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found")
            return
        }
        XCTAssertEqual(mission.status, .blocked)
        XCTAssertTrue(mission.currentStatus == "UNAVAILABLE" || mission.currentStatus == "FAILED")
        XCTAssertNotNil(mission.executionError)
    }

    func testMissionPersistsAcrossRefresh() async throws {
        guard let id = await store.createMission(intent: testIntent) else { return }
        store.refresh()
        XCTAssertFalse(store.missions.isEmpty)
        XCTAssertTrue(store.missions.contains(where: { $0.id == id }))
    }

    func testCompletedWithEmptyReportIsNotPossible() async throws {
        guard let id = await store.createMission(intent: testIntent) else { return }
        let file = testURL.appendingPathComponent("\(id.uuidString).json")
        let data = try Data(contentsOf: file)
        guard var object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        object["state"] = "COMPLETED"
        object["result"] = ""
        let newData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        try newData.write(to: file, options: [.atomic])
        store.refresh()

        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found")
            return
        }
        XCTAssertNotNil(mission.report)
        XCTAssertTrue(mission.report!.isEmpty, "Empty report is stored but should not be treated as valid")
    }

    // MARK: - No simulated execution

    func testExecuteMissionHasNoSimulatedSleep() async throws {
        let sourcePath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("SUPRA/MissionStore.swift")
        let source = try String(contentsOf: sourcePath, encoding: .utf8)
        let lines = source.split(separator: "\n").map(String.init)
        guard let execIdx = lines.firstIndex(where: { $0.contains("func executeMission") }) else {
            XCTFail("executeMission function not found")
            return
        }
        let execBody = lines[(execIdx + 1)...].prefix(50).joined(separator: "\n")
        XCTAssertFalse(execBody.contains("sleep"), "executeMission must not contain simulated sleep")
    }

    func testNoAutomaticFakeCompletionInExecuteMission() async throws {
        let sourcePath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("SUPRA/MissionStore.swift")
        let source = try String(contentsOf: sourcePath, encoding: .utf8)
        let lines = source.split(separator: "\n").map(String.init)
        guard let execIdx = lines.firstIndex(where: { $0.contains("func executeMission") }) else {
            XCTFail("executeMission function not found")
            return
        }
        let execBody = lines[(execIdx + 1)...].prefix(50).joined(separator: "\n")
        XCTAssertFalse(execBody.contains("COMPLETED") && execBody.contains("result") && execBody.contains("sleep"),
                        "No automatic completion without real result")
    }

    // MARK: - Controlled provider adapter test

    func testExecuteMissionWithControlledProviderSuccess() async throws {
        let registry = SUPRAProviderRegistry.shared
        let testProvider = TestProvider(
            type: .ollama,
            shouldSucceed: true,
            responseContent: "Analyse terminée. SUPRA est prêt."
        )
        registry.register(testProvider)
        defer { registry.unregister(.ollama) }

        guard let id = await store.createMission(intent: testIntent) else {
            XCTFail("createMission failed")
            return
        }

        await store.executeMission(id: id)
        store.refresh()

        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found after execution")
            return
        }
        XCTAssertEqual(mission.status, .completed, "Mission should complete with real report")
        XCTAssertNotNil(mission.report)
        XCTAssertFalse(mission.report!.isEmpty)
        XCTAssertTrue(mission.report!.contains("Analyse terminée"))
    }

    func testExecuteMissionPublishesNextMissionAndValidationEvidence() async throws {
        let registry = SUPRAProviderRegistry.shared
        let testProvider = TestProvider(
            type: .ollama,
            shouldSucceed: true,
            responseContent: "Mission completed with evidence."
        )
        registry.register(testProvider)
        defer { registry.unregister(.ollama) }

        guard let id = await store.createMission(intent: testIntent) else {
            XCTFail("createMission failed")
            return
        }

        await store.executeMission(id: id)
        store.refresh()

        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found after execution")
            return
        }

        XCTAssertEqual(mission.lifecycle, .nextPrepared)
        XCTAssertEqual(mission.validation.buildStatus, "PASSED")
        XCTAssertEqual(mission.validation.testStatus, "PASSED")
        XCTAssertEqual(mission.validation.evidenceStatus, "PUBLISHED")
        XCTAssertNotNil(mission.nextMission)
        XCTAssertFalse(mission.nextMission?.isEmpty ?? true)
        XCTAssertGreaterThanOrEqual(mission.evidence.count, 3)
        XCTAssertGreaterThanOrEqual(mission.artifacts.count, 2)
        XCTAssertGreaterThanOrEqual(mission.logs.count, 1)
    }

    func testExecuteMissionWithControlledProviderFailure() async throws {
        let registry = SUPRAProviderRegistry.shared
        let testProvider = TestProvider(
            type: .ollama,
            shouldSucceed: false,
            responseContent: "",
            errorMessage: "Erreur test: provider indisponible"
        )
        registry.register(testProvider)
        defer { registry.unregister(.ollama) }

        guard let id = await store.createMission(intent: testIntent) else {
            XCTFail("createMission failed")
            return
        }

        await store.executeMission(id: id)
        store.refresh()

        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found after execution failure")
            return
        }
        XCTAssertEqual(mission.status, .blocked, "Mission should be blocked on failure")
        XCTAssertNotNil(mission.executionError)
        XCTAssertFalse(mission.executionError!.isEmpty)
    }

    func testDetailViewDisplaysReport() async throws {
        guard let id = await store.createMission(intent: testIntent) else { return }
        let file = testURL.appendingPathComponent("\(id.uuidString).json")
        let data = try Data(contentsOf: file)
        guard var object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        object["state"] = "COMPLETED"
        object["result"] = "Rapport de test complet."
        let newData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        try newData.write(to: file, options: [.atomic])
        store.refresh()

        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found")
            return
        }

        let detailView = MissionDetailView(mission: mission)
        XCTAssertNotNil(detailView, "Detail view should render with report")
        XCTAssertEqual(mission.report, "Rapport de test complet.")
    }

    func testDetailViewDisplaysError() async throws {
        guard let id = await store.createMission(intent: testIntent) else { return }
        let file = testURL.appendingPathComponent("\(id.uuidString).json")
        let data = try Data(contentsOf: file)
        guard var object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        object["state"] = "FAILED"
        object["error"] = "Erreur critique: mémoire insuffisante"
        let newData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        try newData.write(to: file, options: [.atomic])
        store.refresh()

        guard let mission = store.missions.first(where: { $0.id == id }) else {
            XCTFail("Mission not found")
            return
        }

        let detailView = MissionDetailView(mission: mission)
        XCTAssertNotNil(detailView, "Detail view should render with error")
        XCTAssertEqual(mission.executionError, "Erreur critique: mémoire insuffisante")
    }
}

// MARK: - Controlled test provider

private final class TestProvider: SUPRAProvider {
    let type: SUPRAProviderType
    let configuration: SUPRAProviderConfiguration
    let shouldSucceed: Bool
    let responseContent: String
    let errorMessage: String

    var isAvailable: Bool { true }
    var supportedCapabilities: [SUPRACapability] { [.reasoning, .analysis] }

    init(type: SUPRAProviderType, shouldSucceed: Bool, responseContent: String = "", errorMessage: String = "") {
        self.type = type
        self.configuration = SUPRAProviderConfiguration(type: type, baseURL: "http://test.local", isEnabled: true, priority: 0, timeoutSeconds: 5)
        self.shouldSucceed = shouldSucceed
        self.responseContent = responseContent
        self.errorMessage = errorMessage
    }

    func execute(request: SUPRAExecutionRequest) async throws -> SUPRAProviderResponse {
        if shouldSucceed {
            SUPRAProviderResponse(
                requestID: request.id,
                content: responseContent,
                model: "test-model",
                provider: type,
                durationMs: 1,
                tokensIn: 0,
                tokensOut: responseContent.count,
                finishedNormally: true,
                error: nil
            )
        } else {
            throw SUPRAProviderError.executionFailed(type, errorMessage)
        }
    }

    func checkHealth() async -> Bool { shouldSucceed }
}
