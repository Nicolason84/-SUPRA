import SwiftUI

struct DecisionAuthorityView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    var body: some View {
        SUPRAOSCard(
            title: "Decision Control Center",
            subtitle: autonomySubtitle,
            icon: "checkmark.seal.fill",
            color: .supraAccent
        ) {
            if let decision = state.decisionSection {
                VStack(spacing: 12) {
                    autonomyGauge(decision.autonomyLevel)
                    Divider().background(Color.supraBorder)
                    HStack(spacing: 12) {
                        queuePill("🤖 Auto", count: decision.autoCount, color: .supraGreen)
                        queuePill("🟡 Supervision", count: decision.supervisionCount, color: .supraOrange)
                        queuePill("🔴 Human", count: decision.humanCount, color: .supraRed)
                    }
                    if !decision.verdicts.isEmpty {
                        Divider().background(Color.supraBorder)
                        Text("Decisions")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.supraTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(Array(decision.verdicts.prefix(6)), id: \.key) { id, verdict in
                            let title = decision.missionTitles[id] ?? "Unknown"
                            HStack(spacing: 6) {
                                authorityIcon(verdict.authority)
                                    .frame(width: 16)
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(title)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.supraText)
                                        .lineLimit(1)
                                    Text("Φ \(Int(verdict.confidence * 100))% · \(verdict.authority.rawValue)")
                                        .font(.system(size: 8))
                                        .foregroundColor(.supraTextTertiary)
                                }
                                Spacer()
                                Text(verdict.requiredAction)
                                    .font(.system(size: 8))
                                    .foregroundColor(.supraTextTertiary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            } else {
                Text("No decisions classified")
                    .font(.system(size: 12))
                    .foregroundColor(.supraTextTertiary)
            }
        }
    }

    private var autonomySubtitle: String {
        guard let d = state.decisionSection else { return "—" }
        return "\(Int(d.autonomyLevel * 100))% autonomous"
    }

    private func autonomyGauge(_ level: Double) -> some View {
        VStack(spacing: 4) {
            Text("\(Int(level * 100))%")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(level >= 0.5 ? .supraGreen : level >= 0.25 ? .supraOrange : .supraRed)
            Text("AUTONOMY LEVEL")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.supraTextTertiary)
                .tracking(2)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.supraBorder.opacity(0.3))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(level >= 0.5 ? Color.supraGreen : level >= 0.25 ? Color.supraOrange : Color.supraRed)
                        .frame(width: geo.size.width * level, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private func queuePill(_ label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.supraTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func authorityIcon(_ authority: DecisionAuthority) -> some View {
        switch authority {
        case .autoExecute:
            AnyView(Image(systemName: "bolt.fill").font(.system(size: 10)).foregroundColor(.supraGreen))
        case .supervised:
            AnyView(Image(systemName: "eye.fill").font(.system(size: 10)).foregroundColor(.supraOrange))
        case .humanRequired:
            AnyView(Image(systemName: "person.fill").font(.system(size: 10)).foregroundColor(.supraRed))
        case .sovereignHumanOnly:
            AnyView(Image(systemName: "crown.fill").font(.system(size: 10)).foregroundColor(.supraPurple))
        }
    }
}
