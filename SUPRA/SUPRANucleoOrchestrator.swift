import Foundation
import Combine

// MARK: - Nucleo Request / Response

enum NucleoRequestSource: String, Codable {
    case opencode
    case api
    case scheduler
    case user
    case mission
    case `internal`
}

enum NucleoExecutor: String, Codable {
    case mission
    case decision
    case resource
    case runtime
    case knowledge
    case canonical
    case scheduler
    case observer
    case intelligence
}

struct NucleoRequest: Codable {
    let id: String
    let source: NucleoRequestSource
    let executor: NucleoExecutor
    let payload: [String: String]
    let timeout: TimeInterval?
    let timestamp: String
}

struct NucleoResponse: Codable {
    let id: String
    let requestId: String
    let status: NucleoStatus
    let data: [String: String]?
    let error: String?
    let elapsedMs: Int
    let timestamp: String
}

enum NucleoStatus: String, Codable {
    case success
    case error
    case timeout
    case cancelled
}

// MARK: - TraceStore (Observabilité)

struct TraceRecord: Codable, Identifiable {
    let id: String
    let source: NucleoRequestSource
    let executor: NucleoExecutor
    let provider: String
    let model: String
    let promptTokens: Int
    let completionTokens: Int
    let elapsedMs: Int
    let cancelled: Bool
    let retryCount: Int
    let timeout: Bool
    let cacheHit: Bool
    let status: NucleoStatus
    let error: String?
    let timestamp: String

    init(id: String = UUID().uuidString,
         source: NucleoRequestSource,
         executor: NucleoExecutor,
         provider: String = "local",
         model: String = "",
         promptTokens: Int = 0,
         completionTokens: Int = 0,
         elapsedMs: Int,
         cancelled: Bool = false,
         retryCount: Int = 0,
         timeout: Bool = false,
         cacheHit: Bool = false,
         status: NucleoStatus,
         error: String? = nil,
         timestamp: String = ISO8601DateFormatter().string(from: Date())) {
        self.id = id
        self.source = source
        self.executor = executor
        self.provider = provider
        self.model = model
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.elapsedMs = elapsedMs
        self.cancelled = cancelled
        self.retryCount = retryCount
        self.timeout = timeout
        self.cacheHit = cacheHit
        self.status = status
        self.error = error
        self.timestamp = timestamp
    }
}

struct NucleoMetrics: Codable {
    let totalRequests: Int
    let successCount: Int
    let errorCount: Int
    let timeoutCount: Int
    let cancelledCount: Int
    let avgElapsedMs: Double
    let p95ElapsedMs: Double
    let byExecutor: [String: Int]
    let bySource: [String: Int]
    let uptime: String
    let since: String
}

struct NucleoHealth: Codable {
    let isRunning: Bool
    let componentCount: Int
    let lastError: String?
    let healthy: Bool
}

struct FreezeManifest: Codable {
    let version: String
    let timestamp: String
    let componentStates: [String: String]
    let traceCount: Int
}

@MainActor
final class TraceStore: ObservableObject {
    static let shared = TraceStore()

    @Published private(set) var records: [TraceRecord] = []
    @Published private(set) var isEnabled = true

    private let maxRecords = 10_000
    private let encoder = JSONEncoder()

    private init() {}

    func record(_ record: TraceRecord) {
        guard isEnabled else { return }
        records.append(record)
        if records.count > maxRecords {
            records = Array(records.suffix(maxRecords / 2))
        }
    }

    func record(source: NucleoRequestSource,
                executor: NucleoExecutor,
                provider: String = "local",
                model: String = "",
                promptTokens: Int = 0,
                completionTokens: Int = 0,
                elapsedMs: Int,
                cancelled: Bool = false,
                retryCount: Int = 0,
                timeout: Bool = false,
                cacheHit: Bool = false,
                status: NucleoStatus,
                error: String? = nil) {
        let record = TraceRecord(
            source: source,
            executor: executor,
            provider: provider,
            model: model,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
            elapsedMs: elapsedMs,
            cancelled: cancelled,
            retryCount: retryCount,
            timeout: timeout,
            cacheHit: cacheHit,
            status: status,
            error: error
        )
        records.append(record)
        if records.count > maxRecords {
            records = Array(records.suffix(maxRecords / 2))
        }
    }

    func metrics() -> NucleoMetrics {
        let total = records.count
        let success = records.filter { $0.status == .success }.count
        let errors = records.filter { $0.status == .error }.count
        let timeouts = records.filter { $0.status == .timeout }.count
        let cancelled = records.filter { $0.status == .cancelled }.count
        let elapsed = records.map(\.elapsedMs)
        let avg = elapsed.isEmpty ? 0 : Double(elapsed.reduce(0, +)) / Double(elapsed.count)
        let sorted = elapsed.sorted()
        let p95 = sorted.isEmpty ? 0 : sorted[Int(Double(sorted.count) * 0.95)]

        var byExecutor: [String: Int] = [:]
        var bySource: [String: Int] = [:]
        for r in records {
            byExecutor[r.executor.rawValue, default: 0] += 1
            bySource[r.source.rawValue, default: 0] += 1
        }

        return NucleoMetrics(
            totalRequests: total,
            successCount: success,
            errorCount: errors,
            timeoutCount: timeouts,
            cancelledCount: cancelled,
            avgElapsedMs: avg,
            p95ElapsedMs: Double(p95),
            byExecutor: byExecutor,
            bySource: bySource,
            uptime: "",
            since: records.first?.timestamp ?? ISO8601DateFormatter().string(from: Date())
        )
    }

    func save(to url: URL) throws {
        let data = try encoder.encode(records)
        try data.write(to: url)
    }

    func clear() {
        records.removeAll()
    }

    func disable() { isEnabled = false }
    func enable() { isEnabled = true }
}

// MARK: - Nucleo Orchestrator

@MainActor
final class SUPRANucleoOrchestrator: ObservableObject {
    static let shared = SUPRANucleoOrchestrator()

    @Published private(set) var isRunning = false
    @Published private(set) var lastError: String?
    @Published private(set) var startDate: Date?

    let traceStore = TraceStore.shared

    private let governor = SUPRAResourceGovernor.shared
    private let gateway = RuntimeGateway.shared
    private let monitor: RuntimeMonitor
    private let dataService: RuntimeDataService
    private let scheduler = SUPRAScheduler.shared
    private let decisionEngine = SUPRADecisionEngine.self
    private let missionExecutor = SUPRAMissionExecutor.shared
    private let missionStore: MissionStore
    private let missionContext: MissionContext
    private let kernel = NOVAKnowledgeKernel.shared
    private let openCodeClient = OpenCodeClient.shared
    private let canonicalWorld = SUPRACanonicalWorldAccess.shared

    private var cancellables = Set<AnyCancellable>()
    private var requestCounter = 0

    private init() {
        let compositionRoot = SUPRACompositionRoot.shared
        dataService = compositionRoot.runtimeDataService
        monitor = compositionRoot.runtimeMonitor
        missionStore = compositionRoot.missionStore
        missionContext = MissionContext(kernel: kernel)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        startDate = Date()
        lastError = nil

        governor.startMonitoring()
        monitor.start()
        scheduler.start()

        traceStore.record(
            source: .internal,
            executor: .runtime,
            elapsedMs: 0,
            status: .success,
            error: nil
        )
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        scheduler.stop()
        governor.stopMonitoring()
        monitor.stop()
    }

    func pause() {
        scheduler.stop()
    }

    func resume() {
        scheduler.start()
    }

    func health() -> NucleoHealth {
        NucleoHealth(
            isRunning: isRunning,
            componentCount: 11,
            lastError: lastError,
            healthy: isRunning && lastError == nil
        )
    }

    func metrics() -> NucleoMetrics {
        traceStore.metrics()
    }

    func execute(_ request: NucleoRequest) async -> NucleoResponse {
        let start = Date()
        let responseId = "nucleo_\(requestCounter)"
        requestCounter += 1

        var retryCount = 0
        var lastError: String?
        var status: NucleoStatus = .success
        var cancelled = false
        var timeout = false
        var cacheHit = false
        var data: [String: String]?

        let maxRetries = 3

        for attempt in 0...maxRetries {
            if attempt > 0 { retryCount += 1 }

            do {
                let result = try await route(request)
                data = result
                status = .success
                lastError = nil
                break
            } catch let error as NucleoError {
                if error == .timeout { timeout = true; status = .timeout; lastError = error.localizedDescription; break }
                if error == .cancelled { cancelled = true; status = .cancelled; lastError = error.localizedDescription; break }
                lastError = error.localizedDescription
                if attempt < maxRetries { try? await Task.sleep(nanoseconds: 1_000_000_000) }
                else { status = .error }
            } catch {
                lastError = error.localizedDescription
                if attempt < maxRetries { try? await Task.sleep(nanoseconds: 500_000_000) }
                else { status = .error }
            }
        }

        let elapsed = Int(Date().timeIntervalSince(start) * 1000)

        traceStore.record(
            source: request.source,
            executor: request.executor,
            elapsedMs: elapsed,
            cancelled: cancelled,
            retryCount: retryCount,
            timeout: timeout,
            cacheHit: cacheHit,
            status: status,
            error: lastError
        )

        return NucleoResponse(
            id: responseId,
            requestId: request.id,
            status: status,
            data: data,
            error: lastError,
            elapsedMs: elapsed,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }

    private func route(_ request: NucleoRequest) async throws -> [String: String] {
        switch request.executor {
        case .resource:
            return try await routeResource(request)
        case .mission:
            return try await routeMission(request)
        case .decision:
            return try await routeDecision(request)
        case .runtime:
            return try await routeRuntime(request)
        case .knowledge:
            return try await routeKnowledge(request)
        case .canonical:
            return try await routeCanonical(request)
        case .scheduler:
            return try await routeScheduler(request)
        case .observer:
            return try await routeObserver(request)
        case .intelligence:
            return try await routeIntelligence(request)
        }
    }

    private let resourceIntelligence = SUPRAResourceIntelligenceEngine.shared
    private let intelligenceEngine = SUPRAIntelligenceEngine.shared
    private let observer = SUPRAMissionObserver.shared

    private func routeResource(_ request: NucleoRequest) async throws -> [String: String] {
        let snap = governor.snapshot
        return [
            "cpu": "\(Int(snap.cpuUsage * 100))",
            "ram": "\(Int(snap.ramFraction * 100))",
            "freeDiskGB": "\(Int(snap.freeDiskGB))",
            "throttle": snap.throttleLevel.rawValue,
            "isHighLoad": "\(snap.isHighLoad)",
            "isCritical": "\(snap.isCritical)"
        ]
    }

    private func routeMission(_ request: NucleoRequest) async throws -> [String: String] {
        let missions = missionStore.missions
        let active = missions.filter { $0.status == .active }.count
        let blocked = missions.filter { $0.status == .blocked }.count
        let completed = missions.filter { $0.status == .completed }.count
        return [
            "total": "\(missions.count)",
            "active": "\(active)",
            "blocked": "\(blocked)",
            "completed": "\(completed)"
        ]
    }

    private func routeDecision(_ request: NucleoRequest) async throws -> [String: String] {
        return [
            "autoExecuted": "\(missionExecutor.autoExecutedCount)",
            "pending": "\(missionExecutor.pendingCount)"
        ]
    }

    private func routeRuntime(_ request: NucleoRequest) async throws -> [String: String] {
        let bridgeResponse = await gateway.execute(
            BridgeRequest(
                id: request.id,
                command: .getRuntimeStatus,
                payload: [:],
                timestamp: request.timestamp
            )
        )
        return bridgeResponse.data ?? [:]
    }

    private func routeKnowledge(_ request: NucleoRequest) async throws -> [String: String] {
        let summary = kernel.summary()
        var result: [String: String] = [:]
        for (key, value) in summary {
            result["\(key)"] = "\(value)"
        }
        return result
    }

    private func routeCanonical(_ request: NucleoRequest) async throws -> [String: String] {
        let state = canonicalWorld.getAllStates()
        return [
            "globalHealth": state.globalHealth,
            "missionsTotal": "\(state.missions.total)",
            "missionsActive": "\(state.missions.active)",
            "cpuUsage": "\(Int(state.resources.cpuUsage * 100))",
            "ramFraction": "\(Int(state.resources.ramFraction * 100))",
            "throttleLevel": state.resources.throttleLevel,
            "gatewayConnected": "\(state.runtime.gatewayConnected)"
        ]
    }

    private func routeScheduler(_ request: NucleoRequest) async throws -> [String: String] {
        return [
            "activeTasks": "\(scheduler.activeTaskCount)",
            "isPaused": "\(scheduler.isPaused)",
            "pendingTasks": "\(scheduler.pendingTasks.count)"
        ]
    }

    private func routeObserver(_ request: NucleoRequest) async throws -> [String: String] {
        let observer = SUPRAMissionObserver.shared
        let observations = observer.observe()
        let critical = observations.filter { $0.type == .resourceCritical || $0.type == .runtimeOffline }
        return [
            "total": "\(observations.count)",
            "critical": "\(critical.count)",
            "lastObservation": "\(observer.lastObservationAt?.ISO8601Format() ?? "never")"
        ]
    }

    private func routeIntelligence(_ request: NucleoRequest) async throws -> [String: String] {
        let engine = SUPRAIntelligenceEngine.shared
        engine.refresh()
        let state = engine.state
        return [
            "healthScore": "\(Int(state.healthScore * 100))",
            "confidenceScore": "\(Int(state.confidenceScore * 100))",
            "anomalyCount": "\(state.anomalyCount)",
            "nextAction": state.nextBestAction ?? "none"
        ]
    }
}

enum NucleoError: LocalizedError, Equatable {
    case timeout
    case cancelled
    case notFound(String)
    case executionFailed(String)
    case componentUnavailable(String)

    var errorDescription: String? {
        switch self {
        case .timeout: return "Request timed out"
        case .cancelled: return "Request was cancelled"
        case .notFound(let detail): return "Not found: \(detail)"
        case .executionFailed(let detail): return "Execution failed: \(detail)"
        case .componentUnavailable(let detail): return "Component unavailable: \(detail)"
        }
    }
}
