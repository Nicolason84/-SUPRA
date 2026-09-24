import SwiftUI

struct MissionDetailView: View {
    let mission: Mission

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                header

                if mission.status == .blocked && mission.category == "System Consolidation" {
                    GrandeMissionHumanGateView()
                }

                detailSection("Summary", systemImage: "text.alignleft") {
                    Text(mission.summary).textSelection(.enabled)
                }
                detailSection("Objectives", systemImage: "scope") {
                    itemList(mission.objectives) { objective in
                        Label(objective.title, systemImage: objective.isCompleted ? "checkmark.circle.fill" : "circle")
                    }
                }
                detailSection("Tasks", systemImage: "checklist") {
                    itemList(mission.tasks) { task in
                        HStack {
                            Text(task.title).font(.headline)
                            Spacer()
                            Text(task.status.rawValue).foregroundStyle(.secondary)
                        }
                    }
                }
                detailSection("Dependencies", systemImage: "link") {
                    itemList(mission.dependencies) { dependency in
                        HStack {
                            Text(dependency.title).font(.headline)
                            Spacer()
                            Text(dependency.status).foregroundStyle(.secondary)
                        }
                    }
                }
                detailSection("Timeline", systemImage: "calendar.badge.clock") {
                    itemList(mission.timeline) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title).font(.headline)
                            Text(entry.date, format: .dateTime.day().month(.wide).year())
                                .font(.caption).foregroundStyle(.secondary)
                            if let detail = entry.detail { Text(detail).foregroundStyle(.secondary) }
                        }
                    }
                }
                detailSection("Current Status", systemImage: "waveform.path.ecg") {
                    Text(mission.currentStatus).textSelection(.enabled)
                }
            }
            .padding(28)
            .frame(maxWidth: 900, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(mission.title)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(mission.title).font(.largeTitle.bold())
            HStack(spacing: 10) {
                Label(mission.status.rawValue, systemImage: "circle.fill")
                Label(mission.priority.rawValue, systemImage: "flag.fill")
                Label(mission.category, systemImage: "folder.fill")
                Label(mission.owner, systemImage: "person.fill")
            }
            .font(.callout)
            .foregroundStyle(.secondary)
            ProgressView(value: mission.progress)
        }
    }

    private func detailSection<Content: View>(
        _ title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage).font(.title2.bold())
            content()
        }
    }

    @ViewBuilder
    private func itemList<Item: Identifiable, Content: View>(
        _ items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        if items.isEmpty {
            Text("No associated items.").foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(items) { item in content(item) }
            }
        }
    }
}