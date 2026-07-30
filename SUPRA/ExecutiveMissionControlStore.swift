import Foundation
import Combine

@MainActor
final class ExecutiveMissionControlStore: ObservableObject {
    static let shared = ExecutiveMissionControlStore()

    @Published private(set) var runtime: ExecutiveRuntimeSnapshot?
    @Published private(set) var agents: [ExecutiveAgentSnapshot] = []
    @Published private(set) var missions: [ExecutiveMissionSnapshot] = []
    @Published private(set) var timeline: [ExecutiveRuntimeEvent] = []
    @Published private(set) var alerts: [ExecutiveRuntimeAlert] = []
    @Published private(set) var lastReload: Date?
    @Published private(set) var loadError: String?

    let heartbeatTimeout: TimeInterval
    let agentTimeout: TimeInterval

    private let rootURL: URL
    private let fileManager: FileManager
    private let decoder: JSONDecoder
    private var directorySources: [DispatchSourceFileSystemObject] = []
    private var heartbeatTask: Task<Void, Never>?
    private var reloadTask: Task<Void, Never>?
    private var directoryDescriptors: [Int32] = []

    init(
        rootURL: URL? = nil,
        fileManager: FileManager = .default,
        heartbeatTimeout: TimeInterval = 30,
        agentTimeout: TimeInterval = 120
    ) {
        self.fileManager = fileManager
        self.rootURL = rootURL ?? Self.configuredRootURL()
        self.heartbeatTimeout = heartbeatTimeout
        self.agentTimeout = agentTimeout
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    deinit {
        directorySources.forEach { $0.cancel() }
        directoryDescriptors.forEach { close($0) }
        heartbeatTask?.cancel()
        reloadTask?.cancel()
    }

    func start() {
        stop()
        reload()
        beginDirectoryObservation()
        heartbeatTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                guard !Task.isCancelled else { return }
                self?.evaluateAlerts(now: Date())
            }
        }
    }

    func stop() {
        directorySources.forEach { $0.cancel() }
        directorySources = []
        directoryDescriptors.forEach { close($0) }
        directoryDescriptors = []
        heartbeatTask?.cancel()
        heartbeatTask = nil
        reloadTask?.cancel()
        reloadTask = nil
    }

    func reload() {
        let root = rootURL
        let decoder = decoder
        let manager = fileManager

        do {
            runtime = try decodeOptional(ExecutiveRuntimeSnapshot.self, at: root.appendingPathComponent("runtime.json"))
            agents = try decodeDirectory(ExecutiveAgentSnapshot.self, at: root.appendingPathComponent("agents"), decoder: decoder, manager: manager)
                .sorted { $0.agentName.localizedCaseInsensitiveCompare($1.agentName) == .orderedAscending }
            missions = try decodeDirectory(ExecutiveMissionSnapshot.self, at: root.appendingPathComponent("missions"), decoder: decoder, manager: manager)
                .sorted { $0.updatedAt > $1.updatedAt }
            timeline = try decodeEvents(at: root, decoder: decoder, manager: manager)
            let published = try decodeOptional([ExecutiveRuntimeAlert].self, at: root.appendingPathComponent("alerts.json")) ?? []
            alerts = deduplicated(published + generatedAlerts(now: Date()))
                .sorted { $0.timestamp > $1.timestamp }
            lastReload = Date()
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    func evaluateAlerts(now: Date) {
        let published = (try? decodeOptional([ExecutiveRuntimeAlert].self, at: rootURL.appendingPathComponent("alerts.json"))) ?? []
        alerts = deduplicated((published ?? []) + generatedAlerts(now: now))
            .sorted { $0.timestamp > $1.timestamp }
    }

    var activeAgents: [ExecutiveAgentSnapshot] {
        agents.filter { [.running, .waiting, .blocked].contains($0.status) }
    }

    var missionProgress: Double {
        guard !missions.isEmpty else { return 0 }
        return missions.map(\.progress).reduce(0, +) / Double(missions.count)
    }

    var evidence: [String] {
        Array(Set(
            timeline.flatMap(\.evidence)
                + alerts.flatMap(\.evidence)
                + agents.flatMap(\.filesModified)
        )).sorted()
    }

    private static func configuredRootURL() -> URL {
        if let configured = UserDefaults.standard.string(forKey: "executiveRuntimePath"), !configured.isEmpty {
            return URL(fileURLWithPath: configured, isDirectory: true)
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
            .appendingPathComponent(".runtime", isDirectory: true)
    }

    private func beginDirectoryObservation() {
        let observedURLs = [
            rootURL,
            rootURL.appendingPathComponent("agents", isDirectory: true),
            rootURL.appendingPathComponent("missions", isDirectory: true),
            rootURL.appendingPathComponent("events", isDirectory: true),
            rootURL.appendingPathComponent("freeze", isDirectory: true)
        ]

        for url in observedURLs where fileManager.fileExists(atPath: url.path) {
            let descriptor = open(url.path, O_EVTONLY)
            guard descriptor >= 0 else { continue }
            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: descriptor,
                eventMask: [.write, .extend, .attrib, .rename],
                queue: .global(qos: .utility)
            )
            source.setEventHandler { [weak self] in
                Task { @MainActor [weak self] in
                    self?.scheduleReload()
                }
            }
            directoryDescriptors.append(descriptor)
            directorySources.append(source)
            source.resume()
        }
    }

    private func scheduleReload() {
        reloadTask?.cancel()
        reloadTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }
            self?.reload()
        }
    }

    private func decodeOptional<T: Decodable>(_ type: T.Type, at url: URL) throws -> T? {
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return try decoder.decode(type, from: Data(contentsOf: url, options: .mappedIfSafe))
    }

    private func decodeDirectory<T: Decodable>(
        _ type: T.Type,
        at url: URL,
        decoder: JSONDecoder,
        manager: FileManager
    ) throws -> [T] {
        guard manager.fileExists(atPath: url.path) else { return [] }
        return try manager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension.lowercased() == "json" }
            .map { try decoder.decode(type, from: Data(contentsOf: $0, options: .mappedIfSafe)) }
    }

    private func decodeEvents(at root: URL, decoder: JSONDecoder, manager: FileManager) throws -> [ExecutiveRuntimeEvent] {
        let eventsURL = root.appendingPathComponent("events.json")
        if manager.fileExists(atPath: eventsURL.path) {
            return try decoder.decode([ExecutiveRuntimeEvent].self, from: Data(contentsOf: eventsURL))
                .sorted { $0.timestamp > $1.timestamp }
        }
        return try decodeDirectory(ExecutiveRuntimeEvent.self, at: root.appendingPathComponent("events"), decoder: decoder, manager: manager)
            .sorted { $0.timestamp > $1.timestamp }
    }

    private func generatedAlerts(now: Date) -> [ExecutiveRuntimeAlert] {
        var result: [ExecutiveRuntimeAlert] = []

        if let runtime {
            if now.timeIntervalSince(runtime.heartbeat) > heartbeatTimeout {
                result.append(alert(.heartbeatTimeout, .critical, "Runtime heartbeat timeout", runtime.runtimeID, now, ["runtime.json"]))
            }
            if runtime.status == .failed {
                result.append(alert(.runtimeCrash, .critical, "Runtime failed", runtime.runtimeID, now, ["runtime.json"]))
            }
            if runtime.writerCount > 1 {
                result.append(alert(.duplicateWriters, .critical, "Duplicate Runtime writers", "\(runtime.writerCount) writers detected", now, ["runtime.json"]))
            }
            if runtime.freezeStatus == .missing {
                result.append(alert(.missingFreeze, .warning, "Missing Executive Freeze", runtime.runtimeID, now, ["freeze/current_freeze.json"]))
            }
            if runtime.buildStatus == .failed {
                result.append(alert(.buildFailed, .critical, "Build failed", runtime.currentBuild ?? "Current build", now, ["runtime.json"]))
            }
            if runtime.buildStatus == .succeeded {
                result.append(alert(.buildSucceeded, .info, "Build succeeded", runtime.currentBuild ?? "Current build", now, ["runtime.json"]))
            }
        }

        for agent in agents {
            let heartbeatAge = now.timeIntervalSince(agent.heartbeat)
            if heartbeatAge > heartbeatTimeout {
                result.append(alert(.heartbeatTimeout, .critical, "\(agent.agentName) heartbeat timeout", agent.agentID, now, ["agents/\(agent.agentID).json"]))
            } else if now.timeIntervalSince(agent.lastUpdate) > agentTimeout, agent.status == .running {
                result.append(alert(.agentTimeout, .warning, "\(agent.agentName) update timeout", agent.currentTask, now, ["agents/\(agent.agentID).json"]))
            }
            if agent.testsFailed > 0 {
                result.append(alert(.regression, .critical, "Regression detected", "\(agent.testsFailed) failed test(s) · \(agent.agentName)", now, agent.filesModified))
            }
            if agent.errors.contains(where: { $0.localizedCaseInsensitiveContains("merge conflict") }) {
                result.append(alert(.mergeConflict, .critical, "Merge conflict", agent.agentName, now, agent.filesModified))
            }
            if agent.warnings.contains(where: { $0.localizedCaseInsensitiveContains("permission popup") }) {
                result.append(alert(.permissionPopupDetected, .warning, "Permission popup detected", agent.agentName, now, ["agents/\(agent.agentID).json"]))
            }
        }
        return result
    }

    private func alert(
        _ kind: ExecutiveAlertKind,
        _ severity: ExecutiveAlertSeverity,
        _ title: String,
        _ detail: String,
        _ timestamp: Date,
        _ evidence: [String]
    ) -> ExecutiveRuntimeAlert {
        ExecutiveRuntimeAlert(
            alertID: "derived:\(kind.rawValue):\(detail)",
            kind: kind,
            severity: severity,
            title: title,
            detail: detail,
            timestamp: timestamp,
            sourceID: nil,
            evidence: evidence
        )
    }

    private func deduplicated(_ values: [ExecutiveRuntimeAlert]) -> [ExecutiveRuntimeAlert] {
        var seen = Set<String>()
        return values.filter { seen.insert($0.alertID).inserted }
    }
}
