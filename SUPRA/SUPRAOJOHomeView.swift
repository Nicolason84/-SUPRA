import SwiftUI
import AppKit

enum SUPRAOJORoute: String, CaseIterable, Identifiable {
    case france
    case ojo
    case supra
    case control

    var id: String { rawValue }

    var title: String {
        switch self {
        case .france: return "France"
        case .ojo: return "ojO"
        case .supra: return "SUPRA"
        case .control: return "Control Center"
        }
    }

    var subtitle: String {
        switch self {
        case .france: return "Organisme territorial"
        case .ojo: return "Interface privée"
        case .supra: return "Executive OS"
        case .control: return "Runtime & evidence"
        }
    }

    var symbol: String {
        switch self {
        case .france: return "map.fill"
        case .ojo: return "waveform.path.ecg.rectangle"
        case .supra: return "sparkles.rectangle.stack"
        case .control: return "gauge.with.dots.needle.50percent"
        }
    }
}

struct SUPRAOJOHomeView: View {
    @State private var selection: SUPRAOJORoute? = .france

    var body: some View {
        NavigationSplitView {
            List(SUPRAOJORoute.allCases, selection: $selection) { route in
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(route.title)
                            .font(.headline)
                        Text(route.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: route.symbol)
                        .symbolRenderingMode(.hierarchical)
                }
                .tag(route)
                .padding(.vertical, 4)
            }
            .navigationTitle("SUPRA × ojO · FRANCE V1")
            .navigationSplitViewColumnWidth(min: 210, ideal: 245, max: 290)
        } detail: {
            Group {
                switch selection ?? .france {
                case .france:
                    FranceOrganismNativeView()
                case .ojo:
                    OJOOrganismNativeView()
                case .supra:
                    ContentView()
                case .control:
                    SupraControlCenterView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    NSApp.keyWindow?.toggleFullScreen(nil)
                } label: {
                    Label("Plein écran", systemImage: "arrow.up.left.and.arrow.down.right")
                }
                .help("Basculer l’app en plein écran")
            }
        }
        .frame(minWidth: 1180, minHeight: 760)
    }
}
