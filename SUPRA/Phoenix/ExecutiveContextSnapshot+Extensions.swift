// MARK: - ExecutionVision - Vision Engine Snapshot
//
// A snapshot of what the Vision Engine perceives at a given moment.
// Used by OeilPerceptionLayer to determine gaze and mood.

import Foundation

// MARK: - ExecutionVision

public struct ExecutionVision: Codable, Sendable {
    public var isWatching: Bool
    public var readingMode: ReadingMode
    public var gitChangeCount: Int
    public var fileChangeCount: Int
    public var activeBranches: [String]
    public var lastChangeDetected: Date?

    public enum ReadingMode: String, Codable, Sendable {
        case manual, automatic, polling
    }

    public init(
        isWatching: Bool = false,
        readingMode: ReadingMode = .manual,
        gitChangeCount: Int = 0,
        fileChangeCount: Int = 0,
        activeBranches: [String] = [],
        lastChangeDetected: Date? = nil
    ) {
        self.isWatching = isWatching
        self.readingMode = readingMode
        self.gitChangeCount = gitChangeCount
        self.fileChangeCount = fileChangeCount
        self.activeBranches = activeBranches
        self.lastChangeDetected = lastChangeDetected
    }
}

// MARK: - ExecutiveContextSnapshot computed convenience accessors

extension ExecutiveContextSnapshot {
    /// Human-readable display name for this snapshot.
    var displayName: String {
        "Mission Snapshot \(missionId)"
    }

    /// The runtime state string (convenience alias for runtimeStatus).
    var runtimeState: String {
        runtimeStatus
    }
}
