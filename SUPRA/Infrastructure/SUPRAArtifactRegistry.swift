//
//  SUPRAArtifactRegistry.swift
//  SUPRA
//
//  Infrastructure Layer — ArtifactRegistry V1.
//  Single, certified point of access to artefacts for the Runtime.
//  No Runtime module should touch the file system directly.
//  All artefact reads/writes go exclusively through this registry.
//  Created as part of FOUNDATION ERA — Phase 2: Artifact Registry V1.
//

import Foundation

// MARK: - Artifact Registration Status (unique to the registry)

/// Lifecycle status an artefact can have within the ArtifactRegistry.
public enum SUPRAArtifactRegistrationStatus: String, CaseIterable, Codable, Equatable, Sendable {
    case pending = "PENDING"
    case available = "AVAILABLE"
    case degraded = "DEGRADED"
    case unknown = "UNKNOWN"
    case error = "ERROR"
}

// MARK: - Build Status (registry-specific, distinct from HealthMonitor.RuntimeStatus)

/// Typed build status read from BUILD_STATUS.md.
public struct SUPRABuildStatus: Codable, Equatable, Sendable {
    public enum Status: String, Codable, Equatable, Sendable {
        case succeeded = "SUCCEEDED"
        case failed = "FAILED"
        case unknown = "UNKNOWN"
        case pending = "PENDING"
    }

    public let status: Status
    public let version: String
    public let timestamp: Date

    public static let unknown = SUPRABuildStatus(status: .unknown, version: "-", timestamp: .distantPast)
    public static let notInstalled = SUPRABuildStatus(status: .unknown, version: "-", timestamp: .distantPast)
}

// MARK: - Runtime State (registry-specific, distinct from HealthMonitor.RuntimeStatus)

/// Typed runtime state read from SUPRA_STATE.json / RUNTIME_STATUS.json.
public struct SUPRARuntimeState: Codable, Equatable, Sendable {
    public enum State: String, Codable, Equatable, Sendable {
        case ready = "READY"
        case degraded = "DEGRADED"
        case starting = "STARTING"
        case stopping = "STOPPING"
    }

    public enum Environment: String, Codable, Equatable, Sendable {
        case firstLaunch = "FIRST_LAUNCH"
        case created = "CREATED"
        case validated = "VALIDATED"
        case migrated = "MIGRATED"
        case pending = "PENDING"
    }

    public let state: State
    public let environment: Environment
    public let build: SUPRABuildStatus
    public let uptimeMs: Int
    public let lastCheck: Date

    public static let initial = SUPRARuntimeState(
        state: .starting,
        environment: .pending,
        build: .notInstalled,
        uptimeMs: 0,
        lastCheck: .distantPast
    )
}

// MARK: - Continuity Info (registry-specific)

/// Typed continuity information read from CONTINUITY.md.
public struct SUPRAContinuityInfo: Codable, Equatable, Sendable {
    public let currentMission: String?
    public let previousMission: String?
    public let nextMission: String?
    public let resumeAvailable: Bool
    public let generatedAt: String?

    public static let empty = SUPRAContinuityInfo(
        currentMission: nil,
        previousMission: nil,
        nextMission: "FOUNDATION ERA",
        resumeAvailable: false,
        generatedAt: nil
    )
}

// MARK: - Mission Info (registry-specific)

/// Typed mission metadata read from NEXT_MISSION.md.
public struct SUPRAMissionInfo: Codable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let priority: Priority
    public let status: Status

    public enum Priority: String, Codable, Equatable, Sendable {
        case critical = "CRITICAL"
        case high = "HIGH"
        case medium = "MEDIUM"
        case low = "LOW"
    }

    public enum Status: String, Codable, Equatable, Sendable {
        case running = "RUNNING"
        case completed = "COMPLETED"
        case pending = "PENDING"
        case halted = "HALTED"
    }

    public static let foundationEra = SUPRAMissionInfo(
        id: "foundational-era-2026-07-31",
        title: "FOUNDATION ERA",
        priority: .critical,
        status: .pending
    )
}

// MARK: - Mission Queue (registry-specific)

/// Typed mission queue read from MISSION_QUEUE.json.
public struct SUPRAMissionQueue: Codable, Equatable, Sendable {
    public let items: [SUPRAMissionInfo]
    public let active: SUPRAMissionInfo?
    public let count: Int

    public enum QueueStatus: String, Codable, Equatable, Sendable {
        case idle = "IDLE"
        case running = "RUNNING"
        case completed = "COMPLETED"
    }

    public let status: QueueStatus

    public static let empty = SUPRAMissionQueue(items: [], active: nil, count: 0, status: .idle)
}

// MARK: - Runtime Diagnostics (registry-specific, populated by Continuity Engine in V2)

/// Lightweight diagnostics placeholder — populated by Continuity Engine V2 and read via FileSystemPort.
public struct RuntimeDiagnostics: Codable, Equatable, Sendable {
    public let pipelineSteps: [PipelineStep]
    public let artifactDiagnostics: [ArtifactDiag]

    public struct PipelineStep: Codable, Equatable, Identifiable, Sendable {
        public let id = UUID().uuidString
        public let name: String
        public let status: String
        public let detail: String
    }

    public struct ArtifactDiag: Codable, Equatable, Identifiable, Sendable {
        public let id = UUID().uuidString
        public let name: String
        public let exists: Bool
        public let readable: Bool
        public let validated: Bool
    }

    public static let empty = RuntimeDiagnostics(pipelineSteps: [], artifactDiagnostics: [])
}

// MARK: - Registry Update Payload

/// Write payload for the ArtifactRegistry.
public enum SUPRARegistryUpdate: Sendable {
    case runtimeStatus(SUPRARuntimeState)
    case buildStatus(SUPRABuildStatus)
    case continuity(SUPRAContinuityInfo)
    case nextMission(SUPRAMissionInfo)
    case missionQueue(SUPRAMissionQueue)
}

// MARK: - ArtifactRegistry Protocol

/// The canonical, sole point of access to SUPRA artefacts.
///
/// Rule of SUPRA governance (FOUNDATION ERA):
/// No Runtime module — including MissionRuntime, ContinuityEngine, or BootOrchestrator — should
/// access the file system directly. All artifact reads/writes go exclusively through this registry.
/// The registry uses FileSystemPort underneath and returns semantic defaults when artefacts are absent.
public protocol ArtifactRegistry: Sendable {
    func runtimeStatus() async -> SUPRARuntimeState
    func buildStatus() async -> SUPRABuildStatus
    func continuity() async -> SUPRAContinuityInfo
    func nextMission() async -> SUPRAMissionInfo
    func missionQueue() async -> SUPRAMissionQueue
    func diagnostics() async -> RuntimeDiagnostics
    func write(_ update: SUPRARegistryUpdate) async throws
}

// MARK: - LiveArtifactRegistry Implementation

/// Production implementation of ArtifactRegistry.
///
/// Uses FileSystemPort for all file operations — never FileManager directly.
/// Thread-safe: DefaultFileSystemPort uses an immutable rootURL.
public final class LiveArtifactRegistry: ArtifactRegistry {
    public static let shared = LiveArtifactRegistry()

    private let fileSystem: FileSystemPort

    init(fileSystem: FileSystemPort = DefaultFileSystemPort.live()) {
        self.fileSystem = fileSystem
    }

    // MARK: - RUNTIME_STATUS (Phase 1 of migration)

    public func runtimeStatus() async -> SUPRARuntimeState {
        let location = StorageLocation(directory: .state, filename: "SUPRA_STATE.json")
        do {
            let data = try fileSystem.read(location)
            return try JSONDecoder().decode(SUPRARuntimeState.self, from: data)
        } catch {
            SUPRARuntimeLogger.shared.log(.error, "ArtifactRegistry: SUPRA_STATE.json not found or unreadable — returning default (first launch?)")
            return .initial
        }
    }

    // MARK: - BUILD_STATUS (Phase 2 of migration)

    public func buildStatus() async -> SUPRABuildStatus {
        let location = StorageLocation(directory: .continuity, filename: "BUILD_STATUS.md")
        guard fileSystem.exists(location) else {
            SUPRARuntimeLogger.shared.log(.error, "ArtifactRegistry: BUILD_STATUS.md not found — returning unknown")
            return .unknown
        }
        do {
            let text = try fileSystem.readString(location)
            return parseBuildStatusMarkdown(text) ?? .unknown
        } catch {
            return .unknown
        }
    }

    // MARK: - CONTINUITY (Phase 4 of migration)

    public func continuity() async -> SUPRAContinuityInfo {
        let location = StorageLocation(directory: .continuity, filename: "CONTINUITY.md")
        guard fileSystem.exists(location) else {
            SUPRARuntimeLogger.shared.log(.error, "ArtifactRegistry: CONTINUITY.md not found — returning empty")
            return .empty
        }
        do {
            let _ = try fileSystem.readString(location)
            return .empty
        } catch {
            return .empty
        }
    }

    // MARK: - NEXT_MISSION (Phase 3 of migration)

    public func nextMission() async -> SUPRAMissionInfo {
        let location = StorageLocation(directory: .continuity, filename: "NEXT_MISSION.md")
        guard fileSystem.exists(location) else {
            SUPRARuntimeLogger.shared.log(.error, "ArtifactRegistry: NEXT_MISSION.md not found — returning FOUNDATION ERA")
            return .foundationEra
        }
        do {
            let text = try fileSystem.readString(location)
            return parseNextMissionMarkdown(text) ?? .foundationEra
        } catch {
            return .foundationEra
        }
    }

    // MARK: - MISSION_QUEUE

    public func missionQueue() async -> SUPRAMissionQueue {
        let location = StorageLocation(directory: .missions, filename: "MISSION_QUEUE.json")
        guard fileSystem.exists(location) else {
            SUPRARuntimeLogger.shared.log(.error, "ArtifactRegistry: MISSION_QUEUE.json not found — returning empty")
            return .empty
        }
        do {
            let data = try fileSystem.read(location)
            return try JSONDecoder().decode(SUPRAMissionQueue.self, from: data)
        } catch {
            return .empty
        }
    }

    // MARK: - Diagnostics

    public func diagnostics() async -> RuntimeDiagnostics {
        let location = StorageLocation(directory: .runtime, filename: "runtime_diagnostics.json")
        guard fileSystem.exists(location) else {
            return RuntimeDiagnostics.empty
        }
        do {
            let data = try fileSystem.read(location)
            return try JSONDecoder().decode(RuntimeDiagnostics.self, from: data)
        } catch {
            return RuntimeDiagnostics.empty
        }
    }

    // MARK: - Write

    public func write(_ update: SUPRARegistryUpdate) async throws {
        switch update {
        case .runtimeStatus(let status):
            let location = StorageLocation(directory: .state, filename: "SUPRA_STATE.json")
            let data = try JSONEncoder().encode(status)
            try fileSystem.write(data, to: location)

        case .buildStatus(let status):
            let location = StorageLocation(directory: .continuity, filename: "BUILD_STATUS.md")
            let mdText = renderBuildStatusMarkdown(status)
            try fileSystem.writeString(mdText, to: location)

        case .continuity(let info):
            let location = StorageLocation(directory: .continuity, filename: "CONTINUITY.md")
            let mdText = renderContinuityMarkdown(info)
            try fileSystem.writeString(mdText, to: location)

        case .nextMission(let info):
            let location = StorageLocation(directory: .continuity, filename: "NEXT_MISSION.md")
            let mdText = renderNextMissionMarkdown(info)
            try fileSystem.writeString(mdText, to: location)

        case .missionQueue(let queue):
            let location = StorageLocation(directory: .missions, filename: "MISSION_QUEUE.json")
            let data = try JSONEncoder().encode(queue)
            try fileSystem.write(data, to: location)
        }
    }

    // MARK: - Private Helpers

    private func parseBuildStatusMarkdown(_ text: String) -> SUPRABuildStatus? {
        let lines = text.components(separatedBy: .newlines)
        var detectedStatus: SUPRABuildStatus.Status?
        var version = "-"
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.localizedCaseInsensitiveContains("succeeded")
                || trimmed.localizedCaseInsensitiveContains("PASSED")
                || trimmed.localizedCaseInsensitiveContains("BUILD SUCCEEDED") {
                detectedStatus = .succeeded
            } else if trimmed.localizedCaseInsensitiveContains("failed")
                || trimmed.localizedCaseInsensitiveContains("FAILED")
                || trimmed.localizedCaseInsensitiveContains("BUILD FAILED") {
                detectedStatus = .failed
            } else if trimmed.localizedCaseInsensitiveContains("pending") {
                detectedStatus = .pending
            } else if trimmed.localizedCaseInsensitiveContains("build version:") {
                version = trimmed.replacingOccurrences(of: "Build Version:", with: "").trimmingCharacters(in: .whitespaces)
            } else if trimmed.localizedCaseInsensitiveContains("version:") {
                version = trimmed.replacingOccurrences(of: "Version:", with: "").trimmingCharacters(in: .whitespaces)
            }
        }
        guard let status = detectedStatus else { return nil }
        return SUPRABuildStatus(status: status, version: version, timestamp: .now)
    }

    private func parseNextMissionMarkdown(_ text: String) -> SUPRAMissionInfo? {
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            if line.contains("## Mission:") || line.contains("# Mission:") {
                let title = line
                    .replacingOccurrences(of: "## Mission:", with: "")
                    .replacingOccurrences(of: "# Mission:", with: "")
                    .trimmingCharacters(in: .whitespaces)
                return SUPRAMissionInfo(
                    id: "mission-\(title.prefix(40).lowercased().replacingOccurrences(of: " ", with: "-"))",
                    title: title,
                    priority: .critical,
                    status: .pending
                )
            }
        }
        return nil
    }

    // MARK: - Markdown Renderers

    private func renderBuildStatusMarkdown(_ status: SUPRABuildStatus) -> String {
        """
        # Build Status

        Status: \(status.status.rawValue)
        Version: \(status.version)
        Generated: \(ISO8601DateFormatter().string(from: status.timestamp))
        """
    }

    private func renderContinuityMarkdown(_ info: SUPRAContinuityInfo) -> String {
        """
        # Continuity

        Generated: \(ISO8601DateFormatter().string(from: Date()))
        Current Mission: \(info.currentMission ?? "—")
        Previous Mission: \(info.previousMission ?? "—")
        Next Mission: \(info.nextMission ?? "—")
        Resume Available: \(info.resumeAvailable)
        """
    }

    private func renderNextMissionMarkdown(_ info: SUPRAMissionInfo) -> String {
        """
        # Mission: \(info.title)

        Priority: \(info.priority.rawValue)
        Status: \(info.status.rawValue)
        """
    }
}
