import Foundation
import Combine
import CommonCrypto

extension Data {
    var sha256Hex: String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes { buf in
            _ = CC_SHA256(buf.baseAddress, CC_LONG(count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

struct ContinuityState {
    var currentMission: String = "—"
    var previousMission: String = "—"
    var nextMission: String = "—"
    var lastFreeze: String = "—"
    var buildStatus: String = "—"
    var runtimeStatus: String = "—"
    var lastValidation: String = "—"
    var runtimeVersion: String = "—"
    var gitBranch: String = "—"
    var gitCommit: String = "—"
    var knownIssues: String = "—"
    var dashboardVersion: String = "—"
    var pipelineSteps: [PipelineStepState] = []
    var artifacts: [ArtifactDiag] = []
    var lastLogs: [SUPRAEvent] = []

    var bootState: String = "—"
    var freezeStatus: String = "—"
    var continuityStatus: String = "—"
    var resumeAvailable: Bool = false
    var buildVersion: String = "—"
    var gitVersion: String = "—"
    var freezeTimestamp: String = "—"
}

struct PipelineStepState: Identifiable {
    let id = UUID()
    let name: String
    let status: StepStatus
    let detail: String
}

enum StepStatus: String {
    case pass = "PASS"
    case warning = "WARNING"
    case failure = "FAILURE"
    case pending = "PENDING"

    var icon: String {
        switch self {
        case .pass: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .failure: "xmark.circle.fill"
        case .pending: "clock.fill"
        }
    }

    var color: String {
        switch self {
        case .pass: "supraGreen"
        case .warning: "supraOrange"
        case .failure: "supraRed"
        case .pending: "supraTextTertiary"
        }
    }
}

struct ArtifactDiag: Identifiable {
    let id = UUID()
    let name: String
    let expectedPath: String
    let resolvedPath: String
    let exists: Bool
    let readable: Bool
    let decoded: Bool
    let validated: Bool
    let available: Bool
    let hash: String?
    let sizeBytes: Int64?
    let modificationDate: Date?
    let failureReason: String?
}

@MainActor
final class ContinuityManager: ObservableObject {
    static let shared = ContinuityManager()

    @Published var state = ContinuityState()
    @Published var isLoading = false

    private let fileSystem: FileSystemPort
    private let decoder = JSONDecoder()

    private var projectRoot: String {
        SUPRAEnvironmentResolver.shared.projectRoot
    }

    init(fileSystem: FileSystemPort? = nil) {
        self.fileSystem = fileSystem ?? DefaultFileSystemPort(rootURL: URL(fileURLWithPath: SUPRAEnvironmentResolver.shared.projectRoot))
        print("[BOOT 06] ContinuityManager.init() — fileSystem.rootURL: \(self.fileSystem.rootURL.path), projectRoot: \(SUPRAEnvironmentResolver.shared.projectRoot), isResolved: \(SUPRAEnvironmentResolver.shared.isResolved)")
    }

    func load() {
        isLoading = true
        defer { isLoading = false }

        loadVersionJSON()
        loadSupraState()
        loadRuntimeStatus()
        loadRuntimeDiagnostics()
        loadContinuityMarkdown()
        loadNextMission()
        loadGitState()
        loadLogs()
        loadFreezeTimestamp()
        resolveContinuityStatus()
    }

    private func loadVersionJSON() {
        let versionLocation = StorageLocation(directory: .state, filename: "version.json")
        guard fileSystem.exists(versionLocation) else { return }
        guard let data = try? fileSystem.read(versionLocation) else { return }
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        if let sv = obj["supra_state_version"] as? String {
            state.runtimeVersion = sv
            state.dashboardVersion = sv
        }
    }

    private func loadSupraState() {
        let stateLocation = StorageLocation(directory: .state, filename: "SUPRA_STATE.json")
        guard fileSystem.exists(stateLocation) else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: SUPRA_STATE.json not found via FileSystemPort")
            return
        }
        guard let data = try? fileSystem.read(stateLocation) else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: SUPRA_STATE.json read error via FileSystemPort")
            return
        }
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: SUPRA_STATE.json parse failed — invalid JSON")
            return
        }

        if let build = obj["build"] as? [String: Any] {
            state.buildStatus = build["status"] as? String ?? "—"
        }
        if let runtime = obj["runtime"] as? [String: Any] {
            state.runtimeVersion = runtime["entry_point"] as? String ?? state.runtimeVersion
        }
        if let proj = obj["project"] as? [String: Any] {
            state.gitBranch = proj["branch"] as? String ?? "—"
            let commit = proj["last_commit"] as? String ?? "—"
            state.gitCommit = String(commit.prefix(12))
        }
        if let missions = obj["missions"] as? [String: Any] {
            if let completed = missions["completed"] as? [String], let last = completed.last {
                state.previousMission = last
            }
            if let inProgress = missions["in_progress"] as? [String], let current = inProgress.first {
                state.currentMission = current
            }
        }
    }

    private func loadRuntimeStatus() {
        let runtimeStatusLocation = StorageLocation(directory: .state, filename: "RUNTIME_STATUS.json")
        guard fileSystem.exists(runtimeStatusLocation) else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: RUNTIME_STATUS.json not found via FileSystemPort")
            return
        }
        guard let data = try? fileSystem.read(runtimeStatusLocation) else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: RUNTIME_STATUS.json read error via FileSystemPort")
            return
        }
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: RUNTIME_STATUS.json parse failed — invalid JSON")
            return
        }

        if let build = obj["build"] as? [String: Any] {
            state.runtimeStatus = build["status"] as? String ?? "—"
        }
        if let artifacts = obj["artifacts"] as? [String: Any] {
            let required = artifacts["required_count"] as? Int ?? 0
            let available = artifacts["available_after_fix"] as? Int ?? 0
            state.lastValidation = "\(available)/\(required)"
        }
    }

    private func loadRuntimeDiagnostics() {
        let diagnosticsLocation = StorageLocation(directory: .root, filename: "runtime_diagnostics.json")
        guard fileSystem.exists(diagnosticsLocation) else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: runtime_diagnostics.json not found via FileSystemPort")
            return
        }
        guard let data = try? fileSystem.read(diagnosticsLocation) else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: runtime_diagnostics.json read error via FileSystemPort")
            return
        }
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: runtime_diagnostics.json parse failed — invalid JSON")
            return
        }

        if let pipeline = obj["pipeline_diagnostics"] as? [[String: Any]] {
            state.pipelineSteps = pipeline.map { step in
                let name = step["step"] as? String ?? "?"
                let statusStr = step["status"] as? String ?? "PENDING"
                let detail = step["detail"] as? String ?? ""
                let status: StepStatus
                switch statusStr {
                case "PASS": status = .pass
                case "WARNING": status = .warning
                case "FAILURE": status = .failure
                default: status = .pending
                }
                return PipelineStepState(name: name, status: status, detail: detail)
            }
        }

        if let runtimeStatus = obj["runtime_status"] as? [String: Any] {
            state.runtimeStatus = runtimeStatus["status"] as? String ?? state.runtimeStatus
        }

        loadArtifactDiagnostics(obj: obj)
    }

    private func loadArtifactDiagnostics(obj: [String: Any]) {
        var artifacts: [ArtifactDiag] = []

        let requiredLocations: [(String, StorageLocation, String)] = [
            ("LOT1", StorageLocation(directory: .root, subpath: "proofs", filename: "LOT1_INSTALLATION_PROOF.json"), "LOT1_INSTALLATION_PROOF.json"),
            ("LOT2", StorageLocation(directory: .root, subpath: "proofs", filename: "LOT2_INSTALLATION_PROOF.json"), "LOT2_INSTALLATION_PROOF.json"),
            ("LOT3", StorageLocation(directory: .root, subpath: "proofs", filename: "LOT3_INSTALLATION_PROOF.json"), "LOT3_INSTALLATION_PROOF.json"),
            ("BUILD_STATUS", StorageLocation(directory: .root, filename: "BUILD_STATUS.md"), "BUILD_STATUS.md"),
            ("MANIFEST", StorageLocation(directory: .root, filename: "MANIFEST.json"), "MANIFEST.json"),
            ("ESTATE", StorageLocation(directory: .root, filename: "ESTATE_STATE.json"), "ESTATE_STATE.json"),
            ("INDEX", StorageLocation(directory: .root, filename: "INDEX.json"), "INDEX.json"),
        ]

        for (name, location, filename) in requiredLocations {
            let path = "\(projectRoot)/\(location.relativePath)"
            let exists = fileSystem.exists(location)
            let readable: Bool
            if exists {
                readable = (try? fileSystem.read(location)) != nil
            } else {
                readable = false
            }
            var decoded = false
            var validated = false
            var failureReason: String?
            var hash: String?
            var sizeBytes: Int64?
            var modificationDate: Date?

            if exists {
                if let attrs = try? fileSystem.attributes(of: location) {
                    sizeBytes = attrs.sizeBytes
                    modificationDate = attrs.modificationDate
                } else {
                    SUPRARuntimeLogger.shared.log(.error, "Continuity: Cannot read attributes of \(path)")
                }
            }

            if readable {
                if let data = try? fileSystem.read(location) {
                    hash = data.sha256Hex
                    if filename.hasSuffix(".json") {
                        do {
                            _ = try JSONSerialization.jsonObject(with: data)
                            decoded = true
                            validated = true
                        } catch {
                            failureReason = "JSON decode failed: \(error.localizedDescription)"
                            SUPRARuntimeLogger.shared.log(.error, "Continuity: \(name) JSON parse error — \(error.localizedDescription)")
                        }
                    } else {
                        decoded = true
                        validated = true
                    }
                } else {
                    failureReason = "File exists but read returned nil"
                    SUPRARuntimeLogger.shared.log(.error, "Continuity: \(name) at \(path) exists but cannot be read")
                }
            } else if exists {
                failureReason = "File exists but not readable — permissions or lock"
                SUPRARuntimeLogger.shared.log(.error, "Continuity: \(name) at \(path) exists but is not readable")
            } else {
                failureReason = "File not found at expected path"
                SUPRARuntimeLogger.shared.log(.error, "Continuity: \(name) not found at \(path)")
            }

            artifacts.append(ArtifactDiag(
                name: name,
                expectedPath: path,
                resolvedPath: path,
                exists: exists,
                readable: readable,
                decoded: decoded,
                validated: validated,
                available: exists && readable && decoded && validated,
                hash: hash.map { String($0.prefix(16)) },
                sizeBytes: sizeBytes,
                modificationDate: modificationDate,
                failureReason: failureReason
            ))
        }

        state.artifacts = artifacts
    }

    private func loadContinuityMarkdown() {
        let continuityLocation = StorageLocation(directory: .continuity, filename: "CONTINUITY.md")
        guard fileSystem.exists(continuityLocation) else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: CONTINUITY.md not found via FileSystemPort")
            return
        }
        guard let text = try? fileSystem.readString(continuityLocation) else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: CONTINUITY.md is not valid UTF-8 text via FileSystemPort")
            return
        }

        if let range = range(of: "Début de la session précédente", in: text) {
            state.lastFreeze = String(text[range.upperBound...].prefix(100)).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let range = text.range(of: "Generated:") {
            let snippet = String(text[range.lowerBound...]).prefix(200)
            if let dateRange = snippet.range(of: "\n") {
                state.lastFreeze = String(snippet[snippet.startIndex..<dateRange.lowerBound])
                    .replacingOccurrences(of: "Generated:", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: CONTINUITY.md missing expected markers")
        }
    }

    private func loadNextMission() {
        let nextMissionLocation = StorageLocation(directory: .continuity, filename: "NEXT_MISSION.md")
        guard fileSystem.exists(nextMissionLocation) else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: NEXT_MISSION.md not found via FileSystemPort")
            return
        }
        guard let text = try? fileSystem.readString(nextMissionLocation) else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: NEXT_MISSION.md is not valid UTF-8 text via FileSystemPort")
            return
        }

        let lines = text.components(separatedBy: .newlines)
        if let titleLine = lines.first(where: { $0.contains("## Mission:") }) {
            state.nextMission = titleLine.replacingOccurrences(of: "## Mission:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: NEXT_MISSION.md missing \"## Mission:\" header")
        }
        if state.currentMission == "—" {
            state.currentMission = state.nextMission
        }
    }

    private func loadGitState() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", "cd \"\(projectRoot)\" && git rev-parse --short HEAD 2>/dev/null"]
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
        } catch {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: git rev-parse failed: \(error.localizedDescription)")
            return
        }
        process.waitUntilExit()
        guard let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: git commit output not readable as UTF-8")
            return
        }
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            state.gitCommit = trimmed
        } else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: git rev-parse returned empty string")
        }
    }

    private func loadLogs() {
        state.lastLogs = Array(SUPRARuntimeLogger.shared.events.suffix(100).reversed())
    }

    private func loadFreezeTimestamp() {
        let continuityLocation = StorageLocation(directory: .continuity, filename: "CONTINUITY.md")
        if fileSystem.exists(continuityLocation) {
            if let text = try? fileSystem.readString(continuityLocation) {
                if let range = text.range(of: "Generated:") {
                    let snippet = String(text[range.lowerBound...]).prefix(200)
                    if let endRange = snippet.range(of: "\n") {
                        state.freezeTimestamp = String(snippet[snippet.startIndex..<endRange.lowerBound])
                            .replacingOccurrences(of: "Generated:", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    } else {
                        SUPRARuntimeLogger.shared.log(.error, "Continuity: Cannot parse timestamp from CONTINUITY.md")
                    }
                } else {
                    SUPRARuntimeLogger.shared.log(.error, "Continuity: CONTINUITY.md missing \"Generated:\" marker for timestamp")
                }
            } else {
                SUPRARuntimeLogger.shared.log(.error, "Continuity: CONTINUITY.md is not valid UTF-8 text via FileSystemPort")
            }
        } else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: CONTINUITY.md not found via FileSystemPort")
        }

        let buildStatusLocation = StorageLocation(directory: .continuity, filename: "BUILD_STATUS.md")
        if fileSystem.exists(buildStatusLocation) {
            do {
                let text = try fileSystem.readString(buildStatusLocation)
                let lines = text.components(separatedBy: .newlines)
                var found = false
                for line in lines {
                    if line.contains("Build Version:") {
                        state.buildVersion = line.replacingOccurrences(of: "Build Version:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                        found = true
                    }
                }
                if !found {
                    SUPRARuntimeLogger.shared.log(.error, "Continuity: BUILD_STATUS.md missing \"Build Version:\" line")
                }
            } catch {
                SUPRARuntimeLogger.shared.log(.error, "Continuity: BUILD_STATUS.md read error via FileSystemPort — \(error.localizedDescription)")
            }
        } else {
            SUPRARuntimeLogger.shared.log(.error, "Continuity: BUILD_STATUS.md not found via FileSystemPort")
        }

        state.gitVersion = "git \(state.gitCommit) on \(state.gitBranch)"
    }

    private func resolveContinuityStatus() {
        let bootManager = ExecutiveBootManager.shared
        state.bootState = bootManager.bootState.rawValue
        state.freezeStatus = bootManager.freezeValidity.rawValue
        state.continuityStatus = bootManager.continuityPackExists ? "AVAILABLE" : "UNAVAILABLE"
        state.resumeAvailable = bootManager.isBootComplete && bootManager.bootState != .firstBoot && bootManager.bootState != .divergence
    }

    func resumeSession() {
        ExecutiveBootManager.shared.resumeSession()
        load()
    }

    private func range(of substring: String, in text: String) -> Range<String.Index>? {
        text.range(of: substring)
    }
}
