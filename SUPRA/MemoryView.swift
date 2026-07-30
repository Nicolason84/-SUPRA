import SwiftUI
import CAnnoNicoContracts

struct MemoryView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    var body: some View {
        SUPRAOSCard(
            title: "CAnnoNico Memory",
            subtitle: ageString,
            icon: "memorychip.fill",
            color: .supraPurple
        ) {
            if let cannonico = state.cannonicoSection {
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        statBlock("Sources", value: "\(cannonico.totalSources)")
                        statBlock("Recovered", value: "\(cannonico.recoveredCount)")
                    }
                    if !cannonico.references.isEmpty {
                        Divider().background(Color.supraBorder)
                        Text("References")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.supraTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(cannonico.references.prefix(5), id: \.id) { ref in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(refColor(ref.state))
                                    .frame(width: 6, height: 6)
                                Text(ref.role)
                                    .font(.system(size: 10))
                                    .foregroundColor(.supraText)
                                    .lineLimit(1)
                                Spacer()
                                SUPRAOSBadge(
                                    text: ref.state.rawValue,
                                    color: refColor(ref.state)
                                )
                            }
                        }
                    }
                }
            } else {
                Text("No snapshot cached")
                    .font(.system(size: 12))
                    .foregroundColor(.supraTextTertiary)
            }
        }
    }

    private var ageString: String {
        guard let c = state.cannonicoSection, let date = c.cachedAt else { return "—" }
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "\(Int(interval))s ago" }
        return "\(Int(interval / 60))m ago"
    }

    private func statBlock(_ label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.supraPurple)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.supraTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func refColor(_ state: CAnnoNicoIntegrationState) -> Color {
        switch state {
        case .recovered: .supraGreen
        case .partial: .supraOrange
        case .unavailable: .supraRed
        }
    }
}
