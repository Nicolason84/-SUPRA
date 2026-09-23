import SwiftUI
import AppKit
import WebKit
import CAnnoNicoContracts

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

struct SUPRAMediaUniversalView: View {
    @State private var address = ""
    @State private var sourceURL: URL?
    @State private var note = ""
    @State private var runtimeOutput = ""
    @State private var runtimeState = "IDLE"
    @State private var lastError: String?
    @State private var isPreparingReturn = false

    private let runtime = SUPRAChatRuntimeAdapter()
    private let integration = SUPRACAnnoNicoIntegration.snapshot()

    private var sourceKind: SUPRAMediaSurfaceKind? {
        sourceURL.map(SUPRAMediaSurfaceKind.resolve)
    }

    private var mediaReference: CAnnoNicoSourceReference? {
        integration.references.first(where: { $0.id == "video.swap" })
    }

    private var youtubeDescriptor: ExternalConnectorDescriptor? {
        ExternalConnectorCatalog.descriptor(id: "youtube")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                sourceControls

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

            Label("AUTO-ADAPTIVE", systemImage: "viewfinder")
                .font(.caption.weight(.heavy))
                .foregroundStyle(.purple)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.purple.opacity(0.09), in: Capsule())
        }
        .padding(20)
        .supraCard(radius: 22, strokeOpacity: 0.10)
    }

    private var sourceControls: some View {
        HStack(spacing: 10) {
            TextField("YouTube, web or media URL…", text: $address)
                .textFieldStyle(.roundedBorder)
                .onSubmit(resolveAddress)

            Button("Load", systemImage: "arrow.right.circle.fill") {
                resolveAddress()
            }
            .buttonStyle(.borderedProminent)

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
                Text(sourceKind?.rawValue ?? "NO SOURCE")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(sourceURL == nil ? .orange : .green)
            }

            if let sourceURL {
                SUPRAMediaWebView(url: playbackURL(for: sourceURL))
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

    private var contextRail: some View {
        VStack(alignment: .leading, spacing: 14) {
            contextBlock("SOURCE", symbol: "link") {
                Text(sourceURL?.absoluteString ?? "UNSELECTED")
                    .font(.caption.monospaced())
                    .textSelection(.enabled)
                    .lineLimit(4)
            }

            contextBlock("CONNECTION TRUTH", symbol: "checkmark.shield.fill") {
                if let youtubeDescriptor {
                    truthRow("YouTube", youtubeDescriptor.status.rawValue)
                    truthRow(
                        "Proof",
                        ExternalConnectionProofLedger.freshness(for: youtubeDescriptor).rawValue
                    )
                } else {
                    truthRow("YouTube", "UNPROVEN")
                }

                if let mediaReference {
                    truthRow("Media capability", mediaReference.state.rawValue.uppercased())
                } else {
                    truthRow("Media capability", "UNRESOLVED")
                }
            }

            contextBlock("CIRCULATION", symbol: "arrow.triangle.2.circlepath") {
                Text("SOURCE → CONTEXT → EVIDENCE → NOTE → MEMORY RETURN → CANNONICO")
                    .font(.caption.monospaced().weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }

            contextBlock("NOTE / OBSERVATION", symbol: "square.and.pencil") {
                TextEditor(text: $note)
                    .font(.callout)
                    .frame(minHeight: 115)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))

                Button {
                    Task { await prepareMemoryReturn() }
                } label: {
                    Label(
                        isPreparingReturn ? "Preparing…" : "Prepare memory return",
                        systemImage: "brain.head.profile"
                    )
                }
                .buttonStyle(.borderedProminent)
                .disabled(sourceURL == nil || isPreparingReturn)
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
                Label("MEMORY RETURN PACKET", systemImage: "shippingbox.fill")
                    .font(.headline)
                Spacer()
                Text(runtimeState)
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
                .foregroundStyle(
                    value.contains("CONNECTED") || value.contains("RECOVERED") || value.contains("FRESH")
                        ? .green
                        : .orange
                )
        }
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
    private func prepareMemoryReturn() async {
        guard let sourceURL else { return }

        isPreparingReturn = true
        runtimeState = "RUNNING"
        lastError = nil
        defer { isPreparingReturn = false }

        let mediaState = mediaReference?.state.rawValue.uppercased() ?? "UNRESOLVED"
        let youtubeState = youtubeDescriptor?.status.rawValue ?? "UNPROVEN"
        let noteValue = note.trimmingCharacters(in: .whitespacesAndNewlines)

        let prompt = """
        AUTHORITY=NICOLAS
        MISSION=OJO_MEDIA_MEMORY_RETURN_PREPARE_V1
        SOURCE=\(sourceURL.absoluteString)
        SOURCE_KIND=\(sourceKind?.rawValue ?? "UNKNOWN")
        YOUTUBE_CONNECTION=\(youtubeState)
        MEDIA_CAPABILITY=\(mediaState)
        HUMAN_NOTE=\(noteValue.isEmpty ? "NONE" : noteValue)

        Prepare a bounded evidence-return packet using existing SUPRA memory, provenance and canon.
        Do not claim you watched, transcribed or verified media content unless runtime evidence proves it.
        Do not write canon silently.
        Separate FACTS, USER_NOTE, UNKNOWN, EVIDENCE_NEEDED, MEMORY_RETURN_CANDIDATE and NEXT_ACTION.
        """

        do {
            runtimeOutput = try await runtime.execute(prompt: prompt, mode: .plan)
            runtimeState = "PREPARED"
        } catch {
            runtimeOutput = ""
            runtimeState = "ERROR"
            lastError = error.localizedDescription
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
