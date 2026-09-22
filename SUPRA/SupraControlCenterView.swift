import SwiftUI
import AppKit

struct SupraControlCenterView: View {
    @ObservedObject private var liveStore = SUPRAProcessObservatoryStore.shared
    @State private var installProof = SUPRALocalInstallProof.load()
    @State private var commandText = ""
    @State private var commandOutput = "SUPRA ready. Type an objective or continue from the current proven state."
    @State private var commandBusy = false
    @State private var commandError: String?

    private let missionRunner = SUPRAGrandeMissionRunner.shared

    var body: some View {
        NavigationStack {
            dashboard
                .navigationTitle("SUPRA")
                .toolbar {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        liveStore.refresh(force: true)
                        installProof = SUPRALocalInstallProof.load()
                    }
                }
        }
        .frame(minWidth: 980, minHeight: 680)
        .task {
            liveStore.start()
            liveStore.refresh(force: true)
            installProof = SUPRALocalInstallProof.load()
        }
    }

    private var dashboard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                dashboardHeader
                commandSurface
                executiveSummary
                quickActions
                runtimeHealth
                recentActivity
            }
            .padding(32)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var dashboardHeader: some View {
        SUPRAWorkspaceHeader(
            eyebrow: "SUPRA · EXECUTIVE WORKSPACE",
            title: "Executive Operating System",
            subtitle: "Primary work surface: command, execute through the existing runtime, inspect proof, and escalate only true human gates.",
            tint: .accentColor
        )
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
            let receipt = try await missionRunner.executeExecutiveObjective(command)
            liveStore.refresh(force: true)

            let executionState = receipt.status == "PASS"
                ? "MATERIALIZED"
                : (receipt.status == "BLOCKED" ? "TRUE_HUMAN_GATE" : "UNPROVEN")

            commandOutput = """
            OBJECTIVE_ID=\(receipt.phaseID)
            RUNTIME_ADMISSION=PASS
            EXECUTION=\(executionState)
            RECEIPT_STATUS=\(receipt.status)

            \(receipt.response)
            """

            if override == nil {
                commandText = ""
            }
        } catch {
            commandError = error.localizedDescription
            commandOutput = "SUPRA runtime did not return a proven result."
        }
    }

    private var executiveSummary: some View {
        dashboardSection("Executive Summary", systemImage: "chart.bar.xaxis") {
            LazyVGrid(columns: summaryColumns, spacing: 14) {
                summaryCard(
                    title: "Runtime Status",
                    value: liveStore.bridgeAvailable ? liveStore.momentumLabel : "Unavailable",
                    systemImage: "bolt.shield.fill",
                    healthy: liveStore.bridgeAvailable && liveStore.bottleneckCount == 0 && liveStore.driftCount == 0
                )
                summaryCard(
                    title: "Build Status",
                    value: installProof.displayStatus,
                    systemImage: "hammer.fill",
                    healthy: installProof.isCurrent
                )
                summaryCard(
                    title: "Last Refresh",
                    value: liveStore.lastRefresh.formatted(date: .abbreviated, time: .shortened),
                    systemImage: "clock.fill"
                )
                summaryCard(
                    title: "Materialized Results",
                    value: liveStore.materializedCount.formatted(),
                    systemImage: "checkmark.seal.fill",
                    healthy: liveStore.bridgeAvailable
                )
                summaryCard(
                    title: "Observable Closure",
                    value: "\(Int(liveStore.observableClosure * 100))%",
                    systemImage: "gauge.with.dots.needle.50percent",
                    healthy: liveStore.bridgeAvailable
                )
                summaryCard(
                    title: "Live Bottlenecks",
                    value: liveStore.bottleneckCount.formatted(),
                    systemImage: "exclamationmark.octagon.fill",
                    healthy: liveStore.bottleneckCount == 0
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
                }
            }
        }
    }

    private var runtimeHealth: some View {
        dashboardSection("Runtime Health", systemImage: "waveform.path.ecg") {
            LazyVGrid(columns: healthColumns, spacing: 10) {
                liveHealthCard(
                    "Bridge authority",
                    liveStore.bridgeAvailable ? "CONNECTED" : "UNAVAILABLE",
                    healthy: liveStore.bridgeAvailable
                )
                liveHealthCard(
                    "Installed build",
                    installProof.installedShortSHA,
                    healthy: installProof.isCurrent
                )
                liveHealthCard(
                    "In flight",
                    liveStore.inFlightCount.formatted(),
                    healthy: true
                )
                liveHealthCard(
                    "Drift",
                    liveStore.driftCount.formatted(),
                    healthy: liveStore.driftCount == 0
                )
                liveHealthCard(
                    "Canonical instance",
                    installProof.canonicalInstanceLabel,
                    healthy: installProof.nativeInstanceCount == 1
                )
            }
        }
    }

    private var recentActivity: some View {
        dashboardSection("Recent Activity", systemImage: "clock.arrow.circlepath") {
            HStack(spacing: 14) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Runtime snapshot captured").font(.headline)
                    Text(liveStore.lastRefresh.formatted(date: .long, time: .standard))
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
        VStack(alignment: .leading, spacing: SUPRAUI.sectionSpacing) {
            SUPRASectionTitle(title: title, systemImage: systemImage)
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

    private func liveHealthCard(_ title: String, _ value: String, healthy: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: healthy ? "checkmark.circle.fill" : "minus.circle.fill")
                .foregroundStyle(healthy ? .green : .secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(value)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(.quaternary))
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


private struct SUPRALocalInstallProof {
    let status: String
    let installedSourceSHA: String
    let observedCanonicalSHA: String
    let lastAction: String
    let nativeInstanceCount: Int
    let nativeCommand: String

    static func load() -> SUPRALocalInstallProof {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let stateURL = home
            .appendingPathComponent("Library/Application Support/NOVA ERA/SUPRA Updater/state.json")

        guard let data = try? Data(contentsOf: stateURL),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return SUPRALocalInstallProof(
                status: "UNAVAILABLE",
                installedSourceSHA: "",
                observedCanonicalSHA: "",
                lastAction: "UNAVAILABLE",
                nativeInstanceCount: 0,
                nativeCommand: ""
            )
        }

        let installed = object["installed_source_sha"] as? String ?? ""
        let observed = object["observed_canonical_sha"] as? String ?? installed

        let applications = NSRunningApplication.runningApplications(
            withBundleIdentifier: "com.nicolasalonso.SUPRA"
        )
        let canonicalExec = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Applications/SUPRA.app/Contents/MacOS/SUPRA")
            .path

        return SUPRALocalInstallProof(
            status: installed.isEmpty ? "UNAVAILABLE" : "PASS",
            installedSourceSHA: installed,
            observedCanonicalSHA: observed,
            lastAction: object["last_action"] as? String ?? "UNKNOWN",
            nativeInstanceCount: applications.count,
            nativeCommand: canonicalExec
        )
    }

    var isCurrent: Bool {
        status == "PASS"
            && !installedSourceSHA.isEmpty
            && installedSourceSHA == observedCanonicalSHA
    }

    var displayStatus: String {
        if isCurrent { return "Current" }
        if status == "UNAVAILABLE" { return "Unavailable" }
        return "Behind"
    }

    var installedShortSHA: String {
        installedSourceSHA.isEmpty ? "UNPROVEN" : String(installedSourceSHA.prefix(12))
    }

    var canonicalInstanceLabel: String {
        nativeInstanceCount == 1 ? "1 · canonical" : "\(nativeInstanceCount)"
    }
}

private enum ExecutiveDestination: String, CaseIterable, Identifiable, Hashable {
    case decisionInbox
    case missionCenter
    case runtimeMonitor
    case supraChat

    var id: Self { self }

    var title: String {
        switch self {
        case .decisionInbox: "Decision Inbox"
        case .missionCenter: "Mission Center"
        case .runtimeMonitor: "Runtime Monitor"
        case .supraChat: "SUPRA Chat"
        }
    }

    var systemImage: String {
        switch self {
        case .decisionInbox: "tray.full.fill"
        case .missionCenter: "scope"
        case .runtimeMonitor: "waveform.path.ecg"
        case .supraChat: "bubble.left.and.bubble.right.fill"
        }
    }
}

#Preview {
    SupraControlCenterView()
}
