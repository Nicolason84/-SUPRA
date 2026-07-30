import SwiftUI

struct SUPRAAutonomyControlView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    private let rules: [(String, String, Bool)] = [
        ("Φ ≥ 0.85", "Confidence threshold", true),
        ("Reversible", "Action must be reversible", true),
        ("Evidence available", "Sufficient data to decide", true),
        ("Critical", "Human only", false)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                SUPRAOSSectionHeader(title: "Autonomy Control", actionLabel: "Refresh") {
                    SUPRAMissionProposalEngine.shared.refresh()
                }

                autonomyGaugeCard
                rulesCard
                queueCard
                sovereigntyGuardCard
            }
            .padding(SUPRAOSDesignSystem.padding)
        }
        .background(Color.supraBackground)
    }

    private var autonomyGaugeCard: some View {
        let pe = SUPRAMissionProposalEngine.shared
        let auto = pe.autoQueue.count
        let total = max(pe.proposals.count, 1)
        let level = Double(auto) / Double(total)
        return VStack(spacing: 12) {
            Text("\(Int(level * 100))%")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(level >= 0.85 ? .supraGreen : level >= 0.5 ? .supraOrange : .supraRed)
            Text("CURRENT AUTONOMY LEVEL")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.supraTextTertiary)
                .tracking(2)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.supraBorder.opacity(0.3))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(level >= 0.85 ? Color.supraGreen : level >= 0.5 ? Color.supraOrange : Color.supraRed)
                        .frame(width: geo.size.width * level, height: 8)
                }
            }
            .frame(height: 8)
            HStack(spacing: 8) {
                Text("Φ = \(Int(level * 100))%").font(.system(size: 10)).foregroundColor(.supraTextSecondary)
                Text("·").foregroundColor(.supraBorder)
                Text("\(pe.autoQueue.count) auto / \(pe.proposals.count) total").font(.system(size: 10)).foregroundColor(.supraTextSecondary)
            }
        }
        .padding(SUPRAOSDesignSystem.padding)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var rulesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Rules")
            ForEach(rules, id: \.0) { rule, description, isAuto in
                HStack(spacing: 8) {
                    Image(systemName: isAuto ? "checkmark.shield.fill" : "shield.slash.fill")
                        .font(.system(size: 12))
                        .foregroundColor(isAuto ? .supraGreen : .supraRed)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(rule)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.supraText)
                        Text(description)
                            .font(.system(size: 9))
                            .foregroundColor(.supraTextTertiary)
                    }
                    Spacer()
                    SUPRAOSBadge(text: isAuto ? "AUTO" : "HUMAN", color: isAuto ? .supraGreen : .supraRed)
                }
                .padding(10)
                .background(Color.supraGlass)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var queueCard: some View {
        let pe = SUPRAMissionProposalEngine.shared
        return VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Decision Queues")
            queueRow("AUTO EXECUTE", count: pe.autoQueue.count, color: .supraGreen, icon: "bolt.fill")
            queueRow("SUPERVISION", count: pe.supervisionQueue.count, color: .supraOrange, icon: "eye.fill")
            queueRow("HUMAN REQUIRED", count: pe.humanQueue.count, color: .supraRed, icon: "person.fill")
            if pe.humanQueue.contains(where: { $0.verdict.authority == .sovereignHumanOnly }) {
                Divider().background(Color.supraBorder)
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.supraPurple)
                    Text("Sovereign items require explicit human approval")
                        .font(.system(size: 10))
                        .foregroundColor(.supraPurple)
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var sovereigntyGuardCard: some View {
        let access = SUPRACanonicalWorldAccess.shared
        let missions = access.getMissionState()
        return VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Sovereignty Guard")
            if missions.humanQueue > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.supraPurple)
                    Text("\(missions.humanQueue) items queued for human decision")
                        .font(.system(size: 12))
                        .foregroundColor(.supraText)
                }
            }
            Text("Categories: Policy · Financial · Legal · Security · Authority")
                .font(.system(size: 10))
                .foregroundColor(.supraTextTertiary)
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.supraAccent)
                Text("Sovereign categories cannot be auto-executed regardless of confidence")
                    .font(.system(size: 9))
                    .foregroundColor(.supraTextSecondary)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.supraText)
    }

    private func queueRow(_ label: String, count: Int, color: Color, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
                .frame(width: 20, height: 20)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.supraText)
            Spacer()
            Text("\(count)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
    }
}
