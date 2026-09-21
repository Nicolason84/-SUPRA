import SwiftUI

private enum OJOWorkspaceMode: String, CaseIterable, Identifiable {
    case living
    case decisions
    case missions
    case evidence

    var id: String { rawValue }

    var title: String {
        switch self {
        case .living: return "Vivant"
        case .decisions: return "Décisions"
        case .missions: return "Missions"
        case .evidence: return "Preuves"
        }
    }

    var symbol: String {
        switch self {
        case .living: return "waveform.path.ecg"
        case .decisions: return "tray.full.fill"
        case .missions: return "scope"
        case .evidence: return "doc.text.magnifyingglass"
        }
    }

    var subtitle: String {
        switch self {
        case .living:
            return "État, apprentissage et physiologie"
        case .decisions:
            return "Décisions qui nécessitent de l’attention"
        case .missions:
            return "Travail en cours et trajectoires"
        case .evidence:
            return "Preuves, dérives et matérialisation"
        }
    }
}

struct OJOWorkspaceView: View {
    @AppStorage("OJO_WORKSPACE_MODE_V1")
    private var storedMode = OJOWorkspaceMode.living.rawValue

    private var mode: Binding<OJOWorkspaceMode> {
        Binding(
            get: { OJOWorkspaceMode(rawValue: storedMode) ?? .living },
            set: { storedMode = $0.rawValue }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            workspaceHeader
            Divider()
            workspaceContent
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("ojO")
    }

    private var workspaceHeader: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ojO")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))

                Text((OJOWorkspaceMode(rawValue: storedMode) ?? .living).subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Picker("Espace ojO", selection: mode) {
                ForEach(OJOWorkspaceMode.allCases) { item in
                    Label(item.title, systemImage: item.symbol)
                        .tag(item)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 560)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var workspaceContent: some View {
        switch OJOWorkspaceMode(rawValue: storedMode) ?? .living {
        case .living:
            OJOOrganismNativeView()
        case .decisions:
            DecisionInboxView()
        case .missions:
            MissionCenterView()
        case .evidence:
            SUPRAProcessObservatoryView()
        }
    }
}

#Preview {
    OJOWorkspaceView()
        .frame(width: 1280, height: 820)
        .preferredColorScheme(.dark)
}
