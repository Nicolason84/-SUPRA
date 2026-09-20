import SwiftUI
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
    private let fileManager = FileManager.default

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
    }

    func refresh() {
        lastRefresh = .now
        guard let root = resolveBridgeRoot() else {
            bridgeAvailable = false
            sourceLabel = "LOCAL BRIDGE NOT FOUND"
            return
        }

        bridgeAvailable = true
        sourceLabel = root.path
        let inbox = descriptors(in: root.appendingPathComponent("INBOX"), result: false)
        let outbox = descriptors(in: root.appendingPathComponent("OUTBOX"), result: true)
        processes = buildProcesses(inbox: inbox, outbox: outbox)
    }

    private func resolveBridgeRoot() -> URL? {
        let home = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let candidates = [
            home.appendingPathComponent("SOL_BRIDGE", isDirectory: true),
            home.appendingPathComponent("NOVA_OS/SOL_BRIDGE", isDirectory: true),
            home.appendingPathComponent("NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1", isDirectory: true),
            home.appendingPathComponent("NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1/SOL_BRIDGE", isDirectory: true),
            home.appendingPathComponent("Applications/SUPRA.app/Contents/Resources/SUPRA_RUNTIME/SOL_BRIDGE", isDirectory: true)
        ]

        return candidates.first { candidate in
            fileManager.fileExists(atPath: candidate.appendingPathComponent("INBOX").path)
                && fileManager.fileExists(atPath: candidate.appendingPathComponent("OUTBOX").path)
        }
    }

    private func descriptors(in directory: URL, result: Bool) -> [SUPRAObservedFile] {
        let keys: Set<URLResourceKey> = [.contentModificationDateKey, .isRegularFileKey]
        guard let urls = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return urls.compactMap { url in
            guard url.pathExtension.lowercased() == "json" else { return nil }
            let values = try? url.resourceValues(forKeys: keys)
            guard values?.isRegularFile != false else { return nil }
            return SUPRAObservedFile(
                id: normalizedID(url.lastPathComponent),
                url: url,
                modifiedAt: values?.contentModificationDate,
                result: result
            )
        }
    }

    private func buildProcesses(inbox: [SUPRAObservedFile], outbox: [SUPRAObservedFile]) -> [SUPRAObservedProcess] {
        let inMap = Dictionary(uniqueKeysWithValues: inbox.map { ($0.id, $0) })
        let outMap = Dictionary(uniqueKeysWithValues: outbox.map { ($0.id, $0) })
        let ids = Set(inMap.keys).union(outMap.keys)

        var result = ids.map { id -> SUPRAObservedProcess in
            let input = inMap[id]
            let output = outMap[id]
            let parsed = output.flatMap(parseResult)
            let started = inferredDate(from: id) ?? input?.modifiedAt ?? output?.modifiedAt ?? .now
            let age = max(0, Date().timeIntervalSince(started))
            let hasInbox = input != nil
            let hasResult = output != nil
            let stage = stage(hasInbox: hasInbox, hasResult: hasResult, parsed: parsed)
            let drift = drift(hasInbox: hasInbox, hasResult: hasResult, age: age)
            let progress: Double = hasResult ? (parsed?.proofRefs.isEmpty == false ? 0.85 : 0.60) : (hasInbox ? 0.25 : 0)

            return SUPRAObservedProcess(
                id: id,
                title: title(for: id),
                hasResult: hasResult,
                stage: stage,
                startedAt: started,
                ageSeconds: age,
                progress: stage == .frozen ? 1.0 : progress,
                drift: drift,
                isBottleneck: false,
                statusText: parsed?.status,
                actionNicolas: parsed?.actionNicolas,
                f2StatusAfter: parsed?.f2StatusAfter,
                lg01Classification: parsed?.lg01Classification,
                proofRefs: parsed?.proofRefs ?? []
            )
        }

        if let oldest = result.filter({ !$0.hasResult }).max(by: { $0.ageSeconds < $1.ageSeconds })?.id {
            result = result.map {
                var item = $0
                item.isBottleneck = item.id == oldest
                return item
            }
        }

        result.sort {
            if $0.id == "F2_LG01_AUTHORITY_OR_ALIAS_GATE_20260920_1920" { return true }
            if $1.id == "F2_LG01_AUTHORITY_OR_ALIAS_GATE_20260920_1920" { return false }
            if $0.isBottleneck != $1.isBottleneck { return $0.isBottleneck }
            return $0.startedAt > $1.startedAt
        }
        return result
    }

    private func parseResult(_ file: SUPRAObservedFile) -> SUPRAParsedResult? {
        guard let data = try? Data(contentsOf: file.url),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        var merged = root
        if let bridge = root["bridge_result"] as? [String: Any],
           let reply = bridge["reply"] as? String,
           let replyData = reply.data(using: .utf8),
           let nested = try? JSONSerialization.jsonObject(with: replyData) as? [String: Any] {
            for (key, value) in nested { merged[key] = value }
        }

        return SUPRAParsedResult(
            status: string(merged["status"]),
            actionNicolas: string(merged["action_nicolas"]),
            f2StatusAfter: string(merged["f2_status_after"]),
            lg01Classification: string(merged["lg01_classification"]),
            proofRefs: merged["proof_refs"] as? [String] ?? []
        )
    }

    private func stage(hasInbox: Bool, hasResult: Bool, parsed: SUPRAParsedResult?) -> SUPRAProcessStage {
        if hasResult && !hasInbox { return .anomaly }
        guard hasResult else { return hasInbox ? .inFlight : .unknown }
        let status = (parsed?.status ?? "").uppercased()
        let f2 = (parsed?.f2StatusAfter ?? "").uppercased()
        if status.contains("FROZEN") || f2.contains("FROZEN") { return .frozen }
        if status.contains("BLOCKED") || status.contains("HUMAN_GATE") { return .blocked }
        if status.contains("FAIL") { return .failed }
        return .materialized
    }

    private func drift(hasInbox: Bool, hasResult: Bool, age: TimeInterval) -> SUPRAProcessDrift {
        if hasResult && !hasInbox { return .anomaly }
        guard hasInbox && !hasResult else { return .none }
        if age >= 3600 { return .critical }
        if age >= 900 { return .warning }
        if age >= 300 { return .watch }
        return .none
    }

    private func normalizedID(_ filename: String) -> String {
        filename
            .replacingOccurrences(of: ".result.json", with: "")
            .replacingOccurrences(of: ".json", with: "")
    }

    private func inferredDate(from text: String) -> Date? {
        let pattern = "(20\\d{6})[_-](\\d{4,6})"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..<text.endIndex, in: text)),
              let dateRange = Range(match.range(at: 1), in: text),
              let timeRange = Range(match.range(at: 2), in: text) else { return nil }

        let datePart = String(text[dateRange])
        var timePart = String(text[timeRange])
        if timePart.count == 4 { timePart += "00" }

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
}

struct SUPRAObservedProcess: Identifiable, Equatable {
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

enum SUPRAProcessStage: Equatable {
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

enum SUPRAProcessDrift: Equatable {
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

private struct SUPRAObservedFile {
    let id: String
    let url: URL
    let modifiedAt: Date?
    let result: Bool
}

private struct SUPRAParsedResult {
    let status: String?
    let actionNicolas: String?
    let f2StatusAfter: String?
    let lg01Classification: String?
    let proofRefs: [String]
}

#Preview {
    NavigationStack {
        SUPRAProcessObservatoryView()
    }
}
