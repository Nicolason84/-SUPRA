import SwiftUI

struct SUPRAOperationalCoreView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                systemHealthSection
                systemServicesSection
                memoryMatrixSection
                intelligenceSection
            }
            .padding(SUPRAOSDesignSystem.padding)
        }
        .background(SUPRAOSGradientBackground())
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Image(systemName: "command")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.supraAccent)
                Text("SUPRA Operational Core")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.supraText)
                Spacer()
                if state.isReady {
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
            Text("System overview — read-only")
                .font(.system(size: 13))
                .foregroundColor(.supraTextSecondary)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Section 1: SYSTEM HEALTH

    private var systemHealthSection: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
            SUPRAOSSectionHeader(title: "SYSTEM HEALTH")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 260))], spacing: SUPRAOSDesignSystem.spacingSmall) {
                HealthView()
                RuntimeView()
                MemoryView()
                MissionView()
            }
        }
    }

    // MARK: - Section 2: SYSTEM SERVICES

    private var systemServicesSection: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
            SUPRAOSSectionHeader(title: "SYSTEM SERVICES")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 260))], spacing: SUPRAOSDesignSystem.spacingSmall) {
                ProjectsCardView()
                FileSystemCardView()
            }
        }
    }

    // MARK: - Section 3: MEMORY MATRIX

    private var memoryMatrixSection: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
            SUPRAOSSectionHeader(title: "MEMORY MATRIX")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 400))], spacing: SUPRAOSDesignSystem.spacingSmall) {
                MultiMemoryView()
            }
        }
    }

    // MARK: - Section 3: INTELLIGENCE

    private var intelligenceSection: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
            SUPRAOSSectionHeader(title: "INTELLIGENCE")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 260))], spacing: SUPRAOSDesignSystem.spacingSmall) {
                IntelligenceView()
                DecisionAuthorityView()
                MissionCopilotView()
            }
        }
    }
}
