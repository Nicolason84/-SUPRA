import SwiftUI

struct SUPRAOSMissionCanvasView: View {
    @State private var missions: [(String, String, String, Color)] = [
        ("NOVA_UNIVERSE_ENGINE_V1", "Construction du moteur universel", "active", .supraGreen),
        ("NOVA_KNOWLEDGE_OS_FOUNDATION_V1", "Fondations du Knowledge OS", "completed", .supraAccent),
        ("SUPRA_KNOWLEDGE_GRAPH_V2", "Graphe de connaissance V2", "completed", .supraAccent),
        ("SUPRA_EXECUTIVE_MISSION_CENTER_V001", "Centre des missions exécutif", "archived", .supraTextSecondary),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                actionBar
                missionFlow
            }
            .padding(SUPRAOSDesignSystem.padding)
        }
        .background(Color.supraBackground)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Mission Center")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.supraText)
                Text("\(missions.filter { $0.2 == "active" }.count) active · \(missions.count) totale")
                    .font(.system(size: 13))
                    .foregroundColor(.supraTextSecondary)
            }
            Spacer()
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button { } label: {
                Label("Nouvelle mission", systemImage: "plus")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color.supraAccent)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            Button { } label: {
                Label("Files d'attente", systemImage: "list.bullet")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.supraText)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color.supraSurface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.supraBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }

    private var missionFlow: some View {
        VStack(spacing: 0) {
            ForEach(Array(missions.enumerated()), id: \.offset) { index, mission in
                HStack(spacing: 16) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(missionColor(mission.2))
                            .frame(width: 12, height: 12)
                        if index < missions.count - 1 {
                            Rectangle()
                                .fill(Color.supraBorder)
                                .frame(width: 1, height: 40)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(mission.0)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.supraText)
                            SUPRAOSBadge(text: mission.2.capitalized, color: missionColor(mission.2))
                        }
                        Text(mission.1)
                            .font(.system(size: 12))
                            .foregroundColor(.supraTextSecondary)
                    }
                    Spacer()
                    if mission.2 == "active" {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func missionColor(_ status: String) -> Color {
        switch status {
        case "active": return .supraGreen
        case "completed": return .supraAccent
        case "archived": return .supraTextSecondary
        default: return .supraOrange
        }
    }
}
