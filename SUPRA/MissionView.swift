import SwiftUI

struct MissionView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    var body: some View {
        SUPRAOSCard(
            title: "Missions",
            subtitle: missionSubtitle,
            icon: "flag.fill",
            color: .supraAccent
        ) {
            if let missions = state.missionsSection {
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        statPill("\(missions.total)", label: "Total", color: .supraText)
                        statPill("\(missions.active)", label: "Active", color: .supraGreen)
                        statPill("\(missions.blocked)", label: "Blocked", color: .supraOrange)
                        statPill("\(missions.completed)", label: "Done", color: .supraTeal)
                    }
                    if !missions.recentMissions.isEmpty {
                        Divider().background(Color.supraBorder)
                        Text("Recent")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.supraTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(missions.recentMissions) { mission in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(missionColor(mission.status))
                                    .frame(width: 6, height: 6)
                                Text(mission.title)
                                    .font(.system(size: 10))
                                    .foregroundColor(.supraText)
                                    .lineLimit(1)
                                Spacer()
                                SUPRAOSBadge(
                                    text: mission.status.rawValue,
                                    color: missionColor(mission.status)
                                )
                            }
                        }
                    }
                }
            } else {
                Text("No missions loaded")
                    .font(.system(size: 12))
                    .foregroundColor(.supraTextTertiary)
            }
        }
    }

    private var missionSubtitle: String {
        guard let m = state.missionsSection else { return "—" }
        return "\(m.active) active / \(m.total) total"
    }

    private func statPill(_ value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.supraTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func missionColor(_ status: Mission.Status) -> Color {
        switch status {
        case .active: .supraGreen
        case .planned: .supraBlue
        case .blocked: .supraOrange
        case .completed: .supraTeal
        }
    }
}
