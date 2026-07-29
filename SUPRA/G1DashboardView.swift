import SwiftUI

// MARK: - G1DashboardView

struct G1DashboardView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState
    @StateObject private var coordinator = DashboardCoordinator()
    @State private var isLoading = true
    @State private var showContent = false

    private let config = DashboardHeaderConfig.default
    private let layout = DashboardGridLayout.default

    var body: some View {
        VStack(alignment: .leading, spacing: layout.sectionSpacing) {
            if isLoading {
                skeletonContent
            } else {
                loadedContent
            }
        }
        .padding(SUPRAOSDesignSystem.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SUPRAOSGradientBackground())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isLoading = false
                    showContent = true
                }
            }
        }
    }

    // MARK: - Skeleton

    private var skeletonContent: some View {
        VStack(alignment: .leading, spacing: layout.sectionSpacing) {
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.supraSurfaceLight)
                    .frame(width: 180, height: 12)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.supraSurfaceLight)
                    .frame(width: 280, height: 22)
            }
            LazyVGrid(columns: layout.columns, spacing: layout.spacing) {
                ForEach(0..<6) { _ in
                    RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall)
                        .fill(Color.supraSurfaceLight)
                        .frame(height: SUPRAOSDesignSystem.cardHeight)
                }
            }
        }
    }

    // MARK: - Loaded Content

    private var loadedContent: some View {
        Group {
            if showContent {
                header
                    .transition(.opacity)
                indicatorsBar
                    .transition(.opacity)
                sectionGrid
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.supraAccent)
                Text(config.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.supraText)
                Spacer()
                if config.showLiveIndicator && coordinator.isReady {
                    HStack(spacing: 4) {
                        Circle().fill(Color.supraGreen).frame(width: 8, height: 8)
                        Text("Live")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.supraGreen)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.supraGreen.opacity(0.12))
                    .clipShape(Capsule())
                }
            }
            Text(config.subtitle)
                .font(.system(size: 13))
                .foregroundColor(.supraTextSecondary)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Indicators Bar

    private var indicatorsBar: some View {
        Group {
            if config.showStatusStrip, let runtime = coordinator.runtimeSection {
                HStack(spacing: SUPRAOSDesignSystem.spacingSmall) {
                    indicatorPill(
                        label: "Connection",
                        value: runtime.isConnected ? "Connected" : "Disconnected",
                        color: runtime.isConnected ? .supraGreen : .supraRed
                    )
                    indicatorPill(
                        label: "Agents",
                        value: "\(runtime.agentCount)",
                        color: runtime.agentCount > 0 ? .supraBlue : .supraTextTertiary
                    )
                    indicatorPill(
                        label: "Missions",
                        value: "\(runtime.activeMissions)",
                        color: runtime.activeMissions > 0 ? .supraAccent : .supraTextTertiary
                    )
                    if let resources = coordinator.resourcesSection {
                        indicatorPill(
                            label: "CPU",
                            value: "\(Int(resources.cpuUsage * 100))%",
                            color: resources.cpuUsage > 0.8 ? .supraRed : resources.cpuUsage > 0.6 ? .supraOrange : .supraGreen
                        )
                    }
                    Spacer()
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
    }

    // MARK: - Section Grid

    private var sectionGrid: some View {
        LazyVGrid(columns: layout.columns, spacing: layout.spacing) {
            ForEach(DashboardSectionOrder.defaultOrder) { section in
                sectionCard(for: section)
            }
        }
    }

    // MARK: - Section Card

    @ViewBuilder
    private func sectionCard(for section: DashboardSection) -> some View {
        switch section {
        case .systemHealth:
            HealthView()
        case .runtime:
            RuntimeView()
        case .memory:
            MemoryView()
        case .missions:
            MissionView()
        case .intelligence:
            IntelligenceView()
        case .healthAlerts:
            HealthMonitorView()
        }
    }

    // MARK: - Indicator Pill

    private func indicatorPill(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.supraText)
                Text(label)
                    .font(.system(size: 9))
                    .foregroundColor(.supraTextTertiary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
