import Foundation
import XCTest
@testable import SUPRA

@MainActor
final class ProtectedFolderAccessCoordinatorTests: XCTestCase {
    private var temporaryDirectories: [URL] = []

    override func tearDown() {
        for directory in temporaryDirectories {
            try? FileManager.default.removeItem(at: directory)
        }
        temporaryDirectories.removeAll()
        super.tearDown()
    }

    func testCacheIsRestoredWithoutStartingScopedAccess() throws {
        let support = try makeTemporaryDirectory()
        let cached = ProtectedFolderSnapshot(
            generatedAt: Date(timeIntervalSince1970: 123),
            authorizedRootPaths: ["/cached/root"],
            entries: [
                ProtectedFolderEntry(
                    path: "/cached/root/item.txt",
                    authorizedRootPath: "/cached/root",
                    name: "item.txt",
                    pathExtension: "txt",
                    isDirectory: false,
                    sizeBytes: 12,
                    createdAt: nil,
                    modifiedAt: nil
                )
            ]
        )
        try persist(cached, in: support)
        var accessAttempts = 0

        let coordinator = ProtectedFolderAccessCoordinator(
            supportDirectory: support,
            startScopedAccess: { _ in
                accessAttempts += 1
                return true
            },
            stopScopedAccess: { _ in }
        )

        XCTAssertEqual(coordinator.snapshot.entries.map(\.path), ["/cached/root/item.txt"])
        XCTAssertEqual(accessAttempts, 0)
    }

    func testPermissionStateRequiresDecodableNonemptyBookmarkCollection() throws {
        let emptySupport = try makeTemporaryDirectory()
        try Data("not a bookmark collection".utf8).write(
            to: emptySupport.appendingPathComponent("protected_folder_bookmarks.json")
        )
        let invalid = ProtectedFolderAccessCoordinator(supportDirectory: emptySupport)
        XCTAssertEqual(invalid.permissionState, .notRequested)

        let authorizedSupport = try makeTemporaryDirectory()
        let encoded = try PropertyListEncoder().encode([Data("bookmark".utf8)])
        try encoded.write(
            to: authorizedSupport.appendingPathComponent("protected_folder_bookmarks.json")
        )
        let authorized = ProtectedFolderAccessCoordinator(supportDirectory: authorizedSupport)
        XCTAssertEqual(authorized.permissionState, .authorized)
    }

    func testExplicitTempScanUsesOneScopedAccessAndPreservesGitMetadataOnly() throws {
        let support = try makeTemporaryDirectory()
        let root = try makeTemporaryDirectory()
        let git = root.appendingPathComponent(".git", isDirectory: true)
        let hidden = root.appendingPathComponent(".private", isDirectory: true)
        try FileManager.default.createDirectory(at: git, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: hidden, withIntermediateDirectories: true)
        try Data("git internals".utf8).write(to: git.appendingPathComponent("config"))
        try Data("hidden".utf8).write(to: hidden.appendingPathComponent("secret.txt"))
        try Data("visible".utf8).write(to: root.appendingPathComponent("visible.txt"))
        var starts = 0
        var stops = 0
        let coordinator = ProtectedFolderAccessCoordinator(
            supportDirectory: support,
            startScopedAccess: { _ in
                starts += 1
                return true
            },
            stopScopedAccess: { _ in stops += 1 },
            makeBookmark: { Data($0.path.utf8) }
        )

        let snapshot = try coordinator.scanExplicitlySelectedURLs([root])

        XCTAssertEqual(starts, 1)
        XCTAssertEqual(stops, 1)
        XCTAssertTrue(snapshot.entries.contains { $0.name == ".git" && $0.isDirectory })
        XCTAssertFalse(snapshot.entries.contains { $0.path.contains("/.git/") })
        XCTAssertFalse(snapshot.entries.contains { $0.path.contains("/.private") })
        XCTAssertTrue(snapshot.entries.contains { $0.name == "visible.txt" })
    }

    func testAccessFailureDoesNotReplaceCacheOrPersistBookmarks() throws {
        let support = try makeTemporaryDirectory()
        let root = try makeTemporaryDirectory()
        let cached = ProtectedFolderSnapshot(
            generatedAt: Date(timeIntervalSince1970: 456),
            authorizedRootPaths: ["/previous"],
            entries: []
        )
        try persist(cached, in: support)
        var stops = 0
        let coordinator = ProtectedFolderAccessCoordinator(
            supportDirectory: support,
            startScopedAccess: { _ in false },
            stopScopedAccess: { _ in stops += 1 }
        )

        XCTAssertThrowsError(try coordinator.scanExplicitlySelectedURLs([root]))
        XCTAssertEqual(coordinator.snapshot.authorizedRootPaths, ["/previous"])
        XCTAssertEqual(stops, 0)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: support.appendingPathComponent("protected_folder_bookmarks.json").path
            )
        )
    }

    func testWorkspaceDiscoveryConsumesEmptySnapshotWithoutScanningOrPresentingUI() async throws {
        let support = try makeTemporaryDirectory()
        var accessAttempts = 0
        let coordinator = ProtectedFolderAccessCoordinator(
            supportDirectory: support,
            startScopedAccess: { _ in
                accessAttempts += 1
                return true
            },
            stopScopedAccess: { _ in }
        )
        let discovery = WorkspaceDiscovery(coordinator: coordinator)

        let objects = try await discovery.scan()

        XCTAssertTrue(objects.isEmpty)
        XCTAssertEqual(discovery.discoveredCount, 0)
        XCTAssertEqual(discovery.progress, 1)
        XCTAssertEqual(accessAttempts, 0)
    }

    func testOnlyCoordinatorOwnsEnumerationAndWorkspaceHasNoAuthorizationCall() throws {
        let sourceRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("SUPRA", isDirectory: true)
        let coordinatorSource = try String(
            contentsOf: sourceRoot.appendingPathComponent("ProtectedFolderAccessCoordinator.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(coordinatorSource.contains("fileManager.enumerator("))

        for consumer in [
            "WorkspaceDiscovery.swift",
            "WorkspaceIndexer.swift",
            "SUPRADataTwin.swift",
            "SUPRADeveloperTwin.swift",
            "SUPRAEnvironmentResolver.swift",
            "SUPRAEnvironmentWorldModel.swift",
            "CAnnoNicoSnapshotStore.swift"
        ] {
            let source = try String(
                contentsOf: sourceRoot.appendingPathComponent(consumer),
                encoding: .utf8
            )
            XCTAssertFalse(source.contains(".enumerator("), "\(consumer) must not enumerate folders")
            XCTAssertFalse(source.contains("requestDiscovery()"), "\(consumer) must not open authorization UI")
        }
    }

    func testWorkspaceDefaultsDoNotEnableOrSeedScanning() {
        XCTAssertTrue(WorkspaceConfiguration.default.scanPaths.isEmpty)
        XCTAssertFalse(WorkspaceConfiguration.default.enableAutoScan)
    }

    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SUPRAProtectedFolderTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        temporaryDirectories.append(directory)
        return directory
    }

    private func persist(_ snapshot: ProtectedFolderSnapshot, in support: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(snapshot).write(
            to: support.appendingPathComponent("protected_folder_snapshot.json"),
            options: .atomic
        )
    }
}
