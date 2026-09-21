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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PANDORA · MISSION FLIGHT DECK")
                        .font(.caption2.bold())
                        .tracking(1.2)
                        .foregroundStyle(.secondary)
                    Text("FIRST_REAL_COLLECTED → MAX_ECONOMIC")
                        .font(.headline)
                }
                Spacer()
                Text(store.conductorStatus)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: Capsule())
            }

            Text("3 branches concurrentes · \(store.opportunityCount) opportunités réelles à scorer · autorité finale \(store.finalAuthority)")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 7) {
                lane(
                    "A",
                    "CASH_NOW",
                    "H0 · 0–72 h",
                    "premier encaissement réel · acheteur · preuve · paiement"
                )
                lane(
                    "B",
                    "SCALE_ENGINE",
                    "H1 3–30 j · H2 1–12 mois",
                    "valeur capturable · marge · répétabilité · levier"
                )
                lane(
                    "C",
                    "STRATEGIC_ASSETS",
                    "H3 · 1–10 ans",
                    "problèmes 10M+ value-at-stake · diagnostic · accès · capture"
                )
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("SCORING ÉCONOMIQUE")
                    .font(.caption2.bold())
                    .tracking(1.0)
                    .foregroundStyle(.secondary)
                Text("value-at-stake × douleur × urgence × solvabilité × accès × avantage SUPRA × exécutabilité × valeur capturable ÷ temps / risque / capital")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                Label("\(store.missionSlots) slots", systemImage: "square.grid.3x1.folder.badge.plus")
                Label("\(store.workerProcesses) workers", systemImage: "cpu")
                Label(store.outputMode, systemImage: "tray.2")
                Spacer()
                Text("CAPITAL AVANT 1ER CASH: 0 €")
                    .font(.caption2.bold())
                    .foregroundStyle(.orange)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            Text("Les horizons ne sont pas déduits du rang. Une opportunité reçoit H0/H1/H2/H3 seulement après preuve de délai, accès, capturabilité et risque.")
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
        HStack(spacing: 9) {
            Text(letter)
                .font(.caption.bold())
                .frame(width: 24, height: 24)
                .background(Color.cyan.opacity(0.16), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.caption.bold())
                    Spacer()
                    Text(horizon)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text(rule)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
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
