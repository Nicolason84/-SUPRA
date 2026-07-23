import SwiftUI

struct DecisionInboxView: View {
    @StateObject private var store = DecisionStore()
    @State private var selection: Decision.ID?

    var body: some View {
        NavigationSplitView {
            Group {
                if store.isLoading {
                    ProgressView("Loading decisions…")
                } else if store.visibleDecisions.isEmpty {
                    ContentUnavailableView(
                        store.query.isEmpty && store.activeFilter == .all ? "No decisions" : "No matching decisions",
                        systemImage: "tray",
                        description: Text(emptyDescription)
                    )
                } else {
                    List(store.visibleDecisions, selection: $selection) { decision in
                        DecisionRow(decision: decision)
                            .tag(decision.id)
                    }
                }
            }
            .navigationTitle("Decision Inbox")
            .searchable(text: $store.query, placement: .toolbar, prompt: "Search decisions")
            .toolbar { toolbarContent }
        } detail: {
            if let decision = selectedDecision {
                DecisionDetailView(decision: decision)
            } else {
                ContentUnavailableView(
                    "Select a decision",
                    systemImage: "sidebar.left",
                    description: Text("Decision details will appear here.")
                )
            }
        }
        .task { store.load() }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup {
            Button("Refresh", systemImage: "arrow.clockwise", action: store.refresh)
                .disabled(store.isLoading)

            Menu("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                Picker("Filter", selection: $store.activeFilter) {
                    ForEach(DecisionStore.Filter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
            }

            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Picker("Sort", selection: $store.activeSort) {
                    ForEach(DecisionStore.Sort.allCases) { sort in
                        Text(sort.rawValue).tag(sort)
                    }
                }
            }
        }
    }

    private var selectedDecision: Decision? {
        store.visibleDecisions.first { $0.id == selection }
    }

    private var emptyDescription: String {
        if let errorMessage = store.errorMessage { return errorMessage }
        if !store.query.isEmpty || store.activeFilter != .all {
            return "Adjust Search or Filter to see available decisions."
        }
        return "No decision data is currently available."
    }
}

#Preview {
    NavigationStack { DecisionInboxView() }
}
