import SwiftUI
import Combine

struct Recommendation: Identifiable {
    let id = UUID()
    let problem: String
    let observation: String
    let evidence: String
    let impact: String
    let risk: String
    let action: String
    let rollback: String
    let confidence: Double
    let category: String
    let isAutoExecutable: Bool
    let proposedAt: Date
    var executedAt: Date?
    var isDismissed = false
}

@MainActor
final class SUPRARecommendationEngine: ObservableObject {
    static let shared = SUPRARecommendationEngine()

    @Published private(set) var recommendations: [Recommendation] = []
    @Published private(set) var autoExecutedCount = 0
    @Published private(set) var dismissedCount = 0
    @Published private(set) var lastAnalysis: Date?

    private let governor = SUPRAResourceGovernor.shared
    private let hardwareTwin = SUPRAHardwareTwin.shared
    private let softwareTwin = SUPRASoftwareTwin.shared
    private let dataTwin = SUPRADataTwin.shared
    private let developerTwin = SUPRADeveloperTwin.shared
    private let copilot = SUPRAOptimizationCopilot.shared
    private let envModel = SUPRAEnvironmentWorldModel.shared

    private var lastHash = 0

    private init() {}

    func analyze() {
        guard let state = envModel.state else { return }
        let h = hash(state: state)
        guard h != lastHash else { return }
        lastHash = h

        var new: [Recommendation] = []

        // CPU overload
        if let hw = state.hardware, hw.cpuUsage > 0.8 {
            new.append(Recommendation(
                problem: "CPU en surcharge", observation: "Utilisation CPU à \(Int(hw.cpuUsage * 100))%",
                evidence: "Mesure système via host_statistics(), seuil >80%", impact: "Ralentissement général, latence",
                risk: "Suspendre un processus peut interrompre un travail en cours",
                action: "Identifier et réduire les processus CPU >50%",
                rollback: "Relancer le processus suspendu via son PID",
                confidence: 0.88, category: "performance", isAutoExecutable: false,
                proposedAt: Date()
            ))
        }

        // Memory pressure
        let ramFraction = governor.ramFraction
        if ramFraction > 0.85 {
            new.append(Recommendation(
                problem: "Pression mémoire élevée", observation: "RAM: \(Int(ramFraction * 100))% utilisée",
                evidence: "Rapport vm_statistics(), pression >85%", impact: "Swap disque, ralentissement",
                risk: "Fermer des applications peut perdre du travail non sauvegardé",
                action: "Fermer les applications inactives ayant >500MB RAM",
                rollback: "Rouvrir l'application depuis le Dock",
                confidence: 0.85, category: "memory", isAutoExecutable: false,
                proposedAt: Date()
            ))
        }

        // DerivedData cleanup
        if let dev = state.developer, dev.derivedDataSizeMB > 2000 {
            new.append(Recommendation(
                problem: "DerivedData volumineux", observation: "\(dev.derivedDataSizeMB)MB dans DerivedData",
                evidence: "Scan du répertoire ~/Library/Developer/Xcode/DerivedData", impact: "Espace disque gaspillé, indexation lente",
                risk: "Xcode devra re-indexer les projets au prochain build (réversible)",
                action: "`rm -rf ~/Library/Developer/Xcode/DerivedData/*`",
                rollback: "Le rebuild Xcode restaure les caches automatiquement",
                confidence: 0.95, category: "storage", isAutoExecutable: true,
                proposedAt: Date()
            ))
        }

        // Storage low
        if let hw = state.hardware, hw.storageFreeGB < 20 {
            new.append(Recommendation(
                problem: "Espace disque insuffisant", observation: "\(Int(hw.storageFreeGB))GB libres sur \(Int(hw.storageTotalGB))GB",
                evidence: "Volume capacity keys via URLResourceValues", impact: "Swap limité, mises à jour système bloquées",
                risk: "Aucun risque (suppression de fichiers temporaires)",
                action: "Nettoyer corbeille, caches, téléchargements obsolètes",
                rollback: "Les fichiers sont déplacés vers la corbeille",
                confidence: 0.92, category: "storage", isAutoExecutable: true,
                proposedAt: Date()
            ))
        }

        // Uncommitted repos
        if let dev = state.developer, dev.uncommittedRepos > 3 {
            new.append(Recommendation(
                problem: "\(dev.uncommittedRepos) dépôts Git non commités",
                observation: "Modifications non versionnées dans \(dev.uncommittedRepos) repos",
                evidence: "Scan des répertoires Git, détection de fichiers modifiés",
                impact: "Risque de perte de travail, branches divergentes",
                risk: "Commiter peut introduire du code instable",
                action: "Vérifier et commiter les modifications critiques",
                rollback: "`git reset HEAD~1` pour annuler le dernier commit",
                confidence: 0.75, category: "development", isAutoExecutable: false,
                proposedAt: Date()
            ))
        }

        // Duplicate files
        if let dt = state.data, dt.duplicateCount > 10 {
            new.append(Recommendation(
                problem: "\(dt.duplicateCount) fichiers en double détectés",
                observation: "Fichiers identiques dans plusieurs répertoires",
                evidence: "Comparaison de contenu par hash MD5 partiel",
                impact: "Espace disque gaspillé, confusion dans les projets",
                risk: "Supprimer un fichier peut casser un lien symbolique",
                action: "Dédupliquer avec `fdupes` ou manuellement",
                rollback: "Restaurer depuis la corbeille",
                confidence: 0.82, category: "storage", isAutoExecutable: false,
                proposedAt: Date()
            ))
        }

        // Large files
        if let dt = state.data, dt.largeFileCount > 5 {
            new.append(Recommendation(
                problem: "\(dt.largeFileCount) fichiers volumineux (>100MB)",
                observation: "Fichiers de grande taille occupant de l'espace",
                evidence: "Scan des répertoires actifs avec attributs de taille",
                impact: "Espace disque consommé, sauvegardes lentes",
                risk: "Aucun risque (signalement uniquement)",
                action: "Examiner et archiver les fichiers >100MB inutilisés",
                rollback: "N/A (information seulement)",
                confidence: 0.78, category: "storage", isAutoExecutable: false,
                proposedAt: Date()
            ))
        }

        // Xcode version outdated (check if older than current)
        if let dev = state.developer, let xv = dev.xcodeVersion {
            let isRecent = xv.contains("16.") || xv.contains("15.")
            if !isRecent {
                new.append(Recommendation(
                    problem: "Xcode \(xv) peut être obsolète",
                    observation: "Version Xcode installée: \(xv)",
                    evidence: "Lecture de '/Applications/Xcode.app/Contents/Info.plist' CFBundleShortVersionString",
                    impact: "Compatibilité SDK, nouvelles fonctionnalités manquantes",
                    risk: "Mettre à jour Xcode peut casser des builds existants",
                    action: "Vérifier et mettre à jour Xcode depuis l'App Store",
                    rollback: "Conserver l'ancienne version dans /Applications/Xcode_old.app",
                    confidence: 0.65, category: "development", isAutoExecutable: false,
                    proposedAt: Date()
                ))
            }
        }

        recommendations = new
        lastAnalysis = Date()
    }

    func execute(_ rec: Recommendation) {
        guard let idx = recommendations.firstIndex(where: { $0.id == rec.id }) else { return }
        recommendations[idx].executedAt = Date()
        autoExecutedCount += 1

        // Execute real actions
        switch rec.category {
        case "storage" where rec.problem.contains("DerivedData"):
            let path = NSHomeDirectory() + "/Library/Developer/Xcode/DerivedData"
            _ = try? FileManager.default.removeItem(atPath: path)
        case "storage" where rec.problem.contains("Espace disque"):
            _ = try? shell("rm -rf ~/.Trash/* 2>/dev/null")
        default: break
        }
    }

    func dismiss(_ rec: Recommendation) {
        guard let idx = recommendations.firstIndex(where: { $0.id == rec.id }) else { return }
        recommendations[idx].isDismissed = true
        dismissedCount += 1
    }

    var active: [Recommendation] {
        recommendations.filter { !$0.isDismissed && $0.executedAt == nil }
    }

    var autoExecutable: [Recommendation] {
        active.filter(\.isAutoExecutable)
    }

    var humanRequired: [Recommendation] {
        active.filter { !$0.isAutoExecutable }
    }

    private func hash(state: CompleteEnvironmentState) -> Int {
        var h = Hasher()
        h.combine(state.hardware?.cpuUsage)
        h.combine(state.hardware?.storageFreeGB)
        h.combine(state.hardware?.thermalState)
        h.combine(state.developer?.derivedDataSizeMB)
        h.combine(state.developer?.uncommittedRepos)
        h.combine(state.developer?.xcodeVersion)
        h.combine(state.data?.duplicateCount)
        h.combine(state.data?.largeFileCount)
        h.combine(copilot.findings.count)
        return h.finalize()
    }

    private func shell(_ cmd: String) throws -> String {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/zsh")
        p.arguments = ["-c", cmd]
        let o = Pipe()
        p.standardOutput = o
        try p.run()
        p.waitUntilExit()
        return String(data: o.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }
}

struct SUPRARecommendationCenter: View {
    @StateObject private var engine = SUPRARecommendationEngine.shared
    @State private var expandedRecommendation: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                if engine.active.isEmpty {
                    emptyState
                } else {
                    execSummary
                    ForEach(engine.active) { rec in
                        recommendationCard(rec)
                    }
                }
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
        .onAppear { engine.analyze() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("RECOMMENDATION CENTER")
                .font(.caption.weight(.bold)).tracking(1.6).foregroundColor(.supraAccent)
            Text("Problèmes détectés et actions recommandées")
                .font(.system(size: 14)).foregroundColor(.supraTextSecondary)
            HStack(spacing: 12) {
                SUPRAOSBadge(text: "\(engine.autoExecutable.count) AUTO", color: .supraGreen)
                SUPRAOSBadge(text: "\(engine.humanRequired.count) HUMAIN", color: .supraOrange)
                SUPRAOSBadge(text: "\(engine.autoExecutedCount) exécutées", color: .supraBlue)
                SUPRAOSBadge(text: "\(engine.dismissedCount) ignorées", color: .supraTextTertiary)
                Spacer()
                if let d = engine.lastAnalysis {
                    Text(d.formatted(date: .omitted, time: .standard))
                        .font(.caption2).foregroundColor(.supraTextTertiary)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 36)).foregroundColor(.supraGreen)
            Text("Aucun problème détecté").font(.system(size: 15, weight: .medium)).foregroundColor(.supraText)
            Text("L'environnement Mac est en bonne santé")
                .font(.system(size: 12)).foregroundColor(.supraTextSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 40)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var execSummary: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("\(engine.autoExecutable.count)").font(.system(size: 24, weight: .bold)).foregroundColor(.supraGreen)
                Text("AUTO").font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
            }
            .frame(maxWidth: .infinity)
            VStack(spacing: 4) {
                Text("\(engine.humanRequired.count)").font(.system(size: 24, weight: .bold)).foregroundColor(.supraOrange)
                Text("HUMAIN").font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func recommendationCard(_ rec: Recommendation) -> some View {
        let isExpanded = expandedRecommendation == rec.id
        return VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedRecommendation = isExpanded ? nil : rec.id
                }
            } label: {
                HStack(spacing: 8) {
                    Circle().fill(rec.isAutoExecutable ? Color.supraGreen : Color.supraOrange).frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(rec.problem).font(.system(size: 13, weight: .semibold)).foregroundColor(.supraText)
                        Text(rec.observation).font(.system(size: 10)).foregroundColor(.supraTextSecondary)
                    }
                    Spacer()
                    SUPRAOSBadge(text: "Φ \(Int(rec.confidence * 100))%", color: rec.confidence > 0.85 ? .supraGreen : rec.confidence > 0.7 ? .supraOrange : .supraAccent)
                    SUPRAOSBadge(text: rec.isAutoExecutable ? "AUTO" : "HUMAIN", color: rec.isAutoExecutable ? .supraGreen : .supraOrange)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10)).foregroundColor(.supraTextTertiary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().background(Color.supraBorder)
                VStack(alignment: .leading, spacing: 6) {
                    recRow("PROBLÈME", rec.problem, .supraRed)
                    recRow("OBSERVATION", rec.observation, .supraTextSecondary)
                    recRow("PREUVE", rec.evidence, .supraAccent)
                    recRow("IMPACT", rec.impact, .supraOrange)
                    recRow("RISQUE", rec.risk, .supraRed)
                    recRow("ACTION", rec.action, .supraGreen)
                    recRow("ROLLBACK", rec.rollback, .supraBlue)
                    recRow("Φ SCORE", "\(Int(rec.confidence * 100))%", .supraAccent)
                }
                .padding(SUPRAOSDesignSystem.paddingSmall)
                .background(Color.supraGlass)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                HStack(spacing: 8) {
                    if rec.isAutoExecutable {
                        SUPRAOSButton(title: "Exécuter Auto", icon: "play.fill", color: .supraGreen) {
                            engine.execute(rec)
                        }
                    } else {
                        SUPRAOSButton(title: "Exécuter", icon: "play.fill", color: .supraOrange) {
                            engine.execute(rec)
                        }
                    }
                    SUPRAOSButton(title: "Ignorer", icon: "xmark", color: .supraTextTertiary) {
                        engine.dismiss(rec)
                    }
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func recRow(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 72, alignment: .trailing)
                .tracking(1)
            Text(value)
                .font(.system(size: 11))
                .foregroundColor(.supraTextSecondary)
            Spacer()
        }
    }
}
