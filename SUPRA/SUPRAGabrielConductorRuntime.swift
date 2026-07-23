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

    static let unavailable = SUPRAGabrielConductorSnapshot(
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
                source: "/Users/nicolasalonso/NOVA_OS/PUCHERO",
                status: "WAITING",
                analysis: nil,
                outputDir: nil
            ),
            SUPRAGabrielWorkerSnapshot(
                id: "GABRIEL_WORKER_NICO_APP",
                title: "NICO_APP Human Interface Worker",
                mission: "Human interface and personal context consolidation",
                source: "/Users/nicolasalonso/NOVA_OS/NICO_APP_V1",
                status: "WAITING",
                analysis: nil,
                outputDir: nil
            ),
            SUPRAGabrielWorkerSnapshot(
                id: "GABRIEL_WORKER_VIDEO_SWAP",
                title: "Video Swap Media Worker",
                mission: "Media transformation capability consolidation",
                source: "/Users/nicolasalonso/Desktop/SUPRA_VIDEO_SWAP_V2",
                status: "WAITING",
                analysis: nil,
                outputDir: nil
            )
        ],
        run: nil
    )
}

enum SUPRAGabrielConductorRuntime {
    nonisolated private static let runtimePath =
        "/Users/nicolasalonso/NOVA_OS/GABRIEL_PARALLEL_MISSION_CONDUCTOR_V1/RUNTIME/gabriel_parallel_conductor.py"

    private static let snapshotPath =
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(
                "NOVA_OS/GABRIEL_PARALLEL_MISSION_CONDUCTOR_V1/CURRENT/OUTPUTS/GABRIEL_CONSOLIDATION.json"
            )

    static func load() -> SUPRAGabrielConductorSnapshot {
        guard let data = try? Data(contentsOf: snapshotPath),
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
            process.arguments = [runtimePath, "run"]
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
