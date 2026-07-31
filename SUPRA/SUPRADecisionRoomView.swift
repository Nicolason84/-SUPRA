import SwiftUI

struct SUPRADecisionRoomView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                SUPRAOSSectionHeader(title: "Decision Room", actionLabel: "Refresh") {
                    SUPRAMissionProposalEngine.shared.refresh()
                }

                if SUPRAMissionProposalEngine.shared.proposals.isEmpty {
                    emptyState
                } else {
                    queueOverview
                    ForEach(SUPRAMissionProposalEngine.shared.proposals.prefix(10)) { proposal in
                        decisionCard(proposal)
                    }
                }
            }
            .padding(SUPRAOSDesignSystem.padding)
        }
        .background(Color.supraBackground)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(.supraGreen)
            Text("No pending decisions")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.supraText)
            Text("All proposals have been classified and queued")
                .font(.system(size: 12))
                .foregroundColor(.supraTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var queueOverview: some View {
        let pe = SUPRAMissionProposalEngine.shared
        return HStack(spacing: 12) {
            queuePill("AUTO", count: pe.autoQueue.count, color: .supraGreen, icon: "bolt.fill")
            queuePill("SUPERVISION", count: pe.supervisionQueue.count, color: .supraOrange, icon: "eye.fill")
            queuePill("HUMAN", count: pe.humanQueue.count, color: .supraRed, icon: "person.fill")
        }
    }

    private func queuePill(_ label: String, count: Int, color: Color, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 12)).foregroundColor(color)
            Text("\(count)").font(.system(size: 20, weight: .bold)).foregroundColor(color)
            Text(label).font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func decisionCard(_ proposal: MissionProposal) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            headerRow(proposal)
            Divider().background(Color.supraBorder)
            questionRow(proposal)
            contextRow(proposal)
            evidenceGrid(proposal)
            riskRow(proposal)
            Divider().background(Color.supraBorder)
            actionRow(proposal)
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func headerRow(_ p: MissionProposal) -> some View {
        HStack(spacing: 8) {
            authorityBadge(p.verdict.authority)
            VStack(alignment: .leading, spacing: 2) {
                Text(p.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.supraText)
                Text("\(p.category.rawValue) · Φ \(Int(p.confidence * 100))%")
                    .font(.system(size: 10))
                    .foregroundColor(.supraTextTertiary)
            }
            Spacer()
            SUPRAOSBadge(text: p.verdict.authority.rawValue, color: authorityColor(p.verdict.authority))
        }
    }

    private func questionRow(_ p: MissionProposal) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("QUESTION")
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.supraTextTertiary)
                .tracking(1)
            Text(p.description)
                .font(.system(size: 11))
                .foregroundColor(.supraTextSecondary)
        }
    }

    private func contextRow(_ p: MissionProposal) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CONTEXT")
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.supraTextTertiary)
                .tracking(1)
            Text(p.reason)
                .font(.system(size: 11))
                .foregroundColor(.supraTextSecondary)
        }
    }

    private func evidenceGrid(_ p: MissionProposal) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            evidenceItem("Confidence", "Φ \(Int(p.evidence.confidenceScore * 100))%", Color.supraAccent)
            evidenceItem("Evidence", "\(Int(p.evidence.evidenceScore * 100))%", Color.supraPurple)
            evidenceItem("Impact", p.estimatedImpact.rawValue, impactColor(p.estimatedImpact))
            evidenceItem("Reversible", p.isReversible ? "Yes" : "No", p.isReversible ? .supraGreen : .supraRed)
            evidenceItem("Permissions", p.evidence.permissionsAvailable ? "Granted" : "Required", p.evidence.permissionsAvailable ? .supraGreen : .supraOrange)
            evidenceItem("Category", p.category.rawValue, .supraTextSecondary)
        }
        .padding(10)
        .background(Color.supraGlass)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func evidenceItem(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.supraTextTertiary)
        }
    }

    private func riskRow(_ p: MissionProposal) -> some View {
        HStack(spacing: 8) {
            Image(systemName: p.isReversible ? "arrow.triangle.2.circlepath" : "exclamationmark.triangle.fill")
                .font(.system(size: 10))
                .foregroundColor(p.isReversible ? .supraGreen : .supraRed)
            VStack(alignment: .leading, spacing: 1) {
                Text(p.isReversible ? "Rollback available" : "Action may not be reversible")
                    .font(.system(size: 10))
                    .foregroundColor(.supraTextSecondary)
                Text("Risk level: \(p.estimatedImpact.rawValue)")
                    .font(.system(size: 9))
                    .foregroundColor(impactColor(p.estimatedImpact))
            }
        }
    }

    private func actionRow(_ p: MissionProposal) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("RECOMMENDATION")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(.supraTextTertiary)
                    .tracking(1)
                Text(p.verdict.reason)
                    .font(.system(size: 10))
                    .foregroundColor(.supraTextSecondary)
            }
            Spacer()
            if p.verdict.authority == .autoExecute {
                SUPRAOSButton(title: "Execute", icon: "play.fill", color: .supraGreen) {
                    Task {
                        _ = await SUPRAMissionExecutor.shared.execute(p)
                    }
                }
            }
            if p.verdict.authority == .humanRequired || p.verdict.authority == .sovereignHumanOnly {
                SUPRAOSButton(title: "Review", icon: "eye.fill", color: .supraAccent) {}
            }
        }
    }

    private func authorityBadge(_ authority: DecisionAuthority) -> some View {
        Image(systemName: authorityIconName(authority))
            .font(.system(size: 12))
            .foregroundColor(authorityColor(authority))
            .frame(width: 24, height: 24)
            .background(authorityColor(authority).opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func authorityIconName(_ a: DecisionAuthority) -> String {
        switch a { case .autoExecute: "bolt.fill" case .supervised: "eye.fill" case .humanRequired: "person.fill" case .sovereignHumanOnly: "crown.fill" }
    }

    private func authorityColor(_ a: DecisionAuthority) -> Color {
        switch a { case .autoExecute: .supraGreen case .supervised: .supraOrange case .humanRequired: .supraRed case .sovereignHumanOnly: .supraPurple }
    }

    private func impactColor(_ i: DecisionImpact) -> Color {
        switch i { case .low: .supraTextSecondary case .medium: .supraOrange case .high: .supraRed case .critical: .supraPurple }
    }
}
