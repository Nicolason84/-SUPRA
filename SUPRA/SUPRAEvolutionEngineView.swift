import SwiftUI

struct SUPRAEvolutionEngineView: View {
    @StateObject private var engine = SUPRAEvolutionEngine.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                statusSummary
                if !engine.proposals.isEmpty {
                    proposalsList
                } else {
                    emptyState
                }
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
        .onAppear { engine.observe() }
        .onDisappear { engine.stop() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("AUTO-EVOLUTION ENGINE")
                .font(.caption.weight(.bold)).tracking(1.6).foregroundColor(.supraAccent)
            Text("Observation → Opportunité → Score Φ → Action")
                .font(.system(size: 14)).foregroundColor(.supraTextSecondary)
        }
    }

    private var statusSummary: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("\(engine.autoExecutedCount)").font(.system(size: 24, weight: .bold)).foregroundColor(.supraGreen)
                Text("AUTO").font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
            }
            .frame(maxWidth: .infinity)
            VStack(spacing: 4) {
                Text("\(engine.humanPendingCount)").font(.system(size: 24, weight: .bold)).foregroundColor(.supraOrange)
                Text("HUMAIN").font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
            }
            .frame(maxWidth: .infinity)
            VStack(spacing: 4) {
                Text("\(engine.proposals.count)").font(.system(size: 24, weight: .bold)).foregroundColor(.supraBlue)
                Text("TOTAL").font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
            }
            .frame(maxWidth: .infinity)
            VStack(spacing: 4) {
                Circle()
                    .fill(engine.isObserving ? Color.supraGreen : Color.supraRed)
                    .frame(width: 10, height: 10)
                Text(engine.isObserving ? "ACTIF" : "INACTIF")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(.supraTextTertiary)
                    .tracking(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bolt.shield.fill").font(.system(size: 36)).foregroundColor(.supraGreen)
            Text("Moteur d'évolution en veille").font(.system(size: 15, weight: .medium)).foregroundColor(.supraText)
            Text("Les opportunités d'optimisation seront détectées automatiquement")
                .font(.system(size: 12)).foregroundColor(.supraTextSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 40)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var proposalsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PROPOSITIONS (\(engine.proposals.count))")
                .font(.system(size: 11, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)

            ForEach(engine.proposals.reversed()) { proposal in
                proposalCard(proposal)
            }
        }
    }

    private func proposalCard(_ p: EvolutionProposal) -> some View {
        let autoEligible = p.confidence > 0.85 && p.isReversible && !p.hasCriticalRisk
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: statusIcon(p.status))
                    .font(.system(size: 12))
                    .foregroundColor(statusColor(p.status))
                VStack(alignment: .leading, spacing: 1) {
                    Text(p.title).font(.system(size: 13, weight: .semibold)).foregroundColor(.supraText)
                    Text(p.category.rawValue).font(.system(size: 9)).foregroundColor(.supraTextTertiary)
                }
                Spacer()
                SUPRAOSBadge(text: "Φ \(Int(p.confidence * 100))%", color: p.confidence > 0.85 ? .supraGreen : .supraOrange)
                SUPRAOSBadge(text: autoEligible ? "AUTO" : "HUMAN", color: autoEligible ? .supraGreen : .supraOrange)
                SUPRAOSBadge(text: p.status.rawValue, color: statusColor(p.status))
            }

            Text(p.description).font(.system(size: 11)).foregroundColor(.supraTextSecondary)

            HStack(spacing: 4) {
                Image(systemName: p.isReversible ? "arrow.triangle.2.circlepath" : "lock.fill")
                    .font(.system(size: 8)).foregroundColor(p.isReversible ? .supraGreen : .supraRed)
                Text(p.isReversible ? "Réversible" : "Irréversible")
                    .font(.system(size: 9)).foregroundColor(.supraTextTertiary)
                if let rollback = p.rollbackCommand {
                    Text("· Rollback: \(rollback)").font(.system(size: 8, design: .monospaced)).foregroundColor(.supraTextTertiary)
                }
                Spacer()
                Text(p.impact).font(.system(size: 9)).foregroundColor(.supraAccent)
            }

            if p.status == .pending && !autoEligible {
                HStack(spacing: 8) {
                    SUPRAOSButton(title: "Approuver", icon: "checkmark", color: .supraGreen) {
                        engine.approveHuman(p)
                    }
                    SUPRAOSButton(title: "Rejeter", icon: "xmark", color: .supraRed) {
                        engine.reject(p)
                    }
                }
            }

            if let exec = p.executedAt {
                Text("Exécuté: \(exec.formatted(date: .abbreviated, time: .standard))")
                    .font(.system(size: 9)).foregroundColor(.supraTextTertiary)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func statusIcon(_ status: EvolutionStatus) -> String {
        switch status { case .pending: "clock.fill" case .approved: "checkmark.circle.fill" case .autoExecuted: "bolt.fill" case .executed: "checkmark.shield.fill" case .failed: "exclamationmark.triangle.fill" case .rejected: "xmark.circle.fill" }
    }

    private func statusColor(_ status: EvolutionStatus) -> Color {
        switch status { case .pending: .supraOrange case .approved: .supraGreen case .autoExecuted: .supraGreen case .executed: .supraBlue case .failed: .supraRed case .rejected: .supraTextTertiary }
    }
}
