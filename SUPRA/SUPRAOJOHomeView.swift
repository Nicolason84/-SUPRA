import SwiftUI
import AppKit

enum SUPRAOJORoute: String, CaseIterable, Identifiable {
    case chat
    case france
    case ojo
    case control

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chat: return "Chat"
        case .france: return "France"
        case .ojo: return "ojO"
        case .control: return "Système"
        }
    }

    var subtitle: String {
        switch self {
        case .chat: return "Parler · demander · décider"
        case .france: return "Organisme territorial vivant"
        case .ojo: return "Vivant · décisions · missions · preuves"
        case .control: return "Runtime · diagnostics · technique"
        }
    }

    var symbol: String {
        switch self {
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .france: return "map.fill"
        case .ojo: return "circle.hexagongrid.fill"
        case .control: return "gauge.with.dots.needle.50percent"
        }
    }

    var shortcut: KeyEquivalent {
        switch self {
        case .chat: return "1"
        case .france: return "2"
        case .ojo: return "3"
        case .control: return "4"
        }
    }
}

struct SUPRAOJOHomeView: View {
    @AppStorage("SUPRA_PRIMARY_ROUTE_V1")
    private var storedRoute = SUPRAOJORoute.chat.rawValue

    private var selection: Binding<SUPRAOJORoute?> {
        Binding(
            get: { SUPRAOJORoute(rawValue: storedRoute) ?? .chat },
            set: { storedRoute = ($0 ?? .chat).rawValue }
        )
    }

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 220, ideal: 236, max: 260)
        } detail: {
            detail
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    storedRoute = SUPRAOJORoute.chat.rawValue
                } label: {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .help("Revenir au Chat · ⌘1")
                .keyboardShortcut("1", modifiers: [.command])

                Button {
                    NSApp.keyWindow?.toggleFullScreen(nil)
                } label: {
                    Label("Plein écran", systemImage: "arrow.up.left.and.arrow.down.right")
                }
                .help("Basculer en plein écran")
                .keyboardShortcut("f", modifiers: [.command, .control])
            }
        }
        .frame(minWidth: 1120, minHeight: 720)
        .preferredColorScheme(.dark)
        .tint(.cyan)
    }

    private var sidebar: some View {
        List(selection: selection) {
            sidebarHeader

            Section("Conversation") {
                routeRow(.chat)
            }

            Section("Comprendre") {
                routeRow(.france)
                routeRow(.ojo)
            }

            Section("Technique") {
                routeRow(.control)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("SUPRA × ojO")
    }

    private var sidebarHeader: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("SUPRA × ojO")
                .font(.title2.weight(.semibold))
            Text("Une seule maison.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private func routeRow(_ route: SUPRAOJORoute) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(route.title)
                    .font(.headline)
                Text(route.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        } icon: {
            Image(systemName: route.symbol)
                .symbolRenderingMode(.hierarchical)
                .font(.body.weight(.medium))
                .frame(width: 24)
        }
        .tag(route)
        .padding(.vertical, 5)
    }

    @ViewBuilder
    private var detail: some View {
        switch SUPRAOJORoute(rawValue: storedRoute) ?? .chat {
        case .chat:
            SUPRAChatView()
        case .france:
            FranceOrganismNativeView()
        case .ojo:
            OJOWorkspaceView()
        case .control:
            SupraControlCenterView()
        }
    }
}
