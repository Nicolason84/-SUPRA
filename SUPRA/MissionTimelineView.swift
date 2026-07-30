import SwiftUI
import Combine

struct MissionTimelineView: View {
    @ObservedObject var monitor: RuntimeMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if monitor.events.isEmpty {
                Spacer()
                ContentUnavailableView("No events", systemImage: "clock", description: Text("Events appear here as the Runtime runs."))
                Spacer()
            } else {
                timelineList
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("EVENT TIMELINE")
                .font(.caption.weight(.bold)).tracking(1.6)
            Text("Live Runtime Activity")
                .font(.largeTitle.weight(.semibold))
            HStack(spacing: 16) {
                Label("\(monitor.events.count) events", systemImage: "list.bullet")
                Label("Last: \(monitor.health.lastSyncFormatted)", systemImage: "arrow.triangle.2.circlepath")
            }
            .font(.caption).foregroundStyle(.secondary)
        }
        .padding()
    }

    private var timelineList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(monitor.events) { event in
                    eventRow(event)
                    Divider().padding(.leading, 48)
                }
            }
        }
    }

    private func eventRow(_ event: RuntimeEvent) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Image(systemName: event.type.icon)
                    .font(.body).foregroundStyle(colorFor(event.type))
                    .frame(width: 24, height: 24)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title).fontWeight(.medium)
                if !event.detail.isEmpty {
                    Text(event.detail).font(.caption).foregroundStyle(.secondary)
                }
                HStack(spacing: 12) {
                    Text(event.timestamp, style: .time).font(.caption2.monospaced()).foregroundStyle(.tertiary)
                    Text(event.type.rawValue.replacingOccurrences(of: "_", with: " ")).font(.caption2).foregroundStyle(.tertiary)
                    if let file = event.sourceFile {
                        Text(file).font(.caption2).foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    private func colorFor(_ type: RuntimeEventType) -> Color {
        switch type {
        case .missionCreated, .missionCompleted: .blue
        case .dagGenerated: .purple
        case .schedulerAction: .orange
        case .agentSelected, .providerAssigned: .indigo
        case .executionStarted: .cyan
        case .executionCompleted: .green
        case .validationPassed: .green
        case .validationFailed, .error: .red
        case .info: .secondary
        }
    }
}
