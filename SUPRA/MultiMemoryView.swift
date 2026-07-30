import SwiftUI

struct MultiMemoryView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    var body: some View {
        SUPRAOSCard(
            title: "MultiMemory",
            subtitle: state.multiMemorySection.map { $0.globalHealth } ?? "—",
            icon: "square.stack.3d.down.right.fill",
            color: healthColor
        ) {
            if let mem = state.multiMemorySection {
                VStack(spacing: 6) {
                    ForEach(mem.memories) { source in
                        HStack(spacing: 8) {
                            Image(systemName: source.icon)
                                .font(.system(size: 10))
                                .foregroundColor(source.isConnected ? .supraGreen : .supraRed)
                                .frame(width: 16)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(source.name)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.supraText)
                                HStack(spacing: 4) {
                                    Text("\(source.objectCount) items")
                                        .font(.system(size: 9))
                                        .foregroundColor(.supraTextSecondary)
                                    if let sync = source.lastSync {
                                        Text("•")
                                            .font(.system(size: 9))
                                            .foregroundColor(.supraTextTertiary)
                                        Text(sync.formatted(date: .omitted, time: .shortened))
                                            .font(.system(size: 9))
                                            .foregroundColor(.supraTextTertiary)
                                    }
                                }
                            }
                            Spacer()
                            confidenceBadge(source.confidence)
                        }
                        if !source.anomalies.isEmpty {
                            ForEach(source.anomalies, id: \.self) { anomaly in
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(.supraOrange)
                                    Text(anomaly)
                                        .font(.system(size: 9))
                                        .foregroundColor(.supraOrange)
                                    Spacer()
                                }
                                .padding(.leading, 24)
                            }
                        }
                    }
                }
            } else {
                Text("Loading memories…")
                    .font(.system(size: 12))
                    .foregroundColor(.supraTextTertiary)
            }
        }
    }

    private var healthColor: Color {
        guard let h = state.multiMemorySection?.globalHealth else { return .supraTextTertiary }
        switch h {
        case "healthy": return .supraGreen
        case "degraded": return .supraOrange
        default: return .supraRed
        }
    }

    private func confidenceBadge(_ value: Double) -> some View {
        let pct = Int(value * 100)
        let color: Color = value >= 0.8 ? .supraGreen : value >= 0.5 ? .supraOrange : .supraRed
        return Text("\(pct)%")
            .font(.system(size: 9, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}
