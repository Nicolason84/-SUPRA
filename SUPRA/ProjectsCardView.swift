import SwiftUI

struct ProjectsCardView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    private var projectsSource: MemorySourceInfo? {
        state.multiMemorySection?.memories.first { $0.id == "projects" }
    }

    var body: some View {
        SUPRAOSCard(
            title: "Projects",
            subtitle: projectsSource.map { $0.isConnected ? "\($0.objectCount) active" : "Disconnected" } ?? "—",
            icon: "folder.fill",
            color: projectsSource?.isConnected == true ? .supraBlue : .supraRed
        ) {
            if let source = projectsSource {
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        statBlock("Active", value: "\(source.objectCount)", color: .supraGreen)
                        statBlock("Confidence", value: "\(Int(source.confidence * 100))%", color: confidenceColor(source.confidence))
                    }
                    if let sync = source.lastSync {
                        row("Last Sync", value: sync.formatted(date: .abbreviated, time: .shortened))
                    }
                    row("Status", value: source.isConnected ? "Connected" : "Disconnected")
                    if !source.anomalies.isEmpty {
                        Divider().background(Color.supraBorder)
                        ForEach(source.anomalies, id: \.self) { anomaly in
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.supraOrange)
                                Text(anomaly)
                                    .font(.system(size: 9))
                                    .foregroundColor(.supraOrange)
                                Spacer()
                            }
                        }
                    }
                }
            } else {
                Text("No project data")
                    .font(.system(size: 12))
                    .foregroundColor(.supraTextTertiary)
            }
        }
    }

    private func statBlock(_ label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.supraTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 11)).foregroundColor(.supraTextSecondary)
            Spacer()
            Text(value).font(.system(size: 11, weight: .medium)).foregroundColor(.supraText)
        }
    }

    private func confidenceColor(_ value: Double) -> Color {
        value >= 0.8 ? .supraGreen : value >= 0.5 ? .supraOrange : .supraRed
    }
}
