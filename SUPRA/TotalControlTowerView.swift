import SwiftUI
import Combine
import CAnnoNicoContracts

struct TotalControlTowerView: View {
    @EnvironmentObject private var state: ControlTowerState
    @StateObject private var refreshCoordinator = SUPRAPassiveRefreshCoordinator.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                if state.isLoading {
                    ProgressView("Chargement de la Tour de Contrôle…")
                        .frame(maxWidth: .infinity, minHeight: 300)
                } else {
                    globalStatusSection
                    activeProcessesSection
                    knowledgeCoreSection
                    warningsSection
                }
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
        .task { state.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("TOUR DE CONTRÔLE")
                .font(.caption.weight(.bold))
                .tracking(1.6)
                .foregroundColor(.supraAccent)
            Text("Total Control Tower")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(.supraText)
            HStack(spacing: 12) {
                healthBadge(
                    label: "Build",
                    value: healthString(state.status?.system_health?.build),
                    color: healthColor(state.status?.system_health?.build)
                )
                healthBadge(
                    label: "Runtime",
                    value: healthString(state.status?.system_health?.runtime),
                    color: healthColor(state.status?.system_health?.runtime)
                )
                healthBadge(
                    label: "Git",
                    value: healthString(state.status?.system_health?.git),
                    color: healthColor(state.status?.system_health?.git)
                )
                healthBadge(
                    label: "Agents",
                    value: healthString(state.status?.system_health?.agents),
                    color: healthColor(state.status?.system_health?.agents)
                )
                Spacer()
                controlTowerRefreshIndicator
                if let meta = state.status?.meta {
                    Text(meta.generated_at)
                        .font(.caption2)
                        .foregroundColor(.supraTextTertiary)
                }
            }
        }
    }

    private var controlTowerRefreshIndicator: some View {
        HStack(spacing: 4) {
            if let msg = refreshCoordinator.statusMessage {
                Text(msg)
                    .font(.system(size: 8))
                    .foregroundColor(.supraGreen)
                    .transition(.opacity)
            }
            Circle()
                .fill(refreshCoordinator.isRefreshing ? Color.supraAccent : Color.supraTextTertiary)
                .frame(width: 3, height: 3)
            Text("Dernière actualisation : \(refreshCoordinator.lastRefresh?.formatted(date: .omitted, time: .standard) ?? "—")")
                .font(.system(size: 8))
                .foregroundColor(.supraTextTertiary)
        }
    }

    private var globalStatusSection: some View {
        SUPRAOSCard(
            title: "GLOBAL STATUS",
            subtitle: "Build · Runtime · Git · Agents · Missions",
            icon: "gauge.with.dots.needle.33percent",
            color: .supraAccent
        ) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                if let build = state.status?.builds?.latest_build {
                    SUPRAOSStatCard(
                        label: "Build",
                        value: build.status,
                        icon: "hammer.fill",
                        color: build.status == "SUCCEEDED" ? .supraGreen : .supraRed,
                        trend: build.date
                    )
                }
                if let health = state.status?.system_health {
                    SUPRAOSStatCard(
                        label: "Runtime",
                        value: health.runtime ?? "—",
                        icon: "waveform.path.ecg",
                        color: .supraTeal
                    )
                    SUPRAOSStatCard(
                        label: "Git",
                        value: health.git ?? "—",
                        icon: "arrow.triangle.branch",
                        color: .supraOrange
                    )
                    SUPRAOSStatCard(
                        label: "Agents",
                        value: health.agents ?? "—",
                        icon: "person.2.fill",
                        color: .supraPurple
                    )
                    SUPRAOSStatCard(
                        label: "Missions",
                        value: "\(state.status?.missions?.active_missions.count ?? 0)",
                        icon: "flag.fill",
                        color: .supraGreen
                    )
                }
                if let git = state.status?.git_state {
                    SUPRAOSStatCard(
                        label: "Commits (5)",
                        value: git.last_commit?.hash ?? "—",
                        icon: "checkmark.circle",
                        color: .supraBlue,
                        trend: git.branch
                    )
                }
            }
        }
    }

    private var activeProcessesSection: some View {
        SUPRAOSCard(
            title: "ACTIVE PROCESSES",
            subtitle: "Dernières missions · Agents · Runtime",
            icon: "terminal.fill",
            color: .supraGreen
        ) {
            VStack(spacing: 12) {
                if let mission = state.status?.processes?.last_runtime_mission {
                    HStack {
                        Circle().fill(Color.supraGreen).frame(width: 8, height: 8)
                        Text(mission.id).font(.system(size: 13, weight: .medium)).foregroundColor(.supraText)
                        Spacer()
                        SUPRAOSBadge(text: mission.verdict, color: .supraGreen)
                    }
                    HStack(spacing: 16) {
                        Label("\(mission.agents_dispatched) agents", systemImage: "person.2")
                            .font(.caption).foregroundColor(.supraTextSecondary)
                        Label("\(mission.total_duration_seconds)s", systemImage: "clock")
                            .font(.caption).foregroundColor(.supraTextSecondary)
                        if mission.failed > 0 {
                            Label("\(mission.failed) failed", systemImage: "exclamationmark.triangle")
                                .font(.caption).foregroundColor(.supraRed)
                        }
                    }
                }
                if let smoke = state.status?.processes?.runtime_smoke_test {
                    Divider().background(Color.supraBorder)
                    HStack {
                        Image(systemName: smoke.crash_detected ? "exclamationmark.triangle.fill" : "checkmark.shield.fill")
                            .foregroundColor(smoke.crash_detected ? .supraRed : .supraGreen)
                        Text("Smoke Test: \(smoke.verdict)")
                            .font(.system(size: 12, weight: .medium)).foregroundColor(.supraText)
                        Spacer()
                        Text(smoke.date).font(.caption2).foregroundColor(.supraTextTertiary)
                    }
                }
                if let agents = state.status?.active_agents {
                    Divider().background(Color.supraBorder)
                    HStack(spacing: 4) {
                        ForEach(agents.agents ?? [], id: \.name) { agent in
                            SUPRAOSBadge(
                                text: agent.name,
                                color: agent.edit == true ? .supraGreen : .supraBlue
                            )
                        }
                    }
                }
            }
        }
    }

    private var knowledgeCoreSection: some View {
        SUPRAOSCard(
            title: "KNOWLEDGE CORE",
            subtitle: "CAnnoNico · Sources · Snapshots",
            icon: "brain.head.profile",
            color: .supraPurple
        ) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 12)], spacing: 12) {
                SUPRAOSStatCard(
                    label: "CAnnoNico Recovered",
                    value: "\(state.cannonicoRecoveredCount)",
                    icon: "arrow.triangle.2.circlepath",
                    color: .supraPurple
                )
                SUPRAOSStatCard(
                    label: "Sources Connectées",
                    value: "\(state.cannonicoReferences.count)",
                    icon: "link.circle.fill",
                    color: .supraBlue
                )
                if let health = state.status?.system_health {
                    SUPRAOSStatCard(
                        label: "Capacités",
                        value: "\(health.capabilities ?? 0)",
                        icon: "square.grid.2x2.fill",
                        color: .supraTeal
                    )
                    SUPRAOSStatCard(
                        label: "Fichiers Swift",
                        value: "\(health.swift_files_canonical ?? 0)",
                        icon: "swift",
                        color: .supraOrange
                    )
                    SUPRAOSStatCard(
                        label: "Projets Actifs",
                        value: "\(health.active_projects ?? 0)",
                        icon: "folder.fill",
                        color: .supraGreen
                    )
                    SUPRAOSStatCard(
                        label: "Dépôts Git",
                        value: "\(health.git_repos_total ?? 0)",
                        icon: "arrow.triangle.branch",
                        color: .supraAccent
                    )
                }
            }
            if !state.cannonicoReferences.isEmpty {
                Divider().background(Color.supraBorder).padding(.vertical, 4)
                ForEach(state.cannonicoReferences, id: \.id) { ref in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(ref.state == .recovered ? Color.supraGreen : Color.supraTextTertiary)
                            .frame(width: 6, height: 6)
                        Text(ref.role).font(.system(size: 12)).foregroundColor(.supraText)
                        Spacer()
                        SUPRAOSBadge(
                            text: ref.state == .recovered ? "recovered" : "\(ref.state)",
                            color: ref.state == .recovered ? .supraGreen : .supraTextTertiary
                        )
                    }
                }
            }
        }
    }

    private var warningsSection: some View {
        SUPRAOSCard(
            title: "WARNINGS & NEXT ACTIONS",
            subtitle: "Risques détectés et priorités",
            icon: "exclamationmark.triangle.fill",
            color: .supraOrange
        ) {
            VStack(spacing: 12) {
                if let warnings = state.status?.warnings, !warnings.isEmpty {
                    ForEach(warnings) { warning in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: warning.severity == "medium" ? "exclamationmark.triangle.fill" : "info.circle.fill")
                                .foregroundColor(warning.severity == "medium" ? .supraOrange : .supraBlue)
                                .font(.system(size: 14))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(warning.message)
                                    .font(.system(size: 12))
                                    .foregroundColor(.supraText)
                                if let action = warning.action {
                                    Text(action)
                                        .font(.system(size: 11))
                                        .foregroundColor(.supraAccent)
                                }
                            }
                            Spacer()
                            SUPRAOSBadge(text: warning.severity, color: warning.severity == "medium" ? .supraOrange : .supraBlue)
                        }
                        .padding(.vertical, 4)
                        if warning.id != warnings.last?.id {
                            Divider().background(Color.supraBorder)
                        }
                    }
                }
                if let actions = state.status?.next_actions, !actions.isEmpty {
                    Divider().background(Color.supraBorder).padding(.vertical, 4)
                    Text("PROCHAINES ACTIONS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.supraAccent)
                        .tracking(1.2)
                    ForEach(actions) { action in
                        HStack(spacing: 10) {
                            Text("#\(action.priority)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.supraAccent)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(action.action)
                                    .font(.system(size: 12))
                                    .foregroundColor(.supraText)
                                if let cmd = action.command {
                                    Text(cmd)
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.supraTextTertiary)
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
        }
    }

    private func healthBadge(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.caption2).foregroundColor(.supraTextSecondary)
            Text(value).font(.caption2.bold()).foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }

    private func healthString(_ raw: String?) -> String {
        guard let raw = raw else { return "—" }
        if raw.hasPrefix("PASS") || raw.hasPrefix("GOOD") || raw.hasPrefix("OPERATIONAL") { return "OK" }
        if raw.hasPrefix("WARNING") || raw.hasPrefix("DIRTY") { return "!" }
        return String(raw.prefix(8))
    }

    private func healthColor(_ raw: String?) -> Color {
        guard let raw = raw else { return .gray }
        if raw.hasPrefix("PASS") || raw.hasPrefix("GOOD") || raw.hasPrefix("OPERATIONAL") { return .supraGreen }
        if raw.hasPrefix("WARNING") || raw.hasPrefix("DIRTY") { return .supraOrange }
        return .supraRed
    }
}
