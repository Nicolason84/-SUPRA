import SwiftUI

struct SUPRAImmersiveSpaceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                conceptCard
                architectureCard
                compatibilityCard
                futureCard
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("IMMERSIVE SPACE").font(.caption.weight(.bold)).tracking(2).foregroundColor(.supraAccent)
            Text("Architecture réalité augmentée pour visionOS")
                .font(.system(size: 14)).foregroundColor(.supraTextSecondary)
            Text("Préparé pour RealityKit · RealityView · SwiftUI")
                .font(.system(size: 10)).foregroundColor(.supraTextTertiary)
        }
    }

    private var conceptCard: some View {
        SUPRAOSCard(
            title: "CONCEPT — SUPRA EN ENVIRONNEMENT SPATIAL",
            subtitle: "Le système devient un espace navigable en 3D",
            icon: "visionpro",
            color: .supraAccent
        ) {
            VStack(alignment: .leading, spacing: 8) {
                conceptRow("Nœuds flottants", "Chaque twin, mission et décision devient un objet 3D positionné dans l'espace")
                conceptRow("Connexions lumineuses", "Les relations entre nœuds sont matérialisées par des lignes de lumière")
                conceptRow("Interaction naturelle", "Regard + pincer pour sélectionner, ouvrir, exécuter")
                conceptRow("Couche d'information", "Chaque objet affiche son état, Φ, explication à la demande")
                conceptRow("Mode immersif", "Le bureau disparaît, seul SUPRA reste visible")
            }
        }
    }

    private var architectureCard: some View {
        SUPRAOSCard(
            title: "ARCHITECTURE REALITYKIT",
            subtitle: "SUPRAEntity · SUPRAComponent · SUPRASystem",
            icon: "square.stack.3d.up.fill",
            color: .supraPurple
        ) {
            VStack(alignment: .leading, spacing: 8) {
                codeBlock("""
                // Entité de base pour chaque nœud système
                class SUPRAEntity: Entity {
                    let nodeID: String
                    let state: String
                    let confidence: Double
                    var isSelected: Bool = false
                }

                // Composant de données attaché à chaque entité
                struct SUPRAComponent: Component {
                    let label: String
                    let value: String
                    let icon: String
                    let color: SIMD4<Float>
                }

                // Système de mise à jour continue
                class SUPRASystem: System {
                    override func update(context: SceneUpdateContext) {
                        // Synchronisation avec les twins
                    }
                }
                """)
            }
        }
    }

    private var compatibilityCard: some View {
        SUPRAOSCard(
            title: "COMPATIBILITÉ",
            subtitle: "macOS · visionOS · swiftUI · RealityKit",
            icon: "checkmark.circle.fill",
            color: .supraGreen
        ) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                compatRow("SwiftUI", "✅", "Toutes les vues existantes sont compatibles")
                compatRow("RealityKit", "🔜", "Architecture préparée, import conditionnel")
                compatRow("RealityView", "🔜", "Prêt pour le rendu 3D dans visionOS")
                compatRow("ImmersiveSpace", "🔜", "Scene type pour visionOS")
                compatRow("Twin data", "✅", "Modèles Codable + Sendable")
                compatRow("Φ scoring", "✅", "Confiance intégrée dans chaque nœud")
            }
        }
    }

    private var futureCard: some View {
        SUPRAOSCard(
            title: "PROCHAINES ÉTAPES",
            subtitle: "Vision 2.0 — SUPRA Immersif",
            icon: "sparkles",
            color: .supraBlue
        ) {
            VStack(alignment: .leading, spacing: 8) {
                stepRow("1", "Créer un package RealityKit avec SUPRAEntity + SUPRASystem")
                stepRow("2", "Migrer les vues SwiftUI vers RealityView dans visionOS")
                stepRow("3", "Ajouter des gestes (tap, drag, rotate) sur les nœuds 3D")
                stepRow("4", "Connecter les twins en temps réel via Combine dans le SceneUpdateContext")
                stepRow("5", "Déployer sur visionOS avec ImmersiveSpace")
            }
        }
    }

    private func conceptRow(_ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title.uppercased()).font(.system(size: 8, weight: .semibold)).foregroundColor(.supraAccent)
                .frame(width: 80, alignment: .trailing)
            Text(detail).font(.system(size: 10)).foregroundColor(.supraTextSecondary)
        }
    }

    private func codeBlock(_ code: String) -> some View {
        Text(code)
            .font(.system(size: 9, design: .monospaced))
            .foregroundColor(.supraTextSecondary)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.supraGlass)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func compatRow(_ feature: String, _ status: String, _ note: String) -> some View {
        HStack(spacing: 6) {
            Text(status).font(.system(size: 12))
            VStack(alignment: .leading, spacing: 1) {
                Text(feature).font(.system(size: 11, weight: .medium)).foregroundColor(.supraText)
                Text(note).font(.system(size: 9)).foregroundColor(.supraTextSecondary)
            }
            Spacer()
        }
        .padding(8)
        .background(Color.supraGlass)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func stepRow(_ num: String, _ text: String) -> some View {
        HStack(spacing: 8) {
            Text(num).font(.system(size: 10, weight: .bold)).foregroundColor(.supraAccent)
                .frame(width: 16, height: 16)
                .background(Color.supraAccent.opacity(0.15))
                .clipShape(Circle())
            Text(text).font(.system(size: 11)).foregroundColor(.supraTextSecondary)
        }
    }
}
