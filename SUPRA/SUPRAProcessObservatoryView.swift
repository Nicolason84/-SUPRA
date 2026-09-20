import SwiftUI
import AppKit
import Combine
import Foundation

struct SUPRAProcessObservatoryView: View {
    @StateObject private var store = SUPRAProcessObservatoryStore()
    @State private var selectedID: String?

    private var selected: SUPRAObservedProcess? {
        if let selectedID,
           let item = store.processes.first(where: { $0.id == selectedID }) {
            return item
        }
        return store.processes.first(where: { $0.isBottleneck })
            ?? store.processes.first(where: { $0.id == "F2_LG01_AUTHORITY_OR_ALIAS_GATE_20260920_1920" })
            ?? store.processes.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                summary
                radar
                ledger
                detail
            }
            .padding(28)
            .frame(maxWidth: 1400, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Process Observatory")
        .toolbar {
            Toggle("Live", isOn: $store.isLive)
                .toggleStyle(.switch)
            Button("Refresh", systemImage: "arrow.clockwise") {
                store.refresh()
            }
            Button("Select Bridge…", systemImage: "folder.badge.gearshape") {
                store.selectBridgeRoot()
            }
        }
        .task { store.start() }
        .onDisappear { store.stop() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("SUPRA PROCESS OBSERVATORY")
                    .font(.caption.weight(.bold))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(store.bridgeAvailable ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(store.sourceLabel)
                        .font(.caption.weight(.semibold))
                }
            }
            Text("Execution map")
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text("Read-only observation of mission flow, evidence materialization, drift and bottlenecks.")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Pulse: \(store.lastRefresh.formatted(date: .abbreviated, time: .standard))")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private var summary: some View {
        section("Executive Pulse", systemImage: "dot.radiowaves.left.and.right") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 12)], spacing: 12) {
                metric("In flight", "\(store.inFlightCount)", "arrow.triangle.2.circlepath", .blue)
                metric("Materialized", "\(store.materializedCount)", "checkmark.seal.fill", .green)
                metric("Bottlenecks", "\(store.bottleneckCount)", "exclamationmark.octagon.fill", store.bottleneckCount > 0 ? .orange : .green)
                metric("Drift", "\(store.driftCount)", "waveform.path.badge.exclamationmark", store.driftCount > 0 ? .orange : .green)
                metric("Observable closure", "\(Int(store.observableClosure * 100))%", "gauge.with.dots.needle.50percent", .accentColor)
            }
        }
    }

    private var radar: some View {
        section("Drift & Bottleneck Radar", systemImage: "scope") {
            HStack(alignment: .top, spacing: 14) {
                radarCard(
                    "Current bottleneck",
                    store.processes.filter(\.isBottleneck).prefix(4).map { "\($0.title) · \($0.ageLabel)" },
                    empty: "No bottleneck detected."
                )
                radarCard(
                    "Drift signals",
                    store.processes.filter { $0.drift != .none }.prefix(4).map { "\($0.drift.label): \($0.title)" },
                    empty: "No drift detected."
                )
                radarCard(
                    "Guardrails",
                    [
                        "Observer: READ_ONLY",
                        "No engine creation",
                        "No bridge creation",
                        "No runtime creation"
                    ],
                    empty: "Guardrails unavailable."
                )
            }
        }
    }

    private var ledger: some View {
        section("Process Ledger", systemImage: "list.bullet.rectangle.portrait.fill") {
            VStack(spacing: 7) {
                ForEach(store.processes.prefix(80)) { process in
                    Button {
                        selectedID = process.id
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(process.stage.color)
                                .frame(width: 9, height: 9)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(process.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(process.id)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(process.ageLabel)
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                                .frame(width: 70, alignment: .trailing)
                            ProgressView(value: process.progress)
                                .frame(width: 110)
                            badge(process.stage.label, color: process.stage.color)
                                .frame(width: 110, alignment: .trailing)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            selected?.id == process.id ? Color.accentColor.opacity(0.10) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 11)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
        }
    }

    private var detail: some View {
        section("Selected Process", systemImage: "doc.text.magnifyingglass") {
            if let selected {
                VStack(alignment: .leading, spacing: 12) {
                    detailRow("Stage", selected.stage.label)
                    detailRow("Age", selected.ageLabel)
                    detailRow("Drift", selected.drift.label)
                    detailRow("Progress", "\(Int(selected.progress * 100))% observable")
                    detailRow("Status", selected.statusText ?? "No material result yet")
                    detailRow("Action Nicolas", selected.actionNicolas ?? "NONE / not observed")
                    if let f2Status = selected.f2StatusAfter {
                        detailRow("F2 after", f2Status)
                    }
                    if let lg01 = selected.lg01Classification {
                        detailRow("LG01", lg01)
                    }
                    if !selected.proofRefs.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Proof refs")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            ForEach(selected.proofRefs.prefix(8), id: \.self) {
                                Text($0)
                                    .font(.caption.monospaced())
                                    .textSelection(.enabled)
                            }
                        }
                    }
                }
                .padding(18)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
            } else {
                ContentUnavailableView("No process evidence", systemImage: "binoculars.fill")
            }
        }
    }

    private func section<Content: View>(_ title: String, systemImage: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.title2.bold())
            content()
        }
    }

    private func metric(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value).font(.title2.bold().monospacedDigit())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 105, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
    }

    private func radarCard(_ title: String, _ items: [String], empty: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            if items.isEmpty {
                Text(empty).foregroundStyle(.secondary)
            } else {
                ForEach(items, id: \.self) { Text($0).font(.callout).lineLimit(2) }
            }
            Spacer(minLength: 0)
        }
        .padding(15)
        .frame(maxWidth: .infinity, minHeight: 125, alignment: .topLeading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.quaternary))
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(color.opacity(0.10), in: Capsule())
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.callout.monospaced())
                .textSelection(.enabled)
            Spacer()
        }
    }
}

@MainActor
final class SUPRAProcessObservatoryStore: ObservableObject {
    @Published private(set) var processes: [SUPRAObservedProcess] = []
    @Published private(set) var lastRefresh: Date = .now
    @Published private(set) var bridgeAvailable = false
    @Published private(set) var sourceLabel = "INITIALIZING"
    @Published var isLive = true

    private var pollTask: Swift.Task<Void, Never>?
    private var refreshTask: Swift.Task<Void, Never>?
    private var scanGeneration: UInt64 = 0
    private let scanner = SUPRAProcessObservatoryScanner()
    private let bookmarkKey = "SUPRAProcessObservatory.bridgeRootBookmark.v1"
    private var bookmarkedBridgeRoot: URL?
    private let fileManager = FileManager.default

    init() {
        restoreBridgeBookmark()
    }

    var inFlightCount: Int { processes.filter { $0.stage == .inFlight }.count }
    var materializedCount: Int { processes.filter(\.hasResult).count }
    var bottleneckCount: Int { processes.filter(\.isBottleneck).count }
    var driftCount: Int { processes.filter { $0.drift != .none }.count }
    var observableClosure: Double {
        guard !processes.isEmpty else { return 0 }
        return processes.map(\.progress).reduce(0, +) / Double(processes.count)
    }

    func start() {
        guard pollTask == nil else { return }
        if bookmarkedBridgeRoot == nil {
            restoreBridgeBookmark()
        }
        refresh()
        pollTask = Swift.Task { [weak self] in
            while !Swift.Task.isCancelled {
                try? await Swift.Task.sleep(nanoseconds: 2_000_000_000)
                guard let self, self.isLive else { continue }
                self.refresh()
            }
        }
    }

    func stop() {
        pollTask?.cancel()
        pollTask = nil
        scanGeneration &+= 1
        refreshTask?.cancel()
        refreshTask = nil
    }

    func refresh(force: Bool = false) {
        if refreshTask != nil {
            guard force else { return }
            scanGeneration &+= 1
            refreshTask?.cancel()
            refreshTask = nil
        }

        lastRefresh = .now

        if bookmarkedBridgeRoot == nil,
           UserDefaults.standard.data(forKey: bookmarkKey) != nil {
            restoreBridgeBookmark()
        }

        guard let access = resolveBridgeAccess() else {
            scanGeneration &+= 1
            let hasSavedBookmark = UserDefaults.standard.data(forKey: bookmarkKey) != nil
            clearBridgeState(label: hasSavedBookmark ? "SAVED BRIDGE UNAVAILABLE" : "BRIDGE ACCESS REQUIRED")
            return
        }

        let root = access.url
        if access.requiresSecurityScope && !root.startAccessingSecurityScopedResource() {
            scanGeneration &+= 1
            clearBridgeState(label: "BRIDGE ACCESS FAILED")
            return
        }

        scanGeneration &+= 1
        let generation = scanGeneration
        let requiresSecurityScope = access.requiresSecurityScope
        sourceLabel = root.path

        let scanner = self.scanner
        refreshTask = Swift.Task { [weak self] in
            defer {
                if requiresSecurityScope {
                    root.stopAccessingSecurityScopedResource()
                }
            }

            let snapshot = await scanner.scan(root: root)

            guard let self else { return }
            guard generation == self.scanGeneration else { return }

            self.refreshTask = nil
            guard !Swift.Task.isCancelled, let snapshot else { return }

            if snapshot.bridgeAvailable {
                self.bridgeAvailable = true
                self.sourceLabel = root.path
                self.processes = snapshot.processes
            } else {
                self.clearBridgeState(
                    label: snapshot.unavailableReason ?? "LOCAL BRIDGE UNAVAILABLE"
                )
            }
        }
    }

    func selectBridgeRoot() {
        let panel = NSOpenPanel()
        panel.title = "Select existing SUPRA bridge"
        panel.message = "Choose the existing bridge folder that contains INBOX and OUTBOX. SUPRA will retain read-only access."
        panel.prompt = "Use Bridge"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false

        guard panel.runModal() == .OK, let selectedURL = panel.url else { return }

        guard selectedURL.startAccessingSecurityScopedResource() else {
            sourceLabel = bookmarkedBridgeRoot?.path ?? "BRIDGE SELECTION ACCESS FAILED"
            return
        }
        defer { selectedURL.stopAccessingSecurityScopedResource() }

        guard isBridgeRoot(selectedURL) else {
            sourceLabel = bookmarkedBridgeRoot?.path ?? "SELECT FOLDER CONTAINING INBOX + OUTBOX"
            return
        }

        do {
            let candidateBookmark = try selectedURL.bookmarkData(
                options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )

            guard let validated = validateBookmark(candidateBookmark) else {
                sourceLabel = bookmarkedBridgeRoot?.path ?? "BRIDGE BOOKMARK ACCESS FAILED"
                return
            }

            UserDefaults.standard.set(validated.bookmark, forKey: bookmarkKey)
            bookmarkedBridgeRoot = validated.url
            refresh(force: true)
        } catch {
            sourceLabel = bookmarkedBridgeRoot?.path ?? "BRIDGE BOOKMARK CREATION FAILED"
        }
    }

    private func restoreBridgeBookmark() {
        guard bookmarkedBridgeRoot == nil,
              let storedBookmark = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return
        }

        guard let validated = validateBookmark(storedBookmark) else {
            // Keep the persisted bookmark: an external volume or provider may be
            // temporarily unavailable and can recover on a later live refresh.
            bookmarkedBridgeRoot = nil
            sourceLabel = "SAVED BRIDGE UNAVAILABLE"
            return
        }

        if validated.bookmark != storedBookmark {
            UserDefaults.standard.set(validated.bookmark, forKey: bookmarkKey)
        }
        bookmarkedBridgeRoot = validated.url
    }

    private func validateBookmark(_ bookmark: Data) -> SUPRAValidatedBookmark? {
        var isStale = false

        guard let url = try? URL(
            resolvingBookmarkData: bookmark,
            options: [.withSecurityScope, .withoutUI],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            return nil
        }

        guard url.startAccessingSecurityScopedResource() else {
            return nil
        }
        defer { url.stopAccessingSecurityScopedResource() }

        guard isBridgeRoot(url) else {
            return nil
        }

        if isStale,
           let refreshed = try? url.bookmarkData(
               options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
               includingResourceValuesForKeys: nil,
               relativeTo: nil
           ) {
            return SUPRAValidatedBookmark(url: url, bookmark: refreshed)
        }

        return SUPRAValidatedBookmark(url: url, bookmark: bookmark)
    }

    private func resolveBridgeAccess() -> SUPRABridgeAccess? {
        if let bookmarkedBridgeRoot {
            return SUPRABridgeAccess(url: bookmarkedBridgeRoot, requiresSecurityScope: true)
        }

        guard let resources = Bundle.main.resourceURL else { return nil }
        let packagedCandidates = [
            resources.appendingPathComponent("SOL_BRIDGE", isDirectory: true),
            resources.appendingPathComponent("SUPRA_RUNTIME/SOL_BRIDGE", isDirectory: true)
        ]

        guard let packaged = packagedCandidates.first(where: isBridgeRoot) else {
            return nil
        }
        return SUPRABridgeAccess(url: packaged, requiresSecurityScope: false)
    }

    private func isBridgeRoot(_ candidate: URL) -> Bool {
        isDirectory(candidate.appendingPathComponent("INBOX", isDirectory: true))
            && isDirectory(candidate.appendingPathComponent("OUTBOX", isDirectory: true))
    }

    private func isDirectory(_ url: URL) -> Bool {
        var directoryFlag = ObjCBool(false)
        return fileManager.fileExists(atPath: url.path, isDirectory: &directoryFlag)
            && directoryFlag.boolValue
    }

    private func clearBridgeState(label: String) {
        bridgeAvailable = false
        sourceLabel = label
        processes = []
    }
}

private actor SUPRAProcessObservatoryScanner {
    private let fileManager = FileManager.default
    private let maxProcessIDs = 500
    private let maxDirectoryEntries = 5_000
    private let maxResultBytes = 4 * 1024 * 1024
    private let maxAggregateResultBytes = 32 * 1024 * 1024
    private let maxRetainedTextCharacters = 4_096
    private let maxRetainedProofRefs = 32
    private let maxRetainedProofRefCharacters = 2_048
    private var parsedCache: [String: SUPRAParsedCacheEntry] = [:]

    func scan(root: URL) -> SUPRAProcessSnapshot? {
        guard !Swift.Task.isCancelled else { return nil }

        let inboxURL = root.appendingPathComponent("INBOX", isDirectory: true)
        let outboxURL = root.appendingPathComponent("OUTBOX", isDirectory: true)

        guard isDirectory(inboxURL), isDirectory(outboxURL) else {
            parsedCache.removeAll(keepingCapacity: true)
            return SUPRAProcessSnapshot(
                bridgeAvailable: false,
                processes: [],
                unavailableReason: "BRIDGE DIRECTORIES UNAVAILABLE"
            )
        }

        let inbox: [SUPRAObservedFile]
        switch descriptors(in: inboxURL, result: false) {
        case .success(let files):
            inbox = files
        case .failure(let reason):
            parsedCache.removeAll(keepingCapacity: true)
            return SUPRAProcessSnapshot(
                bridgeAvailable: false,
                processes: [],
                unavailableReason: reason
            )
        case .cancelled:
            return nil
        }

        let outbox: [SUPRAObservedFile]
        switch descriptors(in: outboxURL, result: true) {
        case .success(let files):
            outbox = files
        case .failure(let reason):
            parsedCache.removeAll(keepingCapacity: true)
            return SUPRAProcessSnapshot(
                bridgeAvailable: false,
                processes: [],
                unavailableReason: reason
            )
        case .cancelled:
            return nil
        }

        guard !Swift.Task.isCancelled,
              let processes = buildProcesses(inbox: inbox, outbox: outbox) else {
            return nil
        }

        return SUPRAProcessSnapshot(
            bridgeAvailable: true,
            processes: processes,
            unavailableReason: nil
        )
    }

    private func descriptors(
        in directory: URL,
        result: Bool
    ) -> SUPRADirectoryScanResult {
        let keys: Set<URLResourceKey> = [
            .contentModificationDateKey,
            .isRegularFileKey,
            .fileSizeKey,
            .fileResourceIdentifierKey
        ]

        var enumerationError: Error?
        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants],
            errorHandler: { _, error in
                enumerationError = error
                return false
            }
        ) else {
            return .failure("BRIDGE DIRECTORY ENUMERATION FAILED")
        }

        var files: [SUPRAObservedFile] = []
        files.reserveCapacity(min(maxDirectoryEntries, 1_024))
        var visitedEntries = 0

        while let object = enumerator.nextObject() {
            if Swift.Task.isCancelled { return .cancelled }
            guard let url = object as? URL else { continue }

            visitedEntries += 1
            guard visitedEntries <= maxDirectoryEntries else {
                return .failure("BRIDGE DIRECTORY ENTRY LIMIT EXCEEDED")
            }

            guard url.pathExtension.lowercased() == "json" else { continue }

            do {
                let values = try url.resourceValues(forKeys: keys)
                guard values.isRegularFile == true else { continue }

                files.append(
                    SUPRAObservedFile(
                        id: normalizedID(url.lastPathComponent),
                        url: url,
                        modifiedAt: values.contentModificationDate,
                        fileSize: values.fileSize,
                        resourceIdentifier: values.fileResourceIdentifier.map {
                            String(reflecting: $0)
                        },
                        result: result
                    )
                )
            } catch {
                return .failure("BRIDGE FILE METADATA READ FAILED")
            }
        }

        if Swift.Task.isCancelled { return .cancelled }
        if enumerationError != nil {
            return .failure("BRIDGE DIRECTORY ENUMERATION FAILED")
        }

        return .success(files)
    }

    private func buildProcesses(
        inbox: [SUPRAObservedFile],
        outbox: [SUPRAObservedFile]
    ) -> [SUPRAObservedProcess]? {
        let inMap = deterministicMap(inbox)
        let outMap = deterministicMap(outbox)
        let allIDs = Set(inMap.keys).union(outMap.keys)

        let selectedIDs = Array(
            allIDs.sorted { lhs, rhs in
                let lhsDate = processActivityDate(id: lhs, inbox: inMap, outbox: outMap)
                let rhsDate = processActivityDate(id: rhs, inbox: inMap, outbox: outMap)
                if lhsDate != rhsDate { return lhsDate > rhsDate }
                return lhs < rhs
            }
            .prefix(maxProcessIDs)
        )

        let activeOutputPaths = Set(selectedIDs.compactMap { outMap[$0]?.url.path })
        parsedCache = parsedCache.filter { activeOutputPaths.contains($0.key) }

        var processes: [SUPRAObservedProcess] = []
        processes.reserveCapacity(selectedIDs.count)
        var remainingReadBytes = maxAggregateResultBytes
        var aggregateBudgetLimitedIDs = Set<String>()

        for id in selectedIDs {
            guard !Swift.Task.isCancelled else { return nil }

            let input = inMap[id]
            let output = outMap[id]
            let parsed: SUPRAParsedResult?
            if let output {
                parsed = parseResult(
                    output,
                    remainingReadBytes: &remainingReadBytes,
                    aggregateBudgetLimitedIDs: &aggregateBudgetLimitedIDs
                )
            } else {
                parsed = nil
            }

            guard !Swift.Task.isCancelled else { return nil }

            let hasInbox = input != nil
            let hasOutput = output != nil
            let hasValidResult = parsed != nil
            let started = inferredDate(from: id) ?? input?.modifiedAt ?? output?.modifiedAt ?? .now
            let age = max(0, Date().timeIntervalSince(started))
            let stage = stage(hasInbox: hasInbox, hasOutput: hasOutput, parsed: parsed)
            let drift = drift(
                hasInbox: hasInbox,
                hasOutput: hasOutput,
                hasValidResult: hasValidResult,
                age: age
            )

            processes.append(
                SUPRAObservedProcess(
                    id: id,
                    title: title(for: id),
                    hasResult: hasValidResult,
                    stage: stage,
                    startedAt: started,
                    ageSeconds: age,
                    progress: progress(for: stage, parsed: parsed),
                    drift: drift,
                    isBottleneck: false,
                    statusText: hasOutput && parsed == nil
                        ? invalidResultStatus(
                            output,
                            aggregateBudgetLimited: aggregateBudgetLimitedIDs.contains(id)
                        )
                        : parsed?.status,
                    actionNicolas: parsed?.actionNicolas,
                    f2StatusAfter: parsed?.f2StatusAfter,
                    lg01Classification: parsed?.lg01Classification,
                    proofRefs: parsed?.proofRefs ?? []
                )
            )
        }

        if let oldestUnresolved = processes
            .filter({ $0.stage == .inFlight || $0.stage == .blocked })
            .max(by: { $0.ageSeconds < $1.ageSeconds })?
            .id {
            processes = processes.map {
                var item = $0
                item.isBottleneck = item.id == oldestUnresolved
                return item
            }
        }

        processes.sort {
            if $0.id == "F2_LG01_AUTHORITY_OR_ALIAS_GATE_20260920_1920" { return true }
            if $1.id == "F2_LG01_AUTHORITY_OR_ALIAS_GATE_20260920_1920" { return false }
            if $0.isBottleneck != $1.isBottleneck { return $0.isBottleneck }
            return $0.startedAt > $1.startedAt
        }

        return processes
    }

    private func invalidResultStatus(
        _ output: SUPRAObservedFile?,
        aggregateBudgetLimited: Bool
    ) -> String {
        if aggregateBudgetLimited {
            return "OUTBOX result deferred by 32 MiB scan budget"
        }
        if let size = output?.fileSize, size > maxResultBytes {
            return "OUTBOX result exceeds 4 MiB read limit"
        }
        return "Unreadable or malformed OUTBOX result"
    }

    private func processActivityDate(
        id: String,
        inbox: [String: SUPRAObservedFile],
        outbox: [String: SUPRAObservedFile]
    ) -> Date {
        let inputDate = inbox[id]?.modifiedAt ?? .distantPast
        let outputDate = outbox[id]?.modifiedAt ?? .distantPast
        return max(inputDate, outputDate)
    }

    private func deterministicMap(
        _ files: [SUPRAObservedFile]
    ) -> [String: SUPRAObservedFile] {
        var map: [String: SUPRAObservedFile] = [:]

        for file in files {
            guard let current = map[file.id] else {
                map[file.id] = file
                continue
            }

            if shouldPrefer(file, over: current) {
                map[file.id] = file
            }
        }

        return map
    }

    private func shouldPrefer(
        _ candidate: SUPRAObservedFile,
        over current: SUPRAObservedFile
    ) -> Bool {
        let candidateDate = candidate.modifiedAt ?? .distantPast
        let currentDate = current.modifiedAt ?? .distantPast

        if candidateDate != currentDate {
            return candidateDate > currentDate
        }

        return candidate.url.lastPathComponent < current.url.lastPathComponent
    }

    private func parseResult(
        _ file: SUPRAObservedFile,
        remainingReadBytes: inout Int,
        aggregateBudgetLimitedIDs: inout Set<String>
    ) -> SUPRAParsedResult? {
        if Swift.Task.isCancelled { return nil }

        let cacheKey = file.url.path

        if let identifier = file.resourceIdentifier,
           let cached = parsedCache[cacheKey],
           cached.resourceIdentifier == identifier,
           cached.modifiedAt == file.modifiedAt,
           cached.fileSize == file.fileSize {
            return cached.parsed
        }

        if let fileSize = file.fileSize {
            if fileSize > maxResultBytes {
                cacheParsedResult(nil, for: file)
                return nil
            }
            if fileSize > remainingReadBytes {
                aggregateBudgetLimitedIDs.insert(file.id)
                return nil
            }
        }

        guard remainingReadBytes > 0 else {
            aggregateBudgetLimitedIDs.insert(file.id)
            return nil
        }

        let perReadLimit = min(maxResultBytes, remainingReadBytes)
        let data: Data
        do {
            let handle = try FileHandle(forReadingFrom: file.url)
            defer { try? handle.close() }

            guard let bounded = try handle.read(upToCount: perReadLimit + 1) else {
                return nil
            }
            guard bounded.count <= perReadLimit else {
                if perReadLimit < maxResultBytes {
                    aggregateBudgetLimitedIDs.insert(file.id)
                } else {
                    cacheParsedResult(nil, for: file)
                }
                return nil
            }
            data = bounded
        } catch {
            return nil
        }

        remainingReadBytes = max(0, remainingReadBytes - data.count)

        if Swift.Task.isCancelled { return nil }

        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            cacheParsedResult(nil, for: file)
            return nil
        }
        if Swift.Task.isCancelled { return nil }

        var merged = root
        if let bridge = root["bridge_result"] as? [String: Any],
           let reply = bridge["reply"] as? String,
           let replyData = reply.data(using: .utf8),
           let nested = try? JSONSerialization.jsonObject(with: replyData) as? [String: Any] {
            for (key, value) in nested {
                merged[key] = value
            }
        }

        if Swift.Task.isCancelled { return nil }

        let parsed = SUPRAParsedResult(
            status: boundedString(merged["status"]),
            actionNicolas: boundedString(merged["action_nicolas"]),
            f2StatusAfter: boundedString(merged["f2_status_after"]),
            lg01Classification: boundedString(merged["lg01_classification"]),
            proofRefs: boundedProofRefs(merged["proof_refs"])
        )

        cacheParsedResult(parsed, for: file)
        return parsed
    }

    private func cacheParsedResult(
        _ parsed: SUPRAParsedResult?,
        for file: SUPRAObservedFile
    ) {
        guard !Swift.Task.isCancelled, let identifier = file.resourceIdentifier else {
            return
        }

        parsedCache[file.url.path] = SUPRAParsedCacheEntry(
            modifiedAt: file.modifiedAt,
            fileSize: file.fileSize,
            resourceIdentifier: identifier,
            parsed: parsed
        )
    }

    private func boundedString(_ value: Any?) -> String? {
        guard let value else { return nil }
        let text = value as? String ?? String(describing: value)
        return String(text.prefix(maxRetainedTextCharacters))
    }

    private func boundedProofRefs(_ value: Any?) -> [String] {
        guard let refs = value as? [String] else { return [] }
        return refs.prefix(maxRetainedProofRefs).map {
            String($0.prefix(maxRetainedProofRefCharacters))
        }
    }

    private func stage(
        hasInbox: Bool,
        hasOutput: Bool,
        parsed: SUPRAParsedResult?
    ) -> SUPRAProcessStage {
        if hasOutput && parsed == nil { return .anomaly }
        if parsed != nil && !hasInbox { return .anomaly }
        guard hasOutput else { return hasInbox ? .inFlight : .unknown }

        let status = (parsed?.status ?? "").uppercased()
        let f2 = (parsed?.f2StatusAfter ?? "").uppercased()

        if status.contains("FROZEN") || f2.contains("FROZEN") { return .frozen }
        if status.contains("BLOCKED") || status.contains("HUMAN_GATE") { return .blocked }
        if status.contains("FAIL") { return .failed }
        return .materialized
    }

    private func drift(
        hasInbox: Bool,
        hasOutput: Bool,
        hasValidResult: Bool,
        age: TimeInterval
    ) -> SUPRAProcessDrift {
        if hasOutput && !hasValidResult { return .anomaly }
        if hasValidResult && !hasInbox { return .anomaly }
        guard hasInbox && !hasOutput else { return .none }

        if age >= 3600 { return .critical }
        if age >= 900 { return .warning }
        if age >= 300 { return .watch }
        return .none
    }

    private func progress(
        for stage: SUPRAProcessStage,
        parsed: SUPRAParsedResult?
    ) -> Double {
        switch stage {
        case .frozen:
            return 1.0
        case .materialized:
            return parsed?.proofRefs.isEmpty == false ? 0.85 : 0.60
        case .blocked, .failed:
            return parsed?.proofRefs.isEmpty == false ? 0.70 : 0.50
        case .anomaly:
            return 0.10
        case .inFlight:
            return 0.25
        case .unknown:
            return 0
        }
    }

    private func normalizedID(_ filename: String) -> String {
        filename
            .replacingOccurrences(of: ".result.json", with: "")
            .replacingOccurrences(of: ".json", with: "")
    }

    private func inferredDate(from text: String) -> Date? {
        let pattern = "(20\\d{6})[_-](\\d{4,6})"

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                  in: text,
                  range: NSRange(text.startIndex..<text.endIndex, in: text)
              ),
              let dateRange = Range(match.range(at: 1), in: text),
              let timeRange = Range(match.range(at: 2), in: text) else {
            return nil
        }

        let datePart = String(text[dateRange])
        var timePart = String(text[timeRange])
        if timePart.count == 4 {
            timePart += "00"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Paris")
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.date(from: datePart + timePart)
    }

    private func title(for id: String) -> String {
        if id == "F2_LG01_AUTHORITY_OR_ALIAS_GATE_20260920_1920" {
            return "F2 · LG01 authority-or-alias gate"
        }
        if id.contains("F3C_CANNONICO20B") {
            return "F3C · CANNONICO 20B live proof"
        }
        return id.replacingOccurrences(of: "_", with: " ")
    }

    private func string(_ value: Any?) -> String? {
        guard let value else { return nil }
        return value as? String ?? String(describing: value)
    }

    private func isDirectory(_ url: URL) -> Bool {
        var directoryFlag = ObjCBool(false)
        return fileManager.fileExists(atPath: url.path, isDirectory: &directoryFlag)
            && directoryFlag.boolValue
    }
}

private struct SUPRABridgeAccess {
    let url: URL
    let requiresSecurityScope: Bool
}

private struct SUPRAValidatedBookmark {
    let url: URL
    let bookmark: Data
}

struct SUPRAObservedProcess: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let hasResult: Bool
    let stage: SUPRAProcessStage
    let startedAt: Date
    let ageSeconds: TimeInterval
    let progress: Double
    let drift: SUPRAProcessDrift
    var isBottleneck: Bool
    let statusText: String?
    let actionNicolas: String?
    let f2StatusAfter: String?
    let lg01Classification: String?
    let proofRefs: [String]

    var ageLabel: String {
        if ageSeconds < 60 { return "<1m" }
        if ageSeconds < 3600 { return "\(Int(ageSeconds / 60))m" }
        if ageSeconds < 86_400 { return "\(Int(ageSeconds / 3600))h" }
        return "\(Int(ageSeconds / 86_400))d"
    }
}

enum SUPRAProcessStage: Equatable, Sendable {
    case inFlight, materialized, frozen, blocked, failed, anomaly, unknown

    var label: String {
        switch self {
        case .inFlight: "In flight"
        case .materialized: "Materialized"
        case .frozen: "Frozen"
        case .blocked: "Blocked"
        case .failed: "Failed"
        case .anomaly: "Anomaly"
        case .unknown: "Unknown"
        }
    }

    var color: Color {
        switch self {
        case .inFlight: .blue
        case .materialized: .green
        case .frozen: .cyan
        case .blocked: .orange
        case .failed: .red
        case .anomaly: .pink
        case .unknown: .secondary
        }
    }
}

enum SUPRAProcessDrift: Equatable, Sendable {
    case none, watch, warning, critical, anomaly

    var label: String {
        switch self {
        case .none: "None"
        case .watch: "Watch"
        case .warning: "Warning"
        case .critical: "Critical"
        case .anomaly: "Anomaly"
        }
    }
}

private struct SUPRAObservedFile: Sendable {
    let id: String
    let url: URL
    let modifiedAt: Date?
    let fileSize: Int?
    let resourceIdentifier: String?
    let result: Bool
}

private struct SUPRAParsedResult: Sendable {
    let status: String?
    let actionNicolas: String?
    let f2StatusAfter: String?
    let lg01Classification: String?
    let proofRefs: [String]
}

private struct SUPRAParsedCacheEntry: Sendable {
    let modifiedAt: Date?
    let fileSize: Int?
    let resourceIdentifier: String
    let parsed: SUPRAParsedResult?
}

private struct SUPRAProcessSnapshot: Sendable {
    let bridgeAvailable: Bool
    let processes: [SUPRAObservedProcess]
    let unavailableReason: String?
}

private enum SUPRADirectoryScanResult: Sendable {
    case success([SUPRAObservedFile])
    case failure(String)
    case cancelled
}

#Preview {
    NavigationStack {
        SUPRAProcessObservatoryView()
    }
}
