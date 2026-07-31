//
//  SUPRAApplicationSupportLocator.swift
//  SUPRA
//
//  Foundation Layer — storage root resolution.
//  Resolves the canonical SUPRA storage root in Application Support,
//  following Apple guidance for persistent app data.
//  Created as part of FOUNDATION ERA — EXECUTIVE BOOTSTRAP V1, Step 1 (FileSystemPort).
//

import Foundation

/// Resolves the canonical storage root of the SUPRA runtime.
///
/// Target: `~/Library/Application Support/SUPRA/`
///
/// This is the single place where the storage root is derived. No other
/// component in the runtime should hard-code Application Support paths.
public enum SUPRAApplicationSupportLocator {
    /// Bundle identifier used as the subdirectory inside Application Support.
    public static let storageDirectoryName = "SUPRA"

    /// The canonical storage root URL: `~/Library/Application Support/SUPRA/`.
    ///
    /// The directory may not exist yet — creation is the Bootstrap's
    /// responsibility (via `FileSystemPort.createAllDirectories()`).
    public static func storageRootURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let applicationSupport = base.first
            ?? FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/Application Support", isDirectory: true)
        return applicationSupport.appendingPathComponent(storageDirectoryName, isDirectory: true)
    }

    /// Convenience: the URL for a canonical directory inside the storage root.
    public static func directoryURL(_ directory: StorageDirectory) -> URL {
        storageRootURL().appendingPathComponent(directory.directoryName, isDirectory: true)
    }
}
