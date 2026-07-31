import XCTest
@testable import SUPRA

/// Foundation Layer — FileSystemPort V1 tests.
/// Covers: location resolution, read/write round-trip, atomicity, directories,
/// listing, migration, removal, attributes, and default-root resolution.
final class FileSystemPortTests: XCTestCase {
    private var port: DefaultFileSystemPort!
    private var root: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("SUPRA_FileSystemPortTests_\(UUID().uuidString)", isDirectory: true)
        port = DefaultFileSystemPort(rootURL: root)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: root)
        port = nil
        root = nil
        try super.tearDownWithError()
    }

    // MARK: Resolution

    func testDefaultRootPointsToApplicationSupportSUPRA() {
        let resolved = SUPRAApplicationSupportLocator.storageRootURL()
        XCTAssertTrue(
            resolved.path.contains("Application Support"),
            "root should live under Application Support, got \(resolved.path)"
        )
        XCTAssertEqual(resolved.lastPathComponent, "SUPRA")
    }

    func testLocationResolutionBuildsCanonicalPath() {
        let location = StorageLocation(directory: .runtime, filename: "BOOT_REPORT.json")
        XCTAssertEqual(
            port.url(for: location).path,
            root.appendingPathComponent("Runtime/BOOT_REPORT.json", isDirectory: false).path
        )
    }

    func testLocationResolutionSupportsSubpath() {
        let location = StorageLocation(directory: .artifacts, subpath: "proofs", filename: "LOT1.json")
        XCTAssertEqual(
            port.url(for: location).path,
            root.appendingPathComponent("Artifacts/proofs/LOT1.json", isDirectory: false).path
        )
    }

    func testAllCanonicalDirectoriesAreDeclared() {
        let canonical = StorageDirectory.allCases.filter { $0 != .root }
        XCTAssertEqual(canonical.count, 8)
        let expected: Set<String> = ["State", "Runtime", "Artifacts", "Continuity", "Snapshots", "Logs", "Cache", "Missions"]
        XCTAssertEqual(Set(canonical.map(\.directoryName)), expected)
    }

    // MARK: Directories

    func testCreateAllDirectoriesCreatesEightCanonicalDirectories() throws {
        try port.createAllDirectories()

        for directory in StorageDirectory.allCases {
            XCTAssertTrue(port.directoryExists(directory), "\(directory.directoryName) should exist")
        }
    }

    func testCreateDirectoryIsIdempotent() throws {
        try port.createDirectory(.state)
        try port.createDirectory(.state) // second call must not throw
        XCTAssertTrue(port.directoryExists(.state))
    }

    func testDirectoryExistsIsFalseBeforeCreation() {
        XCTAssertFalse(port.directoryExists(.snapshots))
    }

    // MARK: Read / Write

    func testWriteThenReadRoundTrip() throws {
        let location = StorageLocation(directory: .runtime, filename: "RUNTIME_STATUS.json")
        let payload = Data(#"{"build":{"status":"SUCCEEDED"}}"#.utf8)

        try port.write(payload, to: location)

        XCTAssertTrue(port.exists(location))
        XCTAssertEqual(try port.read(location), payload)
    }

    func testWriteCreatesIntermediateDirectories() throws {
        let location = StorageLocation(directory: .missions, filename: "MISSION_QUEUE.json")
        try port.writeString(#"{"items":[]}"#, to: location)
        XCTAssertTrue(port.directoryExists(.missions))
        XCTAssertEqual(try port.readString(location), #"{"items":[]}"#)
    }

    func testReadThrowsOnMissingLocation() {
        let location = StorageLocation(directory: .state, filename: "missing.json")
        XCTAssertThrowsError(try port.read(location)) { error in
            guard case FileSystemPortError.missingLocation = error else {
                return XCTFail("expected missingLocation, got \(error)")
            }
        }
    }

    func testExistsIsFalseBeforeWriteAndTrueAfter() throws {
        let location = StorageLocation(directory: .continuity, filename: "CONTINUITY.md")
        XCTAssertFalse(port.exists(location))
        try port.writeString("# CONTINUITY", to: location)
        XCTAssertTrue(port.exists(location))
    }

    func testOverwriteReplacesPreviousContent() throws {
        let location = StorageLocation(directory: .state, filename: "SUPRA_STATE.json")
        try port.writeString("v1", to: location)
        try port.writeString("v2", to: location)
        XCTAssertEqual(try port.readString(location), "v2")
    }

    // MARK: Atomicity

    func testWriteLeavesNoTemporaryFilesBehind() throws {
        let location = StorageLocation(directory: .runtime, filename: "BOOT_REPORT.json")
        try port.writeString("{}", to: location)
        try port.writeString("{\"a\":1}", to: location)

        let directoryURL = port.url(for: .runtime)
        let leftovers = try FileManager.default.contentsOfDirectory(atPath: directoryURL.path)
            .filter { $0.contains(".tmp-") }
        XCTAssertTrue(leftovers.isEmpty, "temporary files must be cleaned up, found \(leftovers)")
    }

    func testWriteProducesSingleCanonicalFile() throws {
        let location = StorageLocation(directory: .logs, filename: "runtime.log")
        try port.writeString("line 1", to: location)
        try port.writeString("line 2", to: location)

        let files = try port.list(.logs)
        XCTAssertEqual(files, ["runtime.log"])
    }

    // MARK: Listing

    func testListReturnsFilesOnlySorted() throws {
        try port.createDirectory(.cache)
        try port.writeString("a", to: StorageLocation(directory: .cache, filename: "zeta.json"))
        try port.writeString("b", to: StorageLocation(directory: .cache, filename: "alpha.json"))

        XCTAssertEqual(try port.list(.cache), ["alpha.json", "zeta.json"])
    }

    func testListThrowsOnMissingDirectory() {
        XCTAssertThrowsError(try port.list(.snapshots)) { error in
            guard case FileSystemPortError.missingDirectory = error else {
                return XCTFail("expected missingDirectory, got \(error)")
            }
        }
    }

    // MARK: Migration

    func testMigrateCopiesContentToDestination() throws {
        let source = StorageLocation(directory: .state, filename: "SUPRA_STATE.json")
        let destination = StorageLocation(directory: .runtime, filename: "SUPRA_STATE.json")
        let payload = Data(#"{"version":"2.2.0"}"#.utf8)
        try port.write(payload, to: source)

        try port.migrate(from: source, to: destination)

        XCTAssertTrue(port.exists(source), "migrate must not remove the source")
        XCTAssertEqual(try port.read(destination), payload)
    }

    func testMigrateOverwritesExistingDestination() throws {
        let source = StorageLocation(directory: .state, filename: "version.json")
        let destination = StorageLocation(directory: .runtime, filename: "version.json")
        try port.writeString("new", to: source)
        try port.writeString("old", to: destination)

        try port.migrate(from: source, to: destination)

        XCTAssertEqual(try port.readString(destination), "new")
    }

    func testMigrateThrowsWhenSourceMissing() {
        let source = StorageLocation(directory: .state, filename: "missing.json")
        let destination = StorageLocation(directory: .runtime, filename: "missing.json")
        XCTAssertThrowsError(try port.migrate(from: source, to: destination))
    }

    // MARK: Removal

    func testRemoveDeletesFile() throws {
        let location = StorageLocation(directory: .cache, filename: "temp.json")
        try port.writeString("data", to: location)
        XCTAssertTrue(port.exists(location))

        try port.remove(location)

        XCTAssertFalse(port.exists(location))
    }

    func testRemoveIsNoOpWhenAbsent() throws {
        let location = StorageLocation(directory: .cache, filename: "absent.json")
        XCTAssertNoThrow(try port.remove(location))
    }

    // MARK: Attributes

    func testAttributesReturnSizeAndModificationDate() throws {
        let location = StorageLocation(directory: .state, filename: "SUPRA_STATE.json")
        try port.writeString("0123456789", to: location)

        let attributes = try port.attributes(of: location)

        XCTAssertEqual(attributes.sizeBytes, 10)
        XCTAssertNotNil(attributes.modificationDate)
    }

    func testAttributesThrowOnMissingLocation() {
        let location = StorageLocation(directory: .state, filename: "missing.json")
        XCTAssertThrowsError(try port.attributes(of: location))
    }

    // MARK: Concurrency sanity

    func testConcurrentWritesToDistinctLocationsAreSafe() async {
        let locations = (0..<24).map { index in
            StorageLocation(directory: .runtime, filename: "file-\(index).json")
        }
        let data = (0..<24).map { index in Data("payload-\(index)".utf8) }

        await withTaskGroup(of: Void.self) { group in
            for (location, payload) in zip(locations, data) {
                group.addTask {
                    try? self.port.write(payload, to: location)
                }
            }
            await group.waitForAll()
        }

        for (location, payload) in zip(locations, data) {
            XCTAssertEqual(try? port.read(location), payload)
        }
    }
}
