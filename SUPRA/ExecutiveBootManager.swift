import Foundation
import SwiftUI
import Combine

enum BootPhase: String, CaseIterable {
    case executiveBoot = "Executive Boot"
    case loadContinuity = "Load Continuity"
    case restoreRuntime = "Restore Runtime State"
    case verifyFreeze = "Verify Freeze"
    case verifyBuild = "Verify Build"
    case restoreMission = "Restore Mission"
    case ready = "Ready"

    var icon: String {
        switch self {
        case .executiveBoot: "bolt.shield.fill"
        case .loadContinuity: "arrow.triangle.branch"
        case .restoreRuntime: "arrow.clockwise.circle.fill"
        case .verifyFreeze: "snowflake"
        case .verifyBuild: "hammer.fill"
        case .restoreMission: "flag.fill"
        case .ready: "checkmark.circle.fill"
        }
    }
}

enum BootStepStatus: String {
    case pass = "PASS"
    case warning = "WARNING"
    case failure = "FAILURE"
    case pending = "PENDING"
    case running = "RUNNING"

    var icon: String {
        switch self {
        case .pass: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .failure: "xmark.circle.fill"
        case .pending: "clock.fill"
        case .running: "arrow.triangle.2.circlepath"
        }
    }

    var color: Color {
        switch self {
        case .pass: .supraGreen
        case .warning: .supraOrange
        case .failure: .supraRed
        case .pending: .supraTextTertiary
        case .running: .supraAccent
        }
    }
}

struct BootStep: Identifiable {
    let id = UUID()
    let phase: BootPhase
    let status: BootStepStatus
    let detail: String
}

enum FreezeValidity: String {
    case valid = "VALID"
    case warning = "WARNING"
    case stale = "STALE"
    case invalid = "INVALID"
}

enum BootState: String {
    case idle = "IDLE"
    case booting = "BOOTING"
    case continuityFound = "CONTINUITY_FOUND"
    case firstBoot = "FIRST_BOOT"
    case restored = "RESTORED"
    case divergence = "DIVERGENCE"
    case failed = "FAILED"
}

struct FreezeMetadata {
    var gitCommit: String = "—"
    var gitBranch: String = "—"
    var runtimeVersion: String = "—"
    var buildStatus: String = "—"
    var timestamp: String = "—"
}

struct DivergenceReport {
    var hasDivergence: Bool = false
    var gitCommitDiff: Bool = false
    var gitBranchDiff: Bool = false
    var runtimeDiff: Bool = false
    var buildDiff: Bool = false
    var frozenCommit: String = "—"
    var currentCommit: String = "—"
    var frozenBranch: String = "—"
    var currentBranch: String = "—"
    var frozenRuntime: String = "—"
    var currentRuntime: String = "—"
    var frozenBuild: String = "—"
    var currentBuild: String = "—"
}

final class ExecutiveBootManager: ObservableObject {
    static let shared = ExecutiveBootManager()

    @Published var bootState: BootState = .idle
    @Published var bootSteps: [BootStep] = []
    @Published var freezeValidity: FreezeValidity = .invalid
    @Published var freezeMetadata = FreezeMetadata()
    @Published var divergence = DivergenceReport()
    @Published var isBootComplete = false
    @Published var bootError: String?
    @Published var continuityPackExists = false

    private let fileSystem: FileSystemPort
    private let fm = FileManager.default

    private var projectRoot: String {
        SUPRAEnvironmentResolver.shared.projectRoot
    }

    init(fileSystem: FileSystemPort = DefaultFileSystemPort.live()) {
        self.fileSystem = fileSystem
    }

    private let continuityFiles: [(String, String)] = [
        ("CONTINUITY.md", "CONTINUITY.md"),
        ("NEXT_MISSION.md", "NEXT_MISSION.md"),
        ("SUPRA_STATE.json", "SUPRA_STATE.json"),
        ("BUILD_STATUS.md", "BUILD_STATUS.md"),
        ("RUNTIME_STATUS.json", "RUNTIME_STATUS.json"),
        ("runtime_diagnostics.json", "runtime_diagnostics.json"),
        ("EXECUTION_REPORT.md", "EXECUTION_REPORT.md"),
    ]

    func executeBoot() {
        bootState = .booting
        bootSteps = []
        bootError = nil
        divergence = DivergenceReport()

        BootTrace.mark("EXEC_BOOT_START")
        updateStep(.executiveBoot, .running, "Initializing Executive Boot Manager...")
        SUPRARuntimeLogger.shared.log(.boot, "ExecutiveBoot: Boot sequence started")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.searchContinuityPack()
        }
    }

    private func searchContinuityPack() {
        updateStep(.executiveBoot, .running, "Scanning for continuity pack...")

        var foundCount = 0
        var missingFiles: [String] = []

        for (name, _) in continuityFiles {
            if fm.fileExists(atPath: "\(projectRoot)/\(name)") {
                foundCount += 1
            } else {
                missingFiles.append(name)
            }
        }

        continuityPackExists = foundCount == continuityFiles.count

        if continuityPackExists {
            BootTrace.mark("CONTINUITY_PACK_FOUND")
            SUPRARuntimeLogger.shared.log(.boot, "ExecutiveBoot: Continuity pack found (\(foundCount)/\(continuityFiles.count) files)")
            updateStep(.executiveBoot, .pass, "Continuity pack found (\(foundCount)/\(continuityFiles.count))")
            executeRestorePipeline()
        } else {
            BootTrace.mark("CONTINUITY_PACK_MISSING")
            SUPRARuntimeLogger.shared.log(.boot, "ExecutiveBoot: First boot — no continuity pack found")
            updateStep(.executiveBoot, .warning, "First boot — continuity pack incomplete (\(foundCount)/\(continuityFiles.count), missing: \(missingFiles.joined(separator: ", ")))")
            bootState = .firstBoot
            completeBoot()
        }
    }

    private func executeRestorePipeline() {
        bootState = .continuityFound
        loadContinuity()
    }

    private func loadContinuity() {
        updateStep(.loadContinuity, .running, "Loading CONTINUITY.md...")

        ContinuityManager.shared.load()

        let hasContinuityMd = fm.fileExists(atPath: "\(projectRoot)/CONTINUITY.md")
        let hasStateJson = fm.fileExists(atPath: "\(projectRoot)/SUPRA_STATE.json")

        if hasContinuityMd && hasStateJson {
            SUPRARuntimeLogger.shared.log(.root, "ExecutiveBoot: Continuity loaded successfully")
            updateStep(.loadContinuity, .pass, "CONTINUITY.md + SUPRA_STATE.json loaded")
        } else {
            updateStep(.loadContinuity, .warning, "Continuity files partially loaded")
        }

        restoreRuntimeState()
    }

    private func restoreRuntimeState() {
        updateStep(.restoreRuntime, .running, "Restoring runtime state from RUNTIME_STATUS.json...")

        guard let data = fm.contents(atPath: "\(projectRoot)/RUNTIME_STATUS.json") else {
            let msg = "RUNTIME_STATUS.json not found at \(projectRoot)/RUNTIME_STATUS.json"
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: \(msg)")
            updateStep(.restoreRuntime, .warning, msg)
            verifyFreeze()
            return
        }
        do {
            guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                let msg = "RUNTIME_STATUS.json is not a valid JSON object"
                SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: \(msg)")
                updateStep(.restoreRuntime, .warning, msg)
                verifyFreeze()
                return
            }
            if let build = obj["build"] as? [String: Any],
               let status = build["status"] as? String {
                if status == "SUCCEEDED" {
                    updateStep(.restoreRuntime, .pass, "Runtime status: \(status)")
                } else {
                    updateStep(.restoreRuntime, .warning, "Runtime status: \(status)")
                }
            } else {
                updateStep(.restoreRuntime, .pass, "Runtime state restored")
            }
        } catch {
            let msg = "RUNTIME_STATUS.json parse error: \(error.localizedDescription)"
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: \(msg)")
            updateStep(.restoreRuntime, .warning, msg)
        }

        verifyFreeze()
    }

    private func verifyFreeze() {
        updateStep(.verifyFreeze, .running, "Validating freeze metadata...")

        loadFreezeMetadata()
        validateFreeze()

        switch freezeValidity {
        case .valid:
            updateStep(.verifyFreeze, .pass, "Freeze validated: \(freezeMetadata.timestamp)")
        case .warning:
            updateStep(.verifyFreeze, .warning, "Freeze warning: \(freezeValidity.rawValue)")
        case .stale:
            updateStep(.verifyFreeze, .warning, "Freeze stale: \(freezeMetadata.timestamp)")
        case .invalid:
            updateStep(.verifyFreeze, .failure, "Freeze invalid — metadata mismatch")
        }

        verifyBuild()
    }

    private func loadFreezeMetadata() {
        do {
            if let data = fm.contents(atPath: "\(projectRoot)/SUPRA_STATE.json") {
                guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: SUPRA_STATE.json is not a valid JSON object")
                    return
                }
                if let proj = obj["project"] as? [String: Any] {
                    freezeMetadata.gitBranch = proj["branch"] as? String ?? "—"
                    let commit = proj["last_commit"] as? String ?? "—"
                    freezeMetadata.gitCommit = String(commit.prefix(12))
                    freezeMetadata.timestamp = proj["timestamp"] as? String ?? "—"
                }
                if let runtime = obj["runtime"] as? [String: Any] {
                    freezeMetadata.runtimeVersion = runtime["entry_point"] as? String ?? "—"
                }
                if let build = obj["build"] as? [String: Any] {
                    freezeMetadata.buildStatus = build["status"] as? String ?? "—"
                }
            } else {
                SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: SUPRA_STATE.json not found at \(projectRoot)")
            }
        } catch {
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: SUPRA_STATE.json parse error: \(error.localizedDescription)")
        }

        guard let continuityData = fm.contents(atPath: "\(projectRoot)/CONTINUITY.md") else {
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: CONTINUITY.md not found at \(projectRoot)")
            return
        }
        guard let text = String(data: continuityData, encoding: .utf8) else {
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: CONTINUITY.md is not valid UTF-8 text")
            return
        }
        guard let range = text.range(of: "Generated:") else {
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: CONTINUITY.md missing \"Generated:\" marker")
            return
        }
        let snippet = String(text[range.lowerBound...]).prefix(200)
        guard let endRange = snippet.range(of: "\n") else {
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: Cannot extract timestamp from CONTINUITY.md")
            return
        }
        let ts = String(snippet[snippet.startIndex..<endRange.lowerBound])
            .replacingOccurrences(of: "Generated:", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !ts.isEmpty {
            freezeMetadata.timestamp = ts
        }
    }

    private func validateFreeze() {
        let currentCommit = readCurrentGitCommit()
        let currentBranch = readCurrentGitBranch()

        let commitMatch = freezeMetadata.gitCommit == "—" || currentCommit == "—" || freezeMetadata.gitCommit == currentCommit
        let branchMatch = freezeMetadata.gitBranch == "—" || currentBranch == "—" || freezeMetadata.gitBranch == currentBranch
        let runtimeValid = freezeMetadata.runtimeVersion != "—"
        let buildValid = freezeMetadata.buildStatus == "SUCCEEDED"
        let hasTimestamp = freezeMetadata.timestamp != "—"

        if commitMatch && branchMatch && runtimeValid && buildValid && hasTimestamp {
            freezeValidity = .valid
        } else if !commitMatch || !branchMatch {
            freezeValidity = .invalid
            detectDivergence(currentCommit: currentCommit, currentBranch: currentBranch)
        } else if !runtimeValid || !buildValid {
            freezeValidity = .warning
        } else if !hasTimestamp {
            freezeValidity = .stale
        } else {
            freezeValidity = .warning
        }
    }

    private func detectDivergence(currentCommit: String, currentBranch: String) {
        var report = DivergenceReport()
        report.frozenCommit = freezeMetadata.gitCommit
        report.currentCommit = currentCommit
        report.frozenBranch = freezeMetadata.gitBranch
        report.currentBranch = currentBranch
        report.frozenRuntime = freezeMetadata.runtimeVersion
        report.currentRuntime = ContinuityManager.shared.state.runtimeVersion
        report.frozenBuild = freezeMetadata.buildStatus
        report.currentBuild = ContinuityManager.shared.state.buildStatus

        report.gitCommitDiff = freezeMetadata.gitCommit != "—" && currentCommit != "—" && freezeMetadata.gitCommit != currentCommit
        report.gitBranchDiff = freezeMetadata.gitBranch != "—" && currentBranch != "—" && freezeMetadata.gitBranch != currentBranch
        report.runtimeDiff = false
        report.buildDiff = freezeMetadata.buildStatus != "—" && ContinuityManager.shared.state.buildStatus != "—" && freezeMetadata.buildStatus != ContinuityManager.shared.state.buildStatus
        report.hasDivergence = report.gitCommitDiff || report.gitBranchDiff || report.runtimeDiff || report.buildDiff

        divergence = report

        if report.hasDivergence {
            bootState = .divergence
            SUPRARuntimeLogger.shared.log(.validation, "ExecutiveBoot: Freeze divergence detected — git/branch/build mismatch")
        }
    }

    private func verifyBuild() {
        updateStep(.verifyBuild, .running, "Verifying build status...")

        let buildStatus = ContinuityManager.shared.state.buildStatus

        if buildStatus == "SUCCEEDED" {
            updateStep(.verifyBuild, .pass, "Build: \(buildStatus)")
        } else if buildStatus == "—" {
            updateStep(.verifyBuild, .warning, "Build status unknown")
        } else {
            updateStep(.verifyBuild, .warning, "Build: \(buildStatus)")
        }

        restoreMission()
    }

    private func restoreMission() {
        updateStep(.restoreMission, .running, "Restoring active mission context...")

        let nextMission = ContinuityManager.shared.state.nextMission
        let currentMission = ContinuityManager.shared.state.currentMission

        if nextMission != "—" || currentMission != "—" {
            let mission = currentMission != "—" ? currentMission : nextMission
            updateStep(.restoreMission, .pass, "Mission restored: \(mission)")
            SUPRARuntimeLogger.shared.log(.dashboard, "ExecutiveBoot: Mission context restored — \(mission)")
        } else {
            updateStep(.restoreMission, .warning, "No mission context found")
        }

        completeBoot()
    }

    private func completeBoot() {
        updateStep(.ready, .pass, "SUPRA ready — continuity restored")

        if bootState != .divergence && bootState != .firstBoot {
            bootState = .restored
        }

        isBootComplete = true
        BootTrace.mark("EXEC_BOOT_COMPLETE state=\(bootState.rawValue)")
        SUPRARuntimeLogger.shared.log(.boot, "ExecutiveBoot: Boot sequence complete — state: \(bootState.rawValue)")
    }

    func resumeSession() {
        SUPRARuntimeLogger.shared.log(.boot, "ExecutiveBoot: Resume Session triggered")

        ContinuityManager.shared.load()

        if let data = fm.contents(atPath: "\(projectRoot)/CONTINUITY.md"),
           let _ = String(data: data, encoding: .utf8) {
            SUPRARuntimeLogger.shared.log(.root, "ExecutiveBoot: CONTINUITY.md loaded for resume")
        }

        if let data = fm.contents(atPath: "\(projectRoot)/SUPRA_STATE.json"),
           let _ = try? JSONSerialization.jsonObject(with: data) {
            SUPRARuntimeLogger.shared.log(.snapshot, "ExecutiveBoot: SUPRA_STATE.json loaded for resume")
        }

        let nextMissionLocation = StorageLocation(directory: .continuity, filename: "NEXT_MISSION.md")
        if fileSystem.exists(nextMissionLocation) {
            do {
                let _ = try fileSystem.readString(nextMissionLocation)
                SUPRARuntimeLogger.shared.log(.manifest, "ExecutiveBoot: NEXT_MISSION.md loaded for resume via FileSystemPort")
            } catch {
                SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: NEXT_MISSION.md read error via FileSystemPort — \(error.localizedDescription)")
            }
        } else {
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: NEXT_MISSION.md not found via FileSystemPort")
        }

        let runtimeStatusPath = "\(projectRoot)/RUNTIME_STATUS.json"
        if fm.fileExists(atPath: runtimeStatusPath) {
            SUPRARuntimeLogger.shared.log(.dashboard, "ExecutiveBoot: Runtime status available for resume")
        }

        bootState = .restored
        isBootComplete = true
    }

    func resetBoot() {
        bootState = .idle
        bootSteps = []
        freezeValidity = .invalid
        freezeMetadata = FreezeMetadata()
        divergence = DivergenceReport()
        isBootComplete = false
        bootError = nil
        continuityPackExists = false
    }

    private func updateStep(_ phase: BootPhase, _ status: BootStepStatus, _ detail: String) {
        DispatchQueue.main.async {
            if let index = self.bootSteps.firstIndex(where: { $0.phase == phase }) {
                self.bootSteps[index] = BootStep(phase: phase, status: status, detail: detail)
            } else {
                self.bootSteps.append(BootStep(phase: phase, status: status, detail: detail))
            }
        }
    }

    private func readCurrentGitCommit() -> String {
        BootTrace.mark("GIT_COMMIT_SPAWN_BEGIN")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", "cd \"\(projectRoot)\" && git rev-parse --short HEAD 2>/dev/null"]
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
        } catch {
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: git commit read failed: \(error.localizedDescription)")
            return "—"
        }
        process.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        BootTrace.mark("GIT_COMMIT_SPAWN_END")
        guard let output else {
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: git commit output not readable as UTF-8")
            return "—"
        }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func readCurrentGitBranch() -> String {
        BootTrace.mark("GIT_BRANCH_SPAWN_BEGIN")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", "cd \"\(projectRoot)\" && git rev-parse --abbrev-ref HEAD 2>/dev/null"]
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
        } catch {
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: git branch read failed: \(error.localizedDescription)")
            return "—"
        }
        process.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        BootTrace.mark("GIT_BRANCH_SPAWN_END")
        guard let output else {
            SUPRARuntimeLogger.shared.log(.error, "ExecutiveBoot: git branch output not readable as UTF-8")
            return "—"
        }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
