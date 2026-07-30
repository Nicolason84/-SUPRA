import SwiftUI

struct SUPRAMemoryLensView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                SUPRAOSSectionHeader(title: "Memory Lens")

                overviewGrid
                knownSection
                unknownSection
                needVerificationSection
                historicalPatterns
            }
            .padding(SUPRAOSDesignSystem.padding)
        }
        .background(Color.supraBackground)
    }

    private var overviewGrid: some View {
        let access = SUPRACanonicalWorldAccess.shared
        let m = access.getMemoryState()
        let p = access.getProjectState()
        let e = access.getEnvironmentState()
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            SUPRAOSStatCard(label: "Sources", value: "\(m.sourceCount)", icon: "square.stack.3d.up.fill", color: .supraAccent)
            SUPRAOSStatCard(label: "Recovered", value: "\(m.recoveredCount)", icon: "arrow.triangle.2.circlepath", color: .supraGreen)
            SUPRAOSStatCard(label: "Projects", value: "\(p.totalProjects)", icon: "folder.fill", color: .supraBlue)
            SUPRAOSStatCard(label: "Directories", value: "\(e.activeDirectories)", icon: "folder", color: .supraTeal)
        }
    }

    private var knownSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Known", icon: "checkmark.circle.fill", color: .supraGreen)
            let access = SUPRACanonicalWorldAccess.shared
            let m = access.getMemoryState()
            if !m.references.isEmpty {
                ForEach(m.references.filter { $0.state == "recovered" }.prefix(6)) { ref in
                    HStack(spacing: 6) {
                        Circle().fill(Color.supraGreen).frame(width: 6, height: 6)
                        Text(ref.role)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.supraText)
                        Spacer()
                        Text(ref.state)
                            .font(.system(size: 9))
                            .foregroundColor(.supraGreen)
                    }
                    .padding(10)
                    .background(Color.supraGlass)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                Text("No known sources")
                    .font(.system(size: 11))
                    .foregroundColor(.supraTextTertiary)
                    .padding(10)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var unknownSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Unknown", icon: "questionmark.circle.fill", color: .supraOrange)
            let access = SUPRACanonicalWorldAccess.shared
            let m = access.getMemoryState()
            let unrecovered = m.references.filter { $0.state != "recovered" }
            if !unrecovered.isEmpty {
                ForEach(unrecovered.prefix(6)) { ref in
                    HStack(spacing: 6) {
                        Circle().fill(Color.supraOrange).frame(width: 6, height: 6)
                        Text(ref.role)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.supraText)
                        Spacer()
                        SUPRAOSBadge(text: ref.state, color: .supraOrange)
                    }
                    .padding(10)
                    .background(Color.supraGlass)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                Text("No unknown sources")
                    .font(.system(size: 11))
                    .foregroundColor(.supraTextTertiary)
                    .padding(10)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var needVerificationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Need Verification", icon: "exclamationmark.triangle.fill", color: .supraOrange)
            let observations = SUPRAMissionObserver.shared.observations
            let pending = observations.filter { $0.confidence < 0.85 }.prefix(6)
            if !pending.isEmpty {
                ForEach(pending) { obs in
                    HStack(spacing: 6) {
                        Circle().fill(Color.supraOrange).frame(width: 6, height: 6)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(obs.title)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.supraText)
                            Text("Φ \(Int(obs.confidence * 100))% · \(obs.source)")
                                .font(.system(size: 9))
                                .foregroundColor(.supraTextTertiary)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.supraGlass)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                Text("All observations verified")
                    .font(.system(size: 11))
                    .foregroundColor(.supraGreen)
                    .padding(10)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var historicalPatterns: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Historical Patterns", icon: "chart.xyaxis.line", color: .supraPurple)
            let eng = SUPRAIntelligenceEngine.shared.state
            if !eng.insights.isEmpty {
                ForEach(eng.insights.prefix(8)) { insight in
                    HStack(spacing: 6) {
                        Image(systemName: insightIcon(insight))
                            .font(.system(size: 10))
                            .foregroundColor(insightColor(insight))
                        Text(insight.message)
                            .font(.system(size: 10))
                            .foregroundColor(.supraTextSecondary)
                        Spacer()
                        SUPRAOSBadge(text: insight.severity.rawValue, color: insightColor(insight))
                    }
                    .padding(10)
                    .background(Color.supraGlass)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                Text("No historical data")
                    .font(.system(size: 11))
                    .foregroundColor(.supraTextTertiary)
                    .padding(10)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func sectionHeader(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.supraText)
        }
    }

    private func insightIcon(_ i: SUPRAInsight) -> String {
        switch i.category { case .health: "heart.fill" case .anomaly: "exclamationmark.triangle" case .recommendation: "lightbulb.fill" case .priority: "flag.fill" }
    }

    private func insightColor(_ i: SUPRAInsight) -> Color {
        switch i.severity { case .info: .supraBlue case .warning: .supraOrange case .critical: .supraRed }
    }
}
