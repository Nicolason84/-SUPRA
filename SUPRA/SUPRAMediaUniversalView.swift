import SwiftUI
import Combine
import AppKit
import WebKit
import AVKit
import PDFKit
import CAnnoNicoContracts

struct SUPRAMediaHeroContext: Identifiable, Equatable {
    let id: String
    let objectID: String
    let objectType: String
    let title: String
    let subtitle: String
    let sourceURL: URL?
    let origin: String
    let lineageRefs: [String]
    let initialNote: String

    init(
        id: String = UUID().uuidString,
        objectID: String,
        objectType: String,
        title: String,
        subtitle: String = "",
        sourceURL: URL? = nil,
        origin: String = "ojO",
        lineageRefs: [String] = [],
        initialNote: String = ""
    ) {
        self.id = id
        self.objectID = objectID
        self.objectType = objectType
        self.title = title
        self.subtitle = subtitle
        self.sourceURL = sourceURL
        self.origin = origin
        self.lineageRefs = lineageRefs
        self.initialNote = initialNote
    }
}

@MainActor
final class SUPRAMediaHeroRouter: ObservableObject {
    static let shared = SUPRAMediaHeroRouter()
    @Published var context: SUPRAMediaHeroContext?

    func present(_ context: SUPRAMediaHeroContext) { self.context = context }
    func dismiss() { context = nil }
}

private enum SUPRAMediaProvider: String {
    case youtube = "YOUTUBE"
    case figma = "FIGMA"
    case canva = "CANVA"
    case close = "CLOSE"
    case web = "WEB"
    case local = "LOCAL"

    static func resolve(_ url: URL) -> Self {
        if url.isFileURL { return .local }
        let host = (url.host ?? "").lowercased()
        if host.contains("youtube.com") || host == "youtu.be" { return .youtube }
        if host.contains("figma.com") { return .figma }
        if host.contains("canva.com") || host.contains("canva.link") { return .canva }
        if host.contains("close.com") { return .close }
        return .web
    }

    var guardrail: String {
        switch self {
        case .youtube:
            return "URL identity is not proof of watched/transcribed content."
        case .figma:
            return "Do not claim Figma layer/design access unless runtime connector evidence proves it."
        case .canva:
            return "Do not claim Canva page/brand content access unless runtime connector evidence proves it."
        case .close:
            return "Treat Close as CRM object context, not media content; never mutate CRM from Media Hero."
        case .web:
            return "Treat the page URL as source identity until accessible content is evidenced."
        case .local:
            return "Local file rendering proves file access, not semantic interpretation."
        }
    }
}

private enum SUPRAMediaSurfaceKind: String {
    case youtube = "YOUTUBE"
    case web = "WEB"
    case video = "VIDEO"
    case audio = "AUDIO"
    case image = "IMAGE"
    case pdf = "PDF"
    case file = "FILE"

    var symbol: String {
        switch self {
        case .youtube: return "play.rectangle.fill"
        case .web: return "globe"
        case .video: return "film.fill"
        case .audio: return "waveform"
        case .image: return "photo.fill"
        case .pdf: return "doc.richtext.fill"
        case .file: return "doc.fill"
        }
    }

    nonisolated static func resolve(_ url: URL) -> Self {
        let host = (url.host ?? "").lowercased()
        if host.contains("youtube.com") || host == "youtu.be" {
            return .youtube
        }

        switch url.pathExtension.lowercased() {
        case "mov", "mp4", "m4v", "webm", "avi", "mkv":
            return .video
        case "mp3", "m4a", "aac", "wav", "flac":
            return .audio
        case "jpg", "jpeg", "png", "gif", "webp", "heic":
            return .image
        case "pdf":
            return .pdf
        default:
            return url.isFileURL ? .file : .web
        }
    }
}

private enum SUPRAMediaRuntimeAction: String, CaseIterable, Identifiable {
    case understand = "UNDERSTAND"
    case evidence = "EVIDENCE"
    case lineage = "LINEAGE"
    case memoryReturn = "MEMORY_RETURN"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .understand: return "Understand"
        case .evidence: return "Evidence"
        case .lineage: return "Lineage"
        case .memoryReturn: return "Memory return"
        }
    }

    var subtitle: String {
        switch self {
        case .understand: return "Read only what is actually accessible."
        case .evidence: return "Separate proof from inference and unknown."
        case .lineage: return "Relate source to existing canon and twins."
        case .memoryReturn: return "Prepare a governed return packet."
        }
    }

    var symbol: String {
        switch self {
        case .understand: return "sparkles.rectangle.stack"
        case .evidence: return "checkmark.seal.fill"
        case .lineage: return "point.3.connected.trianglepath.dotted"
        case .memoryReturn: return "brain.head.profile"
        }
    }

    var mode: ChatMode {
        switch self {
        case .understand, .lineage: return .ask
        case .evidence, .memoryReturn: return .plan
        }
    }

    var contract: String {
        switch self {
        case .understand:
            return """
            Determine what can be understood from the selected source using only accessible runtime evidence.
            Distinguish source identity, directly accessible content, context, inference and unknown.
            Never claim playback, transcription, metadata or semantics that were not actually observed.
            """
        case .evidence:
            return """
            Build a bounded evidence packet from what is actually accessible.
            For every material claim, return provenance or mark EVIDENCE_NEEDED.
            Preserve the original source identity and do not silently transform a user note into fact.
            Reuse the existing ProofGraph and USCRC owners when they are RECOVERED; do not create a parallel proof chain.
            If SMCA / Media Coherence Check is only PARTIAL or runtime is unproven, report MCC_RUNTIME_UNPROVEN instead of simulating structural analysis.
            """
        case .lineage:
            return """
            Relate the source to EXISTING Puchero memory, Atlas, twins, missions, products and evidence when proven.
            Reuse existing identities. Do not create a parallel canon, duplicate twin or invented relationship.
            Return MATCHED_EXISTING, POSSIBLE_MATCH and UNRESOLVED separately.
            """
        case .memoryReturn:
            return """
            Prepare a governed memory-return candidate.
            Do not write canon silently. Do not mutate authority.
            Separate FACTS, USER_NOTE, INFERENCES, UNKNOWN, EVIDENCE_NEEDED, MEMORY_RETURN_CANDIDATE and NEXT_ACTION.
            """
        }
    }
}

struct SUPRAMediaUniversalView: View {
    @ObservedObject private var liveStore = SUPRAProcessObservatoryStore.shared
    @ObservedObject private var heroRouter = SUPRAMediaHeroRouter.shared

    @State private var address = ""
    @State private var sourceURL: URL?
    @State private var note = ""
    @State private var runtimeOutput = ""
    @State private var runtimeState = "IDLE"
    @State private var runtimeActionLabel = "NONE"
    @State private var lastError: String?
    @State private var activeAction: SUPRAMediaRuntimeAction?

    private let runtime = SUPRAChatRuntimeAdapter()
    private let integration = SUPRACAnnoNicoIntegration.snapshot()
    private let invocationOrigin: String
    private let heroContext: SUPRAMediaHeroContext?

    init(initialURL: URL? = nil, origin: String = "ojO") {
        invocationOrigin = origin
        heroContext = nil
        _address = State(initialValue: initialURL?.absoluteString ?? "")
        _sourceURL = State(initialValue: initialURL)
        _runtimeState = State(initialValue: initialURL == nil ? "IDLE" : "SOURCE_READY")
    }

    init(context: SUPRAMediaHeroContext) {
        invocationOrigin = context.origin
        heroContext = context
        _address = State(initialValue: context.sourceURL?.absoluteString ?? "")
        _sourceURL = State(initialValue: context.sourceURL)
        _note = State(initialValue: context.initialNote)
        _runtimeState = State(initialValue: context.sourceURL == nil ? "CONTEXT_READY" : "SOURCE_READY")
    }

    private var sourceKind: SUPRAMediaSurfaceKind? {
        sourceURL.map(SUPRAMediaSurfaceKind.resolve)
    }

    private var sourceProvider: SUPRAMediaProvider? {
        sourceURL.map(SUPRAMediaProvider.resolve)
    }

    private var mediaReference: CAnnoNicoSourceReference? {
        integration.references.first(where: { $0.id == "video.swap" })
    }

    private var uscrcProofGraphReference: CAnnoNicoSourceReference? {
        integration.references.first(where: { $0.id == "uscrc.proofgraph.canon" })
    }

    private var uscrcContinuityReference: CAnnoNicoSourceReference? {
        integration.references.first(where: { $0.id == "uscrc.goldenpath" })
    }

    private var proofGraphRuntimeReference: CAnnoNicoSourceReference? {
        integration.references.first(where: { $0.id == "proofgraph.runtime" })
    }

    private var uscrcProofGraphProofReference: CAnnoNicoSourceReference? {
        integration.references.first(where: { $0.id == "uscrc.proofgraph.proof" })
    }

    private var proofGraphRuntimeStateReference: CAnnoNicoSourceReference? {
        integration.references.first(where: { $0.id == "proofgraph.runtime.state" })
    }

    private var proofGraphRuntimeHealthReference: CAnnoNicoSourceReference? {
        integration.references.first(where: { $0.id == "proofgraph.runtime.health" })
    }

    private var smcaReference: CAnnoNicoSourceReference? {
        integration.references.first(where: { $0.id == "smca.media.coherence" })
    }

    private var youtubeDescriptor: ExternalConnectorDescriptor? {
        ExternalConnectorCatalog.descriptor(id: "youtube")
    }

    private var canonicalReferences: [CAnnoNicoSourceReference] {
        let rank = [
            "puchero.memory",
            "uscrc.proofgraph.canon",
            "uscrc.goldenpath",
            "proofgraph.runtime",
            "uscrc.proofgraph.proof",
            "proofgraph.runtime.state",
            "proofgraph.runtime.health",
            "smca.media.coherence",
            "atlas.runtime",
            "twin.registry",
            "twin.environment.fabric",
            "twin.system.file",
            "video.swap"
        ]
        return integration.references.sorted {
            (rank.firstIndex(of: $0.id) ?? rank.count)
                < (rank.firstIndex(of: $1.id) ?? rank.count)
        }
    }

    private var liveProcesses: [SUPRAObservedProcess] {
        Array(
            liveStore.processes
                .filter { $0.stage != .historical }
                .prefix(4)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                sourceControls
                runtimeActions

                HStack(alignment: .top, spacing: 16) {
                    mediaStage
                        .frame(maxWidth: .infinity, minHeight: 560)

                    contextRail
                        .frame(width: 330)
                }
                if !runtimeOutput.isEmpty || lastError != nil {
                    runtimeCard
                }
            }
            .padding(24)
            .frame(maxWidth: 1600, alignment: .leading)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.08),
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .task {
            liveStore.start()
            liveStore.refresh(force: true)
        }
    }

    private var hero: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "play.rectangle.on.rectangle.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.purple)
                .frame(width: 64, height: 64)
                .background(Color.purple.opacity(0.11), in: RoundedRectangle(cornerRadius: 18))
            VStack(alignment: .leading, spacing: 5) {
                Text("ŒIL · UNIVERSAL MEDIA")
                    .font(.caption.weight(.heavy))
                    .tracking(1.4)
                    .foregroundStyle(.purple)
                Text("Voir la source. Comprendre le contexte. Retourner la preuve.")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Text("Playback + provenance + notes + evidence return. La source reste la source; SUPRA ajoute le contexte et la circulation.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Label("AUTO-ADAPTIVE", systemImage: "viewfinder")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.purple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.purple.opacity(0.09), in: Capsule())

                if let heroContext {
                    Text("\(heroContext.objectType) · \(heroContext.objectID)")
                        .font(.caption2.monospaced().weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Button("Close Hero", systemImage: "xmark.circle.fill") {
                        heroRouter.dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(20)
        .supraCard(radius: 22, strokeOpacity: 0.10)
    }

    private var sourceControls: some View {
        HStack(spacing: 10) {
            TextField("YouTube, web or media URL…", text: $address)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("media-source-address")
                .onSubmit(resolveAddress)

            Button("Load", systemImage: "arrow.right.circle.fill") {
                resolveAddress()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("media-source-load")

            Button("Clipboard", systemImage: "doc.on.clipboard") {
                if let string = NSPasteboard.general.string(forType: .string) {
                    address = string
                    resolveAddress()
                }
            }
            .buttonStyle(.bordered)

            Button("File…", systemImage: "folder") {
                chooseFile()
            }
            .buttonStyle(.bordered)

            if let sourceURL {
                Button("Open source", systemImage: "arrow.up.right.square") {
                    NSWorkspace.shared.open(sourceURL)
                }
                .buttonStyle(.bordered)
            }

            Button("Clear", systemImage: "xmark.circle") {
                sourceURL = nil
                address = ""
                note = ""
                runtimeOutput = ""
                runtimeState = "IDLE"
                runtimeActionLabel = "NONE"
                lastError = nil
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var mediaStage: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("MEDIA HERO", systemImage: sourceKind?.symbol ?? "play.rectangle.fill")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.purple)
                Spacer()
                Text(
                    sourceURL == nil
                        ? "NO SOURCE"
                        : "\(sourceProvider?.rawValue ?? "UNKNOWN") · \(sourceKind?.rawValue ?? "UNKNOWN")"
                )
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(sourceURL == nil ? .orange : .green)
            }

            if let sourceURL {
                adaptiveRenderer(for: sourceURL)
                    .frame(minHeight: 505)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
            } else {
                ContentUnavailableView(
                    "Aucun média sélectionné",
                    systemImage: "play.rectangle.on.rectangle",
                    description: Text("Collez une URL ou choisissez un fichier. Aucun player factice n’est affiché.")
                )
                .frame(maxWidth: .infinity, minHeight: 505)
            }
        }
        .padding(16)
        .supraCard(radius: 20, strokeOpacity: 0.08)
    }

    private var runtimeActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("RUNTIME ACTIONS", systemImage: "bolt.horizontal.circle.fill")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.purple)
                Spacer()
                Text("SOURCE → RUNTIME → EVIDENCE → MEMORY → CANON")
                    .font(.caption2.monospaced().weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 220), spacing: 10)],
                spacing: 10
            ) {
                ForEach(SUPRAMediaRuntimeAction.allCases) { action in
                    Button {
                        Task { await runAction(action) }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: action.symbol)
                                .font(.title3)
                                .foregroundStyle(.purple)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(
                                    activeAction == action
                                        ? "\(action.title)…"
                                        : action.title
                                )
                                .font(.headline)
                                Text(action.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, minHeight: 76, alignment: .topLeading)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("media-action-" + action.rawValue.lowercased())
                    .accessibilityLabel(action.title)
                    .disabled(sourceURL == nil || activeAction != nil)
                }
            }
        }
        .padding(16)
        .supraCard(radius: 18, strokeOpacity: 0.07)
    }

    private var contextRail: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let heroContext {
                contextBlock("SELECTED OJO OBJECT", symbol: "scope") {
                    Text(heroContext.title)
                        .font(.headline)
                    if !heroContext.subtitle.isEmpty {
                        Text(heroContext.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    truthRow("Type", heroContext.objectType)
                    truthRow("ID", heroContext.objectID)
                    truthRow("Origin", heroContext.origin)
                    if !heroContext.lineageRefs.isEmpty {
                        Divider()
                        ForEach(heroContext.lineageRefs, id: \.self) { ref in
                            Text(ref)
                                .font(.caption2.monospaced())
                                .textSelection(.enabled)
                        }
                    }
                }
            }

            contextBlock("SOURCE", symbol: "link") {
                Text(sourceURL?.absoluteString ?? "UNSELECTED")
                    .font(.caption.monospaced())
                    .textSelection(.enabled)
                    .lineLimit(4)
                if let sourceProvider {
                    truthRow("Provider", sourceProvider.rawValue)
                    truthRow("Renderer", sourceKind?.rawValue ?? "UNKNOWN")
                    Text(sourceProvider.guardrail)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            contextBlock("EVIDENCE · CONNECTION TRUTH", symbol: "checkmark.shield.fill") {
                if let youtubeDescriptor {
                    truthRow("YouTube", youtubeDescriptor.status.rawValue)
                    truthRow(
                        "Proof",
                        ExternalConnectionProofLedger.freshness(for: youtubeDescriptor).rawValue
                    )
                } else {
                    truthRow("YouTube", "UNPROVEN")
                }

                truthRow(
                    "Media render",
                    mediaReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
                )
                truthRow(
                    "USCRC · ProofGraph canon",
                    uscrcProofGraphReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
                )
                truthRow(
                    "USCRC continuity",
                    uscrcContinuityReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
                )
                truthRow(
                    "ProofGraph runtime",
                    proofGraphRuntimeReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
                )
                truthRow(
                    "USCRC canon proof",
                    uscrcProofGraphProofReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
                )
                truthRow(
                    "ProofGraph state",
                    proofGraphRuntimeStateReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
                )
                truthRow(
                    "ProofGraph health",
                    proofGraphRuntimeHealthReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
                )
                truthRow(
                    "SMCA / MCC runtime",
                    smcaReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
                )
                Text("SMCA/MCC remains structural-analysis only; PARTIAL means the specification is known but executable runtime is not proven.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            contextBlock("LIVE OJO CONTEXT", symbol: "dot.radiowaves.left.and.right") {
                truthRow("Bridge", liveStore.bridgeAvailable ? "CONNECTED" : "UNAVAILABLE")
                truthRow("Flow", liveStore.momentumLabel)
                truthRow("In flight", "\(liveStore.inFlightCount)")
                truthRow("Materialized", "\(liveStore.materializedCount)")

                if liveProcesses.isEmpty {
                    Text("No current non-historical process projected.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Divider()
                    ForEach(liveProcesses, id: \.id) { process in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(process.title)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                            Text("\(process.stage.label) · \(process.ageLabel) · \(process.id)")
                                .font(.caption2.monospaced())
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }

            contextBlock("LINEAGE · CANONICAL", symbol: "point.3.connected.trianglepath.dotted") {
                Text("Existing owners only · no parallel canon")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)

                ForEach(canonicalReferences, id: \.id) { reference in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(reference.id)
                                .font(.caption.monospaced().weight(.semibold))
                            Spacer()
                            Text(reference.state.rawValue.uppercased())
                                .font(.caption2.monospaced().weight(.heavy))
                                .foregroundStyle(
                                    reference.state == .recovered ? .green : .orange
                                )
                        }
                        Text(reference.role)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            contextBlock("CIRCULATION", symbol: "arrow.triangle.2.circlepath") {
                Text("SOURCE → CONTEXT → EVIDENCE → NOTE → MEMORY RETURN → CANNONICO")
                    .font(.caption.monospaced().weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }

            contextBlock("MEMORY · NOTE / OBSERVATION", symbol: "square.and.pencil") {
                TextEditor(text: $note)
                    .font(.callout)
                    .frame(minHeight: 115)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))

                Button {
                    Task { await runAction(.memoryReturn) }
                } label: {
                    Label(
                        activeAction == .memoryReturn ? "Preparing…" : "Prepare memory return",
                        systemImage: "brain.head.profile"
                    )
                }
                .buttonStyle(.borderedProminent)
                .disabled(sourceURL == nil || activeAction != nil)
            }

            contextBlock("GUARDRAIL", symbol: "person.badge.key.fill") {
                Text("No silent canonical write. No invented transcript, metadata or engagement. Human validates authority-changing memory.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var runtimeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(
                    runtimeActionLabel == "MEMORY_RETURN"
                        ? "MEMORY RETURN PACKET"
                        : "MEDIA RUNTIME RESULT",
                    systemImage: "shippingbox.fill"
                )
                    .font(.headline)
                Spacer()
                Text("\(runtimeActionLabel) · \(runtimeState)")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(lastError == nil ? .green : .red)
            }

            if let lastError {
                Text(lastError)
                    .font(.callout)
                    .foregroundStyle(.red)
            } else {
                Text(runtimeOutput)
                    .font(.callout.monospaced())
                    .textSelection(.enabled)
            }

            Button("Copy packet", systemImage: "doc.on.doc") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(runtimeOutput, forType: .string)
            }
            .buttonStyle(.bordered)
            .disabled(runtimeOutput.isEmpty)
        }
        .padding(18)
        .supraCard()
    }

    private func contextBlock<Content: View>(
        _ title: String,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Label(title, systemImage: symbol)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(.purple)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .supraCard(radius: 16, strokeOpacity: 0.06)
    }

    private func truthRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
            Spacer()
            Text(value)
                .font(.caption2.monospaced().weight(.semibold))
                .foregroundStyle(truthTint(value))
        }
    }

    private func truthTint(_ value: String) -> Color {
        let upper = value.uppercased()
        if upper.contains("CONNECTED")
            || upper.contains("RECOVERED")
            || upper.contains("FRESH")
            || upper == "PASS"
            || upper == "CLEAR"
            || upper == "PROGRESSING"
            || upper == "ACCELERATING" {
            return .green
        }
        if upper.contains("ERROR")
            || upper.contains("FAILED")
            || upper.contains("UNAVAILABLE")
            || upper.contains("CRITICAL") {
            return .red
        }
        if upper.contains("UNPROVEN")
            || upper.contains("UNRESOLVED")
            || upper.contains("PARTIAL")
            || upper.contains("STALE")
            || upper.contains("BLOCK") {
            return .orange
        }
        return .secondary
    }
    private func resolveAddress() {
        let raw = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else {
            sourceURL = nil
            lastError = "Source vide."
            return
        }

        let resolved: URL?
        if raw.hasPrefix("/") {
            resolved = URL(fileURLWithPath: raw)
        } else if let direct = URL(string: raw), direct.scheme != nil {
            resolved = direct
        } else {
            resolved = URL(string: "https://" + raw)
        }

        guard let resolved else {
            lastError = "URL invalide."
            return
        }

        sourceURL = resolved
        address = resolved.absoluteString
        runtimeOutput = ""
        runtimeState = "SOURCE_READY"
        lastError = nil
    }

    private func chooseFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.message = "Choose a media or document source for ojO."

        guard panel.runModal() == .OK, let url = panel.url else { return }
        sourceURL = url
        address = url.path
        runtimeOutput = ""
        runtimeState = "SOURCE_READY"
        lastError = nil
    }

    @MainActor
    private func runAction(_ action: SUPRAMediaRuntimeAction) async {
        guard let sourceURL, activeAction == nil else { return }

        let originConversationID = SUPRAConversationLineage.canonicalID()
        activeAction = action
        runtimeActionLabel = action.rawValue
        runtimeState = "RUNNING"
        runtimeOutput = ""
        lastError = nil
        liveStore.refresh(force: true)
        defer { activeAction = nil }

        let mediaState = mediaReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
        let uscrcCanonState = uscrcProofGraphReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
        let uscrcContinuityState = uscrcContinuityReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
        let proofGraphRuntimeState = proofGraphRuntimeReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
        let uscrcProofState = uscrcProofGraphProofReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
        let proofGraphStateState = proofGraphRuntimeStateReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
        let proofGraphHealthState = proofGraphRuntimeHealthReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
        let smcaState = smcaReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
        let youtubeState = youtubeDescriptor?.status.rawValue ?? "UNPROVEN"
        let noteValue = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let processContext = liveProcesses.map {
            let proof = $0.proofRefs.prefix(3).joined(separator: ",")
            return "\($0.id)|stage=\($0.stage.label)|status=\($0.statusText ?? "UNKNOWN")|proof=\(proof.isEmpty ? "NONE" : proof)"
        }.joined(separator: "\n")
        let canonContext = canonicalReferences.map {
            let path = $0.path ?? "NONE"
            let outputs = $0.outputs.joined(separator: ",")
            let capabilities = $0.capabilities.joined(separator: ",")
            return "\($0.id)|state=\($0.state.rawValue.uppercased())|role=\($0.role)|path=\(path)|outputs=\(outputs)|capabilities=\(capabilities)"
        }.joined(separator: "\n")

        let prompt = """
        OJO_UNIVERSAL_MEDIA_V2
        AUTHORITY=NICOLAS
        ACTION=\(action.rawValue)
        INVOCATION_ORIGIN=\(invocationOrigin)
        ORIGIN_CONVERSATION_ID=\(originConversationID)
        ORIGIN_CHAT=\(originConversationID)
        ORIGIN_CHAT_EXACT_REQUIRED=YES
        READ_EXISTING_FIRST=YES
        NO_PARALLEL_ENGINE=YES

        SOURCE=\(sourceURL.absoluteString)
        SOURCE_KIND=\(sourceKind?.rawValue ?? "UNKNOWN")
        SOURCE_PROVIDER=\(sourceProvider?.rawValue ?? "UNKNOWN")
        PROVIDER_GUARDRAIL=\(sourceProvider?.guardrail ?? "No provider-specific contract")
        YOUTUBE_CONNECTION=\(youtubeState)
        MEDIA_RENDER_CAPABILITY=\(mediaState)
        USCRC_PROOFGRAPH_CANON=\(uscrcCanonState)
        USCRC_CONTINUITY=\(uscrcContinuityState)
        PROOFGRAPH_RUNTIME=\(proofGraphRuntimeState)
        USCRC_PROOFGRAPH_CANON_PROOF=\(uscrcProofState)
        PROOFGRAPH_RUNTIME_STATE=\(proofGraphStateState)
        PROOFGRAPH_RUNTIME_HEALTH=\(proofGraphHealthState)
        SMCA_MCC_RUNTIME=\(smcaState)
        HUMAN_NOTE=\(noteValue.isEmpty ? "NONE" : noteValue)
        OJO_OBJECT_ID=\(heroContext?.objectID ?? "UNSCOPED")
        OJO_OBJECT_TYPE=\(heroContext?.objectType ?? "UNSCOPED")
        OJO_OBJECT_TITLE=\(heroContext?.title ?? "UNSCOPED")
        OJO_OBJECT_LINEAGE=\(heroContext?.lineageRefs.joined(separator: ",") ?? "NONE")

        LIVE_RUNTIME_CONTEXT:
        \(processContext.isEmpty ? "NONE" : processContext)

        EXISTING_CANNONICO_REFERENCES:
        \(canonContext.isEmpty ? "NONE" : canonContext)

        ACTION_CONTRACT:
        \(action.contract)

        GLOBAL_GUARDRAILS:
        - Treat the URL as source identity, not proof that media contents were observed.
        - Do not claim you watched, transcribed or verified media content unless runtime evidence proves it.
        - Never claim playback, transcript, metadata, comments, engagement or semantics unless actually accessible and evidenced.
        - RENDER is not STRUCTURAL_ANALYSIS. A rendered source is never automatically SMCA/MCC-analysed.
        - Reuse existing USCRC, ProofGraph, Puchero, Atlas, Twins, VideoSwap, Evidence and Memory owners when present.
        - If USCRC / ProofGraph is RECOVERED, resolve lineage against it before proposing any new proof object.
        - If SMCA_MCC_RUNTIME is PARTIAL or UNRESOLVED, return MCC_RUNTIME_UNPROVEN and EVIDENCE_NEEDED; never fabricate a coherence result.
        - A coherence indicator is structural only; never call it truth_score or authenticity_score.
        - No silent canonical write, no invented relation, no authority mutation.
        - USER_NOTE remains attributed to Nicolas unless independently evidenced.

        RETURN:
        ACTION
        ACCESS_PROOF
        FACTS
        USER_NOTE
        INFERENCES
        UNKNOWN
        EVIDENCE_REFS
        EXISTING_LINEAGE
        EVIDENCE_NEEDED
        MEMORY_RETURN_CANDIDATE
        NEXT_ACTION
        """

        let objectiveID = makeMediaObjectiveID(action)

        do {
            runtimeState = "RECOVERING"
            try await runtime.checkHealth()
            runtimeState = "RUNNING"

            let correlatedPrompt = """
            MEDIA_OBJECTIVE_ID=\(objectiveID)
            ORIGIN_CONVERSATION_ID=\(originConversationID)
            ORIGIN_CHAT=\(originConversationID)
            MATERIALIZE_VIA_EXISTING_BRIDGE=YES
            RUNTIME_CORRELATION_REQUIRED=YES

            \(prompt)
            """

            SUPRAConversationLineage.append(
                role: .user,
                mode: action.mode,
                content: "MEDIA_ACTION=\(action.rawValue)\nSOURCE=\(sourceURL.absoluteString)",
                originConversationID: originConversationID
            )

            let response = try await runtime.execute(
                prompt: correlatedPrompt,
                mode: action.mode
            )
            runtimeOutput = response
            SUPRAConversationLineage.append(
                role: .runtime,
                mode: action.mode,
                content: "MEDIA_OBJECTIVE_ID=\(objectiveID)\nORIGIN_CONVERSATION_ID=\(originConversationID)\n\(response)",
                originConversationID: originConversationID
            )
            runtimeState = action == .memoryReturn ? "PREPARED" : "COMPLETE"
            liveStore.refresh(force: true)
        } catch {
            runtimeOutput = ""
            runtimeState = "ERROR"
            lastError = error.localizedDescription
            liveStore.refresh(force: true)
        }
    }

    private func makeMediaObjectiveID(_ action: SUPRAMediaRuntimeAction) -> String {
        let stamp = Self.mediaStamp.string(from: Date())
        return "OJO_MEDIA_\(action.rawValue)_\(stamp)_\(UUID().uuidString.prefix(8))"
    }

    private static let mediaStamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()

    @ViewBuilder
    private func adaptiveRenderer(for url: URL) -> some View {
        switch SUPRAMediaSurfaceKind.resolve(url) {
        case .youtube:
            SUPRAMediaWebView(url: playbackURL(for: url))
        case .web:
            SUPRAMediaWebView(url: url)
        case .video, .audio:
            SUPRAMediaAVPlayerView(url: url)
        case .image:
            SUPRAMediaImageView(url: url)
        case .pdf:
            if url.isFileURL {
                SUPRAMediaPDFView(url: url)
            } else {
                SUPRAMediaWebView(url: url)
            }
        case .file:
            SUPRAMediaWebView(url: url)
        }
    }

    private func playbackURL(for url: URL) -> URL {
        guard SUPRAMediaSurfaceKind.resolve(url) == .youtube,
              let id = youtubeVideoID(from: url),
              let embed = URL(string: "https://www.youtube.com/embed/\(id)?rel=0")
        else {
            return url
        }
        return embed
    }

    private func youtubeVideoID(from url: URL) -> String? {
        let host = (url.host ?? "").lowercased()
        let parts = url.pathComponents.filter { $0 != "/" }

        if host == "youtu.be" {
            return parts.first
        }

        if host.contains("youtube.com") {
            if let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "v" })?.value {
                return query
            }

            if let marker = parts.firstIndex(where: { $0 == "shorts" || $0 == "embed" }),
               parts.indices.contains(marker + 1) {
                return parts[marker + 1]
            }
        }

        return nil
    }
}

private struct SUPRAMediaWebView: NSViewRepresentable {
    let url: URL

    final class Coordinator {
        var lastURL: URL?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let view = WKWebView(frame: .zero, configuration: configuration)
        view.allowsMagnification = true
        return view
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.lastURL != url else { return }
        context.coordinator.lastURL = url

        if url.isFileURL {
            webView.loadFileURL(
                url,
                allowingReadAccessTo: url.deletingLastPathComponent()
            )
        } else {
            webView.load(URLRequest(url: url))
        }
    }

    static func dismantleNSView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.stopLoading()
    }
}
private struct SUPRAMediaAVPlayerView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView(frame: .zero)
        view.controlsStyle = .floating
        view.videoGravity = .resizeAspect
        view.player = AVPlayer(url: url)
        return view
    }

    func updateNSView(_ view: AVPlayerView, context: Context) {
        guard let current = (view.player?.currentItem?.asset as? AVURLAsset)?.url,
              current == url else {
            view.player = AVPlayer(url: url)
            return
        }
    }

    static func dismantleNSView(_ view: AVPlayerView, coordinator: ()) {
        view.player?.pause()
        view.player = nil
    }
}

private struct SUPRAMediaImageView: View {
    let url: URL

    var body: some View {
        Group {
            if url.isFileURL, let image = NSImage(contentsOf: url) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        ContentUnavailableView("Image unavailable", systemImage: "photo.badge.exclamationmark")
                    case .empty:
                        ProgressView("Loading image…")
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.03))
    }
}

private struct SUPRAMediaPDFView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> PDFView {
        let view = PDFView(frame: .zero)
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.document = PDFDocument(url: url)
        return view
    }

    func updateNSView(_ view: PDFView, context: Context) {
        guard view.document?.documentURL != url else { return }
        view.document = PDFDocument(url: url)
    }
}
