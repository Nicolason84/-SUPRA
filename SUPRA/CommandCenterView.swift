import SwiftUI

struct CommandCenterView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 260))], spacing: SUPRAOSDesignSystem.spacingSmall) {
                    G1DashboardView()
                    HealthView()
                    RuntimeView()
                    MemoryView()
                    MissionView()
                    MultiMemoryView()
                    IntelligenceView()
                    G4IntegrationView()
                }
            }
            .padding(SUPRAOSDesignSystem.padding)
        }
        .background(SUPRAOSGradientBackground())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Image(systemName: "command")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.supraAccent)
                Text("SUPRA Command Center")
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
            Text("Operational dashboard — read-only")
                .font(.system(size: 13))
                .foregroundColor(.supraTextSecondary)
        }
        .padding(.bottom, 8)
    }
}
