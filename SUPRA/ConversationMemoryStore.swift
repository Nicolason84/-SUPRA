import Foundation
import Combine
import CommonCrypto

struct ConversationMessage: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let role: String
    let content: String
    let timestamp: Date?
}

struct ConversationSummary: Codable, Equatable, Sendable {
    var context: String
    var decisions: [String]
    var nextActions: [String]
    var relatedFiles: [String]
}

struct ConversationRecord: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let title: String
    let date: Date
    let messages: [ConversationMessage]
    let tags: [String]
    let projects: [String]
    let decisions: [String]
    let missions: [String]
    let freezes: [String]
    let evidence: [String]
    var summary: ConversationSummary?
    let sourceFile: String
    let importVersion: Int
    let sourceCanonicalPath: String?

    var messageCount: Int { messages.count }
    var duration: TimeInterval {
        guard let first = messages.compactMap({ $0.timestamp }).min(),
              let last = messages.compactMap({ $0.timestamp }).max() else { return 0 }
        return last.timeIntervalSince(first)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, date, messages, tags, projects, decisions, missions, freezes, evidence, summary, sourceFile, importVersion, sourceCanonicalPath
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(Date.self, forKey: .date)
        messages = try container.decode([ConversationMessage].self, forKey: .messages)
        tags = try container.decode([String].self, forKey: .tags)
        projects = try container.decode([String].self, forKey: .projects)
        decisions = try container.decode([String].self, forKey: .decisions)
        missions = try container.decode([String].self, forKey: .missions)
        freezes = try container.decode([String].self, forKey: .freezes)
        evidence = try container.decode([String].self, forKey: .evidence)
        summary = try container.decodeIfPresent(ConversationSummary.self, forKey: .summary)
        sourceFile = try container.decode(String.self, forKey: .sourceFile)
        importVersion = try container.decode(Int.self, forKey: .importVersion)
        sourceCanonicalPath = try container.decodeIfPresent(String.self, forKey: .sourceCanonicalPath)
    }

    init(id: String, title: String, date: Date, messages: [ConversationMessage], tags: [String], projects: [String], decisions: [String], missions: [String], freezes: [String], evidence: [String], summary: ConversationSummary? = nil, sourceFile: String, importVersion: Int, sourceCanonicalPath: String? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.messages = messages
        self.tags = tags
        self.projects = projects
        self.decisions = decisions
        self.missions = missions
        self.freezes = freezes
        self.evidence = evidence
        self.summary = summary
        self.sourceFile = sourceFile
        self.importVersion = importVersion
        self.sourceCanonicalPath = sourceCanonicalPath
    }
}

struct FileScanSnapshot: Sendable, Equatable {
    var scanned = 0
    var imported = 0
    var skipped = 0
    var failed = 0
}

struct ConversationFileFingerprint: Sendable, Equatable, Codable {
    let path: String
    let fileSize: Int
    let modificationDate: Date
}

private struct FingerprintManifest: Codable {
    let version: Int
    let fingerprints: [String: ConversationFileFingerprint]
}

struct ConversationSourceKey: Hashable, Sendable {
    let sourceCanonicalPath: String?
    let stableConversationComponent: String

    static func forSourcePath(_ path: String?, stableComponent: String) -> ConversationSourceKey {
        ConversationSourceKey(sourceCanonicalPath: path, stableConversationComponent: stableComponent)
    }

    static func forRecord(_ record: ConversationRecord, canonicalPath: String?) -> ConversationSourceKey? {
        guard let component = extractStableComponent(from: record) else { return nil }
        return ConversationSourceKey(sourceCanonicalPath: canonicalPath ?? record.sourceCanonicalPath, stableConversationComponent: component)
    }

    static func extractStableComponent(from record: ConversationRecord) -> String? {
        let parts = record.id.components(separatedBy: "_")
        if parts.count >= 3, let last = parts.last {
            return last
        }
        return record.id
    }
}

struct ConversationReconciliationResult: Sendable {
    let records: [ConversationRecord]
    let addedCount: Int
    let updatedCount: Int
    let removedCount: Int
    let unchangedCount: Int
    let affectedSources: Set<String>
}

private func sha256Digest(_ data: Data) -> Data {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes { buffer in
        _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash)
}

@MainActor
final class ConversationMemoryStore: ObservableObject {
    static let shared = ConversationMemoryStore()

    @Published private(set) var conversations: [ConversationRecord] = []
    @Published private(set) var visibleConversations: [ConversationRecord] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isImporting = false
    @Published private(set) var importStatus: String?
    @Published private(set) var lastRefresh: Date?
    @Published private(set) var refreshCount = 0
    @Published var query = "" { didSet { scheduleFilterRefresh() } }
    @Published var activeTags: Set<String> = [] { didSet { scheduleFilterRefresh() } }
    @Published var selectedConversation: ConversationRecord?
    @Published private(set) var importVersion = 0
    @Published private(set) var fileScanStats = FileScanSnapshot()
    @Published private(set) var loadDurationMS: Double = 0
    @Published private(set) var filterDurationMS: Double = 0
    @Published private(set) var saveDurationMS: Double = 0

    static let allTags = ["SUPRA", "NOVA ERA", "CAnnoNico", "Runtime", "Business", "Legal", "Décisions"]

    private var timer: Timer?
    private let saveURL: URL
    private var knowledgeGraph: KnowledgeGraph?
    private var decisionStore: DecisionStore?
    private var missionStore: MissionStore?
    private var importStatusDismissTask: Task<Void, Never>?

    private var loadTask: Task<Void, Never>?
    private var importTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?
    private var summaryTask: Task<Void, Never>?
    private var filterTask: Task<Void, Never>?

    private var fileFingerprints: [String: ConversationFileFingerprint] = [:]

    private var fingerprintManifestURL: URL {
        saveURL.deletingLastPathComponent().appendingPathComponent("ConversationMemoryIndex_fingerprints.json")
    }

    nonisolated static func canonicalPath(for url: URL) -> String {
        url.resolvingSymlinksInPath().standardizedFileURL.path
    }

    nonisolated static func canonicalSourceDigest(for canonicalPath: String) -> String {
        let data = Data(canonicalPath.utf8)
        let hash = sha256Digest(data)
        return hash.prefix(8).map { String(format: "%02x", $0) }.joined()
    }

    private init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        saveURL = home.appendingPathComponent("NOVA_OS/SUPRA/SUPRA_Conversations/ConversationMemoryIndex.json")
        startLoad()
    }

    deinit {
        timer?.invalidate()
        for task in [loadTask, importTask, refreshTask, saveTask, summaryTask, filterTask] {
            task?.cancel()
        }
    }

    func configure(knowledgeGraph: KnowledgeGraph, decisionStore: DecisionStore, missionStore: MissionStore) {
        self.knowledgeGraph = knowledgeGraph
        self.decisionStore = decisionStore
        self.missionStore = missionStore
    }

    func startAutoRefresh() {
        stopAutoRefresh()
        timer = Timer.scheduledTimer(withTimeInterval: 90, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
        refreshTask?.cancel()
        refreshTask = nil
    }

    // MARK: - Initial Load

    private func startLoad() {
        isLoading = true
        let url = saveURL
        let fpURL = fingerprintManifestURL
        let t0 = ContinuousClock.now
        loadTask = Task { [weak self] in
            let result = await Task.detached {
                Self.loadIndexOffMain(from: url)
            }.value
            let fingerprints = await Task.detached {
                Self.loadFingerprintManifestOffMain(from: fpURL) ?? [:]
            }.value
            guard !Task.isCancelled else { return }
            let loaded: [ConversationRecord]
            switch result {
            case .success(let records): loaded = records
            case .failure: loaded = []
            }
            let sorted = loaded.sorted { $0.date > $1.date }
            let elapsed = Double((ContinuousClock.now - t0).components.seconds) + Double((ContinuousClock.now - t0).components.attoseconds) / 1e18
            await MainActor.run { [weak self] in
                guard let self, !Task.isCancelled else { return }
                conversations = sorted
                fileFingerprints = fingerprints
                loadDurationMS = elapsed * 1000
                scheduleFilterRefresh()
                isLoading = false
                loadTask = nil
            }
        }
    }

    // MARK: - Import

    func importConversations(from url: URL) {
        importTask?.cancel()
        let version = importVersion + 1
        importVersion = version
        isImporting = true
        importStatus = nil
        let sourceURL = url
        let snapshot = conversations
        importTask = Task { [weak self] in
            let parsed: [ConversationRecord]
            let cp: String
            do {
                let data = try await Task.detached {
                    try Data(contentsOf: sourceURL)
                }.value
                cp = Self.canonicalPath(for: sourceURL)
                let result = try await Task.detached {
                    try Self.parseChatGPTExportOffMain(data, sourceFile: sourceURL.lastPathComponent, version: version, sourceCanonicalPath: cp).get()
                }.value
                parsed = result
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    importStatus = "Erreur d'import : \(error.localizedDescription)"
                    dismissImportStatus()
                }
                await MainActor.run { [weak self] in
                    self?.isImporting = false
                    self?.importTask = nil
                }
                return
            }
            guard !Task.isCancelled else { return }
            let fp = await Task.detached {
                Self.fingerprintFileOffMain(at: sourceURL)
            }.value
            let reconciliation = await Task.detached {
                Self.reconcileRecords(existing: snapshot, parsedBySource: [cp: parsed])
            }.value
            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                guard let self, !Task.isCancelled else { return }
                fileFingerprints[fp.path] = fp
                conversations = reconciliation.records
                var parts: [String] = []
                if reconciliation.addedCount > 0 { parts.append("\(reconciliation.addedCount) ajoutée(s)") }
                if reconciliation.updatedCount > 0 { parts.append("\(reconciliation.updatedCount) mise(s) à jour") }
                if reconciliation.removedCount > 0 { parts.append("\(reconciliation.removedCount) retirée(s)") }
                if reconciliation.unchangedCount > 0 { parts.append("\(reconciliation.unchangedCount) inchangée(s)") }
                importStatus = parts.isEmpty ? "Aucune modification détectée" : parts.joined(separator: ", ")
                if reconciliation.addedCount > 0 || reconciliation.updatedCount > 0 || reconciliation.removedCount > 0 {
                    scheduleSaveIndex()
                }
                connectToKnowledgeGraph()
                scheduleFilterRefresh()
                dismissImportStatus()
                isImporting = false
                importTask = nil
            }
        }
    }

    // MARK: - Refresh

    func refresh() {
        guard refreshTask == nil else { return }
        isLoading = true
        refreshCount += 1
        let dir = saveURL.deletingLastPathComponent()
        let currentFingerprints = fileFingerprints
        let currentVersion = importVersion
        guard let snapshot = conversations as [ConversationRecord]? else { return }
        refreshTask = Task { [weak self] in
            let discovered = await Task.detached {
                Self.findConversationFilesOffMain(in: dir)
            }.value
            guard !Task.isCancelled else { return }
            var toParse: [URL] = []
            var stats = FileScanSnapshot(scanned: discovered.count, imported: 0, skipped: 0, failed: 0)
            for url in discovered {
                let fp = await Task.detached {
                    Self.fingerprintFileOffMain(at: url)
                }.value
                if let existing = currentFingerprints[fp.path], existing == fp {
                    stats.skipped += 1
                } else {
                    toParse.append(url)
                }
            }
            let version = currentVersion + 1
            var newFingerprints: [String: ConversationFileFingerprint] = [:]
            var parsedBySource: [String: [ConversationRecord]] = [:]
            for url in toParse {
                guard !Task.isCancelled else { return }
                do {
                    let data = try await Task.detached {
                        try Data(contentsOf: url)
                    }.value
                    let cp = Self.canonicalPath(for: url)
                    let parsed = try await Task.detached {
                        try Self.parseChatGPTExportOffMain(data, sourceFile: url.lastPathComponent, version: version, sourceCanonicalPath: cp).get()
                    }.value
                    parsedBySource[cp] = parsed
                    stats.imported += 1
                    let fp = await Task.detached {
                        Self.fingerprintFileOffMain(at: url)
                    }.value
                    newFingerprints[fp.path] = fp
                } catch {
                    stats.failed += 1
                }
            }
            guard !Task.isCancelled else { return }
            let reconciliation = await Task.detached {
                Self.reconcileRecords(existing: snapshot, parsedBySource: parsedBySource)
            }.value
            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                guard let self, !Task.isCancelled else { return }
                for (path, fp) in newFingerprints {
                    fileFingerprints[path] = fp
                }
                importVersion = version
                conversations = reconciliation.records
                fileScanStats = stats
                if reconciliation.addedCount > 0 || reconciliation.updatedCount > 0 || reconciliation.removedCount > 0 || !newFingerprints.isEmpty {
                    scheduleSaveIndex()
                }
                connectToKnowledgeGraph()
                scheduleFilterRefresh()
                isLoading = false
                lastRefresh = Date()
                refreshTask = nil
            }
        }
    }

    // MARK: - Summaries

    func generateSummary(for conversationId: String) {
        guard let idx = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        let conv = conversations[idx]
        let messages = conv.messages
        summaryTask?.cancel()
        summaryTask = Task { [weak self] in
            let result = await Task.detached {
                let allText = messages.map { "[\($0.role)] \($0.content)" }.joined(separator: "\n")
                return ConversationSummary(
                    context: Self.extractContextOffMain(from: allText),
                    decisions: Self.extractDecisionsOffMain(from: allText),
                    nextActions: Self.extractNextActionsOffMain(from: allText),
                    relatedFiles: Self.extractRelatedFilesOffMain(from: allText)
                )
            }.value
            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                guard let self, !Task.isCancelled else { return }
                guard let idx = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
                conversations[idx].summary = result
                scheduleSaveIndex()
                summaryTask = nil
            }
        }
    }

    func generateAllSummaries() {
        summaryTask?.cancel()
        let snapshot = conversations
        summaryTask = Task { [weak self] in
            let updated = await Task.detached {
                Self.computeAllSummariesOffMain(snapshot: snapshot)
            }.value
            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                guard let self, !Task.isCancelled else { return }
                var idxMap: [String: Int] = [:]
                for (i, c) in conversations.enumerated() {
                    idxMap[c.id] = i
                }
                for entry in updated {
                    if let idx = idxMap[entry.id] {
                        conversations[idx].summary = entry.summary
                    }
                }
                scheduleSaveIndex()
                summaryTask = nil
            }
        }
    }

    // MARK: - Save

    private func scheduleSaveIndex() {
        saveTask?.cancel()
        let url = saveURL
        let fpURL = fingerprintManifestURL
        let fingerprintSnapshot = fileFingerprints
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            guard let self else { return }
            let snapshot = conversations
            let t0 = ContinuousClock.now
            do {
                try await Task.detached {
                    try Self.saveIndexOffMain(conversations: snapshot, to: url)
                    try Self.saveFingerprintManifestOffMain(fingerprints: fingerprintSnapshot, to: fpURL)
                }.value
                let elapsed = Double((ContinuousClock.now - t0).components.seconds) + Double((ContinuousClock.now - t0).components.attoseconds) / 1e18
                await MainActor.run { [weak self] in
                    self?.saveDurationMS = elapsed * 1000
                }
            } catch {
                print("[ConversationMemoryStore] Save failed: \(error.localizedDescription)")
            }
            guard !Task.isCancelled else { return }
            saveTask = nil
        }
    }

    // MARK: - Filter

    private func scheduleFilterRefresh() {
        filterTask?.cancel()
        let capturedConversations = conversations
        let capturedQuery = query
        let capturedTags = activeTags
        filterTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }
            let t0 = ContinuousClock.now
            let filtered = await Task.detached {
                Self.filterOffMain(conversations: capturedConversations, query: capturedQuery, activeTags: capturedTags)
            }.value
            let elapsed = Double((ContinuousClock.now - t0).components.seconds) + Double((ContinuousClock.now - t0).components.attoseconds) / 1e18
            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                guard let self else { return }
                guard capturedQuery == query, capturedTags == activeTags else { return }
                visibleConversations = filtered
                filterDurationMS = elapsed * 1000
                filterTask = nil
            }
        }
    }

    // MARK: - Internal

    private func connectToKnowledgeGraph() {
        guard let graph = knowledgeGraph else { return }
        let existingIds = Set(graph.objects.map { $0.id })
        for conv in conversations {
            let objId = "conversation:\(conv.id)"
            guard !existingIds.contains(objId) else { continue }
            let obj = KnowledgeObject(
                id: objId,
                source: "conversation",
                type: .conversation,
                title: conv.title,
                summary: conv.summary?.context ?? "\(conv.messages.count) messages",
                path: conv.sourceFile,
                project: nil,
                module: nil,
                created: conv.date,
                updated: conv.date,
                tags: conv.tags,
                relations: [],
                authority: 0.8,
                confidence: 0.85,
                status: nil,
                metadata: ["messageCount": "\(conv.messages.count)", "importVersion": "\(conv.importVersion)"]
            )
            graph.objects.append(obj)
        }
    }

    private func dismissImportStatus() {
        importStatusDismissTask?.cancel()
        importStatusDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            guard !Task.isCancelled else { return }
            self.importStatus = nil
        }
    }

    // MARK: - Nonisolated Static Helpers

    nonisolated static func fingerprintFileOffMain(at url: URL) -> ConversationFileFingerprint {
        let cp = Self.canonicalPath(for: url)
        let attrs = try? FileManager.default.attributesOfItem(atPath: cp)
        let size = (attrs?[.size] as? Int) ?? 0
        let modDate = (attrs?[.modificationDate] as? Date) ?? Date.distantPast
        return ConversationFileFingerprint(path: cp, fileSize: size, modificationDate: modDate)
    }

    nonisolated static func loadIndexOffMain(from saveURL: URL) -> Result<[ConversationRecord], Error> {
        guard FileManager.default.fileExists(atPath: saveURL.path) else {
            return .success([])
        }
        do {
            let data = try Data(contentsOf: saveURL)
            let decoded = try JSONDecoder().decode([ConversationRecord].self, from: data)
            return .success(decoded)
        } catch {
            print("[ConversationMemoryStore] Index load failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    nonisolated static func saveFingerprintManifestOffMain(fingerprints: [String: ConversationFileFingerprint], to url: URL) throws {
        let manifest = FingerprintManifest(version: 1, fingerprints: fingerprints)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(manifest)
        let dir = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }

    nonisolated static func loadFingerprintManifestOffMain(from url: URL) -> [String: ConversationFileFingerprint]? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let manifest = try? JSONDecoder().decode(FingerprintManifest.self, from: data) else { return nil }
        return manifest.fingerprints
    }

    nonisolated static func saveIndexOffMain(conversations: [ConversationRecord], to saveURL: URL) throws {
        let dir = saveURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(conversations)
        let tmpURL = dir.appendingPathComponent(".ConversationMemoryIndex_tmp.json")
        try data.write(to: tmpURL, options: .atomic)
        if FileManager.default.fileExists(atPath: saveURL.path) {
            var resultingItemURL: NSURL?
            try FileManager.default.replaceItem(at: saveURL, withItemAt: tmpURL, backupItemName: nil, options: .usingNewMetadataOnly, resultingItemURL: &resultingItemURL)
        } else {
            try FileManager.default.moveItem(at: tmpURL, to: saveURL)
        }
    }

    nonisolated static func findConversationFilesOffMain(in directory: URL) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else { return [] }
        var results: [URL] = []
        for case let url as URL in enumerator {
            if url.lastPathComponent == "ConversationMemoryIndex.json" { continue }
            if url.lastPathComponent == "ConversationMemoryIndex_fingerprints.json" { continue }
            if url.lastPathComponent == "conversations.json" || url.pathExtension == "json" {
                results.append(url)
            }
        }
        return results
    }

    nonisolated static func parseChatGPTExportOffMain(_ data: Data, sourceFile: String, version: Int, sourceCanonicalPath: String? = nil) -> Result<[ConversationRecord], Error> {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return .failure(CocoaError(.fileReadCorruptFile))
        }
        let digest = sourceCanonicalPath.map { Self.canonicalSourceDigest(for: $0) }
        let records = root.compactMap { entry -> ConversationRecord? in
            guard let title = entry["title"] as? String,
                  let createTime = entry["create_time"] as? TimeInterval else { return nil }
            let date = Date(timeIntervalSince1970: createTime)
            var messages: [ConversationMessage] = []
            if let mapping = entry["mapping"] as? [String: [String: Any]] {
                let sorted = mapping.values
                    .compactMap { node -> ConversationMessage? in
                        guard let msg = node["message"] as? [String: Any],
                              let author = msg["author"] as? [String: Any],
                              let role = author["role"] as? String,
                              let content = msg["content"] as? [String: Any],
                              let parts = content["parts"] as? [Any] else { return nil }
                        let text = parts.compactMap { $0 as? String }.joined(separator: "\n")
                        let msgId = (msg["id"] as? String) ?? UUID().uuidString
                        let ts = (msg["create_time"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }
                        return ConversationMessage(id: msgId, role: role, content: text, timestamp: ts)
                    }
                    .sorted { ($0.timestamp ?? .distantPast) < ($1.timestamp ?? .distantPast) }
                messages = sorted
            }
            let tags = Self.inferTagsOffMain(from: title, messages: messages)
            let createTimeInt = Int(createTime)
            let id: String
            if let d = digest {
                id = "conv_\(d)_\(createTimeInt)"
            } else {
                id = "conv_\(sourceFile)_\(createTimeInt)"
            }
            return ConversationRecord(
                id: id,
                title: title,
                date: date,
                messages: messages,
                tags: tags,
                projects: [],
                decisions: [],
                missions: [],
                freezes: [],
                evidence: [],
                summary: nil,
                sourceFile: sourceFile,
                importVersion: version,
                sourceCanonicalPath: sourceCanonicalPath
            )
        }
        return .success(records)
    }

    nonisolated static func hasSourceContentChanged(old: ConversationRecord, new: ConversationRecord) -> Bool {
        old.title != new.title
        || old.date != new.date
        || old.messages != new.messages
        || old.tags != new.tags
        || old.projects != new.projects
        || old.decisions != new.decisions
        || old.missions != new.missions
        || old.freezes != new.freezes
        || old.evidence != new.evidence
    }

    nonisolated static func reconcileRecords(
        existing: [ConversationRecord],
        parsedBySource: [String: [ConversationRecord]]
    ) -> ConversationReconciliationResult {
        var added = 0, updated = 0, removed = 0, unchanged = 0
        var result: [ConversationRecord] = []
        let affectedSources = Set(parsedBySource.keys)

        let existingBySource: [String?: [ConversationRecord]] = Dictionary(grouping: existing) { record in
            affectedSources.contains { $0 == record.sourceCanonicalPath } ? record.sourceCanonicalPath : nil
        }

        for (sourcePath, parsedRecords) in parsedBySource {
            let existingForSource = existingBySource[sourcePath] ?? []
            let existingById: [String: ConversationRecord] = Dictionary(uniqueKeysWithValues: existingForSource.map { ($0.id, $0) })
            let existingKeys: Set<ConversationSourceKey> = Set(existingForSource.compactMap { ConversationSourceKey.forRecord($0, canonicalPath: sourcePath) })
            var matchedExistingIds: Set<String> = []

            for newRecord in parsedRecords {
                let newKey = ConversationSourceKey.forRecord(newRecord, canonicalPath: sourcePath)
                if let key = newKey, let matchedId = (existingForSource.first { ConversationSourceKey.forRecord($0, canonicalPath: sourcePath) == key })?.id {
                    matchedExistingIds.insert(matchedId)
                    if let oldRecord = existingById[matchedId] {
                        if hasSourceContentChanged(old: oldRecord, new: newRecord) {
                            var updatedRecord = newRecord
                            if oldRecord.summary != nil {
                                updatedRecord.summary = hasSourceContentChanged(old: oldRecord, new: newRecord) ? nil : oldRecord.summary
                            } else {
                                updatedRecord.summary = nil
                            }
                            result.append(updatedRecord)
                            updated += 1
                        } else {
                            let preserved = ConversationRecord(id: oldRecord.id, title: oldRecord.title, date: oldRecord.date, messages: oldRecord.messages, tags: oldRecord.tags, projects: oldRecord.projects, decisions: oldRecord.decisions, missions: oldRecord.missions, freezes: oldRecord.freezes, evidence: oldRecord.evidence, summary: oldRecord.summary, sourceFile: oldRecord.sourceFile, importVersion: newRecord.importVersion, sourceCanonicalPath: oldRecord.sourceCanonicalPath)
                            result.append(preserved)
                            unchanged += 1
                        }
                    } else {
                        result.append(newRecord)
                        added += 1
                    }
                } else {
                    result.append(newRecord)
                    added += 1
                }
            }

            let removedCount = existingForSource.count { !matchedExistingIds.contains($0.id) }
            removed += removedCount
        }

        for (sourcePath, records) in existingBySource where sourcePath == nil || !affectedSources.contains(sourcePath ?? "") {
            result.append(contentsOf: records)
        }

        result.sort { $0.date > $1.date }
        return ConversationReconciliationResult(
            records: result,
            addedCount: added,
            updatedCount: updated,
            removedCount: removed,
            unchangedCount: unchanged,
            affectedSources: affectedSources
        )
    }

    nonisolated static func filterOffMain(conversations: [ConversationRecord], query: String, activeTags: Set<String>) -> [ConversationRecord] {
        var result = conversations
        if !query.isEmpty {
            result = result.filter { conv in
                conv.title.localizedStandardContains(query) ||
                conv.messages.contains { $0.content.localizedStandardContains(query) } ||
                conv.tags.contains { $0.localizedStandardContains(query) }
            }
        }
        if !activeTags.isEmpty {
            result = result.filter { conv in
                !activeTags.isDisjoint(with: conv.tags)
            }
        }
        return result
    }

    nonisolated static func inferTagsOffMain(from title: String, messages: [ConversationMessage]) -> [String] {
        let allText = (title + " " + messages.map { $0.content }.joined(separator: " ")).lowercased()
        var tags: [String] = []
        if allText.contains("supra") { tags.append("SUPRA") }
        if allText.contains("nova") || allText.contains("era") { tags.append("NOVA ERA") }
        if allText.contains("cannonico") || allText.contains("canno") { tags.append("CAnnoNico") }
        if allText.contains("runtime") || allText.contains("process") || allText.contains("cpu") { tags.append("Runtime") }
        if allText.contains("business") || allText.contains("revenue") || allText.contains("market") { tags.append("Business") }
        if allText.contains("legal") || allText.contains("license") || allText.contains("compliance") { tags.append("Legal") }
        if allText.contains("decision") || allText.contains("verdict") || allText.contains("approve") || allText.contains("gate") { tags.append("Décisions") }
        return tags
    }

    nonisolated static func extractContextOffMain(from text: String) -> String {
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let assistantLines = lines.filter { $0.hasPrefix("[assistant]") }
        guard let firstResponse = assistantLines.first else { return "Aucun contexte extrait" }
        let cleaned = firstResponse
            .replacingOccurrences(of: "[assistant]", with: "")
            .trimmingCharacters(in: .whitespaces)
        return String(cleaned.prefix(200))
    }

    nonisolated static func extractDecisionsOffMain(from text: String) -> [String] {
        let lower = text.lowercased()
        var results: [String] = []
        if let range = lower.range(of: "décision") {
            let snippet = text[range.lowerBound...].prefix(100)
            results.append(String(snippet))
        }
        if let range = lower.range(of: "decision") {
            let snippet = text[range.lowerBound...].prefix(100)
            results.append(String(snippet))
        }
        return results
    }

    nonisolated static func extractNextActionsOffMain(from text: String) -> [String] {
        let lower = text.lowercased()
        var results: [String] = []
        let markers = ["prochaine action", "next action", "à faire", "todo", "étape suivante"]
        for marker in markers {
            if let range = lower.range(of: marker) {
                let snippet = text[range.lowerBound...].prefix(100)
                results.append(String(snippet))
            }
        }
        return results
    }

    nonisolated static func extractRelatedFilesOffMain(from text: String) -> [String] {
        let pattern = try! NSRegularExpression(pattern: #"(/[^\s]+\.\w+)"#)
        let nsRange = NSRange(text.startIndex..., in: text)
        let matches = pattern.matches(in: text, range: nsRange)
        return matches.prefix(10).compactMap { match in
            guard let range = Range(match.range(at: 1), in: text) else { return nil }
            return String(text[range])
        }
    }

    nonisolated static func computeAllSummariesOffMain(snapshot: [ConversationRecord]) -> [(id: String, summary: ConversationSummary?)] {
        snapshot.compactMap { conv -> (id: String, summary: ConversationSummary?)? in
            guard conv.summary == nil else { return nil }
            let allText = conv.messages.map { "[\($0.role)] \($0.content)" }.joined(separator: "\n")
            let summary = ConversationSummary(
                context: Self.extractContextOffMain(from: allText),
                decisions: Self.extractDecisionsOffMain(from: allText),
                nextActions: Self.extractNextActionsOffMain(from: allText),
                relatedFiles: Self.extractRelatedFilesOffMain(from: allText)
            )
            return (conv.id, summary)
        }
    }
}
