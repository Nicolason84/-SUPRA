import SwiftUI

struct SUPRAOSLiveView: View {
    @State private var events: [(String, String, Color)] = [
        ("Universe Engine démarré", "il y a 2m", .supraGreen),
        ("Knowledge Graph chargé", "il y a 2m", .supraAccent),
        ("Twins générés (4)", "il y a 1m", .supraPurple),
        ("Bridge connecté", "il y a 30s", .supraGreen),
        ("Mission prête", "à l'instant", .supraOrange),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                statusGrid
                eventFeed
            }
            .padding(SUPRAOSDesignSystem.padding)
        }
        .background(Color.supraBackground)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Live")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.supraText)
                Text("Activité en temps réel du système")
                    .font(.system(size: 13))
                    .foregroundColor(.supraTextSecondary)
            }
            Spacer()
            HStack(spacing: 4) {
                Circle().fill(Color.supraGreen).frame(width: 8, height: 8)
                Text("Connecté")
                    .font(.system(size: 12))
                    .foregroundColor(.supraGreen)
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Color.supraGreen.opacity(0.1))
            .clipShape(Capsule())
        }
    }

    private var statusGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: SUPRAOSDesignSystem.spacingSmall) {
            statusCard("Bridge", value: "Connecté", icon: "antenna.radiowaves.left.and.right", color: .supraGreen)
            statusCard("Runtime", value: "Actif", icon: "gear", color: .supraAccent)
            statusCard("Missions", value: "1", icon: "flag", color: .supraPurple)
            statusCard("Workers", value: "0", icon: "person.2", color: .supraTextSecondary)
        }
    }

    private func statusCard(_ label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundColor(color)
            Text(value).font(.system(size: 18, weight: .bold)).foregroundColor(.supraText)
            Text(label).font(.system(size: 11)).foregroundColor(.supraTextSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var eventFeed: some View {
        VStack(alignment: .leading, spacing: 12) {
            SUPRAOSSectionHeader(title: "Flux d'événements")
            ForEach(Array(events.enumerated()), id: \.offset) { i, event in
                HStack(spacing: 12) {
                    Circle().fill(event.2).frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.0)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.supraText)
                        Text(event.1)
                            .font(.system(size: 11))
                            .foregroundColor(.supraTextTertiary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
                if i < events.count - 1 {
                    Divider().background(Color.supraBorder)
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }
}
