import SwiftUI

// MARK: - Mission Center View
//
// Reconnected to the Snapshot Bus (Ω6) per PROJECT PHOENIX.
// Reads mission summary from ExecutiveSnapshotBus.shared.latestSnapshot
// instead of accessing MissionStore directly for read operations.
// MissionStore remains the write-side service for mission creation/execution.

struct MissionCenterView: View {
    @StateObject private var bus = ExecutiveSnapshotBus.shared
    @EnvironmentObject private var store: MissionStore
    @State private var selection: String?

    private var summary: ExecutiveContextSnapshot.MissionsSummary {
        bus.latestSnapshot.context.missionsSummary
    }

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
            // Ensure MissionStore is loaded for write operations
            store.load()
            // Default selection from snapshot bus summary
            if selection == nil, let current = summary.current {
                selection = current.id
            } else if selection == nil, let first = summary.visibleMissions.first {
                selection = first.id
            }
        }
        .onChange(of: summary.visibleMissions) { _, missions in
            guard selection == nil else { return }
            selection = missions.first?.id
        }
    }

    /// Resolve full Mission from MissionStore for the detail view.
    /// MissionStore remains the canonical source for deep mission detail.
    private var selectedMission: Mission? {
        if let selection {
            store.missions.first { $0.id.uuidString == selection }
        } else {
            store.currentMission
        }
    }
}

#Preview {
    NavigationStack { MissionCenterView() }
        .environmentObject(SUPRACompositionRoot.shared.missionStore)
}
