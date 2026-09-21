import SwiftUI

enum OrganizationDepartmentDossierTab: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case live = "Live"
    case missions = "Missions"
    case people = "People / Roles"
    case decisions = "Decisions"
    case evidence = "Evidence"
    case actions = "Actions"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .overview: "rectangle.grid.2x2.fill"
        case .live: "waveform.path.ecg"
        case .missions: "scope"
        case .people: "person.3.fill"
        case .decisions: "gauge.with.dots.needle.50percent"
        case .evidence: "doc.text.magnifyingglass"
        case .actions: "bolt.fill"
        }
    }
}

struct OrganizationDepartmentDossierView: View {
    let department: OrganizationDepartment

    @Environment(\.dismiss) private var dismiss
    @State private var tab: OrganizationDepartmentDossierTab = .overview
    @State private var runtimeState = "NOT QUERIED"
    @State private var runtimeOutput = ""
    @State private var runtimeError: String?
    @State private var isBusy = false
    @State private var lastQuery: Date?

    private let runtime = SUPRAChatRuntimeAdapter()

    var body: some View {
        HStack(spacing: 0) {
            sidebar
                .frame(width: 235)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    content
                }
                .padding(28)
                .frame(maxWidth: 1050, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(minWidth: 1100, minHeight: 760)
        .background(
            LinearGradient(
                colors: [
                    department.accent.opacity(0.10),
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(department.code)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(department.accent)
                    Text(department.id)
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain)
            }

            Divider()

            ForEach(OrganizationDepartmentDossierTab.allCases) { item in
                Button {
                    tab = item
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: item.symbol)
                            .frame(width: 20)
                        Text(item.rawValue)
                        Spacer()
                    }
                    .font(.callout.weight(tab == item ? .bold : .semibold))
                    .foregroundStyle(tab == item ? department.accent : .secondary)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 9)
                    .background(
                        tab == item ? department.accent.opacity(0.10) : Color.clear,
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
                Text(runtimeState)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(runtimeTint)
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

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(department.code)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(department.accent)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(department.accent.opacity(0.12), in: Capsule())

                Text(department.alonso)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    Task { await runLiveQuery(kind: "FULL_DEPARTMENT_STATUS") }
                } label: {
                    Label(isBusy ? "Querying…" : "Refresh live state", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isBusy)
            }

            Text(department.name)
                .font(.system(size: 34, weight: .bold, design: .rounded))

            Text(department.mission)
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                fact("KPI design", department.kpi, "chart.line.uptrend.xyaxis")
                fact("Authority", "Human-gated where irreversible", "person.badge.key.fill")
                fact("Truth", runtimeOutput.isEmpty ? "Design / declared" : "Runtime queried", "checkmark.seal.fill")
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .overview:
            overview
        case .live:
            runtimePanel(
                title: "Live department state",
                subtitle: "Current operational state from the existing SUPRA runtime.",
                query: "FULL_DEPARTMENT_STATUS"
            )
        case .missions:
            runtimePanel(
                title: "Missions",
                subtitle: "Active, blocked, pending and recently completed missions for this department.",
                query: "DEPARTMENT_MISSIONS"
            )
        case .people:
            runtimePanel(
                title: "People / Roles / Digital workforce",
                subtitle: "Only evidence-backed humans, contractors, providers, seats and digital workers.",
                query: "DEPARTMENT_PEOPLE_ROLES"
            )
        case .decisions:
            runtimePanel(
                title: "Decisions / Gates",
                subtitle: "Pending decisions, authority gates, consequences of delay and reversibility.",
                query: "DEPARTMENT_DECISIONS"
            )
        case .evidence:
            runtimePanel(
                title: "Evidence / Provenance",
                subtitle: "Source paths, evidence refs, freshness, canonical status and contradictions.",
                query: "DEPARTMENT_EVIDENCE"
            )
        case .actions:
            actionDeck
        }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionCard(
                title: "Operating contract",
                symbol: "point.3.connected.trianglepath.dotted",
                lines: [
                    "Mission: \(department.mission)",
                    "Designed KPI family: \(department.kpi)",
                    "Alonso layer: \(department.alonso)",
                    "Current live staffing/capacity is not inferred until runtime evidence is queried."
                ]
            )

            HStack(alignment: .top, spacing: 14) {
                quickAction(
                    "Live state",
                    "Observe current capacity, workload, blockers and momentum.",
                    "waveform.path.ecg",
                    query: "FULL_DEPARTMENT_STATUS"
                )
                quickAction(
                    "Missions",
                    "Inspect active work and execution state.",
                    "scope",
                    query: "DEPARTMENT_MISSIONS"
                )
                quickAction(
                    "Evidence",
                    "Trace current claims to source and canon.",
                    "doc.text.magnifyingglass",
                    query: "DEPARTMENT_EVIDENCE"
                )
            }

            if !runtimeOutput.isEmpty {
                runtimeResult
            }
        }
    }

    private func runtimePanel(
        title: String,
        subtitle: String,
        query: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.bold())
                    Text(subtitle)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    Task { await runLiveQuery(kind: query) }
                } label: {
                    Label("Query runtime", systemImage: "bolt.horizontal.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isBusy)
            }

            if isBusy {
                ProgressView("SUPRA is interrogating current evidence…")
                    .controlSize(.large)
                    .padding(.vertical, 30)
            } else if let runtimeError {
                ContentUnavailableView(
                    "Runtime query failed",
                    systemImage: "exclamationmark.triangle.fill",
                    description: Text(runtimeError)
                )
            } else if runtimeOutput.isEmpty {
                ContentUnavailableView(
                    "No live query yet",
                    systemImage: "waveform.path.ecg",
                    description: Text("Run a read-only query to deepen this department.")
                )
            } else {
                runtimeResult
            }
        }
    }

    private var runtimeResult: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("LIVE RUNTIME RESULT", systemImage: "checkmark.circle.fill")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.green)
                Spacer()
                if let lastQuery {
                    Text(lastQuery.formatted(date: .abbreviated, time: .standard))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            Text(runtimeOutput)
                .font(.callout.monospaced())
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.22))
        )
    }

    private var actionDeck: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Action deck")
                .font(.title2.bold())

            Text("Actions below produce bounded plans or read-only investigations through the existing runtime. No irreversible action is executed silently.")
                .foregroundStyle(.secondary)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 260), spacing: 14)],
                spacing: 14
            ) {
                actionCard(
                    "Find top bottleneck",
                    "Identify the single highest-impact current blocker and its evidence.",
                    "exclamationmark.octagon.fill",
                    query: "TOP_BOTTLENECK"
                )
                actionCard(
                    "Capacity diagnosis",
                    "Determine whether the issue is process, automation, staffing, authority or dependency.",
                    "person.3.sequence.fill",
                    query: "CAPACITY_DIAGNOSIS"
                )
                actionCard(
                    "Prepare next mission",
                    "Produce a bounded next mission with owner, evidence, gate and acceptance criteria.",
                    "scope",
                    query: "PREPARE_NEXT_MISSION"
                )
                actionCard(
                    "Prepare decision",
                    "Prepare a decision packet only if a real human decision is necessary.",
                    "gauge.with.dots.needle.50percent",
                    query: "PREPARE_DECISION"
                )
                actionCard(
                    "Procurement / investment need",
                    "Check whether a purchase or investment is actually justified by a proven bottleneck.",
                    "cart.badge.questionmark",
                    query: "PROCUREMENT_INVESTMENT_CHECK"
                )
                actionCard(
                    "Hiring gate",
                    "Test simplify → automate → reuse → provider → hire before proposing headcount.",
                    "person.crop.circle.badge.questionmark",
                    query: "HIRING_GATE"
                )
            }

            if !runtimeOutput.isEmpty {
                runtimeResult
            }
        }
    }

    private func quickAction(
        _ title: String,
        _ subtitle: String,
        _ symbol: String,
        query: String
    ) -> some View {
        Button {
            Task { await runLiveQuery(kind: query) }
        } label: {
            VStack(alignment: .leading, spacing: 9) {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundStyle(department.accent)
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 145, alignment: .topLeading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(isBusy)
    }

    private func actionCard(
        _ title: String,
        _ subtitle: String,
        _ symbol: String,
        query: String
    ) -> some View {
        Button {
            Task { await runPlanQuery(kind: query) }
        } label: {
            VStack(alignment: .leading, spacing: 9) {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundStyle(department.accent)
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                Spacer()
                Label("Prepare", systemImage: "arrow.right.circle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(department.accent)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 175, alignment: .topLeading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(isBusy)
    }

    private func sectionCard(
        title: String,
        symbol: String,
        lines: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: symbol)
                .font(.headline)
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func fact(
        _ title: String,
        _ value: String,
        _ symbol: String
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(department.accent)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.caption.weight(.semibold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }

    private var runtimeTint: Color {
        switch runtimeState {
        case "CONNECTED", "PASS": return .green
        case "RUNNING": return .orange
        case "ERROR": return .red
        default: return .secondary
        }
    }

    @MainActor
    private func runLiveQuery(kind: String) async {
        await run(kind: kind, mode: .ask)
    }

    @MainActor
    private func runPlanQuery(kind: String) async {
        await run(kind: kind, mode: .plan)
    }

    @MainActor
    private func run(kind: String, mode: ChatMode) async {
        guard !isBusy else { return }

        isBusy = true
        runtimeState = "RUNNING"
        runtimeError = nil

        do {
            try await runtime.checkHealth()
            runtimeState = "CONNECTED"

            let prompt = """
            ORGANIZATION_DEPARTMENT_DOSSIER
            AUTHORITY=NICOLAS
            DEPARTMENT_ID=\(department.id)
            DEPARTMENT_CODE=\(department.code)
            DEPARTMENT_NAME=\(department.name)
            QUERY=\(kind)
            READ_ONLY=YES
            MEMORY_FIRST=YES
            PROOF_FIRST=YES
            NO_NEW_ENGINE=YES
            NO_NEW_BRIDGE=YES
            NO_NEW_RUNTIME=YES
            NO_DESTRUCTIVE_ACTION=YES

            Use current evidence and existing registries first.
            Never invent humans, employees, roles, capacity, missions, money, authority or KPI values.

            Return:
            CURRENT_STATE=
            MOMENTUM=
            LAST_MATERIAL_CHANGE=
            ACTIVE_MISSIONS=
            PEOPLE_ROLES=
            DIGITAL_WORKERS=
            CAPACITY=
            TOP_BOTTLENECK=
            DECISIONS_GATES=
            KPI_EVIDENCE=
            DEPENDENCIES=
            EVIDENCE_REFS=
            FRESHNESS=
            NEXT_MACHINE_ACTION=
            NEXT_HUMAN_ACTION=
            """
            runtimeOutput = try await runtime.execute(prompt: prompt, mode: mode)
            runtimeState = "PASS"
            lastQuery = .now
        } catch {
            runtimeState = "ERROR"
            runtimeError = error.localizedDescription
        }

        isBusy = false
    }
}
