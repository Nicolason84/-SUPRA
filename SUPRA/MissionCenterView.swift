import SwiftUI

struct MissionCenterView: View {
    @StateObject private var store = MissionStore()
    @State private var selection: Mission.ID?

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                flightDeck
                Divider()
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
            }
            .navigationTitle("Missions")
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
        .task { store.load() }
    }

    private var flightDeck: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PANDORA · GABRIEL")
                        .font(.caption2.bold())
                        .tracking(1.2)
                        .foregroundStyle(.secondary)
                    Text("\(store.missionSlots) branches concurrentes")
                        .font(.headline)
                }
                Spacer()
                Text(store.conductorStatus)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: Capsule())
            }

            VStack(alignment: .leading, spacing: 6) {
                lane("A", "Cash maintenant", "0–2 sem.", "buyer / preuve / paiement")
                lane("B", "Levier", "2–8 sem.", "offre high-ticket / réplication")
                lane("C", "10M+ value-at-stake", "stratégique", "diagnostic / décision / preuve")
            }

            Text("Moyen 2–6 mois · Long 6–18 mois · Très long 2–5 ans")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                Label("\(store.workerProcesses) workers", systemImage: "cpu")
                Text("·")
                Text(store.outputMode)
                Text("·")
                Text("autorité \(store.finalAuthority)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.ultraThinMaterial)
    }

    private func lane(
        _ letter: String,
        _ title: String,
        _ horizon: String,
        _ rule: String
    ) -> some View {
        HStack(spacing: 8) {
            Text(letter)
                .font(.caption.bold())
                .frame(width: 22, height: 22)
                .background(Color.cyan.opacity(0.16), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text(title)
                        .font(.caption.bold())
                    Spacer()
                    Text(horizon)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Text(rule)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup {
            Button("Refresh", systemImage: "arrow.clockwise", action: store.refresh)
                .disabled(store.isLoading)

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
