import SwiftUI

struct ExecutiveMissionControlView: View {
    @StateObject private var store = ExecutiveMissionControlStore.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                overview
                HStack(alignment: .top, spacing: SUPRAOSDesignSystem.spacingSmall) {
                    agentsPanel
                    missionPanel
                }
                HStack(alignment: .top, spacing: SUPRAOSDesignSystem.spacingSmall) {
                    alertsPanel
                    healthPanel
                }
                timelinePanel
                evidencePanel
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: SUPRAOSDesignSystem.workspaceMaxWidth)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
        .task { store.start() }
        .onDisappear { store.stop() }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("EXECUTIVE MISSION CONTROL")
                    .font(SUPRAOSDesignSystem.Fonts.label)
                    .tracking(1.8)
                    .foregroundStyle(Color.supraAccent)
                Text("Structured supervision across every engineering provider")
                    .font(SUPRAOSDesignSystem.Fonts.title)
                    .foregroundStyle(Color.supraText)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                SUPRAOSBadge(
                    text: store.runtime?.status.rawValue.uppercased() ?? "WAITING",
                    color: statusColor(store.runtime?.status ?? .waiting)
                )
                Text(store.lastReload.map { "Updated \($0.formatted(date: .omitted, time: .standard))" } ?? "Awaiting structured Runtime state")
                    .font(SUPRAOSDesignSystem.Fonts.caption)
                    .foregroundStyle(Color.supraTextTertiary)
            }
        }
    }

    private var overview: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 135), spacing: SUPRAOSDesignSystem.spacingSmall)], spacing: SUPRAOSDesignSystem.spacingSmall) {
            SUPRAOSStatCard(label: "Running Agents", value: "\(store.activeAgents.count)", icon: "person.3.fill", color: .supraGreen)
            SUPRAOSStatCard(label: "Mission Progress", value: store.missions.isEmpty ? "—" : "\(Int(store.missionProgress * 100))%", icon: "scope", color: .supraAccent)
            SUPRAOSStatCard(label: "Alerts", value: "\(store.alerts.count)", icon: "exclamationmark.triangle.fill", color: store.alerts.isEmpty ? .supraGreen : .supraRed)
            SUPRAOSStatCard(label: "Build", value: store.runtime?.buildStatus.rawValue.uppercased() ?? "—", icon: "hammer.fill", color: buildColor)
            SUPRAOSStatCard(label: "Providers", value: "\(store.runtime?.providers.count ?? 0)", icon: "network", color: .supraTeal)
            SUPRAOSStatCard(label: "Freeze", value: store.runtime?.freezeStatus.rawValue.uppercased() ?? "—", icon: "snowflake", color: freezeColor)
        }
    }

    private var agentsPanel: some View {
        missionPanel(title: "Running Agents", icon: "person.3.fill", color: .supraGreen) {
            if store.agents.isEmpty {
                empty("No agent snapshots published")
            } else {
                VStack(spacing: 10) {
                    ForEach(store.agents) { agent in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Circle().fill(statusColor(agent.status)).frame(width: 7, height: 7)
                                Text(agent.agentName).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.supraText)
                                SUPRAOSBadge(text: agent.role.uppercased(), color: .supraAccent)
                                Spacer()
                                Text(agent.status.rawValue.uppercased()).font(SUPRAOSDesignSystem.Fonts.caption).foregroundStyle(statusColor(agent.status))
                            }
                            Text(agent.currentTask).font(SUPRAOSDesignSystem.Fonts.body).foregroundStyle(Color.supraTextSecondary).lineLimit(1)
                            ProgressView(value: min(max(agent.progress, 0), 1))
                                .tint(statusColor(agent.status))
                            HStack {
                                Text(agent.currentPhase)
                                Spacer()
                                Text(agent.eta.map { "ETA \($0.formatted(date: .omitted, time: .shortened))" } ?? "ETA —")
                                Text("✓ \(agent.testsPassed)  ✕ \(agent.testsFailed)")
                            }
                            .font(SUPRAOSDesignSystem.Fonts.caption)
                            .foregroundStyle(Color.supraTextTertiary)
                        }
                        .padding(10)
                        .background(Color.supraGlass)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var missionPanel: some View {
        missionPanel(title: "Current Tasks", icon: "scope", color: .supraAccent) {
            if store.missions.isEmpty {
                empty("No mission snapshots published")
            } else {
                VStack(spacing: 10) {
                    ForEach(store.missions.prefix(6)) { mission in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(mission.title).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.supraText)
                                Spacer()
                                SUPRAOSBadge(text: mission.status.rawValue.uppercased(), color: statusColor(mission.status))
                            }
                            Text(mission.phase).font(SUPRAOSDesignSystem.Fonts.caption).foregroundStyle(Color.supraTextSecondary)
                            ProgressView(value: min(max(mission.progress, 0), 1)).tint(Color.supraAccent)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var alertsPanel: some View {
        missionPanel(title: "Alerts · Errors · Warnings", icon: "exclamationmark.triangle.fill", color: store.alerts.isEmpty ? .supraGreen : .supraRed) {
            if store.alerts.isEmpty {
                Label("No active alert", systemImage: "checkmark.circle.fill")
                    .font(SUPRAOSDesignSystem.Fonts.body)
                    .foregroundStyle(Color.supraGreen)
            } else {
                VStack(spacing: 8) {
                    ForEach(store.alerts.prefix(8)) { alert in
                        HStack(alignment: .top) {
                            Image(systemName: alert.severity == .critical ? "xmark.octagon.fill" : "exclamationmark.triangle.fill")
                                .foregroundStyle(alert.severity == .critical ? Color.supraRed : Color.supraOrange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(alert.title).foregroundStyle(Color.supraText)
                                Text(alert.detail).foregroundStyle(Color.supraTextSecondary)
                            }
                            Spacer()
                        }
                        .font(SUPRAOSDesignSystem.Fonts.body)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var healthPanel: some View {
        missionPanel(title: "Runtime · Provider · Freeze Health", icon: "waveform.path.ecg", color: .supraTeal) {
            VStack(spacing: 8) {
                healthRow("Runtime", store.runtime?.status.rawValue ?? "unavailable", statusColor(store.runtime?.status ?? .waiting))
                healthRow("Current Build", store.runtime?.currentBuild ?? "No build published", buildColor)
                healthRow("Freeze", store.runtime?.freezeStatus.rawValue ?? "unavailable", freezeColor)
                ForEach(store.runtime?.providers ?? []) { provider in
                    healthRow(provider.providerName, "\(provider.status.rawValue) · \(provider.activeAgents) agents", statusColor(provider.status))
                }
                if let error = store.loadError {
                    healthRow("Schema", error, .supraRed)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var timelinePanel: some View {
        missionPanel(title: "Mission Timeline · Recent Events", icon: "clock.fill", color: .supraBlue) {
            if store.timeline.isEmpty {
                empty("No chronological events published")
            } else {
                VStack(spacing: 9) {
                    ForEach(store.timeline.prefix(12)) { event in
                        HStack(alignment: .top, spacing: 10) {
                            Circle().fill(Color.supraBlue).frame(width: 7, height: 7).padding(.top, 4)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.title).foregroundStyle(Color.supraText)
                                if let detail = event.detail { Text(detail).foregroundStyle(Color.supraTextSecondary) }
                            }
                            Spacer()
                            Text(event.timestamp.formatted(date: .abbreviated, time: .shortened)).foregroundStyle(Color.supraTextTertiary)
                        }
                        .font(SUPRAOSDesignSystem.Fonts.body)
                    }
                }
            }
        }
    }

    private var evidencePanel: some View {
        missionPanel(title: "Evidence", icon: "doc.text.magnifyingglass", color: .supraPurple) {
            if store.evidence.isEmpty {
                empty("No structured evidence references published")
            } else {
                Text(store.evidence.prefix(12).joined(separator: "\n"))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color.supraTextSecondary)
                    .textSelection(.enabled)
            }
        }
    }

    private func missionPanel<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        SUPRAOSCard(title: title, icon: icon, color: color, content: content)
    }

    private func empty(_ value: String) -> some View {
        Text(value)
            .font(SUPRAOSDesignSystem.Fonts.body)
            .foregroundStyle(Color.supraTextTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func healthRow(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(title).foregroundStyle(Color.supraText)
            Spacer()
            Text(value).foregroundStyle(Color.supraTextSecondary).lineLimit(1)
        }
        .font(SUPRAOSDesignSystem.Fonts.body)
    }

    private func statusColor(_ status: ExecutiveAgentStatus) -> Color {
        switch status {
        case .running, .succeeded: .supraGreen
        case .waiting, .idle: .supraOrange
        case .blocked: .supraPurple
        case .failed: .supraRed
        }
    }

    private var buildColor: Color {
        switch store.runtime?.buildStatus {
        case .succeeded: .supraGreen
        case .failed: .supraRed
        case .running: .supraAccent
        default: .supraOrange
        }
    }

    private var freezeColor: Color {
        switch store.runtime?.freezeStatus {
        case .current: .supraGreen
        case .generating: .supraAccent
        case .missing, .stale: .supraOrange
        case nil: .supraTextTertiary
        }
    }
}
