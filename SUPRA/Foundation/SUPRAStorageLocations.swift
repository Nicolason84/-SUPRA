//
//  SUPRAStorageLocations.swift
//  SUPRA
//
//  Foundation Layer — StorageLocation vocabulary.
//  Canonical storage layout for the SUPRA runtime environment.
//  Created as part of FOUNDATION ERA — EXECUTIVE BOOTSTRAP V1, Step 1 (FileSystemPort).
//

import Foundation

/// The canonical directories of the SUPRA runtime environment.
///
/// Layout (created on first launch, under `~/Library/Application Support/SUPRA/`):
///
/// ```
/// Application Support/SUPRA/
/// ├── State/       → SUPRA_STATE.json, version.json, session state
/// ├── Runtime/     → RUNTIME_STATUS.json, runtime_diagnostics.json, BOOT_REPORT.json
/// ├── Artifacts/   → MANIFEST.json, INDEX.json, ESTATE_STATE.json, proofs/
/// ├── Continuity/  → CONTINUITY.md, NEXT_MISSION.md, BUILD_STATUS.md
/// ├── Snapshots/   → durable runtime snapshots
/// ├── Logs/        → runtime journals
/// ├── Cache/       → regenerable data
/// └── Missions/    → MISSION_QUEUE.json, mission history
/// ```
public enum StorageDirectory: String, CaseIterable, Sendable, Identifiable {
    case state = "State"
    case runtime = "Runtime"
    case artifacts = "Artifacts"
    case continuity = "Continuity"
    case snapshots = "Snapshots"
    case logs = "Logs"
    case cache = "Cache"
    case missions = "Missions"

    public var id: String { rawValue }

    /// Directory name on disk (== `rawValue`).
    public var directoryName: String { rawValue }
}

/// A typed, canonical location inside the SUPRA storage root.
///
/// `StorageLocation` is the only vocabulary the Foundation layer exposes to upper
/// layers: a directory, an optional nested subpath, and a file name. No raw
/// absolute path is ever required from callers.
public struct StorageLocation: Hashable, Sendable {
    /// Canonical directory under the storage root.
    public let directory: StorageDirectory
    /// Optional nested subpath inside the directory (e.g. `proofs`).
    /// Components must be plain file-system names; traversal is rejected.
    public let subpath: String?
    /// File name inside the directory (or subpath).
    public let filename: String

    public init(directory: StorageDirectory, subpath: String? = nil, filename: String) {
        self.directory = directory
        self.subpath = subpath
        self.filename = filename
    }

    /// File name with the optional subpath prefixed, e.g. `proofs/LOT1.json`.
    public var relativePath: String {
        if let subpath, !subpath.isEmpty {
            return "\(subpath)/\(filename)"
        }
        return filename
    }

    /// Resolved URL relative to a given root, without touching the file system.
    public func url(relativeTo root: URL) -> URL {
        var url = root.appendingPathComponent(directory.directoryName, isDirectory: true)
        if let subpath, !subpath.isEmpty {
            url = url.appendingPathComponent(subpath, isDirectory: true)
        }
        return url.appendingPathComponent(filename, isDirectory: false)
    }
}

/// Errors surfaced by the Foundation layer. Upper layers translate these into
/// semantic defaults — never into raw `... not found` strings.
public enum FileSystemPortError: LocalizedError, Sendable {
    case missingLocation(StorageLocation)
    case missingDirectory(StorageDirectory)
    case unreadable(StorageLocation, underlying: Error)
    case unwritable(StorageLocation, underlying: Error)
    case migrationFailed(from: StorageLocation, to: StorageLocation, underlying: Error)
    case invalidSubpath(String)

    public var errorDescription: String? {
        switch self {
        case .missingLocation(let location):
            return "File system: artifact not present at \(location.relativePath)"
        case .missingDirectory(let directory):
            return "File system: directory not present: \(directory.directoryName)"
        case .unreadable(let location, _):
            return "File system: cannot read \(location.relativePath)"
        case .unwritable(let location, _):
            return "File system: cannot write \(location.relativePath)"
        case .migrationFailed(let from, let to, _):
            return "File system: migration failed \(from.relativePath) → \(to.relativePath)"
        case .invalidSubpath(let subpath):
            return "File system: invalid subpath '\(subpath)' (traversal rejected)"
        }
    }
}

/// Lightweight file attributes exposed by the Foundation layer.
public struct SUPRASupportedFileAttributes: Sendable, Equatable {
    public let sizeBytes: Int64?
    public let modificationDate: Date?

    public init(sizeBytes: Int64?, modificationDate: Date?) {
        self.sizeBytes = sizeBytes
        self.modificationDate = modificationDate
    }
}
