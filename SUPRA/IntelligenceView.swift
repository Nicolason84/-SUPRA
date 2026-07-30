import SwiftUI

struct IntelligenceView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    var body: some View {
        SUPRAOSCard(
            title: "Intelligence",
            subtitle: scoreLabel,
            icon: "brain.head.profile",
            color: scoreColor
        ) {
            if let intel = state.intelligenceSection {
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        scoreRing("Health", value: intel.healthScore, color: .supraGreen)
                        scoreRing("Alerts", value: Double(min(intel.anomalyCount, 10)) / 10.0, color: intel.anomalyCount > 0 ? .supraOrange : .supraTextTertiary)
                    }
                    if intel.insightCount > 0 {
                        Text("\(intel.insightCount) insights")
                            .font(.system(size: 10))
                            .foregroundColor(.supraTextSecondary)
                    }
                    if let next = intel.nextBestAction {
                        Divider().background(Color.supraBorder)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Next Action")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.supraAccent)
                            Text(next)
                                .font(.system(size: 10))
                                .foregroundColor(.supraText)
                                .lineLimit(3)
                        }
                    }
                }
            } else {
                Text("Analyzing…")
                    .font(.system(size: 12))
                    .foregroundColor(.supraTextTertiary)
            }
        }
    }

    private var scoreLabel: String {
        guard let i = state.intelligenceSection else { return "—" }
        return "\(Int(i.healthScore * 100))%"
    }

    private var scoreColor: Color {
        guard let i = state.intelligenceSection else { return .supraTextTertiary }
        return i.healthScore >= 0.7 ? .supraGreen : i.healthScore >= 0.4 ? .supraOrange : .supraRed
    }

    private func scoreRing(_ label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 4)
                    .frame(width: 36, height: 36)
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(value * 100))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.supraTextSecondary)
        }
    }
}
