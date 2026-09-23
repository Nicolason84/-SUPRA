import SwiftUI
import AppKit

enum SUPRAUniverse: String, CaseIterable, Identifiable {
    case france
    case chat
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

struct SUPRAOJOHomeView: View {
    @ObservedObject private var mediaRouter = SUPRAMediaHeroRouter.shared
    @State private var selection: SUPRAUniverse = .supra
    @State private var inspectorVisible = true
    @State private var paletteVisible = false
    @State private var railCompact = false
    @State private var spatialImmersion = true

    private let circulationStages = [
        "WORLD", "OBSERVE", "EVIDENCE", "DECIDE", "MISSION",
        "EXECUTE", "RESULT", "LEARN", "MEMORY", "CANON"
    ]

    private let primaryUniverses: [SUPRAUniverse] = [.supra, .ojo, .publicPresence]

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
        .animation(.snappy(duration: 0.28), value: selection)
        .animation(.snappy(duration: 0.24), value: inspectorVisible)
        .animation(.easeInOut(duration: 0.35), value: spatialImmersion)
        .task {
            SUPRAGrandeMissionRunner.shared.startIfNeeded()
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
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Text(selection.title.uppercased())
                        .font(.caption.weight(.heavy))
                        .tracking(1.6)
                        .foregroundStyle(selection.accent)

                    Text("/")
                        .foregroundStyle(.tertiary)

                    Text("LIVE UNIVERSE")
                        .font(.caption2.weight(.semibold))
                        .tracking(1.1)
                        .foregroundStyle(.secondary)
                }

                Text(selection.subtitle)
                    .font(.title3.weight(.semibold))
            }

            Spacer()

            statusPill("CANON LIVE", symbol: "checkmark.seal.fill")
            statusPill("BUILD-GATED", symbol: "hammer.fill")
            statusPill("CIRCULAR", symbol: "arrow.triangle.2.circlepath")

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
                Image(systemName: "play.rectangle.on.rectangle.fill")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .help("Open contextual Media Hero")
            .keyboardShortcut("m", modifiers: [.command, .shift])

            Button {
                paletteVisible = true
            } label: {
                Image(systemName: "command")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .help("Universe command palette")
            .keyboardShortcut("k", modifiers: [.command])

            Button {
                inspectorVisible.toggle()
            } label: {
                Image(systemName: inspectorVisible ? "sidebar.right" : "sidebar.trailing")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .help("Toggle universe inspector")

            Button {
                spatialImmersion.toggle()
            } label: {
                Image(systemName: spatialImmersion ? "viewfinder.circle.fill" : "viewfinder.circle")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .help(spatialImmersion ? "Disable augmented spatial HUD" : "Enable augmented spatial HUD")

            Button {
                NSApp.keyWindow?.toggleFullScreen(nil)
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .help("Toggle fullscreen")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: Rectangle())
    }

    private func statusPill(_ text: String, symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .glassEffect(.regular, in: Capsule())
    }

    @ViewBuilder
    private func universeSurface(_ universe: SUPRAUniverse) -> some View {
        ZStack {
            universe.accent.opacity(0.018)

            Group {
                switch universe {
                case .france:
                    FranceOrganismNativeView()
                case .chat:
                    SUPRAChatView()
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
            .id(universe)
            .transition(.opacity.combined(with: .scale(scale: 0.995)))

            if spatialImmersion {
                spatialHUD(universe)
                    .transition(.opacity)
            }
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
        ScrollView(.horizontal) {
            HStack(spacing: 7) {
                Label("CIRCULATION", systemImage: "arrow.triangle.2.circlepath")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.1)
                    .foregroundStyle(selection.accent)

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
            .padding(.vertical, 9)
        }
        .scrollIndicators(.hidden)
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