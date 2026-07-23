import SwiftUI

struct SupraControlCenterView: View {
    @StateObject private var store: ControlCenterStore

    init() {
        _store = StateObject(wrappedValue: ControlCenterStore())
    }

    init(store: ControlCenterStore) {
        _store = StateObject(wrappedValue: store)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let snapshot = store.snapshot {
                    dashboard(snapshot)
                } else if store.isLoading {
                    ProgressView("Loading SUPRA artifacts…")
                        .controlSize(.large)
                } else {
                    ContentUnavailableView(
                        "Executive Dashboard unavailable",
                        systemImage: "exclamationmark.triangle",
                        description: Text(store.errorMessage ?? "No snapshot loaded.")
                    )
                }
            }
            .navigationTitle("SUPRA")
            .toolbar {
                Button("Refresh", systemImage: "arrow.clockwise", action: store.load)
                    .disabled(store.isLoading)
            }
        }
        .frame(minWidth: 980, minHeight: 680)
        .task { store.load() }
    }

    private func dashboard(_ snapshot: Snapshot) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                dashboardHeader
                executiveSummary(snapshot)
                quickActions
                runtimeHealth(snapshot)
                recentActivity(snapshot)
            }
            .padding(32)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var dashboardHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("EXECUTIVE CONTROL CENTER")
                .font(.caption.weight(.bold))
                .tracking(1.6)
                .foregroundStyle(.secondary)
            Text("Executive Dashboard")
                .font(.system(size: 38, weight: .bold, design: .rounded))
            Text("A live, read-only view of SUPRA operational readiness.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private func executiveSummary(_ snapshot: Snapshot) -> some View {
        dashboardSection("Executive Summary", systemImage: "chart.bar.xaxis") {
            LazyVGrid(columns: summaryColumns, spacing: 14) {
                summaryCard(
                    title: "Runtime Status",
                    value: snapshot.availableCount == snapshot.requiredCount ? "Operational" : "Degraded",
                    systemImage: "bolt.shield.fill",
                    healthy: snapshot.availableCount == snapshot.requiredCount
                )
                summaryCard(
                    title: "Build Status",
                    value: snapshot.build.isAvailable ? "Available" : "Unavailable",
                    systemImage: "hammer.fill",
                    healthy: snapshot.build.isAvailable
                )
                summaryCard(
                    title: "Last Refresh",
                    value: snapshot.capturedAt.formatted(date: .abbreviated, time: .shortened),
                    systemImage: "clock.fill"
                )
                summaryCard(
                    title: "Required Artifacts",
                    value: "\(snapshot.availableCount) / \(snapshot.requiredCount)",
                    systemImage: "checklist",
                    healthy: snapshot.availableCount == snapshot.requiredCount
                )
                summaryCard(
                    title: "Optional Artifacts",
                    value: snapshot.index.isAvailable ? "1 / 1" : "0 / 1",
                    systemImage: "square.stack.3d.up.fill",
                    healthy: snapshot.index.isAvailable
                )
            }
        }
    }

    private var quickActions: some View {
        dashboardSection("Quick Actions", systemImage: "bolt.fill") {
            LazyVGrid(columns: actionColumns, spacing: 14) {
                ForEach(ExecutiveDestination.allCases) { destination in
                    NavigationLink(value: destination) {
                        HStack(spacing: 14) {
                            Image(systemName: destination.systemImage)
                                .font(.title2)
                                .frame(width: 36, height: 36)
                                .foregroundStyle(.white)
                                .background(Color.accentColor.gradient, in: RoundedRectangle(cornerRadius: 10))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(destination.title).font(.headline)
                                Text("Open workspace").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, minHeight: 76)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationDestination(for: ExecutiveDestination.self) { destination in
                if destination == .decisionInbox {
                    DecisionInboxView()
                } else if destination == .missionCenter {
                    MissionCenterView()
                } else if destination == .supraChat {
                    SUPRAChatView()
                } else {
                    ExecutivePlaceholderView(destination: destination)
                }
            }
        }
    }

    private func runtimeHealth(_ snapshot: Snapshot) -> some View {
        let artifacts = snapshot.lots + [snapshot.build, snapshot.manifest, snapshot.desktopEstate, snapshot.index]
        return dashboardSection("Runtime Health", systemImage: "waveform.path.ecg") {
            LazyVGrid(columns: healthColumns, spacing: 10) {
                ForEach(artifacts) { artifact in
                    HStack(spacing: 10) {
                        Image(systemName: artifact.isAvailable ? "checkmark.circle.fill" : "minus.circle.fill")
                            .foregroundStyle(artifact.isAvailable ? .green : .secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(healthName(artifact)).font(.headline)
                            Text(artifact.isAvailable ? "Available" : "Unavailable")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 13))
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(.quaternary))
                }
            }
        }
    }

    private func recentActivity(_ snapshot: Snapshot) -> some View {
        dashboardSection("Recent Activity", systemImage: "clock.arrow.circlepath") {
            HStack(spacing: 14) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Runtime snapshot captured").font(.headline)
                    Text(snapshot.capturedAt.formatted(date: .long, time: .standard))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(18)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
        }
    }

    private func dashboardSection<Content: View>(
        _ title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: systemImage)
                .font(.title2.bold())
            content()
        }
    }

    private func summaryCard(
        title: String,
        value: String,
        systemImage: String,
        healthy: Bool? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage).foregroundStyle(.tint)
                Spacer()
                if let healthy {
                    Circle()
                        .fill(healthy ? Color.green : Color.secondary)
                        .frame(width: 8, height: 8)
                }
            }
            Text(value).font(.title3.bold()).lineLimit(1).minimumScaleFactor(0.75)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
    }

    private func healthName(_ artifact: ArtifactStatus) -> String {
        switch artifact.name {
        case "BUILD_STATUS": "BUILD"
        case "Desktop Estate": "ESTATE"
        default: artifact.name
        }
    }

    private var summaryColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 180), spacing: 14)]
    }

    private var actionColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 240), spacing: 14)]
    }

    private var healthColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 150), spacing: 10)]
    }
}

private enum ExecutiveDestination: String, CaseIterable, Identifiable, Hashable {
    case decisionInbox
    case missionCenter
    case runtimeMonitor
    case evidenceExplorer
    case capabilityBrowser
    case supraChat

    var id: Self { self }

    var title: String {
        switch self {
        case .decisionInbox: "Decision Inbox"
        case .missionCenter: "Mission Center"
        case .runtimeMonitor: "Runtime Monitor"
        case .evidenceExplorer: "Evidence Explorer"
        case .capabilityBrowser: "Capability Browser"
        case .supraChat: "SUPRA Chat"
        }
    }

    var systemImage: String {
        switch self {
        case .decisionInbox: "tray.full.fill"
        case .missionCenter: "scope"
        case .runtimeMonitor: "waveform.path.ecg"
        case .evidenceExplorer: "doc.text.magnifyingglass"
        case .capabilityBrowser: "square.grid.2x2.fill"
        case .supraChat: "bubble.left.and.bubble.right.fill"
        }
    }
}

private struct ExecutivePlaceholderView: View {
    let destination: ExecutiveDestination

    var body: some View {
        ContentUnavailableView(
            destination.title,
            systemImage: destination.systemImage,
            description: Text("This workspace is ready for its future product view.")
        )
        .navigationTitle(destination.title)
    }
}

#Preview {
    SupraControlCenterView()
}
