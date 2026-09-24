import SwiftUI

struct MissionCenterView: View {
    @StateObject private var store = MissionStore()
    @ObservedObject private var runner = SUPRAGrandeMissionRunner.shared
    @State private var selection: Mission.ID?

    var body: some View {
        NavigationSplitView {
            Group {
                if store.isLoading {
                    ProgressView("Loading missions…")
                } else if store.visibleMissions.isEmpty {
                    ContentUnavailableView(
                        store.query.isEmpty && store.activeFilter == .all ? "No missions" : "No matching missions",
                        systemImage: "scope",
                        description: Text(emptyDescription)
                    )
                } else {
                    List(store.visibleMissions, selection: $selection) { mission in
                        MissionRow(mission: mission)
                            .tag(mission.id)
                    }
                }
            }
            .navigationTitle("Mission Center")
            .searchable(text: $store.query, placement: .toolbar, prompt: "Search missions")
            .toolbar { toolbarContent }
        } detail: {
            if let mission = selectedMission {
                MissionDetailView(mission: mission)
            } else {
                ContentUnavailableView(
                    "Select a mission",
                    systemImage: "sidebar.left",
                    description: Text("Mission details will appear here.")
                )
            }
        }
        .task {
            store.load()
            selectCurrentMissionIfNeeded()
            while !Task.isCancelled {
                let runner = SUPRAGrandeMissionRunner.shared

                let delay: UInt64
                if runner.isRunning {
                    delay = 1_000_000_000
                } else if runner.isAwaitingHumanDecision {
                    delay = 8_000_000_000
                } else {
                    delay = 3_000_000_000
                }

                try? await Task.sleep(nanoseconds: delay)
                store.refresh()
                selectCurrentMissionIfNeeded()
            }
        }
    }

    private func selectCurrentMissionIfNeeded() {
        guard selection == nil
            || !store.visibleMissions.contains(where: { $0.id == selection })
        else {
            return
        }
        selection = store.visibleMissions.first?.id
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup {
            Button("Refresh", systemImage: "arrow.clockwise", action: store.refresh)
                .disabled(store.isLoading)

            if runner.isRunning {
                Button("Standby", systemImage: "pause.circle.fill") {
                    runner.standbyCurrentMission()
                }

                Button("Abort mission", systemImage: "stop.circle.fill", role: .destructive) {
                    runner.abortCurrentMission()
                }
            } else if runner.isStandby {
                Button("Resume", systemImage: "play.circle.fill") {
                    runner.resumeFromStandby()
                }

                Button("Abort mission", systemImage: "stop.circle", role: .destructive) {
                    runner.abortCurrentMission()
                }
            }

            Menu("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                Picker("Filter", selection: $store.activeFilter) {
                    ForEach(MissionStore.Filter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
            }

            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Picker("Sort", selection: $store.activeSort) {
                    ForEach(MissionStore.Sort.allCases) { sort in
                        Text(sort.rawValue).tag(sort)
                    }
                }
            }
        }
    }

    private var selectedMission: Mission? {
        store.visibleMissions.first { $0.id == selection }
    }

    private var emptyDescription: String {
        if let errorMessage = store.errorMessage { return errorMessage }
        if !store.query.isEmpty || store.activeFilter != .all {
            return "Adjust Search or Filter to see available missions."
        }
        return "No mission data is currently available."
    }
}

#Preview {
    NavigationStack { MissionCenterView() }
}