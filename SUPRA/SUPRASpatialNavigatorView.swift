import SwiftUI

struct SpatialDomain: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let description: String
    let childDomains: [SpatialDomain]
}

struct SUPRASpatialNavigatorView: View {
    @Binding var selectedView: String

    private let domains: [SpatialDomain] = [
        SpatialDomain(id: "core", name: "Core", icon: "command", color: .supraAccent, description: "Centre de contrôle et état du système", childDomains: [
            SpatialDomain(id: "Accueil", name: "Tableau de bord", icon: "house", color: .supraAccent, description: "Vue d'ensemble consolidée", childDomains: []),
            SpatialDomain(id: "Tour de contrôle", name: "Tour de contrôle", icon: "gauge.with.dots.needle.33percent", color: .supraAccent, description: "Métriques temps réel", childDomains: []),
        ]),
        SpatialDomain(id: "twins", name: "Environment Twin", icon: "desktopcomputer", color: .supraGreen, description: "Jumeau numérique complet de l'iMac", childDomains: [
            SpatialDomain(id: "Environnement", name: "Environnement", icon: "desktopcomputer", color: .supraGreen, description: "Hardware, software, données", childDomains: []),
            SpatialDomain(id: "Ressources", name: "Ressources", icon: "cpu", color: .supraRed, description: "CPU, RAM, thermique, énergie", childDomains: []),
            SpatialDomain(id: "Potentiel", name: "Potentiel", icon: "chart.pie.fill", color: .supraTeal, description: "Potentiel inutilisé", childDomains: []),
        ]),
        SpatialDomain(id: "evolution", name: "Evolution Engine", icon: "arrow.triangle.2.circlepath", color: .supraGreen, description: "Moteur d'auto-évolution", childDomains: [
            SpatialDomain(id: "Propositions", name: "Propositions", icon: "lightbulb.fill", color: .supraAccent, description: "Recommandations avec Φ", childDomains: []),
            SpatialDomain(id: "Évolution", name: "Évolution", icon: "bolt.shield.fill", color: .supraPurple, description: "Propositions auto/humain", childDomains: []),
        ]),
        SpatialDomain(id: "missions", name: "Mission Space", icon: "flag", color: .supraOrange, description: "Missions et décisions", childDomains: [
            SpatialDomain(id: "Missions", name: "Missions", icon: "flag", color: .supraOrange, description: "Missions actives", childDomains: []),
            SpatialDomain(id: "Décisions", name: "Décisions", icon: "list.bullet.clipboard.fill", color: .supraAccent, description: "File d'attente décisionnelle", childDomains: []),
        ]),
        SpatialDomain(id: "memory", name: "Memory Space", icon: "brain.head.profile", color: .supraTeal, description: "Mémoire et connaissances", childDomains: [
            SpatialDomain(id: "Mémoire", name: "Mémoire", icon: "brain.head.profile", color: .supraTeal, description: "Lentille mémoire", childDomains: []),
            SpatialDomain(id: "Recherche", name: "Recherche", icon: "magnifyingglass", color: .supraRed, description: "Recherche globale", childDomains: []),
        ]),
        SpatialDomain(id: "explore", name: "Exploration", icon: "circle.hexagongrid", color: .supraPurple, description: "Univers et découverte", childDomains: [
            SpatialDomain(id: "Univers", name: "Univers", icon: "circle.hexagongrid", color: .supraPurple, description: "Vue univers", childDomains: []),
            SpatialDomain(id: "Twins", name: "Twins", icon: "person.2", color: .supraGreen, description: "Centre des twins", childDomains: []),
            SpatialDomain(id: "Workspace", name: "Workspace", icon: "folder", color: .supraBlue, description: "Explorateur de workspace", childDomains: []),
        ]),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
                    ForEach(domains) { domain in
                        domainCard(domain)
                    }
                }
                Text("Entrez dans un domaine pour explorer ses sous-systèmes")
                    .font(.system(size: 10))
                    .foregroundColor(.supraTextTertiary)
                    .frame(maxWidth: .infinity)
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SUPRA SPATIAL NAVIGATOR").font(.caption.weight(.bold)).tracking(2).foregroundColor(.supraAccent)
            Text("Explorez le système comme un univers")
                .font(.system(size: 14)).foregroundColor(.supraTextSecondary)
            Text("Core · Environment Twin · Evolution Engine · Mission Space · Memory Space · Exploration")
                .font(.system(size: 9)).foregroundColor(.supraTextTertiary)
        }
    }

    private func domainCard(_ domain: SpatialDomain) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(domain.color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: domain.icon)
                        .font(.system(size: 18))
                        .foregroundColor(domain.color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(domain.name).font(.system(size: 15, weight: .bold)).foregroundColor(.supraText)
                    Text(domain.description).font(.system(size: 10)).foregroundColor(.supraTextSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 10)).foregroundColor(.supraTextTertiary)
            }

            if !domain.childDomains.isEmpty {
                Divider().background(Color.supraBorder)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                    ForEach(domain.childDomains) { child in
                        Button {
                            selectedView = child.id
                        } label: {
                            HStack(spacing: 6) {
                                Circle().fill(child.color).frame(width: 5, height: 5)
                                Text(child.name).font(.system(size: 10, weight: .medium)).foregroundColor(.supraText).lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(child.color.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius).stroke(domain.color.opacity(0.3), lineWidth: 1))
        .shadow(color: domain.color.opacity(0.05), radius: 8, y: 2)
    }
}
