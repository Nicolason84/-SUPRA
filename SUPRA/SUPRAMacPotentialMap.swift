import SwiftUI
import Combine

struct PotentialItem: Identifiable {
    let id = UUID()
    let domain: String
    let title: String
    let detail: String
    let value: String
    let icon: String
    let color: Color
    let confidence: Double
}

@MainActor
final class SUPRAMacPotential: ObservableObject {
    static let shared = SUPRAMacPotential()

    @Published private(set) var items: [PotentialItem] = []
    @Published private(set) var totalUtilization: Double = 0
    @Published private(set) var potentialPercent: Double = 0
    @Published private(set) var summary: String = ""
    @Published private(set) var lastUpdated: Date?

    private let hardwareTwin = SUPRAHardwareTwin.shared
    private let softwareTwin = SUPRASoftwareTwin.shared
    private let dataTwin = SUPRADataTwin.shared
    private let developerTwin = SUPRADeveloperTwin.shared
    private let governor = SUPRAResourceGovernor.shared
    private let envModel = SUPRAEnvironmentWorldModel.shared

    private init() {}

    func compute() {
        guard let state = envModel.state else { return }
        var newItems: [PotentialItem] = []
        var usedScore = 0.0
        var maxScore = 0.0

        // CPU inutilisé
        if let hw = state.hardware {
            let cpuIdle = 1.0 - hw.cpuUsage
            if cpuIdle > 0.3 {
                newItems.append(PotentialItem(
                    domain: "CPU", title: "Puissance inutilisée",
                    detail: "\(Int(cpuIdle * 100))% du CPU disponible pour des tâches parallèles",
                    value: "\(Int(cpuIdle * 100))% libre", icon: "cpu", color: .supraAccent, confidence: 0.90
                ))
                maxScore += 25
                usedScore += 25 * (1 - cpuIdle)
            } else {
                usedScore += 25 * hw.cpuUsage
                maxScore += 25
            }

            // Stockage récupérable
            if hw.storageFreeGB < hw.storageTotalGB * 0.2 {
                let recoverable = hw.storageTotalGB * 0.15
                newItems.append(PotentialItem(
                    domain: "Stockage", title: "Stockage récupérable",
                    detail: "~\(Int(recoverable))GB récupérables via nettoyage (caches, DerivedData, doublons)",
                    value: "\(Int(recoverable))GB", icon: "trash.fill", color: .supraTeal, confidence: 0.85
                ))
                maxScore += 20
                usedScore += 20 * (1 - recoverable / hw.storageTotalGB)
            } else {
                usedScore += 20
                maxScore += 20
            }
        }

        // RAM
        let ramFree = 1.0 - governor.ramFraction
        if ramFree > 0.2 {
            newItems.append(PotentialItem(
                domain: "RAM", title: "Mémoire disponible",
                detail: "\(Int(ramFree * 100))% de RAM libre pour des traitements en mémoire",
                value: "\(Int(ramFree * 100))% libre", icon: "memorychip.fill", color: .supraBlue, confidence: 0.88
            ))
            maxScore += 15
            usedScore += 15 * (1 - ramFree)
        } else {
            usedScore += 15
            maxScore += 15
        }

        // Automatisations possibles
        if let dev = state.developer {
            if dev.uncommittedRepos > 3 {
                newItems.append(PotentialItem(
                    domain: "Automatisation", title: "Auto-commit Git",
                    detail: "\(dev.uncommittedRepos) dépôts non commités — hook pre-commit automatisable",
                    value: "\(dev.uncommittedRepos) repos", icon: "arrow.triangle.branch", color: .supraOrange, confidence: 0.76
                ))
                maxScore += 15
                usedScore += 15 * 0.5
            } else {
                usedScore += 15
                maxScore += 15
            }

            // Projets dormants
            if dev.projectCount > 10 {
                let dormant = max(1, dev.projectCount - 5)
                newItems.append(PotentialItem(
                    domain: "Projets", title: "Projets dormants",
                    detail: "~\(dormant) projets Xcode non ouverts depuis 30+ jours",
                    value: "\(dormant) projets", icon: "folder.fill", color: .supraPurple, confidence: 0.70
                ))
                maxScore += 10
                usedScore += 10 * 0.6
            } else {
                usedScore += 10
                maxScore += 10
            }

            // Capacités IA locales
            if dev.swiftFileCount > 100 {
                newItems.append(PotentialItem(
                    domain: "IA Locale", title: "Capacités IA locales",
                    detail: "\(dev.swiftFileCount) fichiers Swift, \(dev.swiftPackageCount) packages — ripe pour de l'analyse IA embarquée",
                    value: "\(dev.swiftFileCount) fichiers", icon: "brain.head.profile", color: .supraAccent, confidence: 0.68
                ))
            }

            // Optimisations workflow
            if dev.derivedDataSizeMB > 1000 {
                newItems.append(PotentialItem(
                    domain: "Workflow", title: "Optimisation Xcode",
                    detail: "DerivedData: \(dev.derivedDataSizeMB)MB — le nettoyage régulier accélère les builds de 15-30%",
                    value: "\(dev.derivedDataSizeMB)MB", icon: "hammer.fill", color: .supraOrange, confidence: 0.92
                ))
                maxScore += 15
                usedScore += 15 * 0.4
            } else {
                usedScore += 15
                maxScore += 15
            }
        }

        items = newItems
        totalUtilization = maxScore > 0 ? usedScore / maxScore : 0.5
        potentialPercent = (1.0 - totalUtilization) * 100
        summary = "Votre Mac possède \(Int(potentialPercent))% de potentiel inutilisé."
        lastUpdated = Date()
    }
}

struct SUPRAMacPotentialMap: View {
    @StateObject private var potential = SUPRAMacPotential.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                potentialGauge
                if !potential.items.isEmpty {
                    itemsGrid
                    insightSection
                }
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
        .onAppear { potential.compute() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("MAC POTENTIAL MAP")
                .font(.caption.weight(.bold)).tracking(1.6).foregroundColor(.supraAccent)
            Text(potential.summary)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.supraText)
            if let d = potential.lastUpdated {
                Text("Analyse: \(d.formatted(date: .omitted, time: .standard))")
                    .font(.caption2).foregroundColor(.supraTextTertiary)
            }
        }
    }

    private var potentialGauge: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.supraBorder.opacity(0.3), lineWidth: 10)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: CGFloat(1.0 - potential.potentialPercent / 100))
                    .stroke(gaugeColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("\(Int(potential.potentialPercent))%")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(gaugeColor)
                    Text("INUTILISÉ")
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundColor(.supraTextTertiary)
                        .tracking(1)
                }
            }
            HStack(spacing: 16) {
                gaugeLegend("Utilisé", fill: 1.0 - potential.potentialPercent / 100)
                gaugeLegend("Potentiel", fill: potential.potentialPercent / 100, color: gaugeColor)
            }
        }
        .padding(SUPRAOSDesignSystem.padding)
        .frame(maxWidth: .infinity)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var gaugeColor: Color {
        potential.potentialPercent > 50 ? .supraGreen : potential.potentialPercent > 25 ? .supraAccent : .supraOrange
    }

    private func gaugeLegend(_ label: String, fill: Double, color: Color = .supraTextSecondary) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text("\(Int(fill * 100))% \(label)")
                .font(.system(size: 9)).foregroundColor(.supraTextSecondary)
        }
    }

    private var itemsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 12)], spacing: 12) {
            ForEach(potential.items) { item in
                potentialCard(item)
            }
        }
    }

    private func potentialCard(_ item: PotentialItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundColor(item.color)
                    .frame(width: 28, height: 28)
                    .background(item.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.title).font(.system(size: 13, weight: .semibold)).foregroundColor(.supraText)
                    Text(item.value).font(.system(size: 10, weight: .bold)).foregroundColor(item.color)
                }
                Spacer()
                SUPRAOSBadge(text: "Φ \(Int(item.confidence * 100))%", color: .supraAccent)
            }
            Text(item.detail)
                .font(.system(size: 10))
                .foregroundColor(.supraTextSecondary)
                .lineSpacing(2)
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var insightSection: some View {
        SUPRAOSCard(
            title: "INSIGHT GLOBAL",
            subtitle: "Synthèse du potentiel Mac",
            icon: "lightbulb.fill",
            color: .supraAccent
        ) {
            VStack(alignment: .leading, spacing: 8) {
                insightRow("Priorité", potential.items.first?.title ?? "—")
                insightRow("Domaine clé", potential.items.first?.domain ?? "—")
                insightRow("Confiance moyenne", "Φ \(averageConfidence())%")
                insightRow("Prochain pas", nextStep())
            }
        }
    }

    private func insightRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.supraTextTertiary)
                .frame(width: 80, alignment: .trailing)
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.supraText)
        }
    }

    private func averageConfidence() -> Int {
        guard !potential.items.isEmpty else { return 0 }
        let sum = potential.items.reduce(0) { $0 + $1.confidence }
        return Int((sum / Double(potential.items.count)) * 100)
    }

    private func nextStep() -> String {
        potential.items.first.map {
            "Activer l'optimisation '\($0.title)' avec une confiance de \(Int($0.confidence * 100))%"
        } ?? "Aucune opportunité détectée"
    }
}
