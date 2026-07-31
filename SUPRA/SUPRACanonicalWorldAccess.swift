import Foundation
import CAnnoNicoContracts

// MARK: - Canonical DTOs (no internal dependencies)

struct CanonicalMemoryState {
    let sourceCount: Int
    let recoveredCount: Int
    let references: [CanonicalSourceReference]
    let cachedAt: Date?
    let age: TimeInterval
    let isStale: Bool
    let lastError: String?
}

struct CanonicalSourceReference: Identifiable {
    let id: String
    let role: String
    let state: String
    let sourcePath: String
}

struct CanonicalProjectState {
    let totalProjects: Int
    let activeProjects: Int
    let swiftFileCount: Int
    let lastSync: Date?
    let isAvailable: Bool
}

struct CanonicalRuntimeState {
    let isConnected: Bool
    let agentCount: Int
    let activeMissions: Int
    let lastSync: String
    let connectionState: String
    let gatewayConnected: Bool
    let gatewayWorkers: Int
    let eventCount: Int
}

struct CanonicalMissionState {
    let total: Int
    let active: Int
    let blocked: Int
    let completed: Int
    let autoQueue: Int
    let supervisionQueue: Int
    let humanQueue: Int
    let executedCount: Int
    let recentTitles: [String]
}

struct CanonicalEnvironmentState {
    let activeDirectories: Int
    let lastSync: Date?
    let isAvailable: Bool
}

struct CanonicalResourceState {
    let cpuUsage: Double
    let ramFraction: Double
    let freeDiskGB: Double
    let activeProcessCount: Int
    let isHighLoad: Bool
    let isCritical: Bool
    let throttleLevel: String
    let isXcodeActive: Bool
}

struct CanonicalMultiMemoryState {
    let cannonico: CanonicalMemoryState
    let projects: CanonicalProjectState
    let runtime: CanonicalRuntimeState
    let missions: CanonicalMissionState
    let environment: CanonicalEnvironmentState
    let resources: CanonicalResourceState
    let globalHealth: String
    let timestamp: Date
}

// MARK: - Access Layer

@MainActor
final class SUPRACanonicalWorldAccess {
    static let shared = SUPRACanonicalWorldAccess()

    private var cached: CanonicalMultiMemoryState?
    private var lastHash = 0
    private let ttl: TimeInterval = 15

    private init() {}

    func getMemoryState() -> CanonicalMemoryState {
        let store = CAnnoNicoSnapshotStore.shared
        if let s = store.state {
            return CanonicalMemoryState(
                sourceCount: s.sourceCount,
                recoveredCount: s.recoveredCount,
                references: s.references.map { ref in
                    CanonicalSourceReference(
                        id: ref.id,
                        role: ref.role,
                        state: ref.state.rawValue,
                        sourcePath: ref.path ?? ""
                    )
                },
                cachedAt: s.cachedAt,
                age: s.age,
                isStale: s.isStale,
                lastError: store.lastRefreshError
            )
        }
        return CanonicalMemoryState(sourceCount: 0, recoveredCount: 0, references: [], cachedAt: nil, age: 0, isStale: true, lastError: store.lastRefreshError)
    }

    func getProjectState() -> CanonicalProjectState {
        let mm = MultiMemoryStore.shared
        let project = mm.snapshot.memories.first { $0.id == "projects" }
        return CanonicalProjectState(
            totalProjects: project?.objectCount ?? 0,
            activeProjects: project?.objectCount ?? 0,
            swiftFileCount: 0,
            lastSync: project?.lastSync,
            isAvailable: project?.isConnected ?? false
        )
    }

    func getRuntimeState() -> CanonicalRuntimeState {
        let cc = SUPRACommandCenterState.shared
        guard let r = cc.runtimeSection else {
            return CanonicalRuntimeState(isConnected: false, agentCount: 0, activeMissions: 0, lastSync: "—", connectionState: "unknown", gatewayConnected: false, gatewayWorkers: 0, eventCount: 0)
        }
        return CanonicalRuntimeState(
            isConnected: r.isConnected,
            agentCount: r.agentCount,
            activeMissions: r.activeMissions,
            lastSync: r.lastSync,
            connectionState: r.connectionState.rawValue,
            gatewayConnected: r.gatewayConnected,
            gatewayWorkers: r.gatewayActiveWorkers,
            eventCount: r.events.count
        )
    }

    func getMissionState() -> CanonicalMissionState {
        let ms = SUPRACompositionRoot.shared.missionStore
        let pe = SUPRAMissionProposalEngine.shared
        let ex = SUPRAMissionExecutor.shared
        let all = ms.missions
        let active = all.filter { mission in mission.status == .active }.count
        let blocked = all.filter { mission in mission.status == .blocked }.count
        let completed = all.filter { mission in mission.status == .completed }.count
        let sorted = all.sorted { a, b in
            let da = a.timeline.last?.date ?? .distantPast
            let db = b.timeline.last?.date ?? .distantPast
            return da > db
        }
        let recent = sorted.prefix(5).map(\.title)
        return CanonicalMissionState(
            total: all.count,
            active: active,
            blocked: blocked,
            completed: completed,
            autoQueue: pe.autoQueue.count,
            supervisionQueue: pe.supervisionQueue.count,
            humanQueue: pe.humanQueue.count,
            executedCount: ex.autoExecutedCount,
            recentTitles: recent
        )
    }

    func getEnvironmentState() -> CanonicalEnvironmentState {
        let mm = MultiMemoryStore.shared
        let fs = mm.snapshot.memories.first { $0.id == "filesystem" }
        return CanonicalEnvironmentState(
            activeDirectories: fs?.objectCount ?? 0,
            lastSync: fs?.lastSync,
            isAvailable: fs?.isConnected ?? false
        )
    }

    func getResourceState() -> CanonicalResourceState {
        let g = SUPRAResourceGovernor.shared
        let s = g.snapshot
        return CanonicalResourceState(
            cpuUsage: s.cpuUsage,
            ramFraction: s.ramFraction,
            freeDiskGB: s.freeDiskGB,
            activeProcessCount: s.activeProcessCount,
            isHighLoad: s.isHighLoad,
            isCritical: s.isCritical,
            throttleLevel: s.throttleLevel.rawValue,
            isXcodeActive: s.isXcodeActive
        )
    }

    func getAllStates() -> CanonicalMultiMemoryState {
        let hash = computeHash()
        if let c = cached, hash == lastHash, Date().timeIntervalSince(c.timestamp) < ttl {
            return c
        }
        lastHash = hash

        let mm = MultiMemoryStore.shared.snapshot
        let result = CanonicalMultiMemoryState(
            cannonico: getMemoryState(),
            projects: getProjectState(),
            runtime: getRuntimeState(),
            missions: getMissionState(),
            environment: getEnvironmentState(),
            resources: getResourceState(),
            globalHealth: mm.globalHealth,
            timestamp: Date()
        )
        cached = result
        return result
    }

    func invalidateCache() {
        cached = nil
        lastHash = 0
    }

    private func computeHash() -> Int {
        var h = Hasher()
        h.combine(CAnnoNicoSnapshotStore.shared.state?.cachedAt)
        h.combine(MultiMemoryStore.shared.snapshot.lastUpdated)
        h.combine(SUPRAResourceGovernor.shared.snapshot.timestamp)
        h.combine(SUPRACompositionRoot.shared.missionStore.missions.count)
        h.combine(SUPRAMissionProposalEngine.shared.proposals.count)
        return h.finalize()
    }
}

// MARK: - Multi-client support

@MainActor
final class CustomerWorldAccess {
    private let access: SUPRACanonicalWorldAccess

    init(access: SUPRACanonicalWorldAccess? = nil) {
        self.access = access ?? .shared
    }

    var memory: CanonicalMemoryState { access.getMemoryState() }
    var projects: CanonicalProjectState { access.getProjectState() }
    var runtime: CanonicalRuntimeState { access.getRuntimeState() }
    var missions: CanonicalMissionState { access.getMissionState() }
    var environment: CanonicalEnvironmentState { access.getEnvironmentState() }
    var resources: CanonicalResourceState { access.getResourceState() }
    var all: CanonicalMultiMemoryState { access.getAllStates() }
}
