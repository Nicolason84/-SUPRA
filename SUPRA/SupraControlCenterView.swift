import SwiftUI
import AppKit

struct SupraControlCenterView: View {
    @ObservedObject private var liveStore = SUPRAProcessObservatoryStore.shared
    @State private var installProof = SUPRALocalInstallProof.load()
    @State private var commandText = ""
    @State private var commandOutput = "SUPRA ready. Type an objective or continue from the current proven state."
    @State private var commandBusy = false
    @State private var commandError: String?
    @State private var activeCommandText: String?
    @AppStorage("supra.command.standby.text.v1") private var standbyCommandText = ""
    @AppStorage("supra.command.standby.objective.v1") private var standbyObjectiveID = ""
    @State private var commandInterruptionIntent: SUPRAGrandeMissionRunner.ExecutiveInterruptionIntent?
    @State private var versionRefreshBusy = false
    @State private var versionRefreshStatus = "Ready"
    @State private var versionRefreshError: String?
    @State private var admissionClosureProbeStarted = false
    @State private var megabusStartStarted = false

    private let missionRunner = SUPRAGrandeMissionRunner.shared

    var body: some View {
        NavigationStack {
            dashboard
                .navigationTitle("SUPRA")
                .toolbar {
                    Button("Refresh data", systemImage: "arrow.clockwise") {
                        liveStore.refresh(force: true)
                        installProof = SUPRALocalInstallProof.load()
                    }

                    Button {
                        Task { await refreshCanonicalVersion() }
                    } label: {
                        Label(
                            versionRefreshBusy ? "Updating…" : "Update & Relaunch",
                            systemImage: versionRefreshBusy
                                ? "arrow.triangle.2.circlepath.circle.fill"
                                : "shippingbox.and.arrow.backward.fill"
                        )
                    }
                    .disabled(versionRefreshBusy)
                    .help("Build Release → sign → install with rollback → relaunch canonical SUPRA")
                }
        }
        .frame(minWidth: 980, minHeight: 680)
        .task {
            liveStore.start()
            liveStore.refresh(force: true)
            installProof = SUPRALocalInstallProof.load()
            // UI lifecycle is observation-only. Durable executive objectives are
            // admitted only by an explicit Execute/Resume action from Nicolas.
            // This prevents launch/relaunch from manufacturing duplicate missions.
        }
    }

    private var dashboard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                dashboardHeader
                commandSurface
                executiveSummary
                versionRelease
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

                    if commandBusy {
                        Button {
                            standbyCommand()
                        } label: {
                            Label("Standby", systemImage: "pause.circle.fill")
                        }
                        .buttonStyle(.bordered)

                        Button(role: .destructive) {
                            abortCommand()
                        } label: {
                            Label("Abort", systemImage: "stop.circle.fill")
                        }
                        .buttonStyle(.bordered)
                    } else if !standbyCommandText.isEmpty {
                        Button {
                            resumeStandbyCommand()
                        } label: {
                            Label("Resume", systemImage: "play.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)

                        Button(role: .destructive) {
                            discardStandbyCommand()
                        } label: {
                            Label("Abort", systemImage: "stop.circle")
                        }
                        .buttonStyle(.bordered)
                    }

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
    private func runExecutiveAdmissionClosureProbeIfNeeded() async {
        let defaults = UserDefaults.standard
        let key = "SUPRA_EXECUTIVE_ADMISSION_CLOSURE_V1_DONE"
        let lastAttemptKey = "SUPRA_EXECUTIVE_ADMISSION_CLOSURE_V1_LAST_ATTEMPT"
        let now = Date().timeIntervalSince1970
        let lastAttempt = defaults.double(forKey: lastAttemptKey)
        let cooldown: TimeInterval = 15 * 60

        guard !defaults.bool(forKey: key),
              !admissionClosureProbeStarted,
              lastAttempt == 0 || now - lastAttempt >= cooldown else {
            return
        }

        admissionClosureProbeStarted = true
        defaults.set(now, forKey: lastAttemptKey)

        let objective = """
        Report the current SUPRA runtime state and identify the first real unresolved blocker using existing evidence only. Make no changes. Return one material result or a true Human Gate.
        """

        commandText = objective
        await executeCommand(objective)

        let upper = commandOutput.uppercased()
        let proven = upper.contains("STATUS=PASS")
            || upper.contains("HUMAN_GATE_REQUIRED=YES")

        if proven,
           upper.contains("OBJECTIVE_ID=EXECUTIVE_OBJECTIVE_"),
           upper.contains("RUNTIME_ADMISSION=") {
            defaults.set(true, forKey: key)
        }
    }

    @MainActor
    private func startExistingMegabusIfNeeded() async {
        let defaults = UserDefaults.standard
        let key = "SUPRA_EXISTING_MEGABUS_CANONICAL_STORE_V2_DONE"

        if SUPRATerminalMegabusBridge.status() == "CONNECTED" {
            defaults.set(true, forKey: key)
            return
        }

        guard !defaults.bool(forKey: key),
              !megabusStartStarted else {
            return
        }

        megabusStartStarted = true

        let objective = """
        Close ONLY the final EXISTING SUPRA Terminal Megabus lock.

        PROVEN_ONE_SUPRA=PASS
        PROVEN_INSTALLED_HEAD=1741f05c0f308e596dd6e29cad18ca712b0ca551
        PROVEN_CANONICAL_EXEC=$HOME/Applications/SUPRA.app/Contents/MacOS/SUPRA

        IMPORTANT_CANONICAL_STORE_TRUTH:
        The current SUPRA app is sandboxed.
        Its canonical Megabus root is:
        $HOME/Library/Containers/com.nicolasalonso.SUPRA/Data/NOVA_OS/SUPRA_TERMINAL_MEGABUS_V1

        The old shell-visible root:
        $HOME/NOVA_OS/SUPRA_TERMINAL_MEGABUS_V1
        is historical/legacy and MUST NOT be treated as the current app store.

        HISTORICAL_PROVEN_RUN:
        $HOME/NOVA_OS/SUPRA_TERMINAL_MEGABUS_AND_CANNONICO_FIX_V1/RUNS/20260721_063157

        HISTORICAL_FOLLOWUP_RUN:
        $HOME/NOVA_OS/CONNECT_SUPRA_GABRIEL_SCRIPT_EDITOR_TO_MEGABUS_V1/RUNS/20260721_063804

        Historical proof:
        TERMINAL_MEGABUS=STARTED
        MEGABUS_PID=96457
        MEGABUS_SELF_TEST=PASS
        SUPRA_MEGABUS_BRIDGE=PASS
        GABRIEL_MEGABUS_REGISTRATION=PASS
        SCRIPT_EDITOR_MEGABUS_BRIDGE=PASS
        MEGABUS_ROUTED_MESSAGES=3

        DO NOW, SEQUENTIALLY:
        1) Inspect ONLY the two historical proven run directories above and the current canonical container root.
        2) Recover the EXISTING Megabus consumer/daemon artifact and its original supported start semantics from those runs or their directly referenced artifacts.
        3) Do NOT recreate, rewrite, regenerate or replace the consumer/daemon.
        4) Do NOT rerun the old CAnnoNico core patch/build.
        5) Do NOT change sandbox entitlements or any security boundary.
        6) Do NOT fabricate TERMINALS/CURRENT.json.
        7) If the recovered existing consumer supports selecting/configuring its root without source mutation, start/restart that exact consumer against:
           $HOME/Library/Containers/com.nicolasalonso.SUPRA/Data/NOVA_OS/SUPRA_TERMINAL_MEGABUS_V1
        8) If it is already running against that exact canonical root, reuse it.
        9) Confirm it consumes the real SUPRA/GABRIEL CLIENT_REGISTERED JSON messages already published in the canonical container INBOX.
        10) Require the real consumer to produce:
            .../TERMINALS/CURRENT.json
            under that SAME canonical container root.
        11) Prove a live consumer process/PID, coherent routing evidence, and the daemon-produced registry.
        12) If the historical consumer artifact is absent, or is hard-coded to the legacy root and cannot be redirected using an existing supported option/configuration, STOP at that exact bounded blocker. Do not implement an alternative.
        13) A security-boundary/entitlement change is a TRUE_HUMAN_GATE. Ordinary missing artifact/configuration is BLOCKED/UNPROVEN, not permission to recreate infrastructure.

        PASS requires ALL:
        - recovered existing consumer, not a recreated one
        - consumer live on the canonical container root
        - SUPRA/GABRIEL registration messages consumed
        - daemon-produced canonical TERMINALS/CURRENT.json
        - no new engine/runtime/bridge/registry/backend
        - no entitlement change

        RETURN:
        STATUS=PASS|BLOCKED|UNPROVEN
        CURRENT_STATE=
        WORK_COMPLETED=
        REAL_RESULT=
        EVIDENCE_REFS=
        BLOCKERS=
        HUMAN_GATE_REQUIRED=YES|NO
        ACTION_NICOLAS=NONE|<single indispensable action>
        NEXT_MACHINE_ACTION=
        """

        commandText = objective
        await executeCommand(objective)

        let upper = commandOutput.uppercased()
        let proven =
            upper.contains("STATUS=PASS")
            && upper.contains("HUMAN_GATE_REQUIRED=NO")

        if proven {
            defaults.set(true, forKey: key)
        }
    }

    private func executeCommand(_ override: String? = nil) async {
        guard !commandBusy else { return }

        let raw = override ?? commandText
        let command = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { return }

        commandBusy = true
        commandError = nil
        activeCommandText = command
        commandInterruptionIntent = nil
        commandOutput = "SUPRA is executing through the existing runtime…"

        defer {
            commandBusy = false
            activeCommandText = nil
            commandInterruptionIntent = nil
        }

        do {
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

            let result = try await missionRunner.executeExecutiveObjective(
                objective: command,
                runtimePrompt: prompt
            )

            commandOutput = """
            OBJECTIVE_ID=\(result.objectiveID)
            RUNTIME_ADMISSION=\(result.admissionPath)
            RECEIPT=\(result.receiptPath)
            STATUS=\(result.status)
            HUMAN_GATE_REQUIRED=\(result.humanGateRequired ? "YES" : "NO")

            \(result.response)
            """

            if override == nil {
                commandText = ""
            }
        } catch is CancellationError {
            commandError = nil
            switch commandInterruptionIntent {
            case .standby:
                commandOutput = """
                STATUS=STANDBY
                OBJECTIVE_ID=\(!standbyObjectiveID.isEmpty ? standbyObjectiveID : (missionRunner.activeExecutiveObjectiveID ?? "UNPROVEN"))
                ACTION_NICOLAS=NONE
                NEXT=Resume or Abort
                """
            case .abort:
                commandOutput = """
                STATUS=ABORTED
                ACTION_NICOLAS=NONE
                NEXT=Ready for a new objective
                """
            case .none:
                commandOutput = "STATUS=CANCELLED"
            }
        } catch {
            commandError = error.localizedDescription
            commandOutput = "SUPRA runtime did not return a proven result."
        }
    }

    private func standbyCommand() {
        guard commandBusy else { return }
        standbyCommandText = activeCommandText ?? commandText
        standbyObjectiveID = missionRunner.activeExecutiveObjectiveID ?? ""
        commandInterruptionIntent = .standby
        missionRunner.requestExecutiveInterruption(.standby)
    }

    private func abortCommand() {
        guard commandBusy else { return }
        standbyCommandText = ""
        standbyObjectiveID = ""
        commandInterruptionIntent = .abort
        missionRunner.requestExecutiveInterruption(.abort)
    }

    private func resumeStandbyCommand() {
        guard !commandBusy, !standbyCommandText.isEmpty else { return }
        let command = standbyCommandText
        let parent = standbyObjectiveID
        standbyCommandText = ""
        standbyObjectiveID = ""
        let resumed = parent.isEmpty
            ? command
            : "RESUME_FROM_OBJECTIVE_ID=\(parent)\n" + command
        Task { await executeCommand(resumed) }
    }

    private func discardStandbyCommand() {
        standbyCommandText = ""
        standbyObjectiveID = ""
        commandOutput = "STATUS=ABORTED\nACTION_NICOLAS=NONE\nNEXT=Ready for a new objective"
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

    private var versionRelease: some View {
        dashboardSection("Version & Release", systemImage: "shippingbox.and.arrow.backward.fill") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Installed app baseline")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(installProof.installedShortSHA)
                            .font(.headline.monospaced())
                    }

                    Divider()
                        .frame(height: 34)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Observed canonical")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(installProof.observedShortSHA)
                            .font(.headline.monospaced())
                    }

                    Divider()
                        .frame(height: 34)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Updater")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(installProof.lastAction)
                            .font(.caption.monospaced())
                            .lineLimit(2)
                    }

                    Spacer()

                    Button {
                        Task { await refreshCanonicalVersion() }
                    } label: {
                        HStack(spacing: 8) {
                            if versionRefreshBusy {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "hammer.fill")
                            }
                            Text(versionRefreshBusy ? "Release in progress…" : "Build Release + Relaunch")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(versionRefreshBusy)
                }

                HStack(spacing: 8) {
                    Image(systemName: versionRefreshError == nil ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(versionRefreshError == nil ? .green : .orange)
                    Text(versionRefreshError ?? versionRefreshStatus)
                        .font(.callout)
                        .foregroundStyle(versionRefreshError == nil ? Color.secondary : Color.orange)
                }

                Text("Uses the existing governed updater only: exact canonical SHA → CI gate → Release build → sign → rollback-safe install → single canonical relaunch → runtime proof.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(18)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
        }
    }

    @MainActor
    private func refreshCanonicalVersion() async {
        guard !versionRefreshBusy else { return }

        versionRefreshBusy = true
        versionRefreshError = nil
        versionRefreshStatus = "Starting the existing SUPRA updater…"

        let installedBefore = installProof.installedSourceSHA

        let kicked = await kickstartExistingUpdater()
        if kicked {
            versionRefreshStatus = "Release build started. SUPRA will install with rollback and relaunch automatically."
        } else {
            versionRefreshStatus = "Direct updater kickstart unavailable. Routing the same bounded update through the existing SUPRA runtime…"

            do {
                let objective = """
                Refresh the canonical SUPRA application now using ONLY the existing governed updater.

                REQUIRED_SEQUENCE:
                1) Resolve the current canonical branch head and distinguish app-impacting changes from control-only commits.
                2) Require successful Validate Canonical SUPRA CI for the exact source being installed.
                3) Reuse ONLY com.novaera.supra-autoupdate and the existing supra_autobuild_self_update.sh.
                4) Perform the existing Release build, signing, rollback-safe install and canonical relaunch.
                5) Launch exactly one /Users/nicolasalonso/Applications/SUPRA.app instance.
                6) Preserve rollback and do not create any engine, bridge, runtime, backend or updater.
                7) Publish the existing SUPRA_LOCAL_RUNTIME_PROOF.json.
                8) Do not ask Nicolas to use Terminal.

                RETURN ONE MATERIAL RESULT OR THE FIRST EXACT BLOCKER.
                """

                _ = try await missionRunner.executeExecutiveObjective(
                    objective: "Refresh SUPRA to the latest CI-passed canonical application version and relaunch it.",
                    runtimePrompt: objective
                )
                versionRefreshStatus = "Update admitted through the existing runtime. Waiting for install/relaunch proof…"
            } catch {
                versionRefreshError = "Updater unavailable: \(error.localizedDescription)"
                versionRefreshBusy = false
                return
            }
        }

        for _ in 0..<150 {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            let proof = SUPRALocalInstallProof.load()
            installProof = proof

            if proof.lastAction == "BUILD_SIGN_INSTALL_LAUNCH_PASS",
               proof.installedSourceSHA != installedBefore {
                versionRefreshStatus = "Release installed. SUPRA is relaunching on the fresh build…"
                return
            }

            if proof.lastAction == "NO_APP_REBUILD_REQUIRED",
               proof.isCurrent {
                versionRefreshStatus = "Already current. No app-impacting rebuild was required."
                versionRefreshBusy = false
                return
            }
        }

        versionRefreshError = "Updater started, but final install proof was not observed within 5 minutes."
        versionRefreshBusy = false
    }

    private func kickstartExistingUpdater() async -> Bool {
        await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
            process.arguments = [
                "kickstart",
                "-k",
                "gui/\(getuid())/com.novaera.supra-autoupdate"
            ]

            let output = Pipe()
            process.standardOutput = output
            process.standardError = output

            do {
                try process.run()
                process.waitUntilExit()
                return process.terminationStatus == 0
            } catch {
                return false
            }
        }.value
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
        let fm = FileManager.default
        let embeddedSourceSHA = Bundle.main
            .object(forInfoDictionaryKey: "SUPRASourceSHA") as? String ?? ""

        var projection: [String: Any] = [:]
        if let appSupport = fm.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first {
            let projectionURL = appSupport
                .appendingPathComponent("SUPRA", isDirectory: true)
                .appendingPathComponent("Projection", isDirectory: true)
                .appendingPathComponent("UPDATER_STATE.json")

            if let data = try? Data(contentsOf: projectionURL, options: [.mappedIfSafe]),
               let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                projection = object
            }
        }

        let projectedInstalled = projection["installed_source_sha"] as? String ?? ""
        let observed = projection["observed_canonical_sha"] as? String ?? ""
        let installed = embeddedSourceSHA.isEmpty ? projectedInstalled : embeddedSourceSHA

        let applications = NSRunningApplication.runningApplications(
            withBundleIdentifier: "com.nicolasalonso.SUPRA"
        )
        let canonicalExec = Bundle.main.executableURL?.path ?? ""

        let proofStatus: String
        if installed.isEmpty {
            proofStatus = "UNAVAILABLE"
        } else if !projectedInstalled.isEmpty && projectedInstalled != installed {
            proofStatus = "DRIFT"
        } else {
            proofStatus = "PASS"
        }

        return SUPRALocalInstallProof(
            status: proofStatus,
            installedSourceSHA: installed,
            observedCanonicalSHA: observed,
            lastAction: projection["last_action"] as? String
                ?? (installed.isEmpty ? "UNAVAILABLE" : "PROJECTION_PENDING"),
            nativeInstanceCount: applications.count,
            nativeCommand: canonicalExec
        )
    }

    var isCurrent: Bool {
        status == "PASS"
            && !installedSourceSHA.isEmpty
            && (
                installedSourceSHA == observedCanonicalSHA
                || lastAction == "NO_APP_REBUILD_REQUIRED"
            )
    }

    var displayStatus: String {
        if isCurrent { return "Current" }
        if status == "UNAVAILABLE" { return "Unproven" }
        if status == "DRIFT" { return "Drift" }
        return "Behind"
    }

    var installedShortSHA: String {
        installedSourceSHA.isEmpty ? "UNPROVEN" : String(installedSourceSHA.prefix(12))
    }

    var observedShortSHA: String {
        observedCanonicalSHA.isEmpty ? "UNPROVEN" : String(observedCanonicalSHA.prefix(12))
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
