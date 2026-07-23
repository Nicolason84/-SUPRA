import SwiftUI

struct DecisionDetailView: View {
    let decision: Decision

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                header
                detailSection("Summary", systemImage: "text.alignleft") {
                    Text(decision.summary)
                        .textSelection(.enabled)
                }
                detailSection("Evidence", systemImage: "doc.text.magnifyingglass") {
                    itemList(decision.evidence) { evidence in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(evidence.title).font(.headline)
                            Text(evidence.detail).foregroundStyle(.secondary)
                            if let source = evidence.source {
                                Text(source).font(.caption).foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                detailSection("Next Actions", systemImage: "arrow.right.circle") {
                    itemList(decision.nextActions) { action in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(action.title).font(.headline)
                            if let owner = action.owner { Text(owner).foregroundStyle(.secondary) }
                            if let dueDate = action.dueDate {
                                Text(dueDate, format: .dateTime.day().month(.wide).year())
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                detailSection("History", systemImage: "clock.arrow.circlepath") {
                    itemList(decision.history) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title).font(.headline)
                            Text(entry.date, format: .dateTime.day().month(.wide).year().hour().minute())
                                .font(.caption).foregroundStyle(.secondary)
                            if let detail = entry.detail { Text(detail).foregroundStyle(.secondary) }
                        }
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: 900, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(decision.title)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(decision.title).font(.largeTitle.bold())
            HStack(spacing: 10) {
                Label(decision.status.rawValue, systemImage: "circle.fill")
                Label(decision.priority.rawValue, systemImage: "flag.fill")
                Label(decision.humanGate.rawValue, systemImage: "person.badge.shield.checkmark")
                if let confidence = decision.confidence {
                    Label(confidence.formatted(.percent.precision(.fractionLength(0))), systemImage: "gauge.with.dots.needle.33percent")
                }
            }
            .font(.callout)
            .foregroundStyle(.secondary)
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
