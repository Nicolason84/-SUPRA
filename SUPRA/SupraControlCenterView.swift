import SwiftUI

struct SupraControlCenterView: View {
    @StateObject private var store: ControlCenterStore
    @State private var commandText = ""
    @State private var commandOutput = "SUPRA ready. Type an objective or continue from the current proven state."
    @State private var commandBusy = false
    @State private var commandError: String?

    private let runtime = SUPRAChatRuntimeAdapter()

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
                commandSurface
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
            Text("Primary executive work surface: command, execute through the existing runtime, inspect evidence, and escalate only true human gates.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var commandSurface: some View {
        dashboardSection("Command SUPRA", systemImage: "terminal.fill") {
            VStack(alignment: .leading, spacing: 12) {
                TextEditor(text: $commandText)
                    .font(.body)
                    .frame(minHeight: 96, maxHeight: 160)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.quaternary)
                    )
                    .disabled(commandBusy)
                    .accessibilityLabel("SUPRA command")

                HStack(spacing: 10) {
                    Button {
                        Task { await executeCommand() }
                    } label: {
                        Label(commandBusy ? "Running…" : "Execute", systemImage: "bolt.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        commandBusy
                        || commandText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )

                    Button {
                        Task {
                            await executeCommand(
                                "Continue from the current proven state. Resolve the highest-impact machine-solvable blocker, then continue the active mission. Do not ask Nicolas to relay shell commands."
                            )
                        }
                    } label: {
                        Label("Continue", systemImage: "forward.fill")
                    }
                    .buttonStyle(.bordered)
                    .disabled(commandBusy)

                    Spacer()

                    Text("Existing SUPRA runtime · proof-first · human gate only when required")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let commandError {
                    Label(commandError, systemImage: "exclamationmark.triangle.fill")
                        .font(.callout)
                        .foregroundStyle(.orange)
                }

                ScrollView {
                    Text(commandOutput)
                        .font(.callout.monospaced())
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 90, maxHeight: 220)
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    @MainActor
    private func executeCommand(_ override: String? = nil) async {
        guard !commandBusy else { return }

        let raw = override ?? commandText
        let command = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { return }

        commandBusy = true
        commandError = nil
        commandOutput = "SUPRA is executing through the existing runtime…"

        defer { commandBusy = false }

        do {
            try await runtime.checkHealth()

            let prompt = """
            SUPRA_PRIMARY_WORK_SURFACE
            AUTHORITY=NICOLAS
            CONTROL_SURFACE=SUPRA
            MODE=EXECUTE_NOT_REINVESTIGATE
            MEMORY_FIRST=YES
            PATRIMONY_FIRST=YES
            PROOF_FIRST=YES
            NO_NEW_ENGINE=YES
            NO_NEW_BRIDGE=YES
            NO_NEW_RUNTIME=YES
            NO_HUMAN_RELAY=YES
            NO_FAKE_PASS=YES
            AUTO_EXECUTE_READ_ONLY=YES
            AUTO_EXECUTE_REVERSIBLE_LOCAL=YES
            HUMAN_GATE_ONLY_FOR=IRREVERSIBLE_DELETE|SECURITY_BOUNDARY_CHANGE|AUTHORITY_CHANGE|MONEY_MOVEMENT|LEGAL_ADMIN_SUBMISSION|PUBLICATION|SIGNATURE_BINDING_COMMITMENT

            USER_COMMAND:
            \(command)

            Work from the existing SUPRA runtime and current evidence.
            Do all machine-solvable work before asking Nicolas anything.
            Never ask Nicolas to copy/paste a Terminal command when an existing machine path can do it.
            Preserve rollback and return concrete evidence.

            RETURN:
            STATUS=
            CURRENT_STATE=
            WORK_COMPLETED=
            REAL_RESULT=
            EVIDENCE_REFS=
            BLOCKERS=
            HUMAN_GATE_REQUIRED=YES|NO
            ACTION_NICOLAS=NONE|<single indispensable action>
            NEXT_MACHINE_ACTION=
            """

            commandOutput = try await runtime.execute(prompt: prompt, mode: .plan)

            if override == nil {
                commandText = ""
            }
        } catch {
            commandError = error.localizedDescription
            commandOutput = "SUPRA runtime did not return a proven result."
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
                } else if destination == .runtimeMonitor {
                    SUPRAProcessObservatoryView()
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
