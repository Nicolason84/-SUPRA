import Foundation

struct SUPRAGabrielWorkerSnapshot: Codable, Sendable, Identifiable {
    let id: String
    let title: String
    let mission: String
    let source: String
    let status: String
    let analysis: String?
    let outputDir: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case mission
        case source
        case status
        case analysis
        case outputDir = "output_dir"
    }
}

struct SUPRAGabrielConductorSnapshot: Codable, Sendable {
    let status: String
    let generatedAt: String?
    let visibleConductor: String?
    let finalAuthority: String?
    let missionSlots: Int
    let workerProcesses: Int
    let uiInstances: Int
    let sharedSourceMode: String
    let outputMode: String
    let workers: [SUPRAGabrielWorkerSnapshot]
    let run: String?

    enum CodingKeys: String, CodingKey {
        case status
        case generatedAt = "generated_at"
        case visibleConductor = "visible_conductor"
        case finalAuthority = "final_authority"
        case missionSlots = "mission_slots"
        case workerProcesses = "worker_processes"
        case uiInstances = "ui_instances"
        case sharedSourceMode = "shared_source_mode"
        case outputMode = "output_mode"
        case workers
        case run
    }

    static var unavailable: SUPRAGabrielConductorSnapshot {
        SUPRAGabrielConductorSnapshot(
            status: "NOT RUN",
            generatedAt: nil,
            visibleConductor: "GABRIEL",
            finalAuthority: "SUPRA",
            missionSlots: 3,
            workerProcesses: 3,
            uiInstances: 1,
            sharedSourceMode: "READ_ONLY",
            outputMode: "ISOLATED_RUNS",
            workers: [
                SUPRAGabrielWorkerSnapshot(
                    id: "GABRIEL_WORKER_PUCHERO",
                    title: "PUCHERO Memory Worker",
                    mission: "Memory, proof and lineage consolidation",
                    source: SUPRAGabrielConductorRuntime.pucheroSource,
                    status: "WAITING",
                    analysis: nil,
                    outputDir: nil
                ),
                SUPRAGabrielWorkerSnapshot(
                    id: "GABRIEL_WORKER_NICO_APP",
                    title: "NICO_APP Human Interface Worker",
                    mission: "Human interface and personal context consolidation",
                    source: SUPRAGabrielConductorRuntime.nicoAppSource,
                    status: "WAITING",
                    analysis: nil,
                    outputDir: nil
                ),
                SUPRAGabrielWorkerSnapshot(
                    id: "GABRIEL_WORKER_VIDEO_SWAP",
                    title: "Video Swap Media Worker",
                    mission: "Media transformation capability consolidation",
                    source: SUPRAGabrielConductorRuntime.videoSwapSource,
                    status: "WAITING",
                    analysis: nil,
                    outputDir: nil
                )
            ],
            run: nil
        )
    }
}

enum SUPRAGabrielConductorRuntime {
    private static func ensureResolved() {
        SUPRAEnvironmentResolver.shared.resolve()
    }

    static var gabrielRuntimePath: String {
        ensureResolved()
        return SUPRAEnvironmentResolver.shared.path(for: "gabrielConductorRoot")
            ?? NSHomeDirectory() + "/NOVA_OS/GABRIEL_PARALLEL_MISSION_CONDUCTOR_V1/RUNTIME"
    }

    static var gabrielSnapshotPath: String {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(
                "NOVA_OS/GABRIEL_PARALLEL_MISSION_CONDUCTOR_V1/CURRENT/OUTPUTS/GABRIEL_CONSOLIDATION.json"
            ).path
    }

    static var pucheroSource: String {
        ensureResolved()
        return SUPRAEnvironmentResolver.shared.path(for: "pucheroRoot")
            ?? NSHomeDirectory() + "/NOVA_OS/PUCHERO"
    }

    static var nicoAppSource: String {
        ensureResolved()
        return SUPRAEnvironmentResolver.shared.path(for: "nicoAppRoot")
            ?? NSHomeDirectory() + "/NOVA_OS/NICO_APP_V1"
    }

    static var videoSwapSource: String {
        ensureResolved()
        return SUPRAEnvironmentResolver.shared.path(for: "videoSwapRoot")
            ?? ""
    }

    static func load() -> SUPRAGabrielConductorSnapshot {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: gabrielSnapshotPath)),
              let snapshot = try? JSONDecoder().decode(
                  SUPRAGabrielConductorSnapshot.self,
                  from: data
              )
        else {
            return .unavailable
        }

        return snapshot
    }

    static func run() async {
        await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
            process.arguments = [gabrielRuntimePath + "/gabriel_parallel_conductor.py", "run"]
            process.standardOutput = Pipe()
            process.standardError = Pipe()

            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                return
            }
        }.value
    }
}
