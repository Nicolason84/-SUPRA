import SwiftUI

struct SUPRABusinessDemoView: View {
    @StateObject private var demo = ExecutiveDemoMode.shared
    @State private var showReport = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                headerSection
                if demo.results.isEmpty {
                    beforeSection
                } else {
                    analysisSection
                    actionsSection
                    resultsSection
                    roiSection
                }
            }
            .padding(SUPRAOSDesignSystem.padding)
        }
        .background(Color.supraBackground)
        .sheet(isPresented: $showReport) {
            reportSheet
        }
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.supraAccent)
            Text("Business Value Demo")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.supraText)
            Text("See what SUPRA can do for your organization")
                .font(.system(size: 12))
                .foregroundColor(.supraTextSecondary)

            if !demo.isRunning && demo.results.isEmpty {
                SUPRAOSButton(title: "Run Demo", icon: "play.fill", color: .supraAccent) {
                    Task { await demo.runFullDemo() }
                }
            }

            if demo.isRunning {
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                    Text("Running demo pipeline...")
                        .font(.system(size: 11))
                        .foregroundColor(.supraTextTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var beforeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            phaseHeader("Before", icon: "xmark.circle.fill", color: .supraRed)
            VStack(spacing: 8) {
                beforeRow("Manual operations", "8 hours/day")
                beforeRow("Reactive issue detection", "Delayed")
                beforeRow("No autonomy", "All decisions manual")
                beforeRow("No intelligence", "Spreadsheet analysis")
                beforeRow("No business twin", "No customer visibility")
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            phaseHeader("Analysis", icon: "magnifyingglass.circle.fill", color: .supraBlue)
            if let env = demo.results.first(where: { $0.phase == "Environment Analysis" }) {
                HStack {
                    Text(env.status)
                        .font(.system(size: 11))
                    Spacer()
                    Text("\(env.durationMs)ms")
                        .font(.system(size: 10))
                        .foregroundColor(.supraTextTertiary)
                }
            }
            let access = SUPRACanonicalWorldAccess.shared
            let m = access.getMissionState()
            let r = access.getResourceState()
            VStack(spacing: 6) {
                detailRow("System Health", access.getAllStates().globalHealth)
                detailRow("CPU Load", "\(Int(r.cpuUsage * 100))%")
                detailRow("Active Missions", "\(m.active)")
                detailRow("Blocked Missions", "\(m.blocked)")
                detailRow("Auto Queue", "\(m.autoQueue)")
                detailRow("Human Queue", "\(m.humanQueue)")
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            phaseHeader("Actions Taken", icon: "bolt.circle.fill", color: .supraGreen)
            if !demo.results.isEmpty {
                ForEach(demo.results) { result in
                    HStack(spacing: 8) {
                        Text(result.status.contains("PASS") ? "✅" : "⚠️")
                            .font(.system(size: 10))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(result.phase)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.supraText)
                            Text(result.detail)
                                .font(.system(size: 9))
                                .foregroundColor(.supraTextTertiary)
                        }
                        Spacer()
                        Text("\(result.durationMs)ms")
                            .font(.system(size: 9))
                            .foregroundColor(.supraTextTertiary)
                    }
                    .padding(8)
                    .background(Color.supraGlass)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            phaseHeader("Results", icon: "chart.bar.fill", color: .supraAccent)
            if !demo.results.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    SUPRAOSStatCard(label: "Phases Passed", value: "\(demo.passCount)/\(demo.results.count)", icon: "checkmark.circle.fill", color: .supraGreen)
                    SUPRAOSStatCard(label: "Duration", value: "\(demo.totalDurationMs)ms", icon: "clock.fill", color: .supraAccent)
                    SUPRAOSStatCard(label: "Proposals", value: "\(SUPRAMissionProposalEngine.shared.proposals.count)", icon: "doc.text.fill", color: .supraPurple)
                }
            }
            if let bp = SUPRABusinessPlatform.shared.customerTwin {
                Divider().background(Color.supraBorder)
                VStack(spacing: 6) {
                    detailRow("Environment Score", "\(Int(bp.environment.overallScore * 100))%")
                    detailRow("Autonomy Level", "\(Int(bp.decision.autonomyLevel * 100))%")
                    detailRow("Auto-Executed", "\(bp.decision.autoExecuted)")
                    detailRow("Memory Sources", "\(bp.knowledge.totalSources)")
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var roiSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            phaseHeader("Return on Investment", icon: "dollarsign.circle.fill", color: .supraGreen)
            if let w = SUPRAWorldModel.shared.world {
                let metrics = SUPRAPricingModel.valueMetrics(from: w)
                let tier = SUPRAPricingModel.recommendedTier(for: metrics)
                let report = SUPRAPricingModel.savingsReport(metrics: metrics, tier: tier)
                VStack(spacing: 6) {
                    Text(report)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.supraTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
                .background(Color.supraGlass)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                SUPRAOSButton(title: "Full Report", icon: "doc.text.fill", color: .supraAccent) {
                    showReport = true
                }
            } else {
                Text("Run demo to see ROI calculation")
                    .font(.system(size: 11))
                    .foregroundColor(.supraTextTertiary)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var reportSheet: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let w = SUPRAWorldModel.shared.world {
                        let metrics = SUPRAPricingModel.valueMetrics(from: w)
                        let tier = SUPRAPricingModel.recommendedTier(for: metrics)
                        let report = SUPRAPricingModel.savingsReport(metrics: metrics, tier: tier)

                        Text(report)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.supraText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Divider().background(Color.supraBorder)

                        Text("Recommended: \(tier.rawValue)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.supraAccent)

                        Text("$\(Int((tier.monthlyPrice as NSDecimalNumber).intValue))/month")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.supraGreen)

                        VStack(alignment: .leading, spacing: 4) {
                            featureRow(tier.includesAutoExecute, "Auto-execute missions")
                            featureRow(tier.includesBusinessIntelligence, "Business intelligence")
                            featureRow(tier.includesCustomerTwin, "Customer twin")
                            Text("Memory sources: \(tier.maxMemorySources == .max ? "Unlimited" : "\(tier.maxMemorySources)")")
                                .font(.system(size: 10))
                                .foregroundColor(.supraTextSecondary)
                            Text("Missions/day: \(tier.maxMissionsPerDay == .max ? "Unlimited" : "\(tier.maxMissionsPerDay)")")
                                .font(.system(size: 10))
                                .foregroundColor(.supraTextSecondary)
                            Text("Workers: \(tier.workerLimit == .max ? "Unlimited" : "\(tier.workerLimit)")")
                                .font(.system(size: 10))
                                .foregroundColor(.supraTextSecondary)
                        }
                    }
                }
                .padding(SUPRAOSDesignSystem.padding)
            }
            .background(Color.supraBackground)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showReport = false }
                        .foregroundColor(.supraAccent)
                }
            }
        }
    }

    private func phaseHeader(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.supraText)
        }
    }

    private func beforeRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.supraTextSecondary)
            Spacer()
            SUPRAOSBadge(text: value, color: .supraRed)
        }
        .padding(8)
        .background(Color.supraGlass)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.supraTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.supraText)
        }
    }

    private func featureRow(_ included: Bool, _ label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: included ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 10))
                .foregroundColor(included ? .supraGreen : .supraRed)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.supraTextSecondary)
        }
    }
}
