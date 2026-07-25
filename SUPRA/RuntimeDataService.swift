import Foundation
import Combine

@MainActor
final class RuntimeDataService: ObservableObject {
    static let shared = RuntimeDataService()
    @Published var runtimeTrace: RuntimeTrace?
    @Published var delegationTrace: DelegationTrace?
    @Published var runtimeMetrics: RuntimeMetrics?
    @Published var agentExecution: AgentExecution?
    @Published var executionGraph: ExecutionGraph?
    @Published var missionGraphMetrics: MissionGraphMetrics?
    @Published var providerMetrics: ProviderMetrics?
    @Published var dashboardSnapshot: DashboardSnapshot?

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var autoRefreshInterval: TimeInterval = 30

    @Published private(set) var systemMetrics = SystemMetricsSnapshot(
        cpu: .loading,
        heavyProcesses: .loading,
        services: .loading,
        projects: .loading,
        gitRepos: .loading,
        storage: .loading,
        xcode: .loading,
        timestamp: Date(),
        refreshDuration: nil,
        failedMetrics: [],
        refreshState: .idle
    )

    private var refreshTask: Task<Void, Never>?
    private var systemRefreshTask: Task<Void, Never>?
    private let decoder = JSONDecoder()

    private var previousCpuTicks: (user: UInt32, system: UInt32, idle: UInt32)?
    private var cpuWarmingUp = true

    var runtimePath: String {
        UserDefaults.standard.string(forKey: "runtimePath")
            ?? FileManager.default.currentDirectoryPath
    }

    func load() {
        isLoading = true
        errorMessage = nil

        let base = runtimePath

        let files = [
            "runtime_trace.json", "delegation_trace.json", "runtime_metrics.json",
            "agent_execution.json", "execution_graph.json", "mission_graph_metrics.json",
            "provider_metrics.json", "dashboard_snapshot.json"
        ]

        for filename in files {
            let url = URL(fileURLWithPath: base).appendingPathComponent(filename)
            guard let data = try? Data(contentsOf: url) else { continue }
            switch filename {
            case "runtime_trace.json":
                runtimeTrace = try? decoder.decode(RuntimeTrace.self, from: data)
            case "delegation_trace.json":
                delegationTrace = try? decoder.decode(DelegationTrace.self, from: data)
            case "runtime_metrics.json":
                runtimeMetrics = try? decoder.decode(RuntimeMetrics.self, from: data)
            case "agent_execution.json":
                agentExecution = try? decoder.decode(AgentExecution.self, from: data)
            case "execution_graph.json":
                executionGraph = try? decoder.decode(ExecutionGraph.self, from: data)
            case "mission_graph_metrics.json":
                missionGraphMetrics = try? decoder.decode(MissionGraphMetrics.self, from: data)
            case "provider_metrics.json":
                providerMetrics = try? decoder.decode(ProviderMetrics.self, from: data)
            case "dashboard_snapshot.json":
                dashboardSnapshot = try? decoder.decode(DashboardSnapshot.self, from: data)
            default: break
            }
        }

        isLoading = false
    }

    func startAutoRefresh() {
        stopAutoRefresh()
        refreshTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(self.autoRefreshInterval))
                self.load()
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    // MARK: - System Metrics Pipeline

    func refreshSystemMetrics() {
        guard systemMetrics.refreshState != .refreshing else { return }
        systemRefreshTask?.cancel()
        // Set refreshing state synchronously so guard works immediately
        systemMetrics = SystemMetricsSnapshot(
            cpu: systemMetrics.cpu,
            heavyProcesses: systemMetrics.heavyProcesses,
            services: systemMetrics.services,
            projects: systemMetrics.projects,
            gitRepos: systemMetrics.gitRepos,
            storage: systemMetrics.storage,
            xcode: systemMetrics.xcode,
            timestamp: systemMetrics.timestamp,
            refreshDuration: systemMetrics.refreshDuration,
            failedMetrics: systemMetrics.failedMetrics,
            refreshState: .refreshing
        )
        systemRefreshTask = Task { [weak self] in
            guard let self else { return }
            let start = Date()

            var failed: [String] = []

            let cpu = await collectCPU()
            if case .unavailable = cpu { failed.append("cpu") }

            let processes: SystemMetricState<[HeavyProcess]>
            if Task.isCancelled { return }
            processes = await collectProcesses()
            if case .unavailable = processes { failed.append("processes") }

            let services: SystemMetricState<ServicesInfo>
            if Task.isCancelled { return }
            services = await collectServices()
            if case .unavailable = services { failed.append("services") }

            let projects: SystemMetricState<ProjectsInfo>
            if Task.isCancelled { return }
            projects = await collectProjects()
            if case .unavailable = projects { failed.append("projects") }

            let gitRepos: SystemMetricState<GitReposInfo>
            if Task.isCancelled { return }
            gitRepos = await collectGitRepos()
            if case .unavailable = gitRepos { failed.append("gitRepos") }

            let storage: SystemMetricState<StorageInfo>
            if Task.isCancelled { return }
            storage = await collectStorage()
            if case .unavailable = storage { failed.append("storage") }

            let xcode: SystemMetricState<XcodeInfo>
            if Task.isCancelled { return }
            xcode = await collectXcode()
            if case .unavailable = xcode { failed.append("xcode") }

            let duration = Date().timeIntervalSince(start)

            if !Task.isCancelled {
                await MainActor.run {
                    self.systemMetrics = SystemMetricsSnapshot(
                        cpu: cpu,
                        heavyProcesses: processes,
                        services: services,
                        projects: projects,
                        gitRepos: gitRepos,
                        storage: storage,
                        xcode: xcode,
                        timestamp: Date(),
                        refreshDuration: duration,
                        failedMetrics: failed,
                        refreshState: .idle
                    )
                }
            }

            if cpuWarmingUp {
                await MainActor.run { self.cpuWarmingUp = false }
            }
        }
    }

    private func collectCPU() async -> SystemMetricState<CPUMetrics> {
        var cpuInfo = host_cpu_load_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else {
            return .unavailable(reason: "host_statistics failed")
        }

        let current = (user: cpuInfo.cpu_ticks.0, system: cpuInfo.cpu_ticks.1, idle: cpuInfo.cpu_ticks.2)

        guard let prev = previousCpuTicks else {
            previousCpuTicks = current
            self.cpuWarmingUp = true
            return .available(CPUMetrics(
                totalPercent: 0,
                userPercent: 0,
                systemPercent: 0,
                idlePercent: 0,
                sampleState: .warmingUp
            ))
        }
        previousCpuTicks = current

        let deltaUser = Double(current.user - prev.user)
        let deltaSystem = Double(current.system - prev.system)
        let deltaIdle = Double(current.idle - prev.idle)
        let total = deltaUser + deltaSystem + deltaIdle

        guard total > 0, deltaUser >= 0, deltaSystem >= 0, deltaIdle >= 0 else {
            return .available(CPUMetrics(
                totalPercent: 0,
                userPercent: 0,
                systemPercent: 0,
                idlePercent: 0,
                sampleState: .unavailable
            ))
        }

        let busy = deltaUser + deltaSystem
        let totalPct = min(100, (busy / total) * 100)
        let userPct = min(100, (deltaUser / total) * 100)
        let systemPct = min(100, (deltaSystem / total) * 100)
        let idlePct = min(100, (deltaIdle / total) * 100)

        cpuWarmingUp = false
        return .available(CPUMetrics(
            totalPercent: totalPct,
            userPercent: userPct,
            systemPercent: systemPct,
            idlePercent: idlePct,
            sampleState: .valid
        ))
    }

    private func collectProcesses() async -> SystemMetricState<[HeavyProcess]> {
        guard let r = try? await shell("ps axro pid,pcpu,pmem,comm -m 2>/dev/null | head -8") else {
            return .unavailable(reason: "ps command failed")
        }
        var result: [HeavyProcess] = []
        let lines = r.components(separatedBy: .newlines).dropFirst()
        for line in lines {
            let parts = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            if parts.count >= 4, let pid = Int(parts[0]), let cpu = Double(parts[1]), cpu > 5 {
                let mem = Double(parts[2]) ?? 0
                result.append(HeavyProcess(id: pid, name: parts[3], cpuPercent: cpu, memoryPercent: mem))
            }
        }
        return .available(result)
    }

    private func collectServices() async -> SystemMetricState<ServicesInfo> {
        let workspace = FileManager.default.currentDirectoryPath
        let supraProcs = try? await shell("ps aux 2>/dev/null | grep -i 'supra' | grep -v grep | wc -l")
        let totalStr = supraProcs?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
        let total = Int(totalStr) ?? 0

        let activeProcs = try? await shell("ps aux 2>/dev/null | grep -i 'supra' | grep -v grep | grep -v 'sh -c' | wc -l")
        let activeStr = activeProcs?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
        let active = Int(activeStr) ?? 0

        return .available(ServicesInfo(total: total, active: active, unavailable: 0))
    }

    private func collectProjects() async -> SystemMetricState<ProjectsInfo> {
        let registryPath = "PROJECT_REGISTRY.json"
        let fm = FileManager.default
        guard fm.fileExists(atPath: registryPath),
              let data = try? Data(contentsOf: URL(fileURLWithPath: registryPath)),
              let registry = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let projects = registry["projects"] as? [[String: Any]] else {
            return .unavailable(reason: "PROJECT_REGISTRY.json not found")
        }
        let all = projects.count
        let active = projects.filter { ($0["status"] as? String)?.lowercased() == "active" }.count
        let validated = projects.filter { ($0["build_status"] as? String) == "PASS" }.count
        return .available(ProjectsInfo(discovered: all, active: active, validated: validated, unavailable: 0))
    }

    private func collectGitRepos() async -> SystemMetricState<GitReposInfo> {
        let registryPath = "PROJECT_REGISTRY.json"
        let fm = FileManager.default
        guard fm.fileExists(atPath: registryPath),
              let data = try? Data(contentsOf: URL(fileURLWithPath: registryPath)),
              let registry = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let projects = registry["projects"] as? [[String: Any]] else {
            return .unavailable(reason: "PROJECT_REGISTRY.json not found")
        }
        var canonical: Set<String> = []
        for p in projects {
            guard let path = p["path"] as? String, let gitRepo = p["git_repo"] as? Bool, gitRepo else { continue }
            let canon = URL(fileURLWithPath: path).standardizedFileURL.resolvingSymlinksInPath().path
            canonical.insert(canon)
        }
        var total = 0
        var dirty = 0
        for repo in canonical {
            total += 1
            guard let status = try? await shell("cd \"\(repo)\" 2>/dev/null && git status --porcelain 2>/dev/null | head -1"),
                  !status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            dirty += 1
        }
        return .available(GitReposInfo(total: total, dirty: dirty, clean: total - dirty, unavailable: 0))
    }

    private func collectStorage() async -> SystemMetricState<StorageInfo> {
        let keys: [URLResourceKey] = [.volumeTotalCapacityKey, .volumeAvailableCapacityKey]
        let url = URL(fileURLWithPath: "/")
        guard let values = try? url.resourceValues(forKeys: Set(keys)),
              let total = values.volumeTotalCapacity,
              let available = values.volumeAvailableCapacity else {
            return .unavailable(reason: "volume capacity unavailable")
        }
        let totalBytes = Int64(total)
        let availableBytes = Int64(available)
        let usedBytes = max(0, totalBytes - availableBytes)

        var recoverableBytes: Int64 = 0
        var confidence: StorageInfo.RecoverableConfidence = .unavailable

        let trashPath = NSHomeDirectory() + "/.Trash"
        if let trashContents = try? fm.contentsOfDirectory(atPath: trashPath) {
            var trashSize: Int64 = 0
            for item in trashContents {
                let itemPath = trashPath + "/" + item
                if let attrs = try? fm.attributesOfItem(atPath: itemPath),
                   let size = attrs[.size] as? UInt64 {
                    trashSize += Int64(size)
                }
            }
            recoverableBytes = trashSize
            if trashSize > 0 {
                confidence = .measured
            } else {
                confidence = .unavailable
            }
        }

        let derivedData = NSHomeDirectory() + "/Library/Developer/Xcode/DerivedData"
        if var ddSize = try? directorySize(at: derivedData) {
            if let contents = try? fm.contentsOfDirectory(atPath: derivedData) {
                for item in contents where item.hasPrefix("SUPRA") {
                    let itemPath = derivedData + "/" + item
                    if let s = try? directorySize(at: itemPath) {
                        ddSize = s
                    }
                }
            }
            if ddSize > recoverableBytes {
                recoverableBytes = ddSize
                if confidence == .unavailable {
                    confidence = .estimated
                }
            }
        }

        return .available(StorageInfo(
            totalBytes: totalBytes,
            availableBytes: availableBytes,
            usedBytes: usedBytes,
            recoverableBytes: recoverableBytes,
            recoverableConfidence: confidence
        ))
    }

    private func collectXcode() async -> SystemMetricState<XcodeInfo> {
        let xcodePath = "/Applications/Xcode.app"
        let installed = fm.fileExists(atPath: xcodePath)

        guard installed else {
            return .available(XcodeInfo(
                installed: false, version: "", buildVersion: "",
                developerDir: "", swiftVersion: "", status: .missing
            ))
        }

        guard let version = try? await shell("/usr/bin/xcodebuild -version 2>/dev/null | head -1") else {
            return .available(XcodeInfo(
                installed: true, version: "", buildVersion: "",
                developerDir: "", swiftVersion: "", status: .commandFailure
            ))
        }
        let verStr = version.trimmingCharacters(in: .whitespacesAndNewlines)

        let buildVersion = (try? await shell("/usr/bin/xcodebuild -version 2>/dev/null | head -2 | tail -1"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""

        let devDir = (try? await shell("xcode-select -p 2>/dev/null"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""

        let swiftVer = (try? await shell("swift --version 2>/dev/null | head -1"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""

        return .available(XcodeInfo(
            installed: true,
            version: verStr,
            buildVersion: buildVersion,
            developerDir: devDir,
            swiftVersion: swiftVer,
            status: .available
        ))
    }

    private nonisolated func shell(_ cmd: String) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", cmd]
        let output = Pipe()
        process.standardOutput = output
        try process.run()
        process.waitUntilExit()
        return String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }

    private nonisolated func directorySize(at path: String) throws -> Int64 {
        guard fm.fileExists(atPath: path) else { return 0 }
        guard let enumerator = fm.enumerator(atPath: path) else { return 0 }
        var total: Int64 = 0
        for case let filePath as String in enumerator {
            let fullPath = path + "/" + filePath
            if let attrs = try? fm.attributesOfItem(atPath: fullPath),
               let size = attrs[.size] as? UInt64 {
                total += Int64(size)
            }
            if total > 10_737_418_240 { break }
        }
        return total
    }

    private let fm = FileManager.default

    deinit {
        refreshTask?.cancel()
        systemRefreshTask?.cancel()
    }
}
