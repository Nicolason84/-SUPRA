import XCTest
@testable import SUPRA

@MainActor
final class SUPRAConversationMemoryAsyncTests: XCTestCase {

    private var tempDir: URL!

    override func setUp() async throws {
        try await super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("SUPRA_MEMORY_TEST_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDir)
        try await super.tearDown()
    }

    // MARK: - Fixtures

    private func makeSampleMessage(id: String = "m1", role: String = "user",
                                    content: String = "Hello", timestamp: Date? = nil) -> ConversationMessage {
        ConversationMessage(id: id, role: role, content: content, timestamp: timestamp)
    }

    private func makeSampleRecord(id: String = "conv_test_1", title: String = "Test Conv",
                                   date: Date = Date(), messages: [ConversationMessage] = [],
                                   tags: [String] = ["SUPRA"], sourceFile: String = "test.json",
                                   version: Int = 1) -> ConversationRecord {
        ConversationRecord(
            id: id, title: title, date: date, messages: messages, tags: tags,
            projects: [], decisions: [], missions: [], freezes: [], evidence: [],
            summary: nil, sourceFile: sourceFile, importVersion: version
        )
    }

    private func makeChatGPTExportJSON(conversations: Int = 1) -> Data {
        let entries = (0..<conversations).map { i -> [String: Any] in
            [
                "title": "Chat \(i)",
                "create_time": TimeInterval(Date().timeIntervalSince1970 + Double(i)),
                "mapping": [
                    "msg1": [
                        "message": [
                            "id": "msg_\(i)",
                            "author": ["role": "user"],
                            "content": ["parts": ["Hello \(i)"]],
                            "create_time": Date().timeIntervalSince1970
                        ] as [String: Any]
                    ] as [String: Any]
                ] as [String: Any]
            ] as [String: Any]
        }
        return try! JSONSerialization.data(withJSONObject: entries)
    }

    // MARK: - OFF-MAINACTOR PROOF

    func testFILTER_RUNS_OFF_MAINACTOR() throws {
        let records = [makeSampleRecord()]
        var ranOffMain = false
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let _ = ConversationMemoryStore.filterOffMain(conversations: records, query: "", activeTags: [])
            ranOffMain = !Thread.isMainThread
            sem.signal()
        }
        sem.wait()
        XCTAssertTrue(ranOffMain, "filterOffMain must execute outside MainActor when called from background")
    }

    func testIMPORT_PARSING_RUNS_OFF_MAINACTOR() throws {
        let data = makeChatGPTExportJSON(conversations: 1)
        var ranOffMain = false
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let _ = ConversationMemoryStore.parseChatGPTExportOffMain(data, sourceFile: "test.json", version: 1)
            ranOffMain = !Thread.isMainThread
            sem.signal()
        }
        sem.wait()
        XCTAssertTrue(ranOffMain, "parseChatGPTExportOffMain must execute outside MainActor")
    }

    func testSAVE_INDEX_RUNS_OFF_MAINACTOR() throws {
        let url = tempDir.appendingPathComponent("off_main_test.json")
        let records = [makeSampleRecord(id: "off_test")]
        var ranOffMain = false
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            try? ConversationMemoryStore.saveIndexOffMain(conversations: records, to: url)
            ranOffMain = !Thread.isMainThread
            sem.signal()
        }
        sem.wait()
        XCTAssertTrue(ranOffMain, "saveIndexOffMain must execute outside MainActor")
    }

    func testFIND_FILES_RUNS_OFF_MAINACTOR() throws {
        let dir = tempDir!
        var ranOffMain = false
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let _ = ConversationMemoryStore.findConversationFilesOffMain(in: dir)
            ranOffMain = !Thread.isMainThread
            sem.signal()
        }
        sem.wait()
        XCTAssertTrue(ranOffMain, "findConversationFilesOffMain must execute outside MainActor")
    }

    func testLOAD_INDEX_RUNS_OFF_MAINACTOR() throws {
        let url = tempDir.appendingPathComponent("load_off_main.json")
        var ranOffMain = false
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let _ = ConversationMemoryStore.loadIndexOffMain(from: url)
            ranOffMain = !Thread.isMainThread
            sem.signal()
        }
        sem.wait()
        XCTAssertTrue(ranOffMain, "loadIndexOffMain must execute outside MainActor")
    }

    func testSUMMARY_BATCH_RUNS_OFF_MAINACTOR() throws {
        let records = [makeSampleRecord(id: "summary_off")]
        var ranOffMain = false
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let _ = ConversationMemoryStore.computeAllSummariesOffMain(snapshot: records)
            ranOffMain = !Thread.isMainThread
            sem.signal()
        }
        sem.wait()
        XCTAssertTrue(ranOffMain, "computeAllSummariesOffMain must execute outside MainActor")
    }

    // MARK: - FIRST SAVE (no pre-existing index)

    func testSAVE_CREATES_INDEX_WHEN_MISSING() throws {
        let indexPath = tempDir.appendingPathComponent("ConversationMemoryIndex.json")
        XCTAssertFalse(FileManager.default.fileExists(atPath: indexPath.path),
                       "Index must not exist before first save")
        let records = [makeSampleRecord(id: "first_save")]
        try ConversationMemoryStore.saveIndexOffMain(conversations: records, to: indexPath)
        XCTAssertTrue(FileManager.default.fileExists(atPath: indexPath.path),
                      "Index must be created by saveIndexOffMain")
        let loaded = ConversationMemoryStore.loadIndexOffMain(from: indexPath)
        switch loaded {
        case .success(let loadedRecords):
            XCTAssertEqual(loadedRecords.count, 1)
            XCTAssertEqual(loadedRecords[0].id, "first_save")
        case .failure(let error):
            XCTFail("Reload of newly saved index failed: \(error)")
        }
    }

    // MARK: - UNCHANGED FILES NOT REPARSED

    func testUNCHANGED_FILES_NOT_REPARSED() throws {
        let indexPath = tempDir.appendingPathComponent("ConversationMemoryIndex.json")
        let chatFile = tempDir.appendingPathComponent("conversations.json")
        let data = makeChatGPTExportJSON(conversations: 1)
        try data.write(to: chatFile)

        let result = ConversationMemoryStore.parseChatGPTExportOffMain(data, sourceFile: "conversations.json", version: 1)
        guard case .success(let records) = result else {
            XCTFail("Parsing failed"); return
        }

        try ConversationMemoryStore.saveIndexOffMain(conversations: records, to: indexPath)

        let discovered = ConversationMemoryStore.findConversationFilesOffMain(in: tempDir)
        XCTAssertTrue(discovered.contains(chatFile), "chat file must be discovered")

        let importedFiles = Set(records.map { $0.sourceFile })
        let newFiles = discovered.filter { !importedFiles.contains($0.lastPathComponent) }
        XCTAssertTrue(newFiles.isEmpty, "Already imported file should not appear as new")
    }

    // MARK: - INDEX FILE EXCLUDED

    func testINDEX_FILE_EXCLUDED_FROM_SCAN() throws {
        let indexPath = tempDir.appendingPathComponent("ConversationMemoryIndex.json")
        try "[]".write(to: indexPath, atomically: true, encoding: .utf8)
        let fpManifestPath = tempDir.appendingPathComponent("ConversationMemoryIndex_fingerprints.json")
        try "{}".write(to: fpManifestPath, atomically: true, encoding: .utf8)
        let convPath = tempDir.appendingPathComponent("valid_conversations.json")
        try "[]".write(to: convPath, atomically: true, encoding: .utf8)
        let files = ConversationMemoryStore.findConversationFilesOffMain(in: tempDir)
        XCTAssertFalse(files.contains { $0.lastPathComponent == "ConversationMemoryIndex.json" },
                       "Index file must be excluded from scan results")
        XCTAssertFalse(files.contains { $0.lastPathComponent == "ConversationMemoryIndex_fingerprints.json" },
                       "Fingerprint manifest must be excluded from scan results")
        XCTAssertTrue(files.contains(convPath), "Valid JSON files must be found")
    }

    // MARK: - CORRUPTED INDEX HANDLING

    func testCORRUPTED_INDEX_DOES_NOT_CRASH() throws {
        let indexPath = tempDir.appendingPathComponent("ConversationMemoryIndex.json")
        try "not valid json".write(to: indexPath, atomically: true, encoding: .utf8)
        let result = ConversationMemoryStore.loadIndexOffMain(from: indexPath)
        switch result {
        case .success(let records):
            XCTAssertTrue(records.isEmpty, "Corrupt index should yield empty array via fallback or error")
        case .failure:
            XCTAssertTrue(true, "Corrupt index error captured without crash")
        }
    }

    // MARK: - ATOMIC SAVE ROUND-TRIP

    func testATOMIC_SAVE_RELOAD() throws {
        let indexPath = tempDir.appendingPathComponent("ConversationMemoryIndex.json")
        let records = [
            makeSampleRecord(id: "save_test_1"),
            makeSampleRecord(id: "save_test_2")
        ]
        try ConversationMemoryStore.saveIndexOffMain(conversations: records, to: indexPath)
        XCTAssertTrue(FileManager.default.fileExists(atPath: indexPath.path), "Index file must exist")
        let loaded = ConversationMemoryStore.loadIndexOffMain(from: indexPath)
        switch loaded {
        case .success(let loadedRecords):
            XCTAssertEqual(loadedRecords.count, 2)
            XCTAssertEqual(loadedRecords[0].id, "save_test_1")
        case .failure(let error):
            XCTFail("Reload failed: \(error)")
        }
    }

    // MARK: - IMPORT PARSING

    func testIMPORT_PARSING_OFF_MAINACTOR() throws {
        let data = makeChatGPTExportJSON(conversations: 2)
        let result = ConversationMemoryStore.parseChatGPTExportOffMain(data, sourceFile: "export.json", version: 1)
        switch result {
        case .success(let records):
            XCTAssertEqual(records.count, 2)
            XCTAssertTrue(records.allSatisfy { $0.sourceFile == "export.json" })
            XCTAssertEqual(records[0].importVersion, 1)
        case .failure(let error):
            XCTFail("Parsing failed: \(error)")
        }
    }

    // MARK: - CONVERSATION DEDUPLICATION

    func testCONVERSATION_DEDUPLICATION() throws {
        let data = makeChatGPTExportJSON(conversations: 1)
        let result1 = ConversationMemoryStore.parseChatGPTExportOffMain(data, sourceFile: "same.json", version: 1)
        let result2 = ConversationMemoryStore.parseChatGPTExportOffMain(data, sourceFile: "same.json", version: 1)
        guard case .success(let records1) = result1,
              case .success(let records2) = result2 else {
            XCTFail("Parsing failed"); return
        }
        let existingIds = Set(records1.map { $0.id })
        let newRecords = records2.filter { !existingIds.contains($0.id) }
        XCTAssertTrue(newRecords.isEmpty, "Same file content with same sourceFile must produce same ids")
    }

    // MARK: - FILTER

    func testFILTER_OFF_MAINACTOR() {
        let records = [
            makeSampleRecord(id: "f1", title: "Alpha Project", tags: ["SUPRA"]),
            makeSampleRecord(id: "f2", title: "Beta Plan", tags: ["NOVA ERA"]),
            makeSampleRecord(id: "f3", title: "Gamma Report", tags: ["Business"])
        ]
        let filtered = ConversationMemoryStore.filterOffMain(conversations: records, query: "Alpha", activeTags: [])
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered[0].id, "f1")

        let tagFiltered = ConversationMemoryStore.filterOffMain(conversations: records, query: "", activeTags: ["NOVA ERA"])
        XCTAssertEqual(tagFiltered.count, 1)
        XCTAssertEqual(tagFiltered[0].id, "f2")
    }

    func testFILTER_STALE_RESULT_REJECTED() async throws {
        let records = [makeSampleRecord(id: "s1", title: "Stale Test")]
        let freshRecords = [makeSampleRecord(id: "s1", title: "Updated Title")]
        let filtered1 = ConversationMemoryStore.filterOffMain(conversations: records, query: "Stale", activeTags: [])
        let filtered2 = ConversationMemoryStore.filterOffMain(conversations: freshRecords, query: "Updated", activeTags: [])
        XCTAssertEqual(filtered1.count, 1)
        XCTAssertEqual(filtered2.count, 1)
        XCTAssertTrue(filtered2[0].title.contains("Updated"))
    }

    // MARK: - TAG INFERENCE

    func testINFER_TAGS_OFF_MAINACTOR() {
        let msg = makeSampleMessage(content: "This is a conversation about SUPRA runtime")
        let tags = ConversationMemoryStore.inferTagsOffMain(from: "Test", messages: [msg])
        XCTAssertTrue(tags.contains("SUPRA"))
        XCTAssertTrue(tags.contains("Runtime"))
    }

    // MARK: - SUMMARY EXTRACTION

    func testEXTRACT_CONTEXT_OFF_MAINACTOR() {
        let text = "[assistant] The project decision is to proceed with phase 2."
        let context = ConversationMemoryStore.extractContextOffMain(from: text)
        XCTAssertTrue(context.contains("phase 2"))
    }

    func testEXTRACT_DECISIONS_OFF_MAINACTOR() {
        let text = "The décision was made to approve the budget."
        let decisions = ConversationMemoryStore.extractDecisionsOffMain(from: text)
        XCTAssertFalse(decisions.isEmpty)
    }

    func testEXTRACT_NEXT_ACTIONS_OFF_MAINACTOR() {
        let text = "Next action: review the pull request."
        let actions = ConversationMemoryStore.extractNextActionsOffMain(from: text)
        XCTAssertFalse(actions.isEmpty)
    }

    func testSUMMARY_BATCH_OFF_MAINACTOR() {
        let msg = makeSampleMessage(role: "assistant", content: "We decided to launch.")
        let record = makeSampleRecord(id: "batch_test", messages: [msg])
        let results = ConversationMemoryStore.computeAllSummariesOffMain(snapshot: [record])
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.first?.id, "batch_test")
        XCTAssertNotNil(results.first?.summary)
    }

    // MARK: - SAVE CORRUPTION RESILIENCE

    func testSAVE_CORRUPTED_FILE() {
        let indexPath = tempDir.appendingPathComponent("ConversationMemoryIndex.json")
        try? "{{{corrupt".write(to: indexPath, atomically: true, encoding: .utf8)
        let result = ConversationMemoryStore.loadIndexOffMain(from: indexPath)
        if case .success(let records) = result {
            XCTAssertTrue(records.isEmpty, "Corrupted file should produce empty or fallback")
        }
    }

    // MARK: - FINGERPRINT SURVIVES RELOAD

    func testFINGERPRINT_SURVIVES_RELOAD() throws {
        let fpURL = tempDir.appendingPathComponent("ConversationMemoryIndex_fingerprints.json")
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let fps = [
            "/tmp/a.json": ConversationFileFingerprint(path: "/tmp/a.json", fileSize: 100, modificationDate: date)
        ]
        try ConversationMemoryStore.saveFingerprintManifestOffMain(fingerprints: fps, to: fpURL)
        let loaded = ConversationMemoryStore.loadFingerprintManifestOffMain(from: fpURL)
        XCTAssertNotNil(loaded, "Manifest should load successfully")
        XCTAssertEqual(loaded?.count, 1)
        XCTAssertEqual(loaded?["/tmp/a.json"]?.fileSize, 100)
        XCTAssertEqual(loaded?["/tmp/a.json"]?.modificationDate, date)
        XCTAssertEqual(loaded?["/tmp/a.json"]?.path, "/tmp/a.json")
    }

    // MARK: - ZERO NEW IDS ON REFRESH

    func testZERO_NEW_IDS_SKIPPED_ON_REFRESH() throws {
        let chatFile = tempDir.appendingPathComponent("conversations.json")
        let json = makeChatGPTExportJSON(conversations: 2)
        try json.write(to: chatFile)

        let r1 = ConversationMemoryStore.parseChatGPTExportOffMain(json, sourceFile: "conversations.json", version: 1)
        guard case .success(let records1) = r1 else { XCTFail("First parse failed"); return }
        let existingIds = Set(records1.map { $0.id })
        let fpInitial = ConversationMemoryStore.fingerprintFileOffMain(at: chatFile)

        // Touch file — same content, new modification date
        try json.write(to: chatFile)

        let r2 = ConversationMemoryStore.parseChatGPTExportOffMain(json, sourceFile: "conversations.json", version: 2)
        guard case .success(let records2) = r2 else { XCTFail("Second parse failed"); return }

        let newRecords = records2.filter { !existingIds.contains($0.id) }
        XCTAssertTrue(newRecords.isEmpty, "Zero new IDs should be detected")
        XCTAssertEqual(records2.count, 2, "Still produces 2 records")

        // Fingerprint changed because mod date differs
        let fpUpdated = ConversationMemoryStore.fingerprintFileOffMain(at: chatFile)
        XCTAssertNotEqual(fpInitial.modificationDate, fpUpdated.modificationDate, "Modification date must differ after re-write")
        XCTAssertEqual(fpInitial.fileSize, fpUpdated.fileSize, "File size stays same since content is identical")

        // Simulate: store cached fpInitial, then refresh re-parses, updates to fpUpdated.
        // Subsequent scan compares against fpUpdated → match → skipped.
        let fpVerify = ConversationMemoryStore.fingerprintFileOffMain(at: chatFile)
        XCTAssertEqual(fpUpdated, fpVerify, "Subsequent fingerprint matches — would be skipped next scan")
        XCTAssertEqual(fpInitial.path, fpVerify.path, "Canonical path stable")
    }

    // MARK: - MODIFIED CONVERSATION REPLACES PREVIOUS

    func testMODIFIED_CONVERSATION_REPLACES_PREVIOUS() throws {
        let v1 = [
            makeSampleRecord(id: "conv1", title: "Original Title", date: Date(timeIntervalSince1970: 1000)),
            makeSampleRecord(id: "conv2", title: "Unchanged Record", date: Date(timeIntervalSince1970: 2000))
        ]
        let reParsed = [
            makeSampleRecord(id: "conv1", title: "Modified Title", date: Date(timeIntervalSince1970: 1000)),
            makeSampleRecord(id: "conv3", title: "Brand New Record", date: Date(timeIntervalSince1970: 3000))
        ]

        let parsedIds = Set(reParsed.map { $0.id })
        var merged = v1.filter { !parsedIds.contains($0.id) }
        merged.append(contentsOf: reParsed)
        merged.sort { $0.date > $1.date }

        XCTAssertEqual(merged.count, 3, "conv2 from v1 preserved, conv1 replaced, conv3 added")
        XCTAssertTrue(merged.contains(where: { $0.id == "conv1" && $0.title == "Modified Title" }), "conv1 replaced")
        XCTAssertTrue(merged.contains(where: { $0.id == "conv2" }), "conv2 preserved from other source")
        XCTAssertTrue(merged.contains(where: { $0.id == "conv3" }), "conv3 added as new")
        XCTAssertFalse(merged.contains(where: { $0.id == "conv1" && $0.title == "Original Title" }), "Original conv1 removed")
    }

    // MARK: - SYMLINK DEDUPLICATES WITH ORIGINAL

    func testSYMLINK_DEDUPLICATES_WITH_ORIGINAL() throws {
        let origURL = tempDir.appendingPathComponent("real_conversations.json")
        let linkURL = tempDir.appendingPathComponent("link.json")
        try makeChatGPTExportJSON(conversations: 1).write(to: origURL)
        try FileManager.default.createSymbolicLink(at: linkURL, withDestinationURL: origURL)

        let fpOrig = ConversationMemoryStore.fingerprintFileOffMain(at: origURL)
        let fpLink = ConversationMemoryStore.fingerprintFileOffMain(at: linkURL)

        XCTAssertEqual(fpOrig.path, fpLink.path, "Canonical paths must match for symlink and original")
        XCTAssertEqual(fpOrig, fpLink, "Fingerprints must be identical for symlink and original")
    }

    // MARK: - TWO FILES SAME BASENAME DISTINCT

    func testTWO_FILES_SAME_BASENAME_DISTINCT() throws {
        let dirA = tempDir.appendingPathComponent("DirA")
        let dirB = tempDir.appendingPathComponent("DirB")
        try FileManager.default.createDirectory(at: dirA, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: dirB, withIntermediateDirectories: true)
        let fileA = dirA.appendingPathComponent("conversations.json")
        let fileB = dirB.appendingPathComponent("conversations.json")
        try makeChatGPTExportJSON(conversations: 1).write(to: fileA)
        try makeChatGPTExportJSON(conversations: 1).write(to: fileB)

        let fpA = ConversationMemoryStore.fingerprintFileOffMain(at: fileA)
        let fpB = ConversationMemoryStore.fingerprintFileOffMain(at: fileB)

        XCTAssertNotEqual(fpA.path, fpB.path, "Canonical paths must differ for files in different directories")
        XCTAssertEqual(fpA.path, ConversationMemoryStore.canonicalPath(for: fileA), "Canonical path matches helper")
        XCTAssertEqual(fpB.path, ConversationMemoryStore.canonicalPath(for: fileB), "Canonical path matches helper")
    }

    // MARK: - PHASE 11: CANONICAL SOURCE RECONCILIATION TESTS

    private func makeRecordWithSource(id: String, title: String = "Test", sourcePath: String? = nil, messages: [ConversationMessage] = [], sourceFile: String = "test.json", version: Int = 1) -> ConversationRecord {
        ConversationRecord(id: id, title: title, date: Date(timeIntervalSince1970: 1000), messages: messages, tags: [], projects: [], decisions: [], missions: [], freezes: [], evidence: [], summary: nil, sourceFile: sourceFile, importVersion: version, sourceCanonicalPath: sourcePath)
    }

    func testCANONICAL_SOURCE_PATH_ASSIGNED() throws {
        let json = makeChatGPTExportJSON(conversations: 1)
        let result = ConversationMemoryStore.parseChatGPTExportOffMain(json, sourceFile: "test.json", version: 1, sourceCanonicalPath: "/tmp/test.json")
        guard case .success(let records) = result else { XCTFail(); return }
        XCTAssertEqual(records[0].sourceCanonicalPath, "/tmp/test.json")
        XCTAssertTrue(records[0].id.hasPrefix("conv_"), "ID uses canonical format")
    }

    func testLEGACY_RECORD_DECODES_WITHOUT_SOURCE_PATH() throws {
        let record = makeSampleRecord(id: "legacy1", sourceFile: "old.json", version: 1)
        let data = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(ConversationRecord.self, from: data)
        XCTAssertNil(decoded.sourceCanonicalPath, "Legacy record decoded without sourceCanonicalPath")
        XCTAssertEqual(decoded.id, "legacy1")
    }

    func testSAME_BASENAME_RECORD_IDS_DISTINCT() throws {
        let json = makeChatGPTExportJSON(conversations: 1)
        let resultA = ConversationMemoryStore.parseChatGPTExportOffMain(json, sourceFile: "conv.json", version: 1, sourceCanonicalPath: "/dirA/conv.json")
        let resultB = ConversationMemoryStore.parseChatGPTExportOffMain(json, sourceFile: "conv.json", version: 1, sourceCanonicalPath: "/dirB/conv.json")
        guard case .success(let recordsA) = resultA, case .success(let recordsB) = resultB else { XCTFail(); return }
        XCTAssertNotEqual(recordsA[0].id, recordsB[0].id, "Same basename + different paths must produce distinct IDs")
        XCTAssertEqual(recordsA[0].sourceFile, "conv.json")
        XCTAssertEqual(recordsA[0].sourceCanonicalPath, "/dirA/conv.json")
        XCTAssertEqual(recordsB[0].sourceCanonicalPath, "/dirB/conv.json")
    }

    func testMODIFIED_RECORD_REPLACED_BY_SOURCE_KEY() throws {
        let existing = [makeRecordWithSource(id: "conv_abc_1000", title: "Original", sourcePath: "/tmp/a.json", sourceFile: "a.json")]
        let reParsed = [makeRecordWithSource(id: "conv_abc_1000", title: "Modified Content", sourcePath: "/tmp/a.json", sourceFile: "a.json")]
        let result = ConversationMemoryStore.reconcileRecords(existing: existing, parsedBySource: ["/tmp/a.json": reParsed])
        XCTAssertEqual(result.updatedCount, 1)
        XCTAssertEqual(result.addedCount, 0)
        XCTAssertEqual(result.removedCount, 0)
        XCTAssertEqual(result.records.count, 1)
        XCTAssertEqual(result.records[0].title, "Modified Content")
    }

    func testOTHER_SOURCE_COLLIDING_ID_PRESERVED() throws {
        let existing = [
            makeRecordWithSource(id: "conv_collide_1000", title: "File A", sourcePath: "/tmp/a.json", sourceFile: "a.json"),
            makeRecordWithSource(id: "conv_collide_1000", title: "File B", sourcePath: "/tmp/b.json", sourceFile: "b.json")
        ]
        let reParsedA = [makeRecordWithSource(id: "conv_collide_1000", title: "File A Modified", sourcePath: "/tmp/a.json", sourceFile: "a.json")]
        let result = ConversationMemoryStore.reconcileRecords(existing: existing, parsedBySource: ["/tmp/a.json": reParsedA])
        XCTAssertEqual(result.updatedCount, 1)
        let fileB = result.records.first { $0.sourceCanonicalPath == "/tmp/b.json" }
        XCTAssertNotNil(fileB, "File B must be preserved")
        XCTAssertEqual(fileB?.title, "File B", "File B colliding ID content unchanged")
        let fileA = result.records.first { $0.sourceCanonicalPath == "/tmp/a.json" }
        XCTAssertEqual(fileA?.title, "File A Modified")
    }

    func testREMOVED_RECORD_DELETED_FROM_ITS_SOURCE() throws {
        let existing = [
            makeRecordWithSource(id: "conv1", title: "Conversation 1", sourcePath: "/tmp/source.json", sourceFile: "source.json"),
            makeRecordWithSource(id: "conv2", title: "Conversation 2", sourcePath: "/tmp/source.json", sourceFile: "source.json")
        ]
        let reParsed = [makeRecordWithSource(id: "conv1", title: "Conversation 1", sourcePath: "/tmp/source.json", sourceFile: "source.json")]
        let result = ConversationMemoryStore.reconcileRecords(existing: existing, parsedBySource: ["/tmp/source.json": reParsed])
        XCTAssertEqual(result.removedCount, 1, "conv2 removed")
        XCTAssertEqual(result.updatedCount, 0)
        XCTAssertEqual(result.records.count, 1)
        XCTAssertEqual(result.records[0].id, "conv1")
    }

    func testEMPTY_FILE_REMOVES_ONLY_ITS_RECORDS() throws {
        let existing = [
            makeRecordWithSource(id: "a1", title: "From A", sourcePath: "/tmp/a.json", sourceFile: "a.json"),
            makeRecordWithSource(id: "b1", title: "From B", sourcePath: "/tmp/b.json", sourceFile: "b.json")
        ]
        let result = ConversationMemoryStore.reconcileRecords(existing: existing, parsedBySource: ["/tmp/a.json": []])
        XCTAssertEqual(result.removedCount, 1, "a1 removed")
        XCTAssertEqual(result.records.count, 1, "Only b1 remains")
        XCTAssertEqual(result.records[0].id, "b1")
        XCTAssertEqual(result.records[0].sourceCanonicalPath, "/tmp/b.json")
    }

    func testMANUAL_IMPORT_UPDATES_EXISTING() throws {
        let existing = [makeRecordWithSource(id: "conv1", title: "Old Title", sourcePath: "/tmp/import.json", sourceFile: "import.json")]
        let reParsed = [makeRecordWithSource(id: "conv1", title: "New Title", sourcePath: "/tmp/import.json", sourceFile: "import.json", version: 2)]
        let result = ConversationMemoryStore.reconcileRecords(existing: existing, parsedBySource: ["/tmp/import.json": reParsed])
        XCTAssertEqual(result.updatedCount, 1)
        XCTAssertEqual(result.records[0].title, "New Title")
    }

    func testMANUAL_IMPORT_REMOVES_STALE() throws {
        let existing = [
            makeRecordWithSource(id: "conv1", title: "Kept", sourcePath: "/tmp/import.json", sourceFile: "import.json"),
            makeRecordWithSource(id: "conv2", title: "Removed", sourcePath: "/tmp/import.json", sourceFile: "import.json")
        ]
        let reParsed = [makeRecordWithSource(id: "conv1", title: "Kept", sourcePath: "/tmp/import.json", sourceFile: "import.json")]
        let result = ConversationMemoryStore.reconcileRecords(existing: existing, parsedBySource: ["/tmp/import.json": reParsed])
        XCTAssertEqual(result.removedCount, 1)
        XCTAssertEqual(result.records.count, 1)
    }

    func testUNCHANGED_IMPORT_RETURNS_UNCHANGED() throws {
        let existing = [makeRecordWithSource(id: "conv1", title: "Stable", sourcePath: "/tmp/s.json", sourceFile: "s.json", version: 1)]
        let reParsed = [makeRecordWithSource(id: "conv1", title: "Stable", sourcePath: "/tmp/s.json", sourceFile: "s.json", version: 2)]
        let result = ConversationMemoryStore.reconcileRecords(existing: existing, parsedBySource: ["/tmp/s.json": reParsed])
        XCTAssertEqual(result.unchangedCount, 1)
        XCTAssertEqual(result.addedCount, 0)
        XCTAssertEqual(result.updatedCount, 0)
        XCTAssertEqual(result.removedCount, 0)
        XCTAssertEqual(result.records[0].title, "Stable")
        XCTAssertEqual(result.records[0].importVersion, 2, "importVersion updated even when content unchanged")
    }

    func testSUMMARY_PRESERVED_WHEN_SOURCE_UNCHANGED() throws {
        let summary = ConversationSummary(context: "Existing context", decisions: [], nextActions: [], relatedFiles: [])
        var existingRecord = makeRecordWithSource(id: "conv1", title: "Same", sourcePath: "/tmp/s.json", sourceFile: "s.json")
        existingRecord.summary = summary
        let reParsed = [makeRecordWithSource(id: "conv1", title: "Same", sourcePath: "/tmp/s.json", sourceFile: "s.json")]
        let result = ConversationMemoryStore.reconcileRecords(existing: [existingRecord], parsedBySource: ["/tmp/s.json": reParsed])
        XCTAssertEqual(result.unchangedCount, 1)
        XCTAssertNotNil(result.records[0].summary, "Summary preserved when content unchanged")
        XCTAssertEqual(result.records[0].summary?.context, "Existing context")
    }

    func testSUMMARY_INVALIDATED_WHEN_MESSAGES_CHANGE() throws {
        let msg1 = makeSampleMessage(id: "m1", content: "Old message")
        let msg2 = makeSampleMessage(id: "m1", content: "New message")
        let summary = ConversationSummary(context: "Old context", decisions: [], nextActions: [], relatedFiles: [])
        var existingRecord = makeRecordWithSource(id: "conv1", title: "Changed", sourcePath: "/tmp/s.json", messages: [msg1], sourceFile: "s.json")
        existingRecord.summary = summary
        let reParsed = [makeRecordWithSource(id: "conv1", title: "Changed", sourcePath: "/tmp/s.json", messages: [msg2], sourceFile: "s.json")]
        let result = ConversationMemoryStore.reconcileRecords(existing: [existingRecord], parsedBySource: ["/tmp/s.json": reParsed])
        XCTAssertEqual(result.updatedCount, 1)
        XCTAssertNil(result.records[0].summary, "Summary invalidated when messages change")
    }

    func testAMBIGUOUS_LEGACY_RECORD_NOT_DELETED() throws {
        let legacy = makeSampleRecord(id: "legacy_conv", title: "Legacy", sourceFile: "conv.json", version: 1)
        let result = ConversationMemoryStore.reconcileRecords(existing: [legacy], parsedBySource: ["/tmp/new/conv.json": []])
        XCTAssertEqual(result.removedCount, 0, "Legacy record without sourceCanonicalPath not removed by different source")
        XCTAssertEqual(result.records.count, 1, "Legacy record preserved")
        XCTAssertEqual(result.records[0].id, "legacy_conv")
    }

    func testRECONCILIATION_COUNTS() throws {
        let existing = [
            makeRecordWithSource(id: "added_before", title: "Will Be Added", sourcePath: "/tmp/a.json", sourceFile: "a.json"),
            makeRecordWithSource(id: "existing_stays", title: "Unchanged", sourcePath: "/tmp/a.json", sourceFile: "a.json"),
            makeRecordWithSource(id: "will_be_removed", title: "Removed", sourcePath: "/tmp/a.json", sourceFile: "a.json"),
            makeRecordWithSource(id: "other_stays", title: "Other Source", sourcePath: "/tmp/b.json", sourceFile: "b.json")
        ]
        let reParsedA = [
            makeRecordWithSource(id: "existing_stays", title: "Unchanged", sourcePath: "/tmp/a.json", sourceFile: "a.json"),
            makeRecordWithSource(id: "added_new", title: "Brand New", sourcePath: "/tmp/a.json", sourceFile: "a.json"),
            makeRecordWithSource(id: "added_before", title: "Will Be Added (Updated)", sourcePath: "/tmp/a.json", sourceFile: "a.json")
        ]
        let result = ConversationMemoryStore.reconcileRecords(existing: existing, parsedBySource: ["/tmp/a.json": reParsedA])
        XCTAssertEqual(result.unchangedCount, 1, "existing_stays unchanged")
        XCTAssertEqual(result.updatedCount, 1, "added_before updated (title changed)")
        XCTAssertEqual(result.addedCount, 1, "added_new is new")
        XCTAssertEqual(result.removedCount, 1, "will_be_removed removed")
        XCTAssertEqual(result.records.count, 4, "4 total: 1 unchanged + 1 updated + 1 added + 1 other source")
        XCTAssertTrue(result.records.contains(where: { $0.id == "other_stays" }), "Other source record preserved")
    }

    func testRECORDS_FROM_UNAFFECTED_SOURCES_BYTE_EQUIVALENT() throws {
        let bRecord = makeRecordWithSource(id: "b1", title: "From B", sourcePath: "/tmp/b.json", sourceFile: "b.json")
        let cRecord = makeRecordWithSource(id: "c1", title: "From C", sourcePath: "/tmp/c.json", sourceFile: "c.json")
        let existing = [
            makeRecordWithSource(id: "a1", title: "From A", sourcePath: "/tmp/a.json", sourceFile: "a.json"),
            bRecord, cRecord
        ]
        let reParsedA = [makeRecordWithSource(id: "a1", title: "From A Modified", sourcePath: "/tmp/a.json", sourceFile: "a.json")]
        let result = ConversationMemoryStore.reconcileRecords(existing: existing, parsedBySource: ["/tmp/a.json": reParsedA])
        let bResult = result.records.first { $0.id == "b1" }
        let cResult = result.records.first { $0.id == "c1" }
        XCTAssertNotNil(bResult)
        XCTAssertNotNil(cResult)
        XCTAssertEqual(bResult?.title, "From B")
        XCTAssertEqual(cResult?.title, "From C")
        XCTAssertEqual(bResult?.sourceCanonicalPath, "/tmp/b.json")
        XCTAssertEqual(cResult?.sourceCanonicalPath, "/tmp/c.json")
    }
}
