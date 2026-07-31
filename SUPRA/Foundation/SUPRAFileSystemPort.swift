//
//  SUPRAFileSystemPort.swift
//  SUPRA
//
//  Foundation Layer — FileSystemPort V1.
//  The single interface to the file system for the SUPRA runtime.
//  Elementary, atomic, business-free operations only.
//  Created as part of FOUNDATION ERA — EXECUTIVE BOOTSTRAP V1, Step 1 (FileSystemPort).
//

import Foundation

/// The single interface between the SUPRA runtime and the file system.
///
/// Responsibilities:
/// - resolve canonical locations (typed, no raw paths)
/// - read / write (atomic) / list / migrate / remove
/// - create the canonical directory layout
///
/// Non-responsibilities (by design):
/// - no business logic
/// - no default-value decisions (upper layers map failures to semantic defaults)
/// - no version policy / migrations orchestration (ContinuityEngine's role)
public protocol FileSystemPort: Sendable {
    /// Canonical storage root (injectable for tests).
    var rootURL: URL { get }

    // MARK: Resolution

    /// Resolved URL for a location relative to the storage root.
    func url(for location: StorageLocation) -> URL
    /// Resolved URL for a canonical directory.
    func url(for directory: StorageDirectory) -> URL

    // MARK: Existence

    /// Whether the file at the location exists.
    func exists(_ location: StorageLocation) -> Bool
    /// Whether the canonical directory exists.
    func directoryExists(_ directory: StorageDirectory) -> Bool

    // MARK: Read / Write

    /// Reads the raw data at the location. Throws if missing or unreadable.
    func read(_ location: StorageLocation) throws -> Data
    /// Reads UTF-8 text at the location. Throws if missing or unreadable.
    func readString(_ location: StorageLocation) throws -> String
    /// Writes data atomically (temp file + replace). Creates intermediate directories.
    func write(_ data: Data, to location: StorageLocation) throws
    /// Writes UTF-8 text atomically.
    func writeString(_ string: String, to location: StorageLocation) throws

    // MARK: Directories

    /// Creates a canonical directory (with intermediates). Idempotent.
    func createDirectory(_ directory: StorageDirectory) throws
    /// Creates all canonical directories. Idempotent.
    func createAllDirectories() throws
    /// Lists file names (not directories) inside a canonical directory.
    func list(_ directory: StorageDirectory) throws -> [String]

    // MARK: Migration / Removal / Attributes

    /// Copies a location's content to another location (atomic write on destination).
    /// Source is left untouched — callers decide whether to remove it.
    func migrate(from source: StorageLocation, to destination: StorageLocation) throws
    /// Removes the file at the location. No-op if absent.
    func remove(_ location: StorageLocation) throws
    /// Returns size and modification date of the file at the location.
    func attributes(of location: StorageLocation) throws -> SUPRASupportedFileAttributes
}

/// Default production implementation of `FileSystemPort`.
///
/// Thread-safe: `FileManager` is thread-safe and every operation is confined
/// to a single immutable root URL. Safe to call from background contexts;
/// callers on the main actor must keep operations small and fast.
public struct DefaultFileSystemPort: FileSystemPort, @unchecked Sendable {
    /// Canonical storage root.
    public let rootURL: URL

    private let fileManager: FileManager

    public init(rootURL: URL, fileManager: FileManager = .default) {
        self.rootURL = rootURL
        self.fileManager = fileManager
    }

    /// The live, production instance rooted at `~/Library/Application Support/SUPRA/`.
    public static func live() -> DefaultFileSystemPort {
        DefaultFileSystemPort(rootURL: SUPRAApplicationSupportLocator.storageRootURL())
    }

    // MARK: Resolution

    public func url(for location: StorageLocation) -> URL {
        location.url(relativeTo: rootURL)
    }

    public func url(for directory: StorageDirectory) -> URL {
        rootURL.appendingPathComponent(directory.directoryName, isDirectory: true)
    }

    // MARK: Existence

    public func exists(_ location: StorageLocation) -> Bool {
        fileManager.fileExists(atPath: url(for: location).path)
    }

    public func directoryExists(_ directory: StorageDirectory) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: url(for: directory).path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    // MARK: Read / Write

    public func read(_ location: StorageLocation) throws -> Data {
        let url = url(for: location)
        // First check if the file exists to distinguish between missing and unreadable
        if !fileManager.fileExists(atPath: url.path) {
            throw FileSystemPortError.missingLocation(location)
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            throw FileSystemPortError.unreadable(location, underlying: error)
        }
    }

    public func readString(_ location: StorageLocation) throws -> String {
        let data = try read(location)
        guard let text = String(data: data, encoding: .utf8) else {
            throw FileSystemPortError.unreadable(location, underlying: CocoaError(.fileReadCorruptFile))
        }
        return text
    }

    public func write(_ data: Data, to location: StorageLocation) throws {
        let destination = url(for: location)
        let directory = destination.deletingLastPathComponent()
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            throw FileSystemPortError.unwritable(location, underlying: error)
        }

        // Atomic write: temp file in the same directory, then replace.
        let temporary = directory.appendingPathComponent(
            ".\(destination.lastPathComponent).tmp-\(UUID().uuidString)",
            isDirectory: false
        )
        do {
            try data.write(to: temporary, options: [.withoutOverwriting])
            _ = try fileManager.replaceItemAt(destination, withItemAt: temporary)
        } catch {
            try? fileManager.removeItem(at: temporary)
            throw FileSystemPortError.unwritable(location, underlying: error)
        }
    }

    public func writeString(_ string: String, to location: StorageLocation) throws {
        guard let data = string.data(using: .utf8) else {
            throw FileSystemPortError.unwritable(location, underlying: CocoaError(.fileWriteInapplicableStringEncoding))
        }
        try write(data, to: location)
    }

    // MARK: Directories

    public func createDirectory(_ directory: StorageDirectory) throws {
        do {
            try fileManager.createDirectory(at: url(for: directory), withIntermediateDirectories: true)
        } catch {
            throw FileSystemPortError.unwritable(
                StorageLocation(directory: directory, filename: ""),
                underlying: error
            )
        }
    }

    public func createAllDirectories() throws {
        for directory in StorageDirectory.allCases {
            try createDirectory(directory)
        }
    }

    public func list(_ directory: StorageDirectory) throws -> [String] {
        let url = url(for: directory)
        guard fileManager.fileExists(atPath: url.path) else {
            throw FileSystemPortError.missingDirectory(directory)
        }
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            return contents
                .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory != true }
                .map(\.lastPathComponent)
                .sorted()
        } catch {
            throw FileSystemPortError.missingDirectory(directory)
        }
    }

    // MARK: Migration / Removal / Attributes

    public func migrate(from source: StorageLocation, to destination: StorageLocation) throws {
        let data: Data
        do {
            data = try read(source)
        } catch {
            throw FileSystemPortError.migrationFailed(from: source, to: destination, underlying: error)
        }
        do {
            try write(data, to: destination)
        } catch {
            throw FileSystemPortError.migrationFailed(from: source, to: destination, underlying: error)
        }
    }

    public func remove(_ location: StorageLocation) throws {
        let url = url(for: location)
        guard fileManager.fileExists(atPath: url.path) else { return }
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw FileSystemPortError.unwritable(location, underlying: error)
        }
    }

    public func attributes(of location: StorageLocation) throws -> SUPRASupportedFileAttributes {
        let url = url(for: location)
        guard fileManager.fileExists(atPath: url.path) else {
            throw FileSystemPortError.missingLocation(location)
        }
        do {
            let values = try fileManager.attributesOfItem(atPath: url.path)
            return SUPRASupportedFileAttributes(
                sizeBytes: values[.size] as? Int64,
                modificationDate: values[.modificationDate] as? Date
            )
        } catch {
            throw FileSystemPortError.missingLocation(location)
        }
    }
}
