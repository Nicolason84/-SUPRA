import Foundation
import Combine

@MainActor
final class MultiMemoryStore: ObservableObject {
    static let shared = MultiMemoryStore()

    @Published private(set) var snapshot = MultiMemorySnapshot(
        memories: [],
        globalHealth: "initializing",
        lastUpdated: Date()
    )

    private let decoder = JSONDecoder()
    private var cancellables = Set<AnyCancellable>()
    private var cachedProjectRegistry: ProjectRegistryFile?
    private var cachedEnvironmentIndex: EnvironmentIndexFile?
    private weak var missionStore: MissionStore?
    private weak var runtimeMonitor: RuntimeMonitor?

    private init() {
        loadRegistries()
        subscribeToSnapshotStore()
    }

    func refresh() {
        loadRegistries()
        rebuild()
    }

    func bind(missionStore: MissionStore, runtimeMonitor: RuntimeMonitor) {
        self.missionStore = missionStore
        self.runtimeMonitor = runtimeMonitor
        subscribeToMissionStore(missionStore)
        rebuild()
    }

    private func loadRegistries() {
        cachedProjectRegistry = loadJSON("PROJECT_REGISTRY.json")
        cachedEnvironmentIndex = loadJSON("ENVIRONMENT_INDEX.json")
    }

    private func loadJSON<T: Codable>(_ filename: String) -> T? {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    private func subscribeToSnapshotStore() {
        CAnnoNicoSnapshotStore.shared.$state.sink { [weak self] _ in
            self?.rebuild()
        }.store(in: &cancellables)
    }

    private func subscribeToMissionStore(_ missionStore: MissionStore) {
        missionStore.$missions.sink { [weak self] _ in
            self?.rebuild()
        }.store(in: &cancellables)
    }

    private func rebuild() {
        let cannonico = buildCannonicoMemory()
        let project = buildProjectMemory()
        let runtime = buildRuntimeMemory()
        let missions = buildMissionMemory()
        let fileSystem = buildFileSystemMemory()

        let memories = [cannonico, project, runtime, missions, fileSystem]
        let disconnected = memories.filter { !$0.isConnected }
        let hasAnomalies = memories.contains { !$0.anomalies.isEmpty }

        snapshot = MultiMemorySnapshot(
            memories: memories,
            globalHealth: disconnected.isEmpty && !hasAnomalies ? "healthy"
                : disconnected.count <= 2 ? "degraded" : "critical",
            lastUpdated: Date()
        )
    }

    private func buildCannonicoMemory() -> MemorySourceInfo {
        let store = CAnnoNicoSnapshotStore.shared
        return MemorySourceInfo(
            id: "cannonico",
            name: "CAnnoNico",
            icon: "memorychip",
            objectCount: store.references.count,
            lastSync: store.cachedAt,
            confidence: store.state.map { $0.sourceCount > 0 ? 1.0 : 0.5 } ?? 0,
            anomalies: store.lastRefreshError.map { [$0] } ?? [],
            isConnected: store.state != nil
        )
    }

    private func buildProjectMemory() -> MemorySourceInfo {
        let projects = cachedProjectRegistry?.projects ?? []
        let active = projects.filter { $0.status == "ACTIVE" }
        return MemorySourceInfo(
            id: "projects",
            name: "Projects",
            icon: "folder",
            objectCount: active.count,
            lastSync: cachedProjectRegistry?.meta.date.flatMap { ISO8601DateFormatter().date(from: $0) },
            confidence: projects.isEmpty ? 0 : 0.9,
            anomalies: [],
            isConnected: !projects.isEmpty
        )
    }

    private func buildRuntimeMemory() -> MemorySourceInfo {
        let health = runtimeMonitor?.health ?? .initial
        return MemorySourceInfo(
            id: "runtime",
            name: "Runtime",
            icon: "cpu",
            objectCount: health.agentCount,
            lastSync: health.lastSyncDate,
            confidence: health.isConnected ? 0.85 : 0.1,
            anomalies: health.isConnected ? [] : ["Runtime disconnected"],
            isConnected: health.isConnected
        )
    }

    private func buildMissionMemory() -> MemorySourceInfo {
        let missions = missionStore?.missions ?? []
        return MemorySourceInfo(
            id: "missions",
            name: "Missions",
            icon: "flag",
            objectCount: missions.count,
            lastSync: nil,
            confidence: missions.isEmpty ? 0.2 : 0.9,
            anomalies: missions.filter { $0.status == .blocked }.map { "\($0.title) blocked" },
            isConnected: !missions.isEmpty
        )
    }

    private func buildFileSystemMemory() -> MemorySourceInfo {
        let env = cachedEnvironmentIndex
        let homeDirs = env?.homeDirectories?.desktop?.subdirs ?? [:]
        let activeDirs = homeDirs.filter { $0.value.status == "active" }
        return MemorySourceInfo(
            id: "filesystem",
            name: "File System",
            icon: "externaldrive",
            objectCount: activeDirs.count,
            lastSync: env?.meta.date.flatMap { ISO8601DateFormatter().date(from: $0) },
            confidence: env != nil ? 0.95 : 0,
            anomalies: [],
            isConnected: env != nil
        )
    }
}

// MARK: - File models for JSON decoding

private struct ProjectRegistryFile: Codable {
    let meta: ProjectRegistryMeta
    let projects: [ProjectEntry]
}

private struct ProjectRegistryMeta: Codable {
    let date: String?
}

private struct ProjectEntry: Codable {
    let id: String
    let name: String?
    let path: String?
    let status: String?
    let swift_files: Int?
    let build_status: String?
}

private struct EnvironmentIndexFile: Codable {
    let meta: EnvironmentIndexMeta
    let homeDirectories: EnvironmentHomeDirs?

    enum CodingKeys: String, CodingKey {
        case meta
        case homeDirectories = "home_directories"
    }
}

private struct EnvironmentIndexMeta: Codable {
    let date: String?
}

private struct EnvironmentHomeDirs: Codable {
    let desktop: DesktopInfo?
}

private struct DesktopInfo: Codable {
    let subdirs: [String: SubdirInfo]?
}

private struct SubdirInfo: Codable {
    let status: String?
}
