import SwiftUI

struct SUPRAOSTwinCenterView: View {
    @State private var selectedTwin: String?
    @State private var searchText = ""

    let twinTypes: [(String, String, Color, String)] = [
        ("Workspace", "desktopcomputer", .supraAccent, "Environnement de travail SUPRA"),
        ("Knowledge", "brain.head.profile", .supraPurple, "Graphe de connaissance"),
        ("Runtime", "gear", .supraOrange, "Moteur d'exécution OpenCode"),
        ("Missions", "flag", .supraRed, "Centre des missions"),
        ("Decisions", "checkmark.shield", .supraGreen, "Registre des décisions"),
        ("Projects", "folder", .supraTeal, "Projets du workspace"),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                searchBar
                twinGrid
            }
            .padding(SUPRAOSDesignSystem.padding)
        }
        .background(Color.supraBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Twin Center")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.supraText)
            Text("\(twinTypes.count) types de Twins · générés par le Knowledge Graph")
                .font(.system(size: 13))
                .foregroundColor(.supraTextSecondary)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.supraTextTertiary).font(.system(size: 14))
            TextField("Rechercher un Twin...", text: $searchText).textFieldStyle(.plain).font(.system(size: 14)).foregroundColor(.supraText)
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var twinGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: SUPRAOSDesignSystem.spacing) {
            ForEach(twinTypes, id: \.0) { name, icon, color, desc in
                twinCard(name: name, icon: icon, color: color, description: desc)
            }
        }
    }

    private func twinCard(name: String, icon: String, color: Color, description: String) -> some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.15)).frame(width: 44, height: 44)
                    Image(systemName: icon).font(.title3).foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(name).font(.system(size: 16, weight: .semibold)).foregroundColor(.supraText)
                    Text(description).font(.system(size: 12)).foregroundColor(.supraTextSecondary)
                }
                Spacer()
                SUPRAOSBadge(text: "Actif", color: .supraGreen)
            }
            Divider().background(Color.supraBorder)
            HStack {
                statPill("Santé", value: "9.2", color: .supraGreen)
                statPill("Objets", value: "124", color: .supraAccent)
                statPill("V", value: "1.0", color: .supraTextSecondary)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func statPill(_ label: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(value).font(.system(size: 13, weight: .bold)).foregroundColor(color)
            Text(label).font(.system(size: 10)).foregroundColor(.supraTextTertiary)
        }
        .padding(.horizontal, 10).padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}
