import SwiftUI

enum OJOPrivateTab: String, CaseIterable, Identifiable {
    case now = "Now"
    case needsYou = "Needs Nicolas"
    case autonomous = "Machine can continue"
    case missions = "Missions"
    case decisions = "Decisions"
    case connections = "Connections"
    case context = "Private context"
    case signals = "Signals"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .now: "scope"
        case .needsYou: "person.crop.circle.badge.exclamationmark"
        case .autonomous: "bolt.circle.fill"
        case .missions: "target"
        case .decisions: "gauge.with.dots.needle.50percent"
        case .connections: "point.3.connected.trianglepath.dotted"
        case .context: "brain.head.profile"
        case .signals: "waveform.path.ecg"
        }
    }
}

struct OJOPrivateControlView: View {
    @State private var tab: OJOPrivateTab = .now
    @State private var isBusy = false
    @State private var runtimeState = "CHECKING"
    @State private var output = ""
    @State private var lastError: String?
    @State private var lastQuery: Date?
    @State private var lastMaterialChange = "Not queried"
    @State private var topBottleneck = "Not queried"
    @State private var nextMachineAction = "Not queried"
    @State private var nextHumanAction = "Not queried"
    @ObservedObject private var liveStore = SUPRAProcessObservatoryStore.shared

    private let runtime = SUPRAChatRuntimeAdapter()

    var body: some View {
        HStack(spacing: 0) {
            privateRail
                .frame(width: 250)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    hero
                    bodyContent
                }
                .padding(28)
                .frame(maxWidth: 1160, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.10),
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .task {
            await bootstrap()
        }
        .onReceive(liveStore.$processes) { _ in
            refreshFromLiveStore()
        }
    }

    private var privateRail: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Image(systemName: "eye.fill")
                        .foregroundStyle(.purple)
                    Text("ŒIL")
                        .font(.title2.bold())
                        .foregroundStyle(.purple)
                }
                Text("PRIVATE PERCEPTION + CONTROL")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.4)
                    .foregroundStyle(.secondary)
            }

            Divider()

            ForEach(OJOPrivateTab.allCases) { item in
                Button {
                    tab = item
                    if item != .signals {
                        Task { await queryForTab(item) }
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: item.symbol)
                            .frame(width: 20)
                        Text(item.rawValue)
                        Spacer()
                    }
                    .font(.callout.weight(tab == item ? .bold : .semibold))
                    .foregroundStyle(tab == item ? .purple : .secondary)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 9)
                    .background(
                        tab == item ? Color.purple.opacity(0.10) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 11)
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 6) {
                Text("RUNTIME")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(.secondary)
                HStack(spacing: 7) {
                    Circle()
                        .fill(runtimeTint)
                        .frame(width: 7, height: 7)
                    Text(runtimeState)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(runtimeTint)
                }
                if let lastQuery {
                    Text(lastQuery.formatted(date: .omitted, time: .standard))
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(18)
        .background(.ultraThinMaterial)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.10))
                    Circle()
                        .stroke(Color.purple.opacity(0.36), lineWidth: 1)
                        .padding(6)
                    Image(systemName: "eye.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.purple)
                        .shadow(color: .purple.opacity(0.35), radius: 14)
                }
                .frame(width: 78, height: 78)

                VStack(alignment: .leading, spacing: 7) {
                    Text("ŒIL · NICOLAS ↔ SUPRA")
                        .font(.caption.weight(.heavy))
                        .tracking(1.6)
                        .foregroundStyle(.purple)

                    Text("Private authority surface.")
                        .font(.caption.weight(.heavy))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)

                    Text("See what matters. Ignore the noise.")
                        .font(.system(size: 36, weight: .bold, design: .rounded))

                    Text("Primary perceptual layer for true human gates, live context, weak signals, decisions and what the machine can continue alone.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    liveStore.refresh(force: true)
                    refreshFromLiveStore()
                    runtimeState = liveStore.bridgeAvailable ? "CONNECTED" : runtimeState
                    lastError = liveStore.bridgeAvailable ? nil : lastError
                } label: {
                    Label("Refresh now", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
            }

            HStack(spacing: 10) {
                executiveChip(
                    "Last material change",
                    lastMaterialChange,
                    "clock.arrow.circlepath",
                    .blue
                )
                executiveChip(
                    "Top bottleneck",
                    topBottleneck,
                    "exclamationmark.octagon.fill",
                    .orange
                )
                executiveChip(
                    "Machine next",
                    nextMachineAction,
                    "bolt.fill",
                    .green
                )
                executiveChip(
                    "Nicolas next",
                    nextHumanAction,
                    "person.crop.circle.fill",
                    .purple
                )
            }
        }
        .padding(22)
        .supraCard(radius: SUPRAUI.heroRadius, strokeOpacity: 0.10)
    }

    @ViewBuilder
    private var bodyContent: some View {
        if tab == .signals {
            VStack(alignment: .leading, spacing: 12) {
                Label("System signals", systemImage: "waveform.path.ecg")
                    .font(.title2.bold())
                Text("Primary perceptual visualization for pattern sensing, weak-signal detection and living-system awareness. It informs control without replacing proof.")
                    .foregroundStyle(.secondary)
                OJOOrganismNativeView()
                    .frame(minHeight: 680)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        } else {
            VStack(alignment: .leading, spacing: 16) {
                actionStrip

                if isBusy {
                    ProgressView("SUPRA is resolving the current private state…")
                        .controlSize(.large)
                        .padding(.vertical, 34)
                } else if let lastError {
                    ContentUnavailableView(
                        "Private runtime unavailable",
                        systemImage: "exclamationmark.triangle.fill",
                        description: Text(lastError)
                    )
                } else if output.isEmpty {
                    ContentUnavailableView(
                        "No current result",
                        systemImage: tab.symbol,
                        description: Text("Run the current private query.")
                    )
                } else {
                    currentResult
                }
            }
        }
    }

    private var actionStrip: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 230), spacing: 12)],
            spacing: 12
        ) {
            actionButton(
                "What needs me?",
                "Only true human gates.",
                "person.crop.circle.badge.exclamationmark",
                "NEEDS_NICOLAS",
                .ask
            )
            actionButton(
                "Continue alone",
                "Machine-solvable next moves.",
                "bolt.circle.fill",
                "MACHINE_CAN_CONTINUE",
                .plan
            )
            actionButton(
                "Top bottleneck",
                "Highest-impact blocker now.",
                "exclamationmark.octagon.fill",
                "TOP_BOTTLENECK",
                .ask
            )
            actionButton(
                "What changed?",
                "Material delta since prior state.",
                "arrow.triangle.2.circlepath",
                "WHAT_CHANGED",
                .ask
            )
            actionButton(
                "Prepare decision",
                "Evidence-backed human decision packet.",
                "gauge.with.dots.needle.50percent",
                "PREPARE_TOP_DECISION",
                .plan
            )
            actionButton(
                "Next 3 moves",
                "Ordered machine/human actions.",
                "list.number",
                "NEXT_THREE_MOVES",
                .plan
            )

            Button {
                openMediaHero()
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "play.rectangle.on.rectangle.fill")
                        .font(.title2)
                        .foregroundStyle(.purple)
                    Text("Open Media Hero")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Context → source → evidence → lineage → memory return.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
                .supraCard(radius: 16)
            }
            .buttonStyle(.plain)
        }
    }

    private var currentResult: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(tab.rawValue.uppercased(), systemImage: tab.symbol)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.purple)

                Spacer()

                if let lastQuery {
                    Text(lastQuery.formatted(date: .abbreviated, time: .standard))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            Text(output)
                .font(.callout.monospaced())
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .supraCard()
    }

    private func executiveChip(
        _ title: String,
        _ value: String,
        _ symbol: String,
        _ tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(title, systemImage: symbol)
                .font(.caption2.weight(.bold))
                .foregroundStyle(tint)
            Text(value)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
        }
        .padding(11)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }

    private func actionButton(
        _ title: String,
        _ subtitle: String,
        _ symbol: String,
        _ kind: String,
        _ mode: ChatMode
    ) -> some View {
        Button {
            Task { await query(kind: kind, mode: mode) }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundStyle(.purple)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
            .supraCard(radius: 16)
        }
        .buttonStyle(.plain)
        .disabled(isBusy)
    }

    private func openMediaHero() {
        var seen = Set<String>()
        let lineageRefs = liveStore.processes
            .filter { $0.stage != .historical }
            .prefix(4)
            .flatMap { $0.proofRefs.prefix(3) }
            .filter { seen.insert($0).inserted }

        SUPRAMediaHeroRouter.shared.present(
            SUPRAMediaHeroContext(
                objectID: "OJO_PRIVATE_" + tab.rawValue.uppercased().replacingOccurrences(of: " ", with: "_"),
                objectType: "OJO_PRIVATE_CONTEXT",
                title: "ŒIL · " + tab.rawValue,
                subtitle: lastMaterialChange,
                origin: "ojO",
                lineageRefs: Array(lineageRefs.prefix(12))
            )
        )
    }

    private var runtimeTint: Color {
        switch runtimeState {
        case "CONNECTED", "PASS": .green
        case "RUNNING", "CHECKING": .orange
        case "ERROR": .red
        default: .secondary
        }
    }

    @MainActor
    private func bootstrap() async {
        liveStore.start()
        liveStore.refresh(force: true)
        refreshFromLiveStore()

        do {
            try await runtime.checkHealth()
            runtimeState = "CONNECTED"
            lastError = nil
            refreshFromLiveStore()
        } catch {
            runtimeState = liveStore.bridgeAvailable ? "CONNECTED" : "ERROR"
            lastError = liveStore.bridgeAvailable ? nil : error.localizedDescription
            refreshFromLiveStore()
        }
    }

    @MainActor
    private func queryForTab(_ selected: OJOPrivateTab) async {
        let kind: String = switch selected {
        case .now: "PRIVATE_EXECUTIVE_NOW"
        case .needsYou: "NEEDS_NICOLAS"
        case .autonomous: "MACHINE_CAN_CONTINUE"
        case .missions: "PRIVATE_ACTIVE_MISSIONS"
        case .decisions: "PRIVATE_DECISIONS"
        case .connections: "PRIVATE_CONNECTION_STATE"
        case .context: "PRIVATE_CONTEXT_STATE"
        case .signals: "SIGNALS"
        }

        if selected == .now {
            liveStore.refresh(force: true)
            refreshFromLiveStore()
            return
        }

        let mode: ChatMode = selected == .autonomous ? .plan : .ask
        await query(kind: kind, mode: mode)
    }

    @MainActor
    private func query(kind: String, mode: ChatMode) async {
        guard !isBusy else { return }

        isBusy = true
        runtimeState = "RUNNING"
        lastError = nil

        do {
            try await runtime.checkHealth()
            runtimeState = "CONNECTED"

            let prompt = """
            OJO_PRIVATE_CONTROL
            AUTHORITY=NICOLAS
            QUERY=\(kind)
            READ_ONLY=YES
            MEMORY_FIRST=YES
            PROOF_FIRST=YES
            NO_NEW_ENGINE=YES
            NO_NEW_BRIDGE=YES
            NO_NEW_RUNTIME=YES
            NO_DESTRUCTIVE_ACTION=YES
            HUMAN_GATE_FOR_IRREVERSIBLE=YES

            This is the private Nicolas ↔ SUPRA control surface.
            Use only current evidence and existing registries.
            Distinguish LIVE / STALE / HISTORICAL / UNPROVEN.
            Do not invent tasks, people, money, decisions or connection states.

            Return:
            CURRENT_STATE=
            MOMENTUM=
            LAST_MATERIAL_CHANGE=
            CURRENT_MISSION=
            TOP_BOTTLENECK=
            NEEDS_NICOLAS=
            MACHINE_CAN_CONTINUE=
            DECISIONS_WAITING=
            CONNECTIONS_AT_RISK=
            STALE_EVIDENCE=
            NEXT_MACHINE_ACTION=
            NEXT_HUMAN_ACTION=
            EVIDENCE_REFS=
            """
            let execution = Task<String, Error> { @MainActor in
                try await runtime.execute(prompt: prompt, mode: mode)
            }
            let watchdog = Task {
                try? await Task.sleep(nanoseconds: 15_000_000_000)
                if !Task.isCancelled {
                    execution.cancel()
                }
            }
            defer { watchdog.cancel() }

            output = try await execution.value
            runtimeState = "PASS"
            lastQuery = .now
            parseExecutiveFields(output)
        } catch is CancellationError {
            liveStore.refresh(force: true)
            refreshFromLiveStore()
            runtimeState = liveStore.bridgeAvailable ? "CONNECTED" : "ERROR"
            lastError = liveStore.bridgeAvailable
                ? nil
                : "Private runtime timed out and no live bridge state is available."
        } catch {
            liveStore.refresh(force: true)
            refreshFromLiveStore()
            runtimeState = liveStore.bridgeAvailable ? "CONNECTED" : "ERROR"
            lastError = liveStore.bridgeAvailable ? nil : error.localizedDescription
        }

        isBusy = false
    }

    @MainActor
    private func refreshFromLiveStore() {
        let bottleneck = liveStore.processes.first(where: { $0.isBottleneck })
        let humanAction = liveStore.processes
            .compactMap(\.actionNicolas)
            .first { value in
                let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                return !normalized.isEmpty
                    && normalized != "NONE"
                    && normalized != "NONE / NOT OBSERVED"
            }

        lastMaterialChange = liveStore.lastProgressLabel == "not observed"
            ? liveStore.lastRefresh.formatted(date: .omitted, time: .standard)
            : liveStore.lastProgressLabel
        topBottleneck = bottleneck?.title ?? "NONE"
        nextMachineAction = {
            if liveStore.inFlightCount > 0 {
                return "Continue \(liveStore.inFlightCount) live process(es)"
            }
            if let bottleneck {
                return "Resolve \(bottleneck.title)"
            }
            return "No machine blocker"
        }()
        nextHumanAction = humanAction ?? "NONE"

        let directBridgeLive =
            runtimeState == "CONNECTED"
            || runtimeState == "PASS"
        let effectiveBridgeLive = liveStore.bridgeAvailable || directBridgeLive
        let effectiveState = effectiveBridgeLive
            ? (liveStore.bridgeAvailable ? liveStore.momentumLabel : "CLEAR")
            : "OFFLINE"
        let effectiveMomentum = effectiveBridgeLive
            ? (
                liveStore.bridgeAvailable
                    ? liveStore.momentumDetail
                    : "Bridge transport live; process mailbox telemetry unavailable."
            )
            : "Bridge transport unavailable."

        output = """
        CURRENT_STATE=\(effectiveState)
        MOMENTUM=\(effectiveMomentum)
        LAST_MATERIAL_CHANGE=\(lastMaterialChange)
        CURRENT_MISSION=\(liveStore.processes.first(where: { $0.id.hasPrefix("0") })?.title ?? "NONE")
        TOP_BOTTLENECK=\(topBottleneck)
        NEEDS_NICOLAS=\(nextHumanAction)
        MACHINE_CAN_CONTINUE=\(nextMachineAction)
        MATERIALIZED_RESULTS=\(liveStore.materializedCount)
        IN_FLIGHT=\(liveStore.inFlightCount)
        DRIFT=\(liveStore.driftCount)
        NEXT_MACHINE_ACTION=\(nextMachineAction)
        NEXT_HUMAN_ACTION=\(nextHumanAction)
        EVIDENCE_REFS=DIRECT_BRIDGE_HEALTH+SHARED_SUPRA_PROCESS_OBSERVATORY_STORE
        """
        lastQuery = .now
        if liveStore.bridgeAvailable {
            runtimeState = "CONNECTED"
        }
    }

    private func parseExecutiveFields(_ text: String) {
        let fields = text.split(whereSeparator: { $0.isNewline }).reduce(into: [String: String]()) { result, raw in
            let line = String(raw)
            guard let index = line.firstIndex(of: "=") else { return }
            let key = String(line[..<index]).trimmingCharacters(in: .whitespacesAndNewlines)
            let value = String(line[line.index(after: index)...]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !key.isEmpty, !value.isEmpty {
                result[key] = value
            }
        }

        lastMaterialChange = fields["LAST_MATERIAL_CHANGE"] ?? lastMaterialChange
        topBottleneck = fields["TOP_BOTTLENECK"] ?? topBottleneck
        nextMachineAction = fields["NEXT_MACHINE_ACTION"] ?? nextMachineAction
        nextHumanAction = fields["NEXT_HUMAN_ACTION"] ?? nextHumanAction
    }
}
