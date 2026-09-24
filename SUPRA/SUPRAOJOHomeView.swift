import SwiftUI
import AppKit
import CAnnoNicoContracts

enum SUPRAUniverse: String, CaseIterable, Identifiable {
    case france
    case chat
    case media
    case cannonico
    case missions
    case organization
    case connections
    case inpi
    case publicPresence
    case runtime
    case ojo
    case supra
    case control

    var id: String { rawValue }

    var title: String {
        switch self {
        case .france: return "France"
        case .chat: return "Chat"
        case .media: return "Media"
        case .cannonico: return "CAnnoNico"
        case .missions: return "Missions"
        case .organization: return "Organization"
        case .connections: return "Connections"
        case .inpi: return "INPI"
        case .publicPresence: return "Présence"
        case .runtime: return "Runtime"
        case .ojo: return "Œil"
        case .supra: return "SUPRA"
        case .control: return "Control"
        }
    }

    var subtitle: String {
        switch self {
        case .france: return "Territoire vivant"
        case .chat: return "Conversation directe"
        case .media: return "Media Hero · source · preuve · lineage"
        case .cannonico: return "Mémoire · canon · provenance"
        case .missions: return "Missions parallèles"
        case .organization: return "People · départements · autorité"
        case .connections: return "Comms · banques · APIs · organismes"
        case .inpi: return "RNE · comptes · actes · propriété industrielle"
        case .publicPresence: return "Présence publique · signal · influence"
        case .runtime: return "Processus · bridge · santé"
        case .ojo: return "Perception privée · attention · jugement"
        case .supra: return "Executive Operating System"
        case .control: return "Décisions · preuves · autorité"
        }
    }

    var symbol: String {
        switch self {
        case .france: return "map.fill"
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .media: return "play.rectangle.on.rectangle.fill"
        case .cannonico: return "point.3.connected.trianglepath.dotted"
        case .missions: return "scope"
        case .organization: return "person.3.fill"
        case .connections: return "point.3.filled.connected.trianglepath.dotted"
        case .inpi: return "building.columns.fill"
        case .publicPresence: return "dot.radiowaves.left.and.right"
        case .runtime: return "waveform.path.ecg.rectangle"
        case .ojo: return "eye.fill"
        case .supra: return "sparkles.rectangle.stack.fill"
        case .control: return "gauge.with.dots.needle.50percent"
        }
    }

    var accent: Color {
        switch self {
        case .france: return .cyan
        case .chat: return .mint
        case .media: return .purple
        case .cannonico: return .indigo
        case .missions: return .orange
        case .organization: return .green
        case .connections: return .cyan
        case .inpi: return .indigo
        case .publicPresence: return .pink
        case .runtime: return .teal
        case .ojo: return .purple
        case .supra: return .blue
        case .control: return .pink
        }
    }

    var alonsoLevel: String {
        switch self {
        case .france: return "L5 · KNOWLEDGE / WORLD"
        case .chat: return "L6 · EXPERIENCE / HUMAN INTERFACE"
        case .media: return "L6 · EXPERIENCE / MEDIA PROJECTION"
        case .cannonico: return "L4–L5 · MEMORY / KNOWLEDGE"
        case .missions: return "L7 · EXECUTIVE ACTION / E2E"
        case .organization: return "L6–L7 · EXPERIENCE / AUTHORITY"
        case .connections: return "L3–L5 · RUNTIME / KNOWLEDGE"
        case .inpi: return "L5 · KNOWLEDGE / EVIDENCE"
        case .publicPresence: return "L6 · EXPERIENCE / MARKET"
        case .runtime: return "L3 · RUNTIME"
        case .ojo: return "L6 · EXPERIENCE / HUMAN GATE"
        case .supra: return "L7 · EXECUTIVE ACTION"
        case .control: return "L7 · EXECUTIVE ACTION / AUTHORITY"
        }
    }

    var circulation: String {
        switch self {
        case .france: return "World → Evidence → Mission"
        case .chat: return "Human → Intent → Runtime"
        case .media: return "Source → Evidence → Memory → Canon"
        case .cannonico: return "Memory → Provenance → Canon"
        case .missions: return "Decision → Mission → Result"
        case .organization: return "Need → Role → Capacity → Result"
        case .connections: return "External → Normalize → Evidence → Mission"
        case .inpi: return "Official Data → Evidence → Decision"
        case .publicPresence: return "Evidence → Publish → Engagement → Lead"
        case .runtime: return "Runtime → Result → Evidence"
        case .ojo: return "Context → Human Gate → Decision"
        case .supra: return "Canon → Action → Learning"
        case .control: return "Evidence → Authority → Decision"
        }
    }

    var scope: String {
        switch self {
        case .france: return "Territory, institutions, enterprises and real-world signals."
        case .chat: return "Direct conversational control surface over the existing runtime."
        case .media: return "Universal contextual media surface over existing source, evidence, memory and canon owners."
        case .cannonico: return "Canonical memory, lineage, contradictions and knowledge integrity."
        case .missions: return "Parallel bounded execution with evidence-return contracts."
        case .organization: return "Departments, people, digital workforce and decision rights."
        case .connections: return "One governed fabric for communications, finance, APIs, administrations and partner systems."
        case .inpi: return "Official corporate and industrial-property intelligence: RNE, accounts, acts, marks, patents and designs."
        case .publicPresence: return "One public brand truth across LinkedIn, X, Instagram, YouTube and Google Business Profile."
        case .runtime: return "Processes, bridge, workers, services and operational health."
        case .ojo: return "Private Nicolas ↔ SUPRA context, judgment and human authority."
        case .supra: return "Executive synthesis, autonomy gates and system-wide orchestration."
        case .control: return "Decisions, evidence, risk, authority and exception handling."
        }
    }

    var humanGate: String {
        switch self {
        case .france: return "External commitments / publication"
        case .chat: return "High-impact execution"
        case .media: return "Canonical write / public action / source mutation"
        case .cannonico: return "Canonical authority changes"
        case .missions: return "Irreversible or high-impact actions"
        case .organization: return "Hiring / contracts / authority"
        case .connections: return "Money movement / legal submit / sensitive send"
        case .inpi: return "Filings / fees / legal changes"
        case .publicPresence: return "Public publish / sensitive reply"
        case .runtime: return "Security boundary / destructive change"
        case .ojo: return "Nicolas"
        case .supra: return "Founder-reserved decisions"
        case .control: return "Explicit approval gates"
        }
    }
}

private enum SUPRAUniverseDrilldown: String, CaseIterable, Identifiable {
    case evidence = "Evidence"
    case lineage = "Lineage"
    case architecture = "Architecture"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .evidence: return "checkmark.seal.fill"
        case .lineage: return "point.3.connected.trianglepath.dotted"
        case .architecture: return "square.3.layers.3d"
        }
    }
}

enum SUPRAHierarchyFocusTarget: Equatable {
    case missionCurrent
    case connectionsAttention
    case runtimeBottleneck
    case cannonicoGap
    case mediaSource
    case mediaActions
    case mediaEvidence
}

struct SUPRAHierarchyFocusRequest: Equatable, Identifiable {
    let id: UUID
    let target: SUPRAHierarchyFocusTarget

    init(_ target: SUPRAHierarchyFocusTarget) {
        self.id = UUID()
        self.target = target
    }
}

private struct SUPRAHierarchyFocusRequestKey: EnvironmentKey {
    static let defaultValue: SUPRAHierarchyFocusRequest? = nil
}

extension EnvironmentValues {
    var supraHierarchyFocusRequest: SUPRAHierarchyFocusRequest? {
        get { self[SUPRAHierarchyFocusRequestKey.self] }
        set { self[SUPRAHierarchyFocusRequestKey.self] = newValue }
    }
}

private struct SUPRAUniverseSemanticProjection {
    let now: String
    let matters: String
    let action: String
    let actionStatus: String
    let actionTarget: SUPRAHierarchyFocusTarget?
}

struct SUPRAOJOHomeView: View {
    @ObservedObject private var mediaRouter = SUPRAMediaHeroRouter.shared
    @ObservedObject private var liveStore = SUPRAProcessObservatoryStore.shared
    @ObservedObject private var missionRunner = SUPRAGrandeMissionRunner.shared
    @State private var selection: SUPRAUniverse = .supra
    @State private var inspectorVisible = false
    @State private var paletteVisible = false
    @State private var railCompact = false
    @State private var spatialImmersion = false
    @State private var deckDetailsVisible = false
    @State private var circulationExpanded = false
    @State private var activeDrilldown: SUPRAUniverseDrilldown? = nil
    @State private var nativeFocusRequest: SUPRAHierarchyFocusRequest? = nil
    @ObservedObject private var mediaHeroRouter = SUPRAMediaHeroRouter.shared

    private let circulationStages = [
        "WORLD", "OBSERVE", "EVIDENCE", "DECIDE", "MISSION",
        "EXECUTE", "RESULT", "LEARN", "MEMORY", "CANON"
    ]

    private let primaryUniverses: [SUPRAUniverse] = [.supra, .ojo, .media, .publicPresence]

    private var secondaryUniverses: [SUPRAUniverse] {
        SUPRAUniverse.allCases.filter { !primaryUniverses.contains($0) }
    }

    var body: some View {
        ZStack {
            technicalBackplate

            if spatialImmersion {
                spatialDepthField
                    .transition(.opacity)
            }

            HStack(spacing: 0) {
                universeRail

                Rectangle()
                    .fill(.white.opacity(0.07))
                    .frame(width: 1)

                VStack(spacing: 0) {
                    commandDeck

                    HStack(spacing: 0) {
                        universeSurface(selection)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        if inspectorVisible {
                            Rectangle()
                                .fill(.white.opacity(0.07))
                                .frame(width: 1)

                            universeInspector
                                .frame(width: 290)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }

                    circulationDock
                }
            }

            if let context = mediaRouter.context {
                SUPRAMediaUniversalView(context: context)
                    .background(.ultraThickMaterial)
                    .transition(.opacity.combined(with: .scale(scale: 0.992)))
                    .zIndex(100)
            }
        }
        .tint(selection.accent)
        .frame(minWidth: 1180, minHeight: 760)
        .sheet(isPresented: $paletteVisible) {
            commandPalette
        }
        .onReceive(mediaHeroRouter.$context) { context in
            guard context != nil else { return }
            selection = .media
        }
        .onChange(of: selection) { _, newSelection in
            withAnimation(.snappy(duration: 0.24)) {
                applyAdaptiveChrome(for: newSelection)
                deckDetailsVisible = false
                circulationExpanded = false
                activeDrilldown = nil
            }
        }
        .animation(.snappy(duration: 0.28), value: selection)
        .animation(.snappy(duration: 0.24), value: inspectorVisible)
        .animation(.easeInOut(duration: 0.35), value: spatialImmersion)
        .task {
            applyAdaptiveChrome(for: selection)
            liveStore.start()
            liveStore.refresh(force: true)
            await liveStore.refreshTransportHealth()
            SUPRAGrandeMissionRunner.shared.startIfNeeded()
        }
    }

    private func applyAdaptiveChrome(for universe: SUPRAUniverse) {
        switch universe {
        case .media, .chat, .france, .publicPresence:
            // Focus: maximize the working surface.
            railCompact = true
            inspectorVisible = false

        case .supra, .ojo, .missions, .organization:
            // Executive: keep navigation context, remove passive metadata.
            railCompact = false
            inspectorVisible = false

        case .connections, .cannonico, .inpi, .runtime, .control:
            // Inspect: keep evidence metadata without sacrificing the center.
            railCompact = true
            inspectorVisible = true
        }
    }

    private var technicalBackplate: some View {
        ZStack {
            LinearGradient(
                colors: [
                    selection.accent.opacity(0.13),
                    Color(nsColor: .windowBackgroundColor),
                    Color.black.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { proxy in
                Path { path in
                    let spacing: CGFloat = 34
                    var x: CGFloat = 0
                    while x <= proxy.size.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                        x += spacing
                    }

                    var y: CGFloat = 0
                    while y <= proxy.size.height {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                        y += spacing
                    }
                }
                .stroke(selection.accent.opacity(0.035), lineWidth: 0.6)
            }
        }
        .ignoresSafeArea()
    }

    private var spatialDepthField: some View {
        GeometryReader { proxy in
            ZStack {
                RadialGradient(
                    colors: [
                        selection.accent.opacity(0.18),
                        selection.accent.opacity(0.045),
                        .clear
                    ],
                    center: .topTrailing,
                    startRadius: 16,
                    endRadius: max(proxy.size.width, proxy.size.height) * 0.78
                )

                Circle()
                    .stroke(selection.accent.opacity(0.10), lineWidth: 1)
                    .frame(
                        width: min(proxy.size.width, proxy.size.height) * 0.92,
                        height: min(proxy.size.width, proxy.size.height) * 0.92
                    )
                    .offset(
                        x: proxy.size.width * 0.27,
                        y: -proxy.size.height * 0.19
                    )

                Circle()
                    .stroke(selection.accent.opacity(0.06), lineWidth: 1)
                    .frame(
                        width: min(proxy.size.width, proxy.size.height) * 0.58,
                        height: min(proxy.size.width, proxy.size.height) * 0.58
                    )
                    .offset(
                        x: proxy.size.width * 0.23,
                        y: -proxy.size.height * 0.15
                    )

                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .stroke(selection.accent.opacity(0.055), lineWidth: 1)
                    .frame(
                        width: proxy.size.width * 0.82,
                        height: proxy.size.height * 0.50
                    )
                    .rotation3DEffect(
                        .degrees(62),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0.72
                    )
                    .offset(y: proxy.size.height * 0.34)

                Path { path in
                    let center = CGPoint(
                        x: proxy.size.width * 0.72,
                        y: proxy.size.height * 0.24
                    )
                    path.move(to: CGPoint(x: 0, y: center.y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: center.y))
                    path.move(to: CGPoint(x: center.x, y: 0))
                    path.addLine(to: CGPoint(x: center.x, y: proxy.size.height))
                }
                .stroke(selection.accent.opacity(0.045), lineWidth: 0.8)
            }
        }
        .compositingGroup()
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func spatialHUD(_ universe: SUPRAUniverse) -> some View {
        VStack {
            HStack(spacing: 10) {
                Label("SPATIAL HUD", systemImage: "viewfinder")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.1)
                    .foregroundStyle(universe.accent)

                Text(universe.alonsoLevel)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)

                Spacer()

                Label("LIVE CONTEXT", systemImage: "dot.radiowaves.left.and.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 10) {
                Label(universe.circulation, systemImage: "arrow.triangle.2.circlepath")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Label("AUGMENTED · IMMERSIVE", systemImage: "scope")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.9)
                    .foregroundStyle(universe.accent)
            }
        }
        .padding(20)
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(universe.accent.opacity(0.11), lineWidth: 1)
                .padding(8)
        }
        .shadow(color: universe.accent.opacity(0.08), radius: 24)
        .allowsHitTesting(false)
    }

    private var universeRail: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(selection.accent.opacity(0.18))
                    Image(systemName: "triangle.fill")
                        .font(.headline)
                        .foregroundStyle(selection.accent)
                }
                .frame(width: 38, height: 38)

                if !railCompact {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("SUPRA × ŒIL × PRÉSENCE")
                            .font(.headline.weight(.heavy))
                        Text("EXECUTIVE ORGANISM")
                            .font(.caption2.weight(.semibold))
                            .tracking(1.2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)

            ScrollView {
                VStack(spacing: 7) {
                    if !railCompact {
                        Text("CORE")
                            .font(.caption2.weight(.heavy))
                            .tracking(1.4)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 9)
                    }

                    ForEach(primaryUniverses) { universe in
                        universeButton(universe, isCore: true)
                    }

                    Divider()
                        .padding(.vertical, 4)

                    if !railCompact {
                        Text("SYSTEMS")
                            .font(.caption2.weight(.heavy))
                            .tracking(1.4)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 9)
                    }

                    ForEach(secondaryUniverses) { universe in
                        universeButton(universe)
                    }
                }
                .padding(.horizontal, 8)
            }
            .scrollIndicators(.hidden)

            Spacer(minLength: 0)

            Button {
                withAnimation(.snappy(duration: 0.22)) {
                    railCompact.toggle()
                }
            } label: {
                Label(
                    railCompact ? "Expand" : "Compact",
                    systemImage: railCompact ? "sidebar.right" : "sidebar.left"
                )
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .padding(10)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .frame(width: railCompact ? 82 : 238)
        .background(.black.opacity(0.035))
        .glassEffect(.regular, in: Rectangle())
    }

    private func universeButton(_ universe: SUPRAUniverse, isCore: Bool = false) -> some View {
        Button {
            selection = universe
        } label: {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(universe == selection ? universe.accent.opacity(0.22) : .clear)
                    Image(systemName: universe.symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(universe == selection ? universe.accent : .secondary)
                }
                .frame(width: 34, height: 34)

                if !railCompact {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(universe.title)
                            .font(.callout.weight(universe == selection ? .bold : .semibold))
                            .foregroundStyle(.primary)
                        Text(universe.subtitle)
                            .font(.caption2)
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 4)

                    if isCore {
                        Text("CORE")
                            .font(.system(size: 8, weight: .heavy, design: .rounded))
                            .tracking(0.8)
                            .foregroundStyle(universe.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(universe.accent.opacity(0.10), in: Capsule())
                    } else if universe == selection {
                        Circle()
                            .fill(universe.accent)
                            .frame(width: 6, height: 6)
                            .shadow(color: universe.accent.opacity(0.8), radius: 8)
                    }
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("supra-universe-\(universe.rawValue)")
        .background(
            universe == selection
                ? universe.accent.opacity(isCore ? 0.14 : 0.075)
                : (isCore ? universe.accent.opacity(0.035) : Color.clear),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    universe == selection
                        ? universe.accent.opacity(isCore ? 0.48 : 0.25)
                        : (isCore ? universe.accent.opacity(0.13) : .white.opacity(0.025)),
                    lineWidth: 1
                )
        )
    }

    private var commandDeck: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 7) {
                        Text(selection.title.uppercased())
                            .font(.caption.weight(.heavy))
                            .tracking(1.6)
                            .foregroundStyle(selection.accent)

                        Text("CURRENT")
                            .font(.caption2.weight(.semibold))
                            .tracking(1.0)
                            .foregroundStyle(.secondary)
                    }

                    Text(selection.subtitle)
                        .font(.title3.weight(.semibold))
                }

                Spacer()

                Button {
                    mediaRouter.present(
                        SUPRAMediaHeroContext(
                            objectID: "UNIVERSE_\(selection.rawValue.uppercased())",
                            objectType: "SUPRA_UNIVERSE",
                            title: selection.title,
                            subtitle: selection.subtitle,
                            origin: "SUPRAOJOHomeView",
                            lineageRefs: [selection.alonsoLevel, selection.circulation]
                        )
                    )
                } label: {
                    Label("Media", systemImage: "play.rectangle.on.rectangle.fill")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("supra-command-media")
                .help("Open contextual Media Hero")
                .keyboardShortcut("m", modifiers: [.command, .shift])

                Button {
                    paletteVisible = true
                } label: {
                    Label("Commands", systemImage: "command")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("supra-command-palette")
                .help("Universe command palette")
                .keyboardShortcut("k", modifiers: [.command])

                Button {
                    withAnimation(.snappy(duration: 0.22)) {
                        deckDetailsVisible.toggle()
                    }
                } label: {
                    Label(deckDetailsVisible ? "Less" : "Details", systemImage: deckDetailsVisible ? "chevron.up" : "chevron.down")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("supra-command-details")
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)

            if deckDetailsVisible {
                Divider()

                HStack(spacing: 14) {
                    Label(selection.alonsoLevel, systemImage: "triangle.fill")
                        .foregroundStyle(selection.accent)

                    Label(selection.circulation, systemImage: "arrow.triangle.2.circlepath")
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer(minLength: 12)

                    Button {
                        inspectorVisible.toggle()
                    } label: {
                        Label("Inspector", systemImage: inspectorVisible ? "sidebar.right" : "sidebar.trailing")
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("supra-command-inspector")

                    Button {
                        spatialImmersion.toggle()
                    } label: {
                        Label("HUD", systemImage: spatialImmersion ? "viewfinder.circle.fill" : "viewfinder.circle")
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("supra-command-hud")

                    Button {
                        NSApp.keyWindow?.toggleFullScreen(nil)
                    } label: {
                        Label("Full screen", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("supra-command-fullscreen")
                }
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .glassEffect(.regular, in: Rectangle())
    }

    @ViewBuilder
    private func universeSurface(_ universe: SUPRAUniverse) -> some View {
        VStack(spacing: 0) {
            universeHierarchy(universe)

            Rectangle()
                .fill(.white.opacity(0.055))
                .frame(height: 1)

            ZStack {
                universe.accent.opacity(0.018)

                Group {
                    switch universe {
                    case .france:
                        FranceOrganismNativeView()
                    case .chat:
                        SUPRAChatView()
                    case .media:
                        if let context = mediaHeroRouter.context {
                            SUPRAMediaUniversalView(context: context)
                        } else {
                            SUPRAMediaUniversalView(origin: "SUPRA_UNIVERSE")
                        }
                    case .cannonico:
                        ContentView()
                    case .missions:
                        MissionCenterView()
                    case .organization:
                        OrganizationPeopleView()
                    case .connections:
                        ExternalConnectionsView()
                    case .inpi:
                        INPIUniverseView()
                    case .publicPresence:
                        PublicPresenceView()
                    case .runtime:
                        SUPRAProcessObservatoryView()
                    case .ojo:
                        OJOPrivateControlView()
                    case .supra:
                        SupraControlCenterView()
                    case .control:
                        DecisionInboxView()
                    }
                }
                .environment(\.supraHierarchyFocusRequest, nativeFocusRequest)
                .id(universe)
                .transition(.opacity.combined(with: .scale(scale: 0.995)))

                if spatialImmersion {
                    spatialHUD(universe)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func universeHierarchy(_ universe: SUPRAUniverse) -> some View {
        let semantic = semanticProjection(for: universe)

        return VStack(spacing: 9) {
            HStack(alignment: .top, spacing: 9) {
                hierarchyCard(
                    title: "NOW",
                    symbol: "circle.fill",
                    text: semantic.now,
                    universe: universe,
                    identifier: "supra-hierarchy-now"
                )

                hierarchyCard(
                    title: "MATTERS",
                    symbol: "scope",
                    text: semantic.matters,
                    universe: universe,
                    identifier: "supra-hierarchy-matters"
                )

                actionHierarchyCard(semantic: semantic, universe: universe)
            }

            HStack(spacing: 8) {
                Label("DEEP DIVE", systemImage: "square.stack.3d.down.right")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(.secondary)

                ForEach(SUPRAUniverseDrilldown.allCases) { drilldown in
                    Button {
                        withAnimation(.snappy(duration: 0.20)) {
                            activeDrilldown = activeDrilldown == drilldown ? nil : drilldown
                        }
                    } label: {
                        Label(drilldown.rawValue, systemImage: drilldown.symbol)
                            .font(.caption2.weight(.bold))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(activeDrilldown == drilldown ? universe.accent : .secondary)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(
                        (activeDrilldown == drilldown ? universe.accent.opacity(0.12) : Color.primary.opacity(0.035)),
                        in: Capsule()
                    )
                    .accessibilityIdentifier("supra-drilldown-\(drilldown.rawValue.lowercased())")
                }

                Spacer(minLength: 0)

                Text(activeDrilldown == nil ? "DETAILS ON DEMAND" : "NATIVE ROUTE READY")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(.tertiary)
            }

            if let activeDrilldown {
                drilldownPanel(activeDrilldown, universe: universe)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.black.opacity(0.018))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("supra-universe-hierarchy")
    }

    private func hierarchyCard(
        title: String,
        symbol: String,
        text: String,
        universe: SUPRAUniverse,
        identifier: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: symbol)
                .font(.caption2.weight(.heavy))
                .tracking(1.1)
                .foregroundStyle(universe.accent)

            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .topLeading)
        .padding(11)
        .background(.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.045), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(identifier)
    }

    @ViewBuilder
    private func actionHierarchyCard(
        semantic: SUPRAUniverseSemanticProjection,
        universe: SUPRAUniverse
    ) -> some View {
        if let target = semantic.actionTarget {
            Button {
                routeToNative(target)
            } label: {
                actionHierarchyContent(semantic: semantic, universe: universe)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("supra-hierarchy-action-button")
            .accessibilityLabel("ACTION, \(semantic.action)")
        } else {
            actionHierarchyContent(semantic: semantic, universe: universe)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("supra-hierarchy-action")
        }
    }

    private func actionHierarchyContent(
        semantic: SUPRAUniverseSemanticProjection,
        universe: SUPRAUniverse
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Label("ACTION", systemImage: "arrow.right.circle.fill")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.1)
                    .foregroundStyle(universe.accent)

                Spacer(minLength: 4)

                Text(semantic.actionStatus)
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundStyle(semantic.actionTarget == nil ? .secondary : universe.accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background((semantic.actionTarget == nil ? Color.secondary : universe.accent).opacity(0.10), in: Capsule())
            }

            Text(semantic.action)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(universe.alonsoLevel) · Gate: \(universe.humanGate)")
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .topLeading)
        .padding(11)
        .background(.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke((semantic.actionTarget == nil ? Color.white : universe.accent).opacity(0.09), lineWidth: 1)
        }
    }

    private func drilldownPanel(_ drilldown: SUPRAUniverseDrilldown, universe: SUPRAUniverse) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: drilldown.symbol)
                .font(.headline)
                .foregroundStyle(universe.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(drilldown.rawValue.uppercased())
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(universe.accent)

                Text(drilldownText(drilldown, universe: universe))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }

            Spacer(minLength: 0)

            if drilldown == .architecture {
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        inspectorVisible = true
                    }
                } label: {
                    Label("Show owner", systemImage: "sidebar.right")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityIdentifier("supra-drilldown-native-architecture")
            } else if let target = nativeDrilldownTarget(drilldown, universe: universe) {
                Button {
                    routeToNative(target)
                } label: {
                    Label(nativeDrilldownLabel(drilldown), systemImage: "arrow.up.right.square")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityIdentifier("supra-drilldown-native-\(drilldown.rawValue.lowercased())")
            }
        }
        .padding(11)
        .background(universe.accent.opacity(0.055), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityIdentifier("supra-drilldown-panel")
    }

    private func semanticProjection(for universe: SUPRAUniverse) -> SUPRAUniverseSemanticProjection {
        let runner = missionRunner
        let bridge = liveStore.bridgeAvailable ? "bridge connected" : "bridge unavailable"
        let bottleneck = liveStore.processes.first(where: \.isBottleneck)
        let inFlight = liveStore.processes.first(where: { $0.stage == .inFlight })
        let canonical = SUPRACAnnoNicoIntegration.snapshot()
        let recovered = canonical.references.filter { $0.state == .recovered }
        let unresolved = canonical.references.filter { $0.state != .recovered }
        let attention = ExternalConnectorCatalog.attentionCount
        let fresh = ExternalConnectionProofLedger.liveCount
        let stale = ExternalConnectionProofLedger.staleCount
        let publicConnectors = ExternalConnectorCatalog.all.filter { $0.family == "Public Presence" }
        let publicAttention = publicConnectors.filter(requiresConnectionAttention).count
        let publicFresh = publicConnectors.filter { ExternalConnectionProofLedger.freshness(for: $0) == .live }.count
        let inpiConnectors = ExternalConnectorCatalog.all.filter { $0.id == "inpi-rne" || $0.id == "inpi-ip" }
        let inpiAttention = inpiConnectors.filter(requiresConnectionAttention).count
        let source = mediaHeroRouter.liveSourceURL

        switch universe {
        case .supra:
            if let bottleneck {
                return .init(
                    now: "\(liveStore.inFlightCount) in flight · \(liveStore.bottleneckCount) bottleneck · \(liveStore.driftCount) drift · \(bridge)",
                    matters: "\(bottleneck.title) is blocking forward motion. Materialized receipts remain preserved.",
                    action: "Inspect \(bottleneck.title) in the existing Process Observatory before any higher-authority move.",
                    actionStatus: "BLOCKING",
                    actionTarget: .runtimeBottleneck
                )
            }
            return .init(
                now: "\(liveStore.inFlightCount) in flight · \(liveStore.materializedCount) materialized · \(bridge)",
                matters: liveStore.momentumDetail,
                action: liveStore.bridgeAvailable ? "No action required." : "Recover observation through the existing bridge; do not create a replacement.",
                actionStatus: liveStore.bridgeAvailable ? "NO ACTION" : "ATTENTION",
                actionTarget: liveStore.bridgeAvailable ? nil : .runtimeBottleneck
            )

        case .missions:
            let phase = runner.activePhaseID ?? inFlight?.id ?? "NONE"
            let humanGate = runner.isAwaitingHumanDecision
            let running = runner.isRunning || runner.isStandby
            return .init(
                now: humanGate ? "Human gate waiting · current mission \(phase)" : (running ? "Mission active · \(phase)" : "No admitted mission currently executing"),
                matters: runner.lastError ?? (humanGate ? "Execution is intentionally paused for Nicolas; no authority is bypassed." : "Mission state comes from durable runner receipts and the existing Mission Store."),
                action: humanGate ? "Open the current mission and resolve the explicit human gate." : (running ? "Open the current mission and inspect its latest durable result." : "No action required."),
                actionStatus: humanGate ? "HUMAN GATE" : (running ? "RUNNING" : "NO ACTION"),
                actionTarget: (humanGate || running) ? .missionCurrent : nil
            )

        case .connections:
            return .init(
                now: "\(fresh) fresh proof · \(stale) stale · \(attention) routes need attention",
                matters: attention > 0 ? "Authentication, approval and provider gaps remain separate from CONNECTED proof; governance is not bypassed." : "All catalogued connection routes are currently clear of declared auth/approval/provider gaps.",
                action: attention > 0 ? "Open ATTENTION and resolve the next governed connection gap through its existing provider route." : "No action required.",
                actionStatus: attention > 0 ? "ATTENTION" : "NO ACTION",
                actionTarget: attention > 0 ? .connectionsAttention : nil
            )

        case .runtime:
            if let bottleneck {
                return .init(
                    now: "\(liveStore.momentumLabel) · \(liveStore.inFlightCount) in flight · \(liveStore.bottleneckCount) bottleneck · \(liveStore.driftCount) drift",
                    matters: "\(bottleneck.title) is the current runtime bottleneck; owner evidence remains in Process Observatory.",
                    action: "Open the current bottleneck and inspect its materialized receipt/proof before changing runtime state.",
                    actionStatus: "BLOCKING",
                    actionTarget: .runtimeBottleneck
                )
            }
            return .init(
                now: "\(liveStore.momentumLabel) · \(liveStore.inFlightCount) in flight · \(liveStore.driftCount) drift · closure \(Int(liveStore.observableClosure * 100))%",
                matters: liveStore.momentumDetail,
                action: (inFlight != nil || liveStore.driftCount > 0) ? "Inspect the current live process before any runtime change." : "No action required.",
                actionStatus: (inFlight != nil || liveStore.driftCount > 0) ? "INSPECT" : "NO ACTION",
                actionTarget: (inFlight != nil || liveStore.driftCount > 0) ? .runtimeBottleneck : nil
            )

        case .cannonico:
            let nextGap = unresolved.first?.id ?? "NONE"
            return .init(
                now: "\(recovered.count)/\(canonical.references.count) canonical sources recovered · \(unresolved.count) unresolved",
                matters: unresolved.isEmpty ? "Canonical references are recovered; no parallel memory or proof owner is required." : "\(nextGap) is not fully recovered. Existing recovered references remain usable and authoritative for their scope.",
                action: unresolved.isEmpty ? "No action required." : "Open the existing CAnnoNico Spine and inspect \(nextGap); do not create or rewrite canon.",
                actionStatus: unresolved.isEmpty ? "NO ACTION" : "GAP",
                actionTarget: unresolved.isEmpty ? nil : .cannonicoGap
            )

        case .media:
            let hasSource = source != nil
            return .init(
                now: hasSource ? "Source selected · runtime \(liveStore.momentumLabel) · \(recovered.count)/\(canonical.references.count) canon refs recovered" : "No media source selected · runtime \(liveStore.momentumLabel)",
                matters: hasSource ? "The source stays authoritative; Media adds context, evidence and lineage without inventing transcript or metadata." : "No media claim can be evidenced until a source identity is selected in the native Media owner.",
                action: hasSource ? "Use the existing Media runtime actions on the selected source." : "Select a source in Media; do not infer content before evidence exists.",
                actionStatus: hasSource ? "READY" : "SOURCE NEEDED",
                actionTarget: hasSource ? .mediaActions : .mediaSource
            )

        case .chat:
            return .init(
                now: "\(bridge) · runtime \(liveStore.momentumLabel)",
                matters: liveStore.bridgeAvailable ? "Conversation can use the existing private runtime path; high-impact execution remains gated." : "Chat cannot claim live runtime execution while the existing bridge is unavailable.",
                action: liveStore.bridgeAvailable ? "No action required." : "Inspect the existing runtime bridge; do not create a new bridge.",
                actionStatus: liveStore.bridgeAvailable ? "NO ACTION" : "ATTENTION",
                actionTarget: liveStore.bridgeAvailable ? nil : .runtimeBottleneck
            )

        case .inpi:
            return .init(
                now: "\(inpiConnectors.count) official INPI routes · \(inpiAttention) require auth/config",
                matters: "Official-data readiness and legal filing authority are separate; filings and fees remain human-gated.",
                action: inpiAttention > 0 ? "Open the INPI connection routes and resolve official access readiness only." : "No action required.",
                actionStatus: inpiAttention > 0 ? "ATTENTION" : "NO ACTION",
                actionTarget: inpiAttention > 0 ? .connectionsAttention : nil
            )

        case .publicPresence:
            return .init(
                now: "\(publicFresh) public routes with fresh proof · \(publicAttention) need attention",
                matters: "Public publishing remains distinct from read/analysis proof; material public writes stay gated.",
                action: publicAttention > 0 ? "Open Connections ATTENTION for the next public-presence gap; do not publish from UX hierarchy." : "No action required.",
                actionStatus: publicAttention > 0 ? "ATTENTION" : "NO ACTION",
                actionTarget: publicAttention > 0 ? .connectionsAttention : nil
            )

        case .ojo:
            let gate = runner.isAwaitingHumanDecision
            return .init(
                now: gate ? "Nicolas human gate waiting · runtime \(liveStore.momentumLabel)" : "Human gate clear · runtime \(liveStore.momentumLabel)",
                matters: gate ? "A consequential decision is intentionally waiting for Nicolas; SUPRA must not self-authorize it." : "No explicit Nicolas gate is currently waiting in the Grande Mission runner.",
                action: gate ? "Open the current mission and review the exact decision/evidence request." : "No action required.",
                actionStatus: gate ? "HUMAN GATE" : "NO ACTION",
                actionTarget: gate ? .missionCurrent : nil
            )

        case .control:
            let gate = runner.isAwaitingHumanDecision
            if gate {
                return .init(
                    now: "1 human gate waiting · \(liveStore.bottleneckCount) runtime bottleneck",
                    matters: "Authority is paused at an explicit decision boundary; no silent mutation is permitted.",
                    action: "Open the current mission and resolve only the explicit gated decision.",
                    actionStatus: "HUMAN GATE",
                    actionTarget: .missionCurrent
                )
            }
            if liveStore.bottleneckCount > 0 {
                return .init(
                    now: "No human gate waiting · \(liveStore.bottleneckCount) runtime bottleneck",
                    matters: "The blocker is operational, not an authority request; do not manufacture a human decision.",
                    action: "Inspect the current runtime bottleneck; keep authority unchanged.",
                    actionStatus: "INSPECT",
                    actionTarget: .runtimeBottleneck
                )
            }
            return .init(now: "No human gate waiting · no live runtime blocker", matters: "Control has no justified exception to escalate.", action: "No action required.", actionStatus: "NO ACTION", actionTarget: nil)

        case .organization:
            return .init(
                now: "No shared live organization exception surfaced",
                matters: "People, role and authority remain owned by Organization; the shell does not invent staffing state.",
                action: "No action required.",
                actionStatus: "NO ACTION",
                actionTarget: nil
            )

        case .france:
            return .init(
                now: "No shared live territorial exception surfaced",
                matters: "France remains the owner of territorial signals; the shell does not synthesize an unproven event.",
                action: "No action required.",
                actionStatus: "NO ACTION",
                actionTarget: nil
            )
        }
    }

    private func requiresConnectionAttention(_ connector: ExternalConnectorDescriptor) -> Bool {
        connector.status == .authRequired
            || connector.status == .approvalRequired
            || connector.status == .providerRequired
            || connector.status == .blocked
    }

    private func routeToNative(_ target: SUPRAHierarchyFocusTarget) {
        switch target {
        case .missionCurrent:
            selection = .missions
        case .connectionsAttention:
            selection = .connections
        case .runtimeBottleneck:
            selection = .runtime
        case .cannonicoGap:
            selection = .cannonico
        case .mediaSource, .mediaActions, .mediaEvidence:
            selection = .media
        }
        nativeFocusRequest = SUPRAHierarchyFocusRequest(target)
    }

    private func nativeDrilldownTarget(
        _ drilldown: SUPRAUniverseDrilldown,
        universe: SUPRAUniverse
    ) -> SUPRAHierarchyFocusTarget? {
        switch drilldown {
        case .architecture:
            return nil
        case .lineage:
            return .cannonicoGap
        case .evidence:
            switch universe {
            case .media: return .mediaEvidence
            case .connections, .publicPresence, .inpi: return .connectionsAttention
            case .cannonico: return .cannonicoGap
            case .missions: return .missionCurrent
            case .runtime, .supra, .control, .ojo, .chat: return .runtimeBottleneck
            case .france, .organization: return .cannonicoGap
            }
        }
    }

    private func nativeDrilldownLabel(_ drilldown: SUPRAUniverseDrilldown) -> String {
        switch drilldown {
        case .evidence: return "Open native proof"
        case .lineage: return "Open native lineage"
        case .architecture: return "Show owner"
        }
    }

    private func drilldownText(_ drilldown: SUPRAUniverseDrilldown, universe: SUPRAUniverse) -> String {
        let canonical = SUPRACAnnoNicoIntegration.snapshot()
        let recovered = canonical.references.filter { $0.state == .recovered }.count
        switch drilldown {
        case .evidence:
            switch universe {
            case .connections, .publicPresence, .inpi:
                return "Native connection proof: \(ExternalConnectionProofLedger.liveCount) fresh · \(ExternalConnectionProofLedger.staleCount) stale · \(ExternalConnectorCatalog.attentionCount) attention. Open the owner; do not copy proof here."
            case .cannonico:
                return "Native CAnnoNico references: \(recovered)/\(canonical.references.count) recovered. Open the Spine/reference object; paths and states remain the proof source."
            case .media:
                return "Media proof remains in the native Media context rail and runtime receipt. Source identity is not proof of observed contents."
            default:
                return "Runtime proof remains in Process Observatory / durable receipts: \(liveStore.materializedCount) materialized · \(liveStore.bottleneckCount) bottleneck · \(liveStore.driftCount) drift."
            }
        case .lineage:
            return "\(universe.circulation). Open native CAnnoNico lineage; the shell keeps only this route and does not duplicate the graph."
        case .architecture:
            return "Existing owner: \(architectureOwner(for: universe)). Alonso layer: \(universe.alonsoLevel). Reuse the owner/capability/runtime; UX4 adds no authority."
        }
    }

    private func architectureOwner(for universe: SUPRAUniverse) -> String {
        switch universe {
        case .france: return "FranceOrganismNativeView"
        case .chat: return "SUPRAChatView"
        case .media: return "SUPRAMediaUniversalView"
        case .cannonico: return "ContentView / CAnnoNico"
        case .missions: return "MissionCenterView"
        case .organization: return "OrganizationPeopleView"
        case .connections: return "ExternalConnectionsView"
        case .inpi: return "INPIUniverseView"
        case .publicPresence: return "PublicPresenceView"
        case .runtime: return "SUPRAProcessObservatoryView"
        case .ojo: return "OJOPrivateControlView"
        case .supra: return "SupraControlCenterView"
        case .control: return "DecisionInboxView"
        }
    }

    private var universeInspector: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                inspectorHero

                inspectorBlock(
                    title: "ALONSO LAYER",
                    value: selection.alonsoLevel,
                    symbol: "triangle.fill",
                    tint: selection.accent
                )

                inspectorBlock(
                    title: "CIRCULATION",
                    value: selection.circulation,
                    symbol: "arrow.triangle.2.circlepath",
                    tint: selection.accent
                )

                inspectorBlock(
                    title: "SCOPE",
                    value: selection.scope,
                    symbol: "scope",
                    tint: .secondary
                )

                inspectorBlock(
                    title: "GUARDRAIL · HUMAN GATE ONLY IF TRIGGERED",
                    value: selection.humanGate,
                    symbol: "person.badge.key.fill",
                    tint: .orange
                )

                if selection == .supra {
                    alonsoPyramidCard
                }
            }
            .padding(14)
        }
        .scrollIndicators(.hidden)
        .background(.black.opacity(0.025))
    }

    private var alonsoPyramidCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("PYRAMIDE ALONSO")
                        .font(.caption2.weight(.heavy))
                        .tracking(1.3)
                    Text("GLOBAL · SYSTEM-WIDE PROGRESSION LAW")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("PROMOTION MIN 0.92")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(selection.accent)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(selection.accent.opacity(0.10), in: Capsule())
            }

            Text("Upper layers never compensate for a broken lower layer. No level is marked PASS here without live evidence.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(1...7, id: \.self) { level in
                HStack(alignment: .top, spacing: 10) {
                    Text("L\(level)")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(selection.accent)
                        .frame(width: 26, alignment: .leading)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(alonsoLevelTitle(level))
                            .font(.caption.weight(.bold))
                        Text(alonsoLevelContract(level))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("EXISTING ANCHORS · \(alonsoLevelAnchors(level))")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Divider()

            Label("ASCEND only after proof · stability · control · recoverability", systemImage: "arrow.up.circle.fill")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            Label("COHERENCE < 0.92 → REMEDIATION · NO AUTOMATIC PROMOTION", systemImage: "exclamationmark.triangle.fill")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(.orange)

            Label("FAIL → DESCEND_ONE_LEVEL · PROOF > CLAIM · REALITY > PROJECTION", systemImage: "arrow.down.circle.fill")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func alonsoLevelTitle(_ level: Int) -> String {
        switch level {
        case 1: return "FOUNDATION"
        case 2: return "BUILD"
        case 3: return "RUNTIME"
        case 4: return "MEMORY"
        case 5: return "KNOWLEDGE"
        case 6: return "EXPERIENCE"
        case 7: return "EXECUTIVE ACTION"
        default: return "UNKNOWN"
        }
    }

    private func alonsoLevelContract(_ level: Int) -> String {
        switch level {
        case 1:
            return "identity · authority · legal ability · hardware/OS/storage/network · basic truth"
        case 2:
            return "recover + compose existing capabilities · smallest necessary implementation · no equivalent reconstruction"
        case 3:
            return "real executable path · dependency path · rollback · observability"
        case 4:
            return "lineage · history · prior evidence · contradictions · no-loss patrimony"
        case 5:
            return "facts · inferences · unknowns · models · evidence quality"
        case 6:
            return "human usability · understandable proposition · fair interaction · human gate"
        case 7:
            return "decision · execution · result · proof · memory return · canon return · controlled self-evolution"
        default:
            return "unmapped"
        }
    }

    private func alonsoLevelAnchors(_ level: Int) -> String {
        switch level {
        case 1:
            return "Environment Twin · Total System/File Twin · Storage Twin"
        case 2:
            return "Twin Factory V1 · Universal Twin Contract · build/toolchain"
        case 3:
            return "Runtime · Event Bus · Gabriel workers · bridges"
        case 4:
            return "Puchero · CAnnoNico · SUPRA Memory V5"
        case 5:
            return "Knowledge/Company/People/Market/Opportunity/Evidence Twins · Atlas"
        case 6:
            return "Subject/Human/Media Twins · ojO · Chat"
        case 7:
            return "Case Twin · Decision Twin · Missions · Control · SUPRA"
        default:
            return "unmapped"
        }
    }

    private var inspectorHero: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selection.accent.opacity(0.16))
                Image(systemName: selection.symbol)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(selection.accent)
            }
            .frame(width: 58, height: 58)

            Text(selection.title)
                .font(.title2.bold())

            Text("One universe. One bounded context. One shared truth.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func inspectorBlock(title: String, value: String, symbol: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.caption2.weight(.heavy))
                .tracking(1.1)
                .foregroundStyle(tint)

            Text(value)
                .font(.callout.weight(.semibold))
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var circulationDock: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Label("FLOW", systemImage: "arrow.triangle.2.circlepath")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(selection.accent)

                Text(selection.circulation)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer(minLength: 12)

                Button {
                    withAnimation(.snappy(duration: 0.22)) {
                        circulationExpanded.toggle()
                    }
                } label: {
                    Label(
                        circulationExpanded ? "Less" : "Full flow",
                        systemImage: circulationExpanded ? "chevron.down" : "chevron.up"
                    )
                }
                .buttonStyle(.plain)
                .font(.caption2.weight(.semibold))
                .accessibilityIdentifier("supra-circulation-disclosure")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 7)

            if circulationExpanded {
                Divider()

                ScrollView(.horizontal) {
                    HStack(spacing: 7) {
                        ForEach(Array(circulationStages.enumerated()), id: \.offset) { index, stage in
                            if index > 0 {
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.tertiary)
                            }

                            Text(stage)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(index == circulationStages.count - 1 ? selection.accent : .secondary)
                        }

                        Spacer(minLength: 12)

                        Text("RESULT → MEMORY RETURN REQUIRED")
                            .font(.caption2.weight(.heavy))
                            .tracking(0.8)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .scrollIndicators(.hidden)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .glassEffect(.regular, in: Rectangle())
    }

    private var commandPalette: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("UNIVERSE COMMAND DECK")
                        .font(.caption.weight(.heavy))
                        .tracking(1.4)
                        .foregroundStyle(.secondary)
                    Text("Jump directly into a bounded operating universe.")
                        .font(.title2.bold())
                }

                Spacer()

                Button("Close", systemImage: "xmark") {
                    paletteVisible = false
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 210, maximum: 260), spacing: 12)],
                spacing: 12
            ) {
                ForEach(SUPRAUniverse.allCases) { universe in
                    Button {
                        selection = universe
                        paletteVisible = false
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: universe.symbol)
                                .font(.title2.bold())
                                .foregroundStyle(universe.accent)

                            Text(universe.title)
                                .font(.headline)

                            Text(universe.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                        .padding(16)
                        .glassEffect(
                            .regular,
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(24)
        .frame(width: 760, height: 560)
        .background(
            LinearGradient(
                colors: [
                    selection.accent.opacity(0.12),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}