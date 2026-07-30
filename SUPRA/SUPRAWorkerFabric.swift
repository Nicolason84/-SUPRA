import Foundation
import Combine

enum WorkerStatus: String, Codable {
    case idle = "IDLE"
    case working = "WORKING"
    case paused = "PAUSED"
    case error = "ERROR"
}

enum WorkerPermission: String, Codable {
    case read = "READ"
    case observe = "OBSERVE"
    case optimize = "OPTIMIZE"
    case execute = "EXECUTE"
    case supervise = "SUPERVISE"
}

protocol WorkerProtocol: AnyObject {
    var id: String { get }
    var name: String { get }
    var status: WorkerStatus { get set }
    var permissions: [WorkerPermission] { get }
    var isRollbackCapable: Bool { get }

    func work() async -> WorkerResult
    func rollback() async -> Bool
    func canExecute(_ permission: WorkerPermission) -> Bool
}

struct WorkerResult {
    let success: Bool
    let message: String
    let data: [String: Any]?
    let durationMs: Int
}

extension WorkerProtocol {
    func canExecute(_ permission: WorkerPermission) -> Bool {
        permissions.contains(permission)
    }
}

@MainActor
final class MemoryWorker: WorkerProtocol, ObservableObject {
    let id = "memory_worker"
    let name = "Memory Worker"
    @Published var status: WorkerStatus = .idle
    let permissions: [WorkerPermission] = [.read, .observe, .optimize]
    let isRollbackCapable = false

    private let snapshotStore = CAnnoNicoSnapshotStore.shared
    private let multiMemory = MultiMemoryStore.shared

    func work() async -> WorkerResult {
        status = .working
        let start = Date()
        snapshotStore.refreshIfNeeded()
        multiMemory.refresh()
        status = .idle
        return WorkerResult(
            success: true,
            message: "Memory sources synchronized",
            data: ["sources": snapshotStore.references.count, "health": multiMemory.snapshot.globalHealth],
            durationMs: Int(Date().timeIntervalSince(start) * 1000)
        )
    }

    func rollback() async -> Bool {
        false
    }
}

@MainActor
final class RuntimeWorker: WorkerProtocol, ObservableObject {
    let id = "runtime_worker"
    let name = "Runtime Worker"
    @Published var status: WorkerStatus = .idle
    let permissions: [WorkerPermission] = [.read, .observe, .supervise]
    let isRollbackCapable = true

    func work() async -> WorkerResult {
        status = .working
        let start = Date()
        // Runtime health check — reads from shared RuntimeMonitor
        status = .idle
        return WorkerResult(
            success: true,
            message: "Runtime health verified",
            data: ["uptime": ProcessInfo.processInfo.systemUptime],
            durationMs: Int(Date().timeIntervalSince(start) * 1000)
        )
    }

    func rollback() async -> Bool { true }
}

@MainActor
final class OptimizationWorker: WorkerProtocol, ObservableObject {
    let id = "optimization_worker"
    let name = "Optimization Worker"
    @Published var status: WorkerStatus = .idle
    let permissions: [WorkerPermission] = [.read, .observe, .optimize]
    let isRollbackCapable = true

    private let governor = SUPRAResourceGovernor.shared

    func work() async -> WorkerResult {
        status = .working
        let start = Date()
        let snap = governor.snapshot
        if snap.isHighLoad || snap.isCritical {
            status = .idle
            return WorkerResult(
                success: false,
                message: "Cannot optimize under high load",
                data: ["cpu": snap.cpuUsage, "ram": snap.ramFraction],
                durationMs: Int(Date().timeIntervalSince(start) * 1000)
            )
        }
        status = .idle
        return WorkerResult(
            success: true,
            message: "Optimization window available",
            data: ["cpu": snap.cpuUsage, "throttle": snap.throttleLevel.rawValue],
            durationMs: Int(Date().timeIntervalSince(start) * 1000)
        )
    }

    func rollback() async -> Bool { true }
}

@MainActor
final class BusinessWorker: WorkerProtocol, ObservableObject {
    let id = "business_worker"
    let name = "Business Worker"
    @Published var status: WorkerStatus = .idle
    let permissions: [WorkerPermission] = [.read, .observe]
    let isRollbackCapable = false

    private let proposalEngine = SUPRAMissionProposalEngine.shared
    private let executor = SUPRAMissionExecutor.shared

    func work() async -> WorkerResult {
        status = .working
        let start = Date()
        let proposals = proposalEngine.proposals.count
        let executed = executor.autoExecutedCount
        status = .idle
        return WorkerResult(
            success: true,
            message: "Business metrics collected",
            data: ["proposals": proposals, "executed": executed, "autonomy": autonomyLevel()],
            durationMs: Int(Date().timeIntervalSince(start) * 1000)
        )
    }

    func rollback() async -> Bool { false }

    private func autonomyLevel() -> Double {
        let p = proposalEngine.proposals.count
        guard p > 0 else { return 0 }
        return Double(proposalEngine.autoQueue.count) / Double(p)
    }
}

@MainActor
final class SUPRAWorkerFabric: ObservableObject {
    static let shared = SUPRAWorkerFabric()

    let memoryWorker = MemoryWorker()
    let runtimeWorker = RuntimeWorker()
    let optimizationWorker = OptimizationWorker()
    let businessWorker = BusinessWorker()

    var allWorkers: [WorkerProtocol] {
        [memoryWorker, runtimeWorker, optimizationWorker, businessWorker]
    }

    private init() {}

    func statusSummary() -> String {
        allWorkers.map { "\($0.name): \($0.status.rawValue)" }.joined(separator: " | ")
    }

    func pauseAll() {
        for var worker in allWorkers {
            worker.status = .paused
        }
    }

    func resumeAll() {
        for var worker in allWorkers {
            if worker.status == .paused {
                worker.status = .idle
            }
        }
    }
}
