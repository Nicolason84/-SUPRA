import SwiftUI

struct SUPRAEnvironmentCommandCenterView: View {
    @StateObject private var envModel = SUPRAEnvironmentWorldModel.shared
    @StateObject private var copilot = SUPRAOptimizationCopilot.shared
    @StateObject private var snapshotStore = SUPRAEnvironmentSnapshotStore.shared
    @StateObject private var autoMissions = SUPRAEnvironmentAutoMissions.shared
    @StateObject private var refreshCoordinator = SUPRAPassiveRefreshCoordinator.shared
    @StateObject private var protectedAccess = ProtectedFolderAccessCoordinator.shared
    @State private var showDeepScanWarning = false
    @State private var expandedSection: String? = "overview"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                    briefSection
                    Divider().background(Color.supraBorder)
                    discoveryControl
                    Divider().background(Color.supraBorder)

                    expandableSection("OVERVIEW", id: "overview") { overviewSection }
                    expandableSection("HARDWARE", id: "hardware") { hardwareSection }
                    expandableSection("SOFTWARE", id: "software") { softwareSection }
                    expandableSection("DATA", id: "data") { dataSection }
                    expandableSection("DEVELOPMENT", id: "development") { developmentSection }
                    expandableSection("OPTIMIZATION COPILOT", id: "copilot") { optimizationSection }
                    expandableSection("POTENTIAL", id: "potential") { potentialSection }

                    bottomSpacer
                }
                .padding(SUPRAOSDesignSystem.padding)
            }
        }
        .background(Color.supraBackground)
        .onAppear {
            refreshAll()
        }
        .alert("Deep Scan", isPresented: $showDeepScanWarning) {
            Button("Cancel", role: .cancel) { }
            Button("Choose Folders") { runProtectedDiscovery() }
        } message: {
            Text("Choose the folders SUPRA may scan once. Access closes immediately after the cached snapshot is created.")
        }
    }

    // MARK: - BRIEF

    private var briefSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 20))
                    .foregroundColor(.supraAccent)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("ENVIRONMENT TWIN")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.supraAccent)
                        .tracking(2)
                    Text("iMac Digital Twin")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.supraText)
                }
                .accessibilityLabel("Environment Twin — iMac Digital Twin")
                Spacer()
                if let state = envModel.state {
                    Text("\(Int(state.environmentScore * 100))%")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(healthColor(state.health))
                        .accessibilityLabel("Environmental health: \(Int(state.environmentScore * 100)) percent")
                }
                refreshButton
            }

            if let state = envModel.state {
                let brief = SUPRAEnvironmentBrief.generate(from: state, copilot: copilot)
                VStack(alignment: .leading, spacing: 8) {
                    briefRow("headline", text: brief.headline, color: .supraText)
                    briefRow("assessment", text: brief.globalAssessment, color: .supraTextSecondary)
                    if let risk = brief.primaryRisk {
                        briefRow("risk", text: risk, color: .supraOrange)
                    }
                    if let opp = brief.primaryOpportunity {
                        briefRow("action", text: opp, color: .supraAccent)
                    }
                    HStack(spacing: 8) {
                        SUPRAOSBadge(text: "Φ \(Int(brief.confidencePhi * 100))%", color: .supraAccent)
                        SUPRAOSBadge(text: "AUTO \(copilot.autoQueue.count)", color: .supraGreen)
                        SUPRAOSBadge(text: "HUMAN \(copilot.humanQueue.count)", color: .supraOrange)
                        Spacer()
                        Text(brief.lastChangeSummary)
                            .font(.system(size: 8))
                            .foregroundColor(.supraTextTertiary)
                    }
                }
                .padding(SUPRAOSDesignSystem.paddingSmall)
                .background(Color.supraSurface)
                .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius))
                .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius).stroke(healthColor(state.health).opacity(0.3), lineWidth: 1))
            }
        }
    }

    private func briefRow(_ icon: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon == "headline" ? "quote.opening" : icon == "risk" ? "exclamationmark.triangle" : icon == "action" ? "lightbulb" : "info.circle")
                .font(.system(size: 9))
                .foregroundColor(color)
                .frame(width: 14, height: 14)
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(color)
                .lineSpacing(2)
        }
    }

    // MARK: - REFRESH

    private var refreshButton: some View {
        HStack(spacing: 6) {
            Button {
                refreshCoordinator.refreshNow()
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10))
                    Text("↻ Actualiser")
                        .font(.system(size: 9, weight: .medium))
                }
                .foregroundColor(.supraAccent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.supraAccent.opacity(0.12))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(refreshCoordinator.isRefreshing)

            if let msg = refreshCoordinator.statusMessage {
                Text(msg)
                    .font(.system(size: 8))
                    .foregroundColor(.supraGreen)
                    .transition(.opacity)
            }

            lastRefreshIndicator
        }
    }

    private var lastRefreshIndicator: some View {
        HStack(spacing: 3) {
            Circle()
                .fill(refreshCoordinator.isRefreshing ? Color.supraAccent : Color.supraTextTertiary)
                .frame(width: 4, height: 4)
            Text("Dernière actualisation : \(refreshCoordinator.lastRefresh?.formatted(date: .omitted, time: .standard) ?? "—")")
                .font(.system(size: 8))
                .foregroundColor(.supraTextTertiary)
        }
    }

    // MARK: - DISCOVERY CONTROL

    private var discoveryControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: snapshotStore.isRunning ? "arrow.triangle.2.circlepath" :
                        snapshotStore.status == "paused" ? "pause.fill" :
                        snapshotStore.status == "cancelled" ? "xmark.circle" : "bolt.fill")
                    .font(.system(size: 12))
                    .foregroundColor(snapshotStore.isRunning ? .supraAccent : .supraTextSecondary)
                Text(snapshotStore.isRunning ? "Scanning: \(snapshotStore.phase)" :
                        snapshotStore.status == "paused" ? "Paused" :
                        snapshotStore.status == "cancelled" ? "Cancelled" :
                        "Discovery Control")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.supraTextSecondary)
                Spacer()
                if snapshotStore.isRunning {
                    Text("\(Int(snapshotStore.progress * 100))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.supraAccent)
                }
            }

            if snapshotStore.isRunning {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.supraBorder.opacity(0.3)).frame(height: 4)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.supraAccent)
                        .frame(width: geo.size.width * snapshotStore.progress, height: 4)
                }
                .frame(height: 4)
            }

            HStack(spacing: 6) {
                scanButton("Quick", icon: "bolt.fill", color: .supraBlue) { snapshotStore.quickRefresh() }
                scanButton("Discover", icon: "folder.badge.plus", color: .supraAccent) { runProtectedDiscovery() }
                scanButton("Deep", icon: "magnifyingglass", color: .supraPurple) { showDeepScanWarning = true }
                Spacer()
                if snapshotStore.isRunning {
                    scanButton("Pause", icon: "pause.fill", color: .supraOrange) { snapshotStore.pause() }
                } else if snapshotStore.status == "paused" {
                    scanButton("Resume", icon: "play.fill", color: .supraGreen) { snapshotStore.resume() }
                }
                scanButton("Cancel", icon: "xmark", color: .supraRed) { snapshotStore.cancel() }
            }

            if !snapshotStore.errors.isEmpty || !snapshotStore.warnings.isEmpty {
                HStack(spacing: 4) {
                    if !snapshotStore.errors.isEmpty {
                        SUPRAOSBadge(text: "\(snapshotStore.errors.count) errors", color: .supraRed)
                    }
                    if !snapshotStore.warnings.isEmpty {
                        SUPRAOSBadge(text: "\(snapshotStore.warnings.count) warnings", color: .supraOrange)
                    }
                    SUPRAOSBadge(text: "\(snapshotStore.cacheHitCount) cache hits", color: .supraTeal)
                    SUPRAOSBadge(text: "\(snapshotStore.cacheMissCount) misses", color: .supraTextTertiary)
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func scanButton(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 8))
                Text(label).font(.system(size: 8, weight: .medium))
            }
            .foregroundColor(color)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(snapshotStore.isRunning && label != "Pause" && label != "Cancel")
        .accessibilityLabel("\(label) scan")
        .accessibilityHint(label == "Quick" ? "Scans only hardware changes" : label == "Deep" ? "Full directory scan" : label == "Pause" ? "Pause current scan" : label == "Resume" ? "Resume paused scan" : "\(label) refresh")
    }

    // MARK: - EXPANDABLE SECTIONS

    private func expandableSection<Content: View>(_ title: String, id: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedSection = expandedSection == id ? nil : id
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.supraText)
                    Spacer()
                    Image(systemName: expandedSection == id ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.supraTextTertiary)
                }
                .padding(SUPRAOSDesignSystem.paddingSmall)
                .background(Color.supraSurface)
                .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
                .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)

            if expandedSection == id {
                content()
                    .padding(.top, SUPRAOSDesignSystem.spacingSmall)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - OVERVIEW

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let s = envModel.state {
                healthBanner(s)
                LazyVGrid(columns: adaptiveColumns(4), spacing: 8) {
                    SUPRAOSStatCard(label: "CPU Cores", value: "\(s.hardware?.cpuCount ?? 0)", icon: "cpu", color: .supraAccent)
                    SUPRAOSStatCard(label: "RAM", value: "\(Int(s.hardware?.physicalRAMGB ?? 0))GB", icon: "memorychip.fill", color: .supraBlue)
                    SUPRAOSStatCard(label: "Apps", value: "\(s.software?.applicationCount ?? 0)", icon: "square.grid.3x3.fill", color: .supraPurple)
                    SUPRAOSStatCard(label: "Swift Files", value: "\(s.developer?.swiftFileCount ?? 0)", icon: "swift", color: .supraOrange)
                    SUPRAOSStatCard(label: "Projects", value: "\(s.data?.projectCount ?? 0)", icon: "folder.fill", color: .supraTeal)
                    SUPRAOSStatCard(label: "Git Repos", value: "\(s.developer?.gitRepositoryCount ?? 0)", icon: "arrow.triangle.branch", color: .supraGreen)
                    SUPRAOSStatCard(label: "Duplicates", value: "\(s.data?.duplicateCount ?? 0)", icon: "doc.on.doc.fill", color: .supraOrange)
                    SUPRAOSStatCard(label: "Uncommitted", value: "\(s.developer?.uncommittedRepos ?? 0)", icon: "square.and.pencil", color: .supraRed)
                }
            } else {
                loadingState
            }
        }
    }

    private func healthBanner(_ s: CompleteEnvironmentState) -> some View {
        HStack(spacing: 8) {
            Circle().fill(healthColor(s.health)).frame(width: 8, height: 8)
            Text("\(s.health.uppercased()) · \(Int(s.environmentScore * 100))%")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(healthColor(s.health))
            Spacer()
            Text(s.timestamp, style: .time)
                .font(.system(size: 9))
                .foregroundColor(.supraTextTertiary)
        }
        .padding(8)
        .background(healthColor(s.health).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func healthColor(_ h: String) -> Color {
        switch h { case "healthy": .supraGreen case "degraded": .supraOrange default: .supraRed }
    }

    private var loadingState: some View {
        VStack(spacing: 8) {
            ProgressView().progressViewStyle(.circular).scaleEffect(0.8)
            Text("Collecting...")
                .font(.system(size: 11))
                .foregroundColor(.supraTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - HARDWARE

    private var hardwareSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let hw = envModel.state?.hardware {
                performanceGauge("CPU", value: hw.cpuUsage, detail: "\(hw.cpuCount) cores @ \(String(format: "%.1f", hw.cpuFrequencyGHz))GHz")
                performanceGauge("RAM", value: hw.ramUsedGB / max(hw.physicalRAMGB, 1), detail: "\(Int(hw.ramUsedGB))GB / \(Int(hw.physicalRAMGB))GB")
                performanceGauge("Disk", value: 1.0 - (hw.storageFreeGB / max(hw.storageTotalGB, 1)), detail: "\(Int(hw.storageFreeGB))GB free / \(Int(hw.storageTotalGB))GB")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    detailCard("GPU", hw.gpuModel, "\(hw.gpuVRAMMB)MB VRAM", .supraPurple)
                    detailCard("Thermal", hw.thermalState, hw.thermalState.capitalized, thermalColor(hw.thermalState))
                    detailCard("Battery", hw.batteryPresent ? "\(hw.batteryPercent)%" : "N/A", hw.batteryCharging ? "Charging" : "Not charging", .supraTeal)
                    detailCard("Network", hw.networkReachable ? hw.networkInterface : "Offline", hw.networkReachable ? "Connected" : "Disconnected", hw.networkReachable ? .supraGreen : .supraRed)
                }
            } else { loadingState }
        }
    }

    private func performanceGauge(_ label: String, value: Double, detail: String) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(.supraText)
                Spacer()
                Text(detail).font(.system(size: 9)).foregroundColor(.supraTextSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.supraBorder.opacity(0.3)).frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(value > 0.85 ? Color.supraRed : value > 0.7 ? Color.supraOrange : value > 0.5 ? Color.supraOrange : Color.supraGreen)
                        .frame(width: geo.size.width * value, height: 6)
                }
            }.frame(height: 6)
        }
        .padding(10)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func detailCard(_ title: String, _ value: String, _ sub: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Text(title).font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
            Text(value).font(.system(size: 12, weight: .bold)).foregroundColor(color).lineLimit(1)
            Text(sub).font(.system(size: 8)).foregroundColor(.supraTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func thermalColor(_ t: String) -> Color {
        switch t { case "nominal": .supraGreen case "fair": .supraOrange case "serious": .supraRed case "critical": .supraPurple default: .supraTextSecondary }
    }

    // MARK: - SOFTWARE

    private var softwareSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let s = envModel.state?.software {
                LazyVGrid(columns: adaptiveColumns(3), spacing: 8) {
                    SUPRAOSStatCard(label: "Applications", value: "\(s.applicationCount)", icon: "square.grid.3x3.fill", color: .supraAccent)
                    SUPRAOSStatCard(label: "Services", value: "\(s.servicesCount)", icon: "gearshape.2.fill", color: .supraBlue)
                    SUPRAOSStatCard(label: "Launch Agents", value: "\(s.launchAgentsCount)", icon: "terminal.fill", color: .supraPurple)
                    SUPRAOSStatCard(label: "Extensions", value: "\(s.extensionsCount)", icon: "puzzlepiece.fill", color: .supraOrange)
                    SUPRAOSStatCard(label: "OS", value: s.osVersion.components(separatedBy: " ").first ?? "—", icon: "display", color: .supraTeal)
                    SUPRAOSStatCard(label: "Xcode", value: s.xcodeVersion?.components(separatedBy: " ").last ?? "—", icon: "hammer.fill", color: .supraBlue)
                }
                if !s.recentApps.isEmpty {
                    Text("Recent").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 4) {
                        ForEach(s.recentApps, id: \.self) { app in
                            SUPRAOSBadge(text: app, color: .supraAccent)
                        }
                    }
                }
            } else { loadingState }
        }
    }

    // MARK: - DATA

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let d = envModel.state?.data {
                LazyVGrid(columns: adaptiveColumns(3), spacing: 8) {
                    SUPRAOSStatCard(label: "Projects", value: "\(d.projectCount)", icon: "folder.fill", color: .supraAccent)
                    SUPRAOSStatCard(label: "Documents", value: "\(d.documentCount)", icon: "doc.text.fill", color: .supraBlue)
                    SUPRAOSStatCard(label: "Archives", value: "\(d.archiveCount)", icon: "archivebox.fill", color: .supraOrange)
                    SUPRAOSStatCard(label: "Duplicates", value: "\(d.duplicateCount)", icon: "doc.on.doc.fill", color: .supraRed)
                    SUPRAOSStatCard(label: "Large Files", value: "\(d.largeFileCount)", icon: "doc.fill", color: .supraPurple)
                    SUPRAOSStatCard(label: "Active Folders", value: "\(d.activeFolderCount)", icon: "folder", color: .supraTeal)
                }
            } else { loadingState }
        }
    }

    // MARK: - DEVELOPMENT

    private var developmentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let dv = envModel.state?.developer {
                LazyVGrid(columns: adaptiveColumns(3), spacing: 8) {
                    SUPRAOSStatCard(label: "Swift Files", value: "\(dv.swiftFileCount)", icon: "swift", color: .supraOrange)
                    SUPRAOSStatCard(label: "Git Repos", value: "\(dv.gitRepositoryCount)", icon: "arrow.triangle.branch", color: .supraGreen)
                    SUPRAOSStatCard(label: "SPM Packages", value: "\(dv.swiftPackageCount)", icon: "shippingbox.fill", color: .supraPurple)
                    SUPRAOSStatCard(label: "DerivedData", value: "\(dv.derivedDataSizeMB)MB", icon: "trash.fill", color: .supraRed)
                    SUPRAOSStatCard(label: "Uncommitted", value: "\(dv.uncommittedRepos)", icon: "square.and.pencil", color: .supraOrange)
                    SUPRAOSStatCard(label: "Xcode Projects", value: "\(dv.projectCount)", icon: "hammer.fill", color: .supraBlue)
                }
                if dv.xcodeDetected, let xv = dv.xcodeVersion {
                    HStack(spacing: 6) {
                        Image(systemName: "hammer.fill").font(.system(size: 9)).foregroundColor(.supraBlue)
                        Text(xv).font(.system(size: 10)).foregroundColor(.supraTextSecondary)
                    }
                    .padding(8)
                    .background(Color.supraGlass)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            } else { loadingState }
        }
    }

    // MARK: - OPTIMIZATION COPILOT

    private var optimizationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                SUPRAOSButton(title: "Analyze", icon: "magnifyingglass", color: .supraAccent) { copilot.analyze() }
                SUPRAOSButton(title: "Sync Missions", icon: "arrow.triangle.2.circlepath", color: .supraBlue) {
                    autoMissions.sync()
                }
                Spacer()
                if !copilot.findings.isEmpty {
                    SUPRAOSBadge(text: "\(copilot.autoQueue.count) AUTO", color: .supraGreen)
                    SUPRAOSBadge(text: "\(copilot.humanQueue.count) HUMAN", color: .supraOrange)
                }
            }

            if copilot.findings.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 20)).foregroundColor(.supraGreen)
                    Text("No optimization opportunities detected")
                        .font(.system(size: 11)).foregroundColor(.supraTextSecondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 16)
            } else {
                if !copilot.autoQueue.isEmpty {
                    Text("AUTO (\(copilot.autoQueue.count))")
                        .font(.system(size: 10, weight: .semibold)).foregroundColor(.supraGreen)
                    ForEach(copilot.autoQueue) { finding in
                        findingCard(finding, color: .supraGreen)
                    }
                }
                if !copilot.humanQueue.isEmpty {
                    Text("HUMAN REVIEW (\(copilot.humanQueue.count))")
                        .font(.system(size: 10, weight: .semibold)).foregroundColor(.supraOrange)
                        .padding(.top, 4)
                    ForEach(copilot.humanQueue) { finding in
                        findingCard(finding, color: .supraOrange)
                    }
                }
            }

            if !autoMissions.missionProposals.isEmpty {
                Divider().background(Color.supraBorder)
                Text("MISSION PROPOSALS (\(autoMissions.missionProposals.count))")
                    .font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary)
                ForEach(autoMissions.missionProposals.prefix(5)) { prop in
                    HStack(spacing: 6) {
                        Image(systemName: "flag.fill").font(.system(size: 8)).foregroundColor(.supraAccent)
                        Text(prop.title).font(.system(size: 10)).foregroundColor(.supraTextSecondary)
                        Spacer()
                        SUPRAOSBadge(text: prop.verdict.authority.rawValue, color: prop.verdict.authority == .autoExecute ? .supraGreen : .supraOrange)
                    }
                    .padding(8)
                    .background(Color.supraGlass)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }

    private func findingCard(_ f: OptimizationFinding, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: f.canAutoExecute ? "bolt.shield.fill" : "person.fill.questionmark")
                    .font(.system(size: 10)).foregroundColor(color)
                Text(f.title).font(.system(size: 12, weight: .semibold)).foregroundColor(.supraText)
                Spacer()
                SUPRAOSBadge(text: f.impact, color: impactColor(f.impactScore))
            }
            Text(f.detail).font(.system(size: 10)).foregroundColor(.supraTextSecondary)
            HStack(spacing: 4) {
                Text("Φ \(Int(f.confidence * 100))%").font(.system(size: 8)).foregroundColor(.supraAccent)
                Text("·").foregroundColor(.supraBorder)
                Text(f.evidence).font(.system(size: 8)).foregroundColor(.supraTextTertiary).lineLimit(1)
            }
            HStack(spacing: 4) {
                Image(systemName: "lightbulb.fill").font(.system(size: 7)).foregroundColor(.supraAccent)
                Text(f.suggestedAction).font(.system(size: 9)).foregroundColor(.supraTextSecondary)
                Spacer()
                SUPRAOSBadge(text: f.canAutoExecute ? "AUTO" : "HUMAN", color: f.canAutoExecute ? .supraGreen : .supraOrange)
            }
        }
        .padding(10)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func impactColor(_ score: Double) -> Color {
        score > 0.7 ? .supraRed : score > 0.4 ? .supraOrange : .supraAccent
    }

    // MARK: - POTENTIAL

    private var potentialSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let state = envModel.state {
                let pot = EnvironmentPotential.compute(from: state, copilot: copilot)
                LazyVGrid(columns: adaptiveColumns(3), spacing: 8) {
                    potentialCard("Storage Recoverable", pot.storageRecoverableEstimate, icon: "trash.fill", color: .supraTeal)
                    potentialCard("CPU Opportunity", pot.cpuOptimizationOpportunity ? "Yes" : "No", icon: "cpu", color: pot.cpuOptimizationOpportunity ? .supraOrange : .supraGreen)
                    potentialCard("RAM Pressure", pot.ramPressureOpportunity ? "Yes" : "No", icon: "memorychip.fill", color: pot.ramPressureOpportunity ? .supraRed : .supraGreen)
                    potentialCard("Inactive Apps", "\(pot.inactiveApplications)", icon: "square.grid.3x3.fill", color: .supraPurple)
                    potentialCard("Duplicates", "\(pot.duplicateCandidates)", icon: "doc.on.doc.fill", color: .supraOrange)
                    potentialCard("Stale Projects", "\(pot.staleProjects)", icon: "folder.fill", color: .supraRed)
                    potentialCard("Unresolved Sources", "\(pot.unresolvedSources)", icon: "questionmark.circle.fill", color: .supraOrange)
                    potentialCard("Auto Candidates", "\(pot.automationCandidates)", icon: "bolt.fill", color: .supraGreen)
                    potentialCard("Knowledge Coverage", "\(Int(pot.environmentKnowledgeCoverage * 100))%", icon: "chart.pie.fill", color: .supraAccent)
                }
                Text("Confiance Φ \(Int(pot.confidence * 100))% · Source: \(pot.storageSource) · Limites: \(pot.limits)")
                    .font(.system(size: 8))
                    .foregroundColor(.supraTextTertiary)
            } else { loadingState }
        }
    }

    private func potentialCard(_ label: String, _ value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 14, weight: .bold)).foregroundColor(color).lineLimit(1)
            Text(label).font(.system(size: 8)).foregroundColor(.supraTextSecondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.supraBorder, lineWidth: 1))
    }

    // MARK: - HELPERS

    private func adaptiveColumns(_ n: Int) -> [GridItem] {
        [GridItem(.adaptive(minimum: CGFloat(800 / n)), spacing: 8)]
    }

    private var bottomSpacer: some View {
        Color.clear.frame(height: 20)
    }

    private func refreshAll() {
        envModel.refresh()
        copilot.analyze()
    }

    private func runProtectedDiscovery() {
        guard protectedAccess.requestDiscovery() != nil else { return }
        envModel.refresh()
        copilot.analyze()
    }
}
