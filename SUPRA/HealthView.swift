import SwiftUI

struct HealthView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    var body: some View {
        SUPRAOSCard(
            title: "System Health",
            subtitle: statusSubtitle,
            icon: "heart.fill",
            color: statusColor
        ) {
            if let health = state.healthSection {
                VStack(spacing: 8) {
                    statRow("Build", value: health.build, icon: "hammer.fill")
                    statRow("Runtime", value: health.runtime, icon: "play.fill")
                    statRow("Git", value: health.git, icon: "arrow.triangle.branch")
                    statRow("Agents", value: health.agents, icon: "person.3.fill")
                    statRow("Storage", value: health.storage, icon: "externaldrive.fill")
                    Divider().background(Color.supraBorder)
                    if let res = state.resourcesSection {
                        HStack(spacing: 8) {
                            resourcePill("CPU", value: "\(Int(res.cpuUsage * 100))%", color: res.cpuUsage > 0.8 ? .supraRed : res.cpuUsage > 0.6 ? .supraOrange : .supraGreen)
                            resourcePill("RAM", value: "\(Int(res.ramFraction * 100))%", color: res.ramFraction > 0.85 ? .supraRed : res.ramFraction > 0.7 ? .supraOrange : .supraGreen)
                            resourcePill("Disk", value: diskGB, color: .supraBlue)
                        }
                    }
                    HStack {
                        statPill("\(health.activeProjects)", label: "Projects")
                        statPill("\(health.capabilities)", label: "Capabilities")
                        statPill("\(health.swiftFiles)", label: "Swift Files")
                        statPill("\(health.gitRepos)", label: "Git Repos")
                    }
                }
            } else {
                Text("Waiting for data…")
                    .font(.system(size: 12))
                    .foregroundColor(.supraTextTertiary)
            }
        }
    }

    private var statusSubtitle: String {
        state.healthSection.map { $0.overall } ?? "loading…"
    }

    private var statusColor: Color {
        guard let h = state.healthSection else { return .supraTextTertiary }
        switch h.overall.lowercased() {
        case "healthy", "ok": return .supraGreen
        case "degraded", "warning": return .supraOrange
        case "critical", "error": return .supraRed
        default: return .supraTextTertiary
        }
    }

    private func statRow(_ label: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.supraTextTertiary)
                .frame(width: 16)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.supraTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.supraText)
        }
    }

    private var diskGB: String {
        guard let res = state.resourcesSection else { return "—" }
        return String(format: "%.1f GB free", res.freeDiskGB)
    }

    private func resourcePill(_ label: String, value: String, color: Color) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.supraTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func statPill(_ value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.supraAccent)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.supraTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}
