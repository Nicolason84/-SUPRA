// MARK: - Mission Copilot View
//
// Reconnected to the Snapshot Bus (Ω6) per PROJECT PHOENIX.
// Reads copilot stats from ExecutiveSnapshotBus.shared.latestSnapshot.
// Write operations (refresh, execute, clear) remain direct service calls.

import SwiftUI

struct MissionCopilotView: View {
    @StateObject private var bus = ExecutiveSnapshotBus.shared

    private var dashboard: ExecutiveContextSnapshot.DashboardSummary {
        bus.latestSnapshot.context.dashboard
    }

    var body: some View {
        SUPRAOSCard(
            title: "Mission Copilot",
            subtitle: subtitle,
            icon: "brain.head.profile",
            color: .supraTeal
        ) {
            VStack(spacing: 12) {
                statsRow
                Divider().background(Color.supraBorder)
                actionButtons
                if !SUPRAMissionProposalEngine.shared.proposals.isEmpty {
                    Divider().background(Color.supraBorder)
                    Text("Recent Proposals")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.supraTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    proposalsList(SUPRAMissionProposalEngine.shared.proposals.prefix(5))
                }
            }
        }
    }

    private var subtitle: String {
        "\(dashboard.copilotProposalCount) proposals · \(dashboard.copilotAutoQueueCount) auto"
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            statPill("🤖", count: dashboard.copilotAutoQueueCount, color: .supraGreen)
            statPill("📥", count: dashboard.copilotProposalCount, color: .supraBlue)
            statPill("🟡", count: dashboard.copilotSupervisionQueueCount, color: .supraOrange)
            statPill("🔴", count: dashboard.copilotHumanQueueCount, color: .supraRed)
            statPill("✓", count: dashboard.copilotExecutedCount, color: .supraTeal)
        }
    }

    private func statPill(_ icon: String, count: Int, color: Color) -> some View {
        VStack(spacing: 1) {
            Text(icon)
                .font(.system(size: 14))
            Text("\(count)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            SUPRAOSButton(title: "Analyze", icon: "magnifyingglass", color: .supraBlue) {
                SUPRAMissionProposalEngine.shared.refresh()
            }
            SUPRAOSButton(title: "Execute Auto", icon: "play.fill", color: .supraGreen) {
                executeAutoQueue()
            }
            SUPRAOSButton(title: "Rollback", icon: "arrow.uturn.backward", color: .supraOrange) {
                // rollback UI — future
            }
            SUPRAOSButton(title: "Clear", icon: "trash", color: .supraRed) {
                SUPRAMissionProposalEngine.shared.clear()
                SUPRAMissionExecutor.shared.clearHistory()
            }
        }
    }

    private func proposalsList(_ proposals: ArraySlice<MissionProposal>) -> some View {
        ForEach(proposals) { proposal in
            HStack(spacing: 6) {
                authorityIcon(proposal.verdict.authority)
                    .frame(width: 14)
                VStack(alignment: .leading, spacing: 0) {
                    Text(proposal.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.supraText)
                        .lineLimit(1)
                    Text("Φ \(Int(proposal.confidence * 100))% · \(proposal.category.rawValue)")
                        .font(.system(size: 8))
                        .foregroundColor(.supraTextTertiary)
                }
                Spacer()
                SUPRAOSBadge(text: proposal.verdict.authority.rawValue, color: badgeColor(proposal.verdict.authority))
            }
        }
    }

    private func executeAutoQueue() {
        let engine = SUPRAMissionProposalEngine.shared
        let executor = SUPRAMissionExecutor.shared
        for proposal in engine.autoQueue {
            _ = executor.execute(proposal)
        }
    }

    private func authorityIcon(_ authority: DecisionAuthority) -> some View {
        switch authority {
        case .autoExecute: AnyView(Image(systemName: "bolt.fill").font(.system(size: 9)).foregroundColor(.supraGreen))
        case .supervised: AnyView(Image(systemName: "eye.fill").font(.system(size: 9)).foregroundColor(.supraOrange))
        case .humanRequired: AnyView(Image(systemName: "person.fill").font(.system(size: 9)).foregroundColor(.supraRed))
        case .sovereignHumanOnly: AnyView(Image(systemName: "crown.fill").font(.system(size: 9)).foregroundColor(.supraPurple))
        }
    }

    private func badgeColor(_ authority: DecisionAuthority) -> Color {
        switch authority {
        case .autoExecute: .supraGreen
        case .supervised: .supraOrange
        case .humanRequired: .supraRed
        case .sovereignHumanOnly: .supraPurple
        }
    }
}
