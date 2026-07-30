import SwiftUI

struct SUPRAOSHomeView: View {
    @EnvironmentObject var universe: TwinUniverse
    @State private var searchText = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                searchBar
                statsGrid
                universeSection
                twinsSection
                activitySection
            }
            .padding(SUPRAOSDesignSystem.padding)
        }
        .background(Color.supraBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SUPRA OS")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.supraAccent)
                .tracking(2)
            Text("Bienvenue")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.supraText)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.supraTextTertiary)
                .font(.system(size: 14))
            TextField("Rechercher dans l'Univers...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .foregroundColor(.supraText)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.supraTextTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: SUPRAOSDesignSystem.spacingSmall) {
            SUPRAOSStatCard(label: "Objets", value: "\(universe.state?.objectCount ?? 0)", icon: "cube", color: .supraAccent)
            SUPRAOSStatCard(label: "Twins", value: "\(universe.state?.twinCount ?? 0)", icon: "person.2.fill", color: .supraPurple)
            SUPRAOSStatCard(label: "Sources", value: "\(universe.state?.sourceCount ?? 0)", icon: "square.on.square", color: .supraGreen)
            SUPRAOSStatCard(label: "Santé", value: "\(Int((universe.state?.healthScore ?? 0)))", icon: "heart.fill", color: .supraRed, trend: "Stable")
        }
    }

    private var universeSection: some View {
        SUPRAOSCard(title: "Univers", subtitle: "Explorez le graphe de connaissance", icon: "sparkle", color: .supraPurple) {
            HStack(spacing: 16) {
                statItem(value: "\(universe.state?.objectCount ?? 0)", label: "Objets", color: .supraAccent)
                statItem(value: "\(universe.state?.relationCount ?? 0)", label: "Relations", color: .supraGreen)
                statItem(value: universe.state?.uptime ?? "0h", label: "Uptime", color: .supraTeal)
            }
        }
    }

    private var twinsSection: some View {
        SUPRAOSCard(title: "Twins", subtitle: "Entités actives", icon: "person.2.fill", color: .supraPurple) {
            HStack(spacing: 16) {
                statItem(value: "\(universe.state?.twinCount ?? 0)", label: "Enregistrés", color: .supraPurple)
                statItem(value: "\(universe.state?.bindingCount ?? 0)", label: "Liaisons", color: .supraOrange)
            }
        }
    }

    private var activitySection: some View {
        SUPRAOSCard(title: "Activité", subtitle: "Derniers événements", icon: "clock", color: .supraTeal) {
            VStack(alignment: .leading, spacing: 8) {
                activityRow("Univers initialisé", time: "maintenant", color: .supraGreen)
                activityRow("Knowledge Graph construit", time: "récent", color: .supraAccent)
                activityRow("Twins générés", time: "récent", color: .supraPurple)
            }
        }
    }

    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.supraTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func activityRow(_ text: String, time: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.supraText)
            Spacer()
            Text(time)
                .font(.system(size: 11))
                .foregroundColor(.supraTextTertiary)
        }
        .padding(.vertical, 2)
    }
}
