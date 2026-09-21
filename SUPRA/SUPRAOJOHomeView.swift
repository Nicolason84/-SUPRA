import SwiftUI
import AppKit

enum SUPRAUniverse: String, CaseIterable, Identifiable {
    case france
    case chat
    case cannonico
    case missions
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
        case .runtime: return "waveform.path.ecg.rectangle"
        case .ojo: return "eye.fill"
        case .supra: return "sparkles.rectangle.stack.fill"
        case .control: return "gauge.with.dots.needle.50percent"
        }
    }

    var accent: Color {
        switch self {
        case .france: return .blue
        case .chat: return .teal
        case .cannonico: return .indigo
        case .missions: return .orange
        case .runtime: return .mint
        case .ojo: return .purple
        case .supra: return .cyan
        case .control: return .pink
        }
    }

    var alonsoLevel: String {
        switch self {
        case .france: return "L5 · WORLD / MISSIONS"
        case .chat: return "L6 · HUMAN GATE"
        case .cannonico: return "L4 · MEMORY / KNOWLEDGE"
        case .missions: return "L5 · MISSIONS E2E"
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
        case .runtime: return "Runtime → Result → Evidence"
        case .ojo: return "Context → Human Gate → Decision"
        case .supra: return "Canon → Action → Learning"
        case .control: return "Evidence → Authority → Decision"
        }
    }
}

struct SUPRAOJOHomeView: View {
    @State private var selection: SUPRAUniverse = .france

    var body: some View {
        TabView(selection: $selection) {
            ForEach(SUPRAUniverse.allCases) { universe in
                universeSurface(universe)
                    .tag(universe)
                    .tabItem {
                        Label(universe.title, systemImage: universe.symbol)
                    }
            }
        }
        .tint(selection.accent)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                HStack(spacing: 10) {
                    Label(selection.alonsoLevel, systemImage: "triangle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(selection.accent)

                    Button {
                        NSApp.keyWindow?.toggleFullScreen(nil)
                    } label: {
                        Label("Plein écran", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                    .help("Basculer l’app en plein écran")
                }
            }
        }
        .frame(minWidth: 1180, minHeight: 760)
    }

    @ViewBuilder
    private func universeSurface(_ universe: SUPRAUniverse) -> some View {
        VStack(spacing: 0) {
            universeHeader(universe)
            Divider()

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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(
            LinearGradient(
                colors: [
                    universe.accent.opacity(0.10),
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .tint(universe.accent)
    }

    private func universeHeader(_ universe: SUPRAUniverse) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(universe.accent.opacity(0.16))
                Image(systemName: universe.symbol)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(universe.accent)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 3) {
                Text(universe.title.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(universe.accent)
                Text(universe.subtitle)
                    .font(.title3.weight(.semibold))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Label(universe.alonsoLevel, systemImage: "triangle")
                    .font(.caption.weight(.semibold))
                Text(universe.circulation)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
    }
}
