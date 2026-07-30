import SwiftUI

struct MissionDetailView: View {
    let mission: Mission

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                header
                missionOverview
                executionOverview
                detailSection("Summary", systemImage: "text.alignleft") { Text(mission.summary).textSelection(.enabled) }
                detailSection("Contexts", systemImage: "square.stack.3d.up.fill") { contextGrid }
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
                detailSection("Evidence", systemImage: "doc.text.magnifyingglass") {
                    itemList(mission.evidence) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(.headline)
                            Text(item.kind).font(.caption).foregroundStyle(.secondary)
                            Text(item.detail).foregroundStyle(.secondary)
                        }
                    }
                }
                detailSection("Artifacts", systemImage: "shippingbox.fill") {
                    itemList(mission.artifacts) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(.headline)
                            Text(item.kind).font(.caption).foregroundStyle(.secondary)
                            Text(item.path).textSelection(.enabled).font(.caption.monospaced())
                        }
                    }
                }
                detailSection("Timeline", systemImage: "calendar.badge.clock") {
                    itemList(mission.timeline) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title).font(.headline)
                            Text(entry.date, format: .dateTime.day().month(.wide).year().hour().minute())
                                .font(.caption).foregroundStyle(.secondary)
                            if let detail = entry.detail { Text(detail).foregroundStyle(.secondary) }
                        }
                    }
                }
                detailSection("Logs", systemImage: "scroll.fill") {
                    itemList(mission.logs) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.level) · \(entry.date.formatted(.dateTime.hour().minute().second()))")
                                .font(.caption).foregroundStyle(.secondary)
                            Text(entry.message).textSelection(.enabled)
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
                if let report = mission.report, !report.isEmpty {
                    detailSection("Report", systemImage: "doc.text.fill") {
                        Text(report).textSelection(.enabled).font(.body.monospaced())
                    }
                }
                if let error = mission.executionError, !error.isEmpty {
                    detailSection("Execution Error", systemImage: "exclamationmark.triangle.fill") {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                            Text(error).foregroundColor(.red).textSelection(.enabled)
                        }
                    }
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
                Label(mission.lifecycle.rawValue, systemImage: "arrow.triangle.branch")
                Label(mission.health.rawValue, systemImage: "heart.text.square.fill")
            }
            .font(.callout)
            .foregroundStyle(.secondary)
            ProgressView(value: mission.progress)
        }
    }

    private var missionOverview: some View {
        detailSection("Mission Overview", systemImage: "flag.2.crossed.fill") {
            adaptiveGrid([
                detailTile("Mission ID", mission.identity.missionID),
                detailTile("Objective", mission.objective),
                detailTile("Owner", mission.owner),
                detailTile("Planner", mission.planner),
                detailTile("Executor", mission.executor),
                detailTile("Authority", mission.authority.rawValue),
                detailTile("Autonomy Level", "\(mission.autonomyLevel)"),
                detailTile("Score", mission.score.formatted(.number.precision(.fractionLength(2)))),
                detailTile("Confidence", mission.confidence.formatted(.percent.precision(.fractionLength(0)))),
                detailTile("Value", mission.value.formatted(.number.precision(.fractionLength(2)))),
                detailTile("Impact", mission.impact),
                detailTile("Risk", mission.risk.rawValue)
            ])
        }
    }

    private var executionOverview: some View {
        detailSection("Execution Overview", systemImage: "cpu.fill") {
            adaptiveGrid([
                detailTile("Current Status", mission.currentStatus),
                detailTile("Current Step", mission.currentStep),
                detailTile("Provider", mission.currentProvider ?? mission.providers.first ?? "Auto"),
                detailTile("Model", mission.currentModel ?? mission.models.first ?? "Auto"),
                detailTile("Remaining", mission.estimatedRemainingMinutes.map { "\($0) min" } ?? "—"),
                detailTile("Expected Outcome", mission.expectedOutcome ?? "—"),
                detailTile("Executive Decision", mission.executiveDecision ?? "—"),
                detailTile("Next Mission", mission.nextMission ?? "—"),
                detailTile("Blocker", mission.blocker ?? "None"),
                detailTile("Validation", mission.validation.summary),
                detailTile("Build", mission.validation.buildStatus),
                detailTile("Tests", mission.validation.testStatus)
            ])
        }
    }

    private var contextGrid: some View {
        adaptiveGrid([
            detailTile("Business Context", mission.businessContext),
            detailTile("Technical Context", mission.technicalContext),
            detailTile("Execution Strategy", mission.executionStrategy),
            detailTile("Memory Links", mission.memoryLinks.joined(separator: ", ").isEmpty ? "None" : mission.memoryLinks.joined(separator: ", ")),
            detailTile("Lessons Learned", mission.lessonsLearned.joined(separator: "\n").isEmpty ? "None" : mission.lessonsLearned.joined(separator: "\n")),
            detailTile("Constraints", mission.constraints.joined(separator: "\n").isEmpty ? "None" : mission.constraints.joined(separator: "\n"))
        ])
    }

    private func adaptiveGrid(_ items: [AnyView]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                item
            }
        }
    }

    private func detailTile(_ title: String, _ value: String) -> AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
            .background(Color.supraSurface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        )
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
