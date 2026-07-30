import SwiftUI

struct SUPRAEvolutionRoomView: View {
    @StateObject private var evolution = SUPRAEvolutionEngine.shared
    @StateObject private var recommendations = SUPRARecommendationEngine.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                autoActionsSection
                Divider().background(Color.supraBorder)
                propositionsSection
                Divider().background(Color.supraBorder)
                humanGatesSection
                Divider().background(Color.supraBorder)
                rulesCard
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 20)).foregroundColor(.supraGreen)
                VStack(alignment: .leading, spacing: 1) {
                    Text("EVOLUTION ROOM").font(.caption.weight(.bold)).tracking(2).foregroundColor(.supraGreen)
                    Text("Cycle d'auto-évolution supervisée")
                        .font(.system(size: 14)).foregroundColor(.supraTextSecondary)
                }
                Spacer()
                HStack(spacing: 6) {
                    Circle().fill(evolution.isObserving ? Color.supraGreen : Color.supraRed).frame(width: 6, height: 6)
                    Text(evolution.isObserving ? "Observation active" : "En veille")
                        .font(.system(size: 10)).foregroundColor(.supraTextSecondary)
                }
            }
        }
    }

    private var autoActionsSection: some View {
        SUPRAOSCard(
            title: "AUTO ACTIONS",
            subtitle: "\(evolution.autoExecutedCount) actions exécutées automatiquement",
            icon: "bolt.shield.fill",
            color: .supraGreen
        ) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    autoStat("\(evolution.autoExecutedCount)", "EXÉCUTÉES", .supraGreen)
                    autoStat("\(recommendations.autoExecutable.count)", "AUTO DISPO", .supraAccent)
                    autoStat("\(recommendations.autoExecutedCount)", "RECO AUTO", .supraBlue)
                    autoStat("\(evolution.proposals.filter { $0.status == .executed }.count)", "PROPOSITIONS", .supraPurple)
                }

                let executed = evolution.proposals.filter { $0.status == .autoExecuted || $0.status == .executed }
                if !executed.isEmpty {
                    Text("HISTORIQUE").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
                    ForEach(executed.suffix(3)) { prop in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 8)).foregroundColor(.supraGreen)
                            Text(prop.title).font(.system(size: 10)).foregroundColor(.supraTextSecondary)
                            Spacer()
                            SUPRAOSBadge(text: "Φ \(Int(prop.confidence * 100))%", color: .supraAccent)
                            if let d = prop.executedAt {
                                Text(d.formatted(date: .omitted, time: .standard)).font(.system(size: 8)).foregroundColor(.supraTextTertiary)
                            }
                        }
                        .padding(6).background(Color.supraGlass).clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
        }
    }

    private var propositionsSection: some View {
        SUPRAOSCard(
            title: "PROPOSITIONS",
            subtitle: "\(evolution.proposals.count) propositions · Score Φ",
            icon: "lightbulb.fill",
            color: .supraAccent
        ) {
            if evolution.proposals.isEmpty {
                Text("Aucune proposition pour le moment")
                    .font(.system(size: 11)).foregroundColor(.supraTextTertiary).padding(8)
            } else {
                ForEach(evolution.proposals.reversed()) { prop in
                    let autoEligible = prop.confidence > 0.85 && prop.isReversible && !prop.hasCriticalRisk
                    HStack(spacing: 8) {
                        Circle().fill(statusColor(prop.status)).frame(width: 6, height: 6)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(prop.title).font(.system(size: 11, weight: .medium)).foregroundColor(.supraText)
                            HStack(spacing: 4) {
                                SUPRAOSBadge(text: "Φ \(Int(prop.confidence * 100))%", color: .supraAccent)
                                SUPRAOSBadge(text: autoEligible ? "AUTO" : "HUMAIN", color: autoEligible ? .supraGreen : .supraOrange)
                                SUPRAOSBadge(text: prop.status.rawValue, color: statusColor(prop.status))
                                if prop.isReversible {
                                    SUPRAOSBadge(text: "Réversible", color: .supraGreen)
                                }
                            }
                        }
                        Spacer()
                        if let exec = prop.executedAt {
                            Text(exec.formatted(date: .abbreviated, time: .standard))
                                .font(.system(size: 8)).foregroundColor(.supraTextTertiary)
                        }
                    }
                    .padding(8).background(Color.supraGlass).clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }

    private var humanGatesSection: some View {
        SUPRAOSCard(
            title: "HUMAN GATES",
            subtitle: "\(evolution.humanPending.count + recommendations.humanRequired.count) décisions critiques en attente",
            icon: "person.fill.questionmark",
            color: .supraOrange
        ) {
            if evolution.humanPending.isEmpty && recommendations.humanRequired.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.shield.fill").font(.system(size: 20)).foregroundColor(.supraGreen)
                    Text("Aucune décision humaine requise")
                        .font(.system(size: 11)).foregroundColor(.supraGreen)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 12)
            } else {
                if !evolution.humanPending.isEmpty {
                    Text("ÉVOLUTION — \(evolution.humanPending.count)").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraOrange).tracking(1)
                    ForEach(evolution.humanPending) { prop in
                        humanGateCard(prop.title, desc: prop.description, conf: prop.confidence, risk: prop.hasCriticalRisk)
                    }
                }
                if !recommendations.humanRequired.isEmpty {
                    Text("RECOMMENDATIONS — \(recommendations.humanRequired.count)").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraOrange).tracking(1)
                        .padding(.top, 4)
                    ForEach(recommendations.humanRequired) { rec in
                        humanGateCard(rec.problem, desc: rec.action, conf: rec.confidence, risk: false)
                    }
                }
                Divider().background(Color.supraBorder)
                VStack(alignment: .leading, spacing: 4) {
                    Text("RÈGLE").font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
                    Text("Φ > 0.85 ET réversible ET pas critique → AUTO. Sinon → HUMain.")
                        .font(.system(size: 10, design: .monospaced)).foregroundColor(.supraTextSecondary)
                }
                .padding(8).background(Color.supraGlass).clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }

    private var rulesCard: some View {
        SUPRAOSCard(
            title: "RÈGLES D'AUTOMATION",
            subtitle: "Conditions d'auto-exécution",
            icon: "list.bullet.rectangle.fill",
            color: .supraBlue
        ) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ruleCard("Φ > 0.85", "Confiance suffisante", evolution.proposals.contains { $0.confidence > 0.85 } ? .supraGreen : .supraTextSecondary)
                ruleCard("Action réversible", "Rollback disponible", evolution.proposals.contains { $0.isReversible } ? .supraGreen : .supraTextSecondary)
                ruleCard("Aucun risque critique", "Sûr pour l'utilisateur", evolution.proposals.contains { !$0.hasCriticalRisk } ? .supraGreen : .supraTextSecondary)
                ruleCard("Budget CPU <5%", "Respect des ressources", SUPRABackgroundScheduler.shared.cpuBudgetUsed < 0.05 ? .supraGreen : .supraOrange)
            }
        }
    }

    private func autoStat(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 22, weight: .bold)).foregroundColor(color)
            Text(label).font(.system(size: 7, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
        }
        .frame(maxWidth: .infinity)
    }

    private func humanGateCard(_ title: String, desc: String, conf: Double, risk: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: risk ? "exclamationmark.triangle.fill" : "clock.fill")
                .font(.system(size: 8)).foregroundColor(risk ? .supraRed : .supraOrange)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 10, weight: .medium)).foregroundColor(.supraText)
                Text(desc).font(.system(size: 9)).foregroundColor(.supraTextSecondary).lineLimit(1)
            }
            Spacer()
            SUPRAOSBadge(text: "Φ \(Int(conf * 100))%", color: conf > 0.85 ? .supraGreen : .supraOrange)
        }
        .padding(8).background(Color.supraGlass).clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func ruleCard(_ label: String, _ desc: String, _ color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 6, height: 6)
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(.supraText)
                Text(desc).font(.system(size: 9)).foregroundColor(.supraTextSecondary)
            }
            Spacer()
        }
        .padding(8).background(Color.supraGlass).clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func statusColor(_ status: EvolutionStatus) -> Color {
        switch status { case .pending: .supraOrange case .approved: .supraGreen case .autoExecuted: .supraGreen case .executed: .supraBlue case .failed: .supraRed case .rejected: .supraTextTertiary }
    }
}
