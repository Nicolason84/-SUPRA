import Foundation
import Combine
import CAnnoNicoContracts

struct TowerStatusMeta: Codable {
    let mission: String
    let generated_at: String
    let machine: String
    let workspace: String
    let mode: String
}

struct TowerProcesses: Codable {
    let status: String
    let note: String
    let last_runtime_mission: LastRuntimeMission?
    let runtime_smoke_test: RuntimeSmokeTest?
    let agent_results_available: Int?
    let agent_results_dir: String?
}

struct LastRuntimeMission: Codable {
    let id: String
    let date: String
    let agents_dispatched: Int
    let completed: Int
    let failed: Int
    let total_duration_seconds: Int
    let quality_score: Double
    let providers_used: [String]
    let verdict: String
}

struct RuntimeSmokeTest: Codable {
    let date: String
    let build_succeeded: Bool
    let process_survived_12_seconds: Bool
    let crash_detected: Bool
    let application_visible: Bool
    let log_lines: Int
    let verdict: String
}

struct TowerMissions: Codable {
    let active_missions: [TowerMissionItem]
    let mission_center_metrics: MissionCenterMetrics?
    let pending_missions_dir: String?
    let pending_missions: Int?
}

struct TowerMissionItem: Codable, Identifiable {
    var id: String { self.idValue }
    private let idValue: String
    let status: String
    let mode: String
    let output: String

    enum CodingKeys: String, CodingKey {
        case idValue = "id"
        case status, mode, output
    }
}

struct MissionCenterMetrics: Codable {
    let file: String?
    let execution_graph: String?
    let queued_jobs: Int?
    let active_workers: Int?
}

struct TowerBuilds: Codable {
    let latest_build: BuildInfo?
    let previous_build_diagnostic: BuildDiagnostic?
    let build_artifacts: BuildArtifacts?
}

struct BuildInfo: Codable {
    let status: String
    let date: String
    let command: String?
    let exit_code: Int?
    let errors: Int?
    let warnings: Int?
    let scheme: String?
    let configuration: String?
    let platform: String?
    let derived_data: DerivedDataInfo?
}

struct BuildDiagnostic: Codable {
    let date: String?
    let status: String?
    let errors: Int?
    let cause: String?
    let note: String?
}

struct BuildArtifacts: Codable {
    let app_bundle: String?
    let build_dir: String?
    let build_log: String?
}

struct DerivedDataInfo: Codable {
    let path: String?
    let estimated_size_gb: Int?
}

struct TowerGitState: Codable {
    let branch: String?
    let remote: String?
    let last_commit: GitCommit?
    let last_5_commits: [String]?
    let modified_files: Int?
    let modified_details: [String]?
    let untracked_files: Int?
    let untracked_significant: [String]?
    let dirty: Bool?
    let note: String?
}

struct GitCommit: Codable {
    let hash: String?
    let message: String?
    let date: String?
}

struct TowerActiveAgents: Codable {
    let openode_agents_configured: Int?
    let agents: [AgentInfo]?
    let commands_available: [AgentCommand]?
}

struct AgentInfo: Codable {
    let name: String
    let mode: String?
    let edit: Bool?
    let bash: Bool?
}

struct AgentCommand: Codable {
    let name: String
    let agent: String?
    let description: String?
}

struct TowerWarning: Codable, Identifiable {
    var id: String { "\(severity)-\(component)-\(message.prefix(40))" }
    let severity: String
    let component: String
    let message: String
    let file: String?
    let action: String?
}

struct TowerNextAction: Codable, Identifiable {
    var id: Int { priority }
    let priority: Int
    let action: String
    let command: String?
    let reason: String?
}

struct TowerSystemHealth: Codable {
    let overall: String?
    let build: String?
    let runtime: String?
    let git: String?
    let agents: String?
    let storage: String?
    let architecture: String?
    let capabilities: Int?
    let active_projects: Int?
    let swift_files_canonical: Int?
    let swift_files_total_ecosystem: Int?
    let git_repos_total: Int?
}

struct TowerReferences: Codable {
    let environment_index: String?
    let project_registry: String?
    let package_registry: String?
}

struct TowerStatus: Codable {
    let meta: TowerStatusMeta
    let processes: TowerProcesses?
    let missions: TowerMissions?
    let builds: TowerBuilds?
    let git_state: TowerGitState?
    let active_agents: TowerActiveAgents?
    let warnings: [TowerWarning]?
    let next_actions: [TowerNextAction]?
    let system_health: TowerSystemHealth?
    let references: TowerReferences?
}

@MainActor
final class ControlTowerState: ObservableObject {
    @Published var status: TowerStatus?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var gatewayStatus: GatewayRuntimeStatus?
    @Published var gatewayConnected = false

    @Published var runtimeHealth: RuntimeHealth = .initial
    @Published var runtimeEvents: [RuntimeEvent] = []

    @Published var cannonicoRecoveredCount: Int = 0
    @Published var cannonicoReferences: [CAnnoNicoSourceReference] = []

    private let monitor: RuntimeMonitor
    private let gateway = RuntimeGateway.shared
    private let dataService: RuntimeDataService
    private let decoder = JSONDecoder()
    private let snapshotStore = CAnnoNicoSnapshotStore.shared
    private var snapshotObserver: AnyCancellable?

    init(dataService: RuntimeDataService, monitor: RuntimeMonitor) {
        self.dataService = dataService
        self.monitor = monitor
        snapshotObserver = snapshotStore.$state.sink { [weak self] state in
            self?.cannonicoRecoveredCount = state?.recoveredCount ?? 0
            self?.cannonicoReferences = state?.references ?? []
        }
    }

    func load() {
        isLoading = true
        errorMessage = nil

        loadTowerStatus()
        loadRuntimeMonitor()
        loadGatewayStatus()
        loadCannonico()
        dataService.load()

        isLoading = false
    }

    private func loadTowerStatus() {
        let path = towerStatusPath()
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            errorMessage = "CONTROL_TOWER_STATUS.json not found"
            return
        }
        status = try? decoder.decode(TowerStatus.self, from: data)
    }

    private func loadRuntimeMonitor() {
        runtimeHealth = monitor.health
        runtimeEvents = monitor.events
    }

    private func loadGatewayStatus() {
        gatewayStatus = gateway.status
        gatewayConnected = gateway.isConnected
    }

    private func loadCannonico() {
        let _ = snapshotStore.currentState
    }

    private func towerStatusPath() -> String {
        UserDefaults.standard.string(forKey: "towerStatusPath")
            ?? FileManager.default.currentDirectoryPath + "/CONTROL_TOWER_STATUS.json"
    }
}
