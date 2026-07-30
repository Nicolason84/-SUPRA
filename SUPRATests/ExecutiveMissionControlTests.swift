import XCTest
@testable import SUPRA

@MainActor
final class ExecutiveMissionControlTests: XCTestCase {
    private var rootURL: URL!
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    override func setUpWithError() throws {
        rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("SUPRA-Mission-Control-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: rootURL.appendingPathComponent("agents"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: rootURL.appendingPathComponent("missions"), withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let rootURL {
            try? FileManager.default.removeItem(at: rootURL)
        }
    }

    func testMultipleProvidersHeartbeatTimelineAndMissionProgress() throws {
        let now = Date()
        try write(runtime(now: now), to: rootURL.appendingPathComponent("runtime.json"))
        try write(agent(id: "builder-01", name: "Builder", provider: "codex", heartbeat: now), to: rootURL.appendingPathComponent("agents/builder-01.json"))
        try write(agent(id: "validator-01", name: "Validator", provider: "ollama", heartbeat: now), to: rootURL.appendingPathComponent("agents/validator-01.json"))
        try write([
            ExecutiveMissionSnapshot(
                missionID: "mission-001",
                title: "Executive Mission Control",
                objective: "Structured supervision",
                phase: "validation",
                progress: 0.75,
                status: .running,
                startedAt: now.addingTimeInterval(-300),
                updatedAt: now,
                eta: now.addingTimeInterval(120),
                agentIDs: ["builder-01", "validator-01"]
            )
        ].first!, to: rootURL.appendingPathComponent("missions/mission-001.json"))
        try write([
            event(id: "event-2", title: "Validation completed", timestamp: now),
            event(id: "event-1", title: "Agent started", timestamp: now.addingTimeInterval(-10))
        ], to: rootURL.appendingPathComponent("events.json"))

        let store = ExecutiveMissionControlStore(rootURL: rootURL)
        store.reload()

        XCTAssertEqual(store.agents.count, 2)
        XCTAssertEqual(Set(store.agents.map(\.providerID)), Set(["codex", "ollama"]))
        XCTAssertEqual(store.activeAgents.count, 2)
        XCTAssertEqual(store.missionProgress, 0.75, accuracy: 0.001)
        XCTAssertEqual(store.timeline.map(\.eventID), ["event-2", "event-1"])
        XCTAssertFalse(store.alerts.contains { $0.kind == .heartbeatTimeout })
    }

    func testAlertEngineDetectsTimeoutFailureRegressionFreezeAndDuplicateWriterWithoutDuplicates() throws {
        let now = Date()
        let stale = now.addingTimeInterval(-600)
        let failedRuntime = ExecutiveRuntimeSnapshot(
            runtimeID: "runtime-01",
            status: .failed,
            heartbeat: stale,
            version: "1.0",
            writerID: "runtime-writer",
            writerCount: 2,
            buildStatus: .failed,
            currentBuild: "SUPRA Debug",
            freezeStatus: .missing,
            providers: []
        )
        var failedAgent = agent(id: "builder-01", name: "Builder", provider: "codex", heartbeat: stale)
        failedAgent = ExecutiveAgentSnapshot(
            agentID: failedAgent.agentID,
            agentName: failedAgent.agentName,
            providerID: failedAgent.providerID,
            role: failedAgent.role,
            currentTask: failedAgent.currentTask,
            currentPhase: failedAgent.currentPhase,
            progress: failedAgent.progress,
            status: failedAgent.status,
            lastUpdate: stale,
            currentFile: failedAgent.currentFile,
            filesModified: failedAgent.filesModified,
            testsRunning: [],
            testsPassed: 9,
            testsFailed: 1,
            warnings: ["Permission popup detected"],
            errors: ["Merge conflict in Mission.swift"],
            eta: nil,
            branch: "mission-control",
            buildStatus: .failed,
            freezeStatus: .missing,
            heartbeat: stale
        )
        try write(failedRuntime, to: rootURL.appendingPathComponent("runtime.json"))
        try write(failedAgent, to: rootURL.appendingPathComponent("agents/builder-01.json"))

        let store = ExecutiveMissionControlStore(rootURL: rootURL, heartbeatTimeout: 30, agentTimeout: 60)
        store.reload()
        store.evaluateAlerts(now: now)
        store.evaluateAlerts(now: now)

        let kinds = Set(store.alerts.map(\.kind))
        XCTAssertTrue(kinds.isSuperset(of: [
            .heartbeatTimeout, .runtimeCrash, .duplicateWriters, .missingFreeze,
            .buildFailed, .regression, .mergeConflict, .permissionPopupDetected
        ]))
        XCTAssertEqual(store.alerts.count, Set(store.alerts.map(\.alertID)).count)
    }

    private func runtime(now: Date) -> ExecutiveRuntimeSnapshot {
        ExecutiveRuntimeSnapshot(
            runtimeID: "runtime-01",
            status: .running,
            heartbeat: now,
            version: "1.0",
            writerID: "runtime-writer",
            writerCount: 1,
            buildStatus: .running,
            currentBuild: "SUPRA Debug",
            freezeStatus: .current,
            providers: [
                ExecutiveProviderSnapshot(providerID: "codex", providerName: "Codex", status: .running, lastHeartbeat: now, activeAgents: 1, detail: nil),
                ExecutiveProviderSnapshot(providerID: "ollama", providerName: "Ollama", status: .running, lastHeartbeat: now, activeAgents: 1, detail: nil)
            ]
        )
    }

    private func agent(id: String, name: String, provider: String, heartbeat: Date) -> ExecutiveAgentSnapshot {
        ExecutiveAgentSnapshot(
            agentID: id,
            agentName: name,
            providerID: provider,
            role: name.lowercased(),
            currentTask: "Mission Control",
            currentPhase: "implementation",
            progress: 0.5,
            status: .running,
            lastUpdate: heartbeat,
            currentFile: "ExecutiveMissionControlStore.swift",
            filesModified: ["SUPRA/ExecutiveMissionControlStore.swift"],
            testsRunning: ["ExecutiveMissionControlTests"],
            testsPassed: 0,
            testsFailed: 0,
            warnings: [],
            errors: [],
            eta: heartbeat.addingTimeInterval(300),
            branch: "mission-control",
            buildStatus: .running,
            freezeStatus: .current,
            heartbeat: heartbeat
        )
    }

    private func event(id: String, title: String, timestamp: Date) -> ExecutiveRuntimeEvent {
        ExecutiveRuntimeEvent(
            eventID: id,
            timestamp: timestamp,
            type: "validation",
            title: title,
            detail: nil,
            missionID: "mission-001",
            agentID: nil,
            evidence: []
        )
    }

    private func write<T: Encodable>(_ value: T, to url: URL) throws {
        try encoder.encode(value).write(to: url, options: .atomic)
    }
}
