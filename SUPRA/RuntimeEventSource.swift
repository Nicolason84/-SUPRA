import Foundation
import Combine
import SwiftUI

final class JSONRuntimeSource: RuntimeSourceProtocol {
    let mode: RuntimeSourceMode = .json

    @Published private(set) var connectionState: RuntimeConnectionState = .disconnected
    @Published private(set) var events: [RuntimeEvent] = []
    @Published private(set) var health = RuntimeHealth.initial

    weak var dataService: RuntimeDataService?

    private var pollTask: Task<Void, Never>?
    private var lastModificationDates: [String: Date] = [:]
    private let decoder = JSONDecoder()
    private let maxEvents = 200

    private let watchedFiles = [
        "runtime_trace.json", "delegation_trace.json", "runtime_metrics.json",
        "agent_execution.json", "consensus_report.json", "execution_graph.json",
        "provider_metrics.json", "mission_graph_metrics.json", "dashboard_snapshot.json"
    ]

    private var baseURL: URL {
        URL(fileURLWithPath: dataService?.runtimePath ?? FileManager.default.currentDirectoryPath)
    }

    func start() {
        stop()
        connectionState = .connecting
        addEvent(.info, title: "JSON source started", detail: "Watching \(baseURL.path)")

        pollTask = Task { [weak self] in
            guard let self else { return }
            self.connectionState = .connected
            while !Task.isCancelled {
                self.poll()
                try? await Task.sleep(for: .seconds(3))
            }
        }
    }

    func stop() {
        pollTask?.cancel()
        pollTask = nil
        lastModificationDates = [:]
        connectionState = .disconnected
    }

    func refresh() {
        poll()
    }

    private func poll() {
        let base = baseURL
        var changedFiles: [String] = []

        for filename in watchedFiles {
            let url = base.appendingPathComponent(filename)
            guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                  let modDate = attrs[.modificationDate] as? Date
            else { continue }

            if let lastMod = lastModificationDates[filename] {
                if modDate != lastMod {
                    changedFiles.append(filename)
                    lastModificationDates[filename] = modDate
                }
            } else {
                lastModificationDates[filename] = modDate
            }
        }

        if !changedFiles.isEmpty {
            let start = CFAbsoluteTimeGetCurrent()
            dataService?.load()
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)

            for file in changedFiles {
                let mission = inferMission()
                let type = eventType(for: file)
                addEvent(type, title: "File updated: \(file)", detail: "Detected change in runtime data", file: file, missionId: mission)
            }

            updateHealth(durationMs: elapsed)
        }

        let activeFiles = watchedFiles.filter { f in
            FileManager.default.fileExists(atPath: base.appendingPathComponent(f).path)
        }.count

        if activeFiles > 0 {
            var h = health
            h.fileCount = activeFiles
            h.isConnected = true
            h.lastSyncDate = Date()
            if let exec = dataService?.agentExecution {
                h.agentCount = exec.agents.count
                h.activeMissionCount = exec.agents.filter { $0.state == "RUNNING" || $0.state == "dispatched" }.count
            }
            h.activeProviderCount = 2
            h.totalProviderCount = 3
            health = h
        }
    }

    private func updateHealth(durationMs: Int) {
        var h = health
        h.isConnected = true
        h.lastSyncDate = Date()
        h.lastSyncDurationMs = durationMs
        if let exec = dataService?.agentExecution {
            h.agentCount = exec.agents.count
            h.activeMissionCount = exec.agents.filter { $0.state == "RUNNING" || $0.state == "dispatched" }.count
        }
        h.activeProviderCount = 2
        h.totalProviderCount = 3
        health = h
    }

    private func addEvent(_ type: RuntimeEventType, title: String, detail: String = "", file: String? = nil, missionId: String? = nil) {
        let event = RuntimeEvent(type: type, title: title, detail: detail, sourceFile: file, missionId: missionId)
        events.insert(event, at: 0)
        if events.count > maxEvents {
            events = Array(events.prefix(maxEvents))
        }
    }

    private func eventType(for file: String) -> RuntimeEventType {
        switch file {
        case "runtime_trace.json": .schedulerAction
        case "delegation_trace.json": .agentSelected
        case "runtime_metrics.json": .executionCompleted
        case "agent_execution.json": .executionStarted
        case "consensus_report.json": .validationPassed
        case "execution_graph.json": .dagGenerated
        case "mission_graph_metrics.json": .missionCompleted
        default: .info
        }
    }

    private func inferMission() -> String? {
        if let trace = dataService?.runtimeTrace { return trace.mission }
        if let del = dataService?.delegationTrace { return del.mission }
        return nil
    }
}

final class OpenCodeRuntimeSource: RuntimeSourceProtocol {
    let mode: RuntimeSourceMode = .opencode

    @Published private(set) var connectionState: RuntimeConnectionState = .disconnected

    func start() {
        connectionState = .connecting
        Task {
            try? await Task.sleep(for: .seconds(1))
            connectionState = .disconnected
        }
    }

    func stop() {
        connectionState = .disconnected
    }

    func refresh() {}
}
