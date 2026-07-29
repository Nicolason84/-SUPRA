import SwiftUI
import Combine

struct DashboardView: View {
    @ObservedObject var service: RuntimeDataService
    @State private var isLoading = true
    @State private var showContent = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                if isLoading {
                    skeletonContent
                } else {
                    loadedContent
                }
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.supraBackground)
        .onAppear {
            // Simulate progressive loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isLoading = false
                    showContent = true
                }
            }
        }
    }

    private var skeletonContent: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.supraSurfaceLight)
                    .frame(width: 180, height: 12)
                    .skeleton(isLoading: true, shape: .rounded(4))
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.supraSurfaceLight)
                    .frame(width: 280, height: 22)
                    .skeleton(isLoading: true, shape: .rounded(4))
            }

            LazyVGrid(columns: [.init(.adaptive(minimum: 160), spacing: SUPRAOSDesignSystem.spacingSmall)], spacing: SUPRAOSDesignSystem.spacingSmall) {
                ForEach(0..<6) { _ in
                    RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall)
                        .fill(Color.supraSurfaceLight)
                        .frame(height: 110)
                        .skeleton(isLoading: true, shape: .rounded(SUPRAOSDesignSystem.cornerRadiusSmall))
                }
            }
        }
    }

    private var loadedContent: some View {
        Group {
            if showContent {
                header
                    .fadeIn(delay: 0.0)
                statusGrid
                    .fadeIn(delay: 0.1)
                if let metrics = service.runtimeMetrics {
                    executionSummary(metrics)
                        .fadeIn(delay: 0.2)
                }
                if let exec = service.agentExecution {
                    agentSummary(exec)
                        .fadeIn(delay: 0.3)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("EXECUTIVE DASHBOARD")
                .font(.caption.weight(.bold)).tracking(1.6)
                .foregroundColor(.supraAccent)
            Text("SUPRA OS Runtime Overview")
                .font(.largeTitle.weight(.semibold))
                .foregroundColor(.supraText)
            HStack(spacing: 16) {
                StatusBadge(text: "Runtime: \(service.runtimeMetrics?.pipelinePerformance.totalPipelineDurationSeconds ?? 0)s", active: service.runtimeMetrics != nil)
                StatusBadge(text: "Updated: just now", active: true)
            }
        }
    }

    private var statusGrid: some View {
        LazyVGrid(columns: [.init(.adaptive(minimum: 160), spacing: SUPRAOSDesignSystem.spacingSmall)], spacing: SUPRAOSDesignSystem.spacingSmall) {
            SUPRAOSStatCard(label: "Missions", value: "\(service.agentExecution?.totalAgents ?? 0)", icon: "list.clipboard", color: .supraBlue)
            SUPRAOSStatCard(label: "Runtime State", value: service.runtimeMetrics != nil ? "Active" : "Idle", icon: "gearshape.2", color: .supraGreen)
            SUPRAOSStatCard(label: "Providers", value: "2/3", icon: "network", color: .supraTeal)
            SUPRAOSStatCard(label: "Agents", value: "\(service.agentExecution?.agents.count ?? 0)", icon: "person.2", color: .supraPurple)
            SUPRAOSStatCard(label: "Quality", value: service.runtimeMetrics != nil ? "0.82" : "—", icon: "star", color: .supraOrange)
            SUPRAOSStatCard(label: "Success Rate", value: {
                let perf = service.runtimeMetrics?.agentPerformance
                let total = perf?.totalDispatched ?? 0
                let failed = perf?.totalFailed ?? 0
                return total > 0 ? "\(Int((Double(total - failed) / Double(total)) * 100))%" : "—"
            }(), icon: "checkmark.circle", color: .supraGreen)
        }
    }

    private func executionSummary(_ metrics: RuntimeMetrics) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("Pipeline Duration", value: "\(metrics.pipelinePerformance.totalPipelineDurationSeconds)s")
                    .foregroundColor(.supraText)
                LabeledContent("Agents Dispatched", value: "\(metrics.agentPerformance.totalDispatched)")
                    .foregroundColor(.supraText)
                LabeledContent("Completed", value: "\(metrics.agentPerformance.totalCompleted)")
                    .foregroundColor(.supraText)
                LabeledContent("Failed", value: "\(metrics.agentPerformance.totalFailed)")
                    .foregroundColor(.supraText)
            }
        } label: {
            Label("Execution Summary", systemImage: "chart.bar.fill")
                .foregroundColor(.supraAccent)
        }
        .groupBoxStyle(DarkGroupBoxStyle())
    }

    private func agentSummary(_ exec: AgentExecution) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("Total Agents", value: "\(exec.totalAgents)")
                    .foregroundColor(.supraText)
                LabeledContent("Total Agents Configured", value: "\(exec.agents.count)")
                    .foregroundColor(.supraText)

                if !exec.agents.isEmpty {
                    Divider().overlay(Color.supraBorder)
                    Text("Agents").font(.caption.weight(.semibold)).foregroundColor(.supraTextSecondary)
                    ForEach(exec.agents.prefix(5)) { agent in
                        HStack {
                            Circle()
                                .fill(agent.state == "running" || agent.state == "pass" ? Color.supraGreen : Color.supraTextTertiary)
                                .frame(width: 6, height: 6)
                            Text(agent.agent)
                                .font(.caption)
                                .foregroundColor(.supraText)
                            Spacer()
                            Text(agent.state)
                                .font(.caption2)
                                .foregroundColor(.supraTextSecondary)
                        }
                    }
                }
            }
        } label: {
            Label("Agent Execution", systemImage: "person.2.fill")
                .foregroundColor(.supraPurple)
        }
        .groupBoxStyle(DarkGroupBoxStyle())
    }
}

// MARK: - Dark GroupBox Style

struct DarkGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
            configuration.label
                .font(SUPRAOSDesignSystem.Fonts.section)
            configuration.content
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall)
                .stroke(Color.supraBorder)
        )
    }
}
