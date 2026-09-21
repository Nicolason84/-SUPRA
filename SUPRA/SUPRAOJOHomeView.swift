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
        case .publicPresence: return "Public Presence"
        case .runtime: return "Runtime"
        case .ojo: return "ojO"
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
        case .publicPresence: return "LinkedIn · X · Instagram · YouTube"
        case .runtime: return "Processus · bridge · santé"
        case .ojo: return "Interface privée Nicolas"
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
        case .france: return "L5 · WORLD / MISSIONS"
        case .chat: return "L6 · HUMAN GATE"
        case .cannonico: return "L4 · MEMORY / KNOWLEDGE"
        case .missions: return "L5 · MISSIONS E2E"
        case .organization: return "L6–L7 · PEOPLE / GOVERNANCE"
        case .connections: return "L3–L6 · EXTERNAL CONNECTIVITY"
        case .inpi: return "L4–L6 · LEGAL / EVIDENCE"
        case .publicPresence: return "L5–L6 · MARKET / EXPERIENCE"
        case .runtime: return "L3 · RUNTIME"
        case .ojo: return "L6 · EXPERIENCE"
        case .supra: return "L7 · EXECUTIVE / AUTONOMY"
        case .control: return "L6 · AUTHORITY / EVIDENCE"
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
    @State private var selection: SUPRAUniverse = .france
    @State private var inspectorVisible = true
    @State private var paletteVisible = false
    @State private var railCompact = false

    private let circulationStages = [
        "WORLD", "OBSERVE", "EVIDENCE", "DECIDE", "MISSION",
        "EXECUTE", "RESULT", "LEARN", "MEMORY", "CANON"
    ]

    var body: some View {
        ZStack {
            technicalBackplate

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
        }
        .tint(selection.accent)
        .frame(minWidth: 1180, minHeight: 760)
        .sheet(isPresented: $paletteVisible) {
            commandPalette
        }
        .animation(.snappy(duration: 0.28), value: selection)
        .animation(.snappy(duration: 0.24), value: inspectorVisible)
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
                        Text("SUPRA × ojO")
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
                VStack(spacing: 6) {
                    ForEach(SUPRAUniverse.allCases) { universe in
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

    private func universeButton(_ universe: SUPRAUniverse) -> some View {
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

                    if universe == selection {
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
            universe == selection ? universe.accent.opacity(0.075) : Color.clear,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    universe == selection ? universe.accent.opacity(0.25) : .white.opacity(0.025),
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
                    OJOOrganismNativeView()
                case .supra:
                    SupraControlCenterView()
                case .control:
                    DecisionInboxView()
                }
            }
            .id(universe)
            .transition(.opacity.combined(with: .scale(scale: 0.995)))
        }
    }

    private var universeInspector: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                inspectorHero

                inspectorBlock(
                    title: "ALONSO GATE",
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
                    title: "HUMAN GATE",
                    value: selection.humanGate,
                    symbol: "person.badge.key.fill",
                    tint: .orange
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("PYRAMIDE ALONSO")
                        .font(.caption2.weight(.heavy))
                        .tracking(1.3)
                        .foregroundStyle(.secondary)

                    ForEach(1...7, id: \.self) { level in
                        HStack(spacing: 9) {
                            Circle()
                                .fill(levelTint(level))
                                .frame(width: 7, height: 7)
                                .shadow(color: levelTint(level).opacity(0.55), radius: 5)
                            Text("L\(level)")
                                .font(.caption.weight(.bold))
                                .frame(width: 25, alignment: .leading)
                            Rectangle()
                                .fill(levelTint(level).opacity(0.22))
                                .frame(height: 4)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(16)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(14)
        }
        .scrollIndicators(.hidden)
        .background(.black.opacity(0.025))
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

    private func levelTint(_ level: Int) -> Color {
        let digits = selection.alonsoLevel.compactMap { $0.wholeNumberValue }
        if digits.contains(level) {
            return selection.accent
        }
        return .secondary.opacity(0.30)
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
