import AppKit
import Combine
import Foundation

struct ProtectedFolderEntry: Codable, Hashable, Sendable {
    let path: String
    let authorizedRootPath: String
    let name: String
    let pathExtension: String
    let isDirectory: Bool
    let sizeBytes: Int64
    let createdAt: Date?
    let modifiedAt: Date?
}

struct ProtectedFolderSnapshot: Codable, Sendable {
    let generatedAt: Date
    let authorizedRootPaths: [String]
    let entries: [ProtectedFolderEntry]

    static let empty = ProtectedFolderSnapshot(
        generatedAt: .distantPast,
        authorizedRootPaths: [],
        entries: []
    )
}

@MainActor
final class ProtectedFolderAccessCoordinator: ObservableObject {
    static let shared = ProtectedFolderAccessCoordinator()

    enum PermissionState: String, Equatable {
        case notRequested
        case authorized
        case denied
        case stale
    }

    enum AccessError: LocalizedError {
        case accessDenied(URL)
        case noSelectedFolders
        case staleBookmark

        var errorDescription: String? {
            switch self {
            case .accessDenied(let url):
                return "Security-scoped access was denied for \(url.path)."
            case .noSelectedFolders:
                return "Select at least one folder before starting discovery."
            case .staleBookmark:
                return "Folder authorization is stale. Select the folder again to reauthorize access."
            }
        }
    }

    @Published private(set) var permissionState: PermissionState = .notRequested
    @Published private(set) var snapshot: ProtectedFolderSnapshot = .empty
    @Published private(set) var isScanning = false
    @Published private(set) var lastError: String?

    private let fileManager: FileManager
    private let cacheURL: URL
    private let bookmarksURL: URL
    private let startScopedAccess: (URL) -> Bool
    private let stopScopedAccess: (URL) -> Void
    private let makeBookmark: (URL) throws -> Data
    private let resourceKeys: Set<URLResourceKey> = [
        .isDirectoryKey,
        .fileSizeKey,
        .creationDateKey,
        .contentModificationDateKey
    ]

    private convenience init() {
        self.init(
            fileManager: .default,
            supportDirectory: nil,
            startScopedAccess: { $0.startAccessingSecurityScopedResource() },
            stopScopedAccess: { $0.stopAccessingSecurityScopedResource() },
            makeBookmark: {
                try $0.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
            }
        )
    }

    init(
        fileManager: FileManager = .default,
        supportDirectory: URL?,
        startScopedAccess: @escaping (URL) -> Bool = { $0.startAccessingSecurityScopedResource() },
        stopScopedAccess: @escaping (URL) -> Void = { $0.stopAccessingSecurityScopedResource() },
        makeBookmark: @escaping (URL) throws -> Data = {
            try $0.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        }
    ) {
        self.fileManager = fileManager
        self.startScopedAccess = startScopedAccess
        self.stopScopedAccess = stopScopedAccess
        self.makeBookmark = makeBookmark
        let support = supportDirectory
            ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("SUPRA", isDirectory: true)
            ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("SUPRA", isDirectory: true)
        cacheURL = support.appendingPathComponent("protected_folder_snapshot.json")
        bookmarksURL = support.appendingPathComponent("protected_folder_bookmarks.json")
        loadCachedSnapshot()
        loadPermissionState()
    }

    @discardableResult
    func requestDiscovery() -> ProtectedFolderSnapshot? {
        let panel = NSOpenPanel()
        panel.title = "Authorize folders for SUPRA discovery"
        panel.message = "Choose only the folders SUPRA may scan. Access ends when this scan completes."
        panel.prompt = "Authorize and Scan"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.canCreateDirectories = false
        panel.resolvesAliases = true

        guard panel.runModal() == .OK, !panel.urls.isEmpty else {
            if snapshot.authorizedRootPaths.isEmpty {
                permissionState = .denied
            }
            return nil
        }

        do {
            return try scanExplicitlySelectedURLs(panel.urls)
        } catch {
            lastError = error.localizedDescription
            return nil
        }
    }

    @discardableResult
    func scanExplicitlySelectedURLs(_ urls: [URL]) throws -> ProtectedFolderSnapshot {
        guard !urls.isEmpty else {
            throw AccessError.noSelectedFolders
        }
        let next = try scanAuthorizedURLs(urls)
        try persistBookmarks(for: urls)
        try commit(next)
        return next
    }

    @discardableResult
    func refreshAuthorizedRoots() -> ProtectedFolderSnapshot? {
        do {
            let urls = try resolveBookmarks()
            guard !urls.isEmpty else {
                permissionState = .notRequested
                return nil
            }
            let next = try scanAuthorizedURLs(urls)
            try commit(next)
            return next
        } catch AccessError.staleBookmark {
            permissionState = .stale
            lastError = AccessError.staleBookmark.localizedDescription
            return nil
        } catch {
            lastError = error.localizedDescription
            return nil
        }
    }

    func entries(under rootPath: String? = nil) -> [ProtectedFolderEntry] {
        guard let rootPath else { return snapshot.entries }
        return snapshot.entries.filter {
            $0.path == rootPath || $0.path.hasPrefix(rootPath + "/")
        }
    }

    func containsPath(_ path: String) -> Bool {
        snapshot.authorizedRootPaths.contains {
            path == $0 || path.hasPrefix($0 + "/") || $0.hasPrefix(path + "/")
        } || snapshot.entries.contains { $0.path == path || $0.path.hasPrefix(path + "/") }
    }

    private func scanAuthorizedURLs(_ selectedURLs: [URL]) throws -> ProtectedFolderSnapshot {
        isScanning = true
        lastError = nil
        defer { isScanning = false }

        let roots = canonicalRoots(selectedURLs)
        var entries: [ProtectedFolderEntry] = []

        for root in roots {
            try scan(root: root, into: &entries)
        }

        let next = ProtectedFolderSnapshot(
            generatedAt: Date(),
            authorizedRootPaths: roots.map(\.path),
            entries: entries
        )
        return next
    }

    private func commit(_ next: ProtectedFolderSnapshot) throws {
        try persistSnapshot(next)
        snapshot = next
        permissionState = .authorized
    }

    private func scan(root: URL, into entries: inout [ProtectedFolderEntry]) throws {
        guard startScopedAccess(root) else {
            throw AccessError.accessDenied(root)
        }
        defer { stopScopedAccess(root) }

        guard let enumerator = fileManager.enumerator(
            at: root,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsPackageDescendants],
            errorHandler: { [weak self] _, error in
                self?.lastError = error.localizedDescription
                return true
            }
        ) else { return }

        while let url = enumerator.nextObject() as? URL {
            let depth = url.pathComponents.count - root.pathComponents.count
            if depth > 8 {
                enumerator.skipDescendants()
                continue
            }

            let name = url.lastPathComponent
            if name.hasPrefix("."), name != ".git" {
                enumerator.skipDescendants()
                continue
            }

            guard let values = try? url.resourceValues(forKeys: resourceKeys) else { continue }
            let isDirectory = values.isDirectory ?? false
            entries.append(ProtectedFolderEntry(
                path: url.path,
                authorizedRootPath: root.path,
                name: name,
                pathExtension: url.pathExtension.lowercased(),
                isDirectory: isDirectory,
                sizeBytes: Int64(values.fileSize ?? 0),
                createdAt: values.creationDate,
                modifiedAt: values.contentModificationDate
            ))
            if name == ".git", isDirectory {
                enumerator.skipDescendants()
            }
        }
    }

    private func canonicalRoots(_ urls: [URL]) -> [URL] {
        let sorted = Set(urls.map { $0.resolvingSymlinksInPath().standardizedFileURL })
            .sorted { $0.path.count < $1.path.count }
        var roots: [URL] = []
        for url in sorted where !roots.contains(where: { url.path.hasPrefix($0.path + "/") }) {
            roots.append(url)
        }
        return roots
    }

    private func persistBookmarks(for urls: [URL]) throws {
        let directory = bookmarksURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let bookmarks = try canonicalRoots(urls).map(makeBookmark)
        try PropertyListEncoder().encode(bookmarks).write(to: bookmarksURL, options: .atomic)
    }

    private func resolveBookmarks() throws -> [URL] {
        guard let data = try? Data(contentsOf: bookmarksURL) else { return [] }
        let bookmarks = try PropertyListDecoder().decode([Data].self, from: data)
        let urls = try bookmarks.map {
            var bookmarkIsStale = false
            let url = try URL(
                resolvingBookmarkData: $0,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &bookmarkIsStale
            )
            if bookmarkIsStale {
                throw AccessError.staleBookmark
            }
            return url
        }
        return urls
    }

    private func persistSnapshot(_ snapshot: ProtectedFolderSnapshot) throws {
        let directory = cacheURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(snapshot).write(to: cacheURL, options: .atomic)
    }

    private func loadCachedSnapshot() {
        guard let data = try? Data(contentsOf: cacheURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let cached = try? decoder.decode(ProtectedFolderSnapshot.self, from: data) {
            snapshot = cached
        }
    }

    private func loadPermissionState() {
        guard
            let data = try? Data(contentsOf: bookmarksURL),
            let bookmarks = try? PropertyListDecoder().decode([Data].self, from: data),
            !bookmarks.isEmpty
        else {
            permissionState = .notRequested
            return
        }
        if !bookmarks.isEmpty {
            permissionState = .authorized
        }
    }
}
