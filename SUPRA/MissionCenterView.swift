import SwiftUI

struct MissionCenterView: View {
    @EnvironmentObject private var store: MissionStore
    @State private var selection: Mission.ID?

    var body: some View {
        NavigationSplitView {
            MissionSurfaceView(selection: $selection)
                .navigationTitle("Mission Center")
        } detail: {
            if let mission = selectedMission {
                MissionDetailView(mission: mission)
                    .id(mission.id)
            } else {
                ContentUnavailableView {
                    VStack(spacing: 12) {
                        Image(systemName: "flag.slash.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(Color.supraTextTertiary)
                        Text("No mission selected")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.supraText)
                    }
                } description: {
                    Text("Create or select a mission from Mission Center to inspect its evidence and execution state.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.supraTextSecondary)
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .task {
            store.load()
            if selection == nil {
                selection = store.currentMission?.id ?? store.visibleMissions.first?.id
            }
        }
        .onChange(of: store.visibleMissions) { _, missions in
            guard selection == nil else { return }
            selection = missions.first?.id
        }
    }

    private var selectedMission: Mission? {
        store.missions.first { $0.id == selection } ?? store.currentMission
    }
}

#Preview {
    NavigationStack { MissionCenterView() }
        .environmentObject(SUPRACompositionRoot.shared.missionStore)
}
