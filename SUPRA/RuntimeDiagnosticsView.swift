import SwiftUI

struct RuntimeDiagnosticsView: View {
    @StateObject private var manager = ContinuityManager.shared
    @EnvironmentObject private var bootManager: ExecutiveBootManager
    @StateObject private var logger = SUPRARuntimeLogger.shared
    @State private var selectedLogFilter: LogFilter = .all
    @State private var expandedArtifact: UUID?
    @State private var isLoading = true
    @State private var loadProgress = 0

    enum LogFilter: String, CaseIterable {
        case all = "ALL"
        case boot = "BOOT"
        case root = "ROOT"
        case discovery = "DISCOVERY"
        case artifact = "ARTIFACT"
        case manifest = "MANIFEST"
        case index = "INDEX"
        case validation = "VALIDATION"
        case snapshot = "SNAPSHOT"
        case dashboard = "DASHBOARD"
        case performance = "PERFORMANCE"
        case error = "ERROR"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    skeletonContent
                        .transition(.opacity)
                } else {
                    mainContent
                        .transition(.opacity.combined(with: .scale(scale: 0.99)))
                }
            }
            .background(Color.supraBackground)
            .task {
                manager.load()
                // Progressive loading
                withAnimation(.easeOut(duration: 0.2)) { loadProgress = 1 }
                try? await Task.sleep(nanoseconds: 150_000_000)
                withAnimation(.easeOut(duration: 0.2)) { loadProgress = 2 }
                try? await Task.sleep(nanoseconds: 150_000_000)
                withAnimation(.easeOut(duration: 0.3)) {
                    isLoading = false
                    loadProgress = 3
                }
            }
            .toolbar {
                Button(action: manager.load) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(manager.isLoading)
            }
        }
    }

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
            header
                .fadeIn(delay: 0.0)
            rootCauseSection
                .fadeIn(delay: 0.05)
            bootStateCard
                .fadeIn(delay: 0.1)
            runtimeStatusCard
                .fadeIn(delay: 0.15)
            pipelineSection
                .fadeIn(delay: 0.2)
            timelineSection
                .fadeIn(delay: 0.25)
            artifactTable
                .fadeIn(delay: 0.3)
            executiveDashboard
                .fadeIn(delay: 0.35)
            logsSection
                .fadeIn(delay: 0.4)
        }
        .padding(SUPRAOSDesignSystem.padding)
        .frame(maxWidth: 1280, alignment: .leading)
        .frame(maxWidth: .infinity)
    }

    private var skeletonContent: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
            // Skeleton header
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.supraSurfaceLight)
                    .frame(width: 200, height: 14)
                    .skeleton(isLoading: true, shape: .rounded(4))
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.supraSurfaceLight)
                    .frame(width: 300, height: 24)
                    .skeleton(isLoading: true, shape: .rounded(4))
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.supraSurfaceLight)
                    .frame(width: 450, height: 12)
                    .skeleton(isLoading: true, shape: .rounded(4))
            }
            .padding(.horizontal, SUPRAOSDesignSystem.padding)
            .padding(.top, SUPRAOSDesignSystem.padding)

            // Skeleton cards
            ForEach(0..<4) { _ in
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.supraSurfaceLight)
                        .frame(width: 120, height: 12)
                        .skeleton(isLoading: true, shape: .rounded(4))
                    HStack(spacing: 10) {
                        ForEach(0..<4) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.supraSurfaceLight)
                                .frame(height: 70)
                                .skeleton(isLoading: true, shape: .rounded(10))
                        }
                    }
                }
                .padding(SUPRAOSDesignSystem.paddingSmall)
                .background(Color.supraSurface)
                .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
                .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder))
                .padding(.horizontal, SUPRAOSDesignSystem.padding)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("RUNTIME DIAGNOSTICS")
                .font(.caption.weight(.bold))
                .tracking(2)
                .foregroundColor(.supraOrange)
            Text("Executive Cockpit")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.supraText)
            Text("Root cause analysis, artifact exploration, execution timeline, and health dashboard.")
                .font(.system(size: 12))
                .foregroundColor(.supraTextSecondary)
        }
    }

    private var rootCauseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("ROOT CAUSE EXPLAINER")
            RootCauseExplainerView(
                checks: RootCauseExplainerView.build(from: bootManager, continuityManager: manager)
            )
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var bootStateCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("BOOT STATE")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 10)], spacing: 10) {
                bootStat("Boot State", manager.state.bootState, "bolt.shield.fill")
                bootStat("Freeze Status", manager.state.freezeStatus, "snowflake")
                bootStat("Continuity", manager.state.continuityStatus, "arrow.triangle.branch")
                bootStat("Resume", manager.state.resumeAvailable ? "YES" : "NO", "arrow.clockwise.circle.fill")
                bootStat("Runtime", manager.state.runtimeVersion, "number")
                bootStat("Build", manager.state.buildVersion, "hammer.fill")
                bootStat("Git", manager.state.gitVersion, "chevron.left.forwardslash.chevron.right")
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func bootStat(_ label: String, _ value: String, _ icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.supraAccent)
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.supraText)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.supraTextTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .padding(SUPRAOSDesignSystem.paddingTiny)
        .background(Color.supraSurfaceLight)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var runtimeStatusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("RUNTIME STATUS")
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(manager.state.runtimeStatus == "SUCCEEDED" ? Color.supraGreen : Color.supraOrange)
                            .frame(width: 8, height: 8)
                        Text(manager.state.runtimeStatus)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.supraText)
                    }
                    Text("Runtime Status")
                        .font(.system(size: 11))
                        .foregroundColor(.supraTextSecondary)
                }
                Divider().frame(height: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(manager.state.buildStatus)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.supraText)
                    Text("Build Status")
                        .font(.system(size: 11))
                        .foregroundColor(.supraTextSecondary)
                }
                Divider().frame(height: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(manager.state.lastValidation)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.supraText)
                    Text("Artifacts")
                        .font(.system(size: 11))
                        .foregroundColor(.supraTextSecondary)
                }
                Spacer()
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var pipelineSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("PIPELINE STATUS")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 10)], spacing: 10) {
                ForEach(manager.state.pipelineSteps) { step in
                    pipelineStepCard(step)
                }
            }
            if manager.state.pipelineSteps.isEmpty {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.supraTextTertiary)
                    Text("No pipeline data — load diagnostics first")
                        .font(.system(size: 12))
                        .foregroundColor(.supraTextTertiary)
                    Spacer()
                }
                .padding(SUPRAOSDesignSystem.paddingTiny)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func pipelineStepCard(_ step: PipelineStepState) -> some View {
        let color: Color
        switch step.status {
        case .pass: color = .supraGreen
        case .warning: color = .supraOrange
        case .failure: color = .supraRed
        case .pending: color = .supraTextTertiary
        }
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: step.status.icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Text(step.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.supraText)
                Spacer()
            }
            Text(step.status.rawValue)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.15))
                .clipShape(Capsule())
            if !step.detail.isEmpty {
                Text(step.detail)
                    .font(.system(size: 10))
                    .foregroundColor(.supraTextSecondary)
                    .lineLimit(2)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingTiny)
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .background(Color.supraSurfaceLight)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.2), lineWidth: 1))
    }

    private var timelineSection: some View {
        let stages = ["BOOT", "ROOT", "DISCOVERY", "ARTIFACT", "MANIFEST", "INDEX", "VALIDATION", "SNAPSHOT", "DASHBOARD"]
        return VStack(alignment: .leading, spacing: 8) {
            sectionHeader("EXECUTION TIMELINE")
            VStack(spacing: 0) {
                ForEach(Array(stages.enumerated()), id: \.element) { index, stageName in
                    self.timelineEntry(stage: stageName, index: index, total: stages.count)
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func timelineEntry(stage: String, index: Int, total: Int) -> some View {
        let events = logger.events.filter { $0.stage.rawValue == stage }
        let lastEvent = events.last
        let status: String
        let duration: String
        let time: String
        if let event = lastEvent {
            status = event.stage == .error ? "FAILURE" : "PASS"
            duration = event.durationMs.map { "\($0)ms" } ?? "—"
            time = event.timestamp.formatted(date: .omitted, time: .standard)
        } else {
            status = "PENDING"
            duration = "—"
            time = "—"
        }
        return timelineRow(
            stage: stage,
            index: index,
            total: total,
            status: status,
            duration: duration,
            time: time
        )
    }

    private func timelineRow(stage: String, index: Int, total: Int, status: String, duration: String, time: String) -> some View {
        let statusColor: Color = status == "PASS" ? .supraGreen : status == "FAILURE" ? .supraRed : .supraTextTertiary
        return HStack(spacing: 10) {
            VStack(spacing: 0) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                if index < total - 1 {
                    Rectangle()
                        .fill(Color.supraBorder)
                        .frame(width: 1, height: 24)
                }
            }
            .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(stage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.supraText)
                HStack(spacing: 8) {
                    Text(status)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(statusColor)
                    Text("• \(duration)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.supraTextTertiary)
                    Text("• \(time)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.supraTextTertiary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }

    private var artifactTable: some View {
        let availableCount = manager.state.artifacts.filter(\.available).count
        let requiredCount = manager.state.artifacts.count
        return VStack(alignment: .leading, spacing: 8) {
            sectionHeader("ARTEFACT EXPLORER (\(availableCount) / \(requiredCount))")
            if manager.state.artifacts.isEmpty {
                HStack {
                    Image(systemName: "tray")
                        .foregroundColor(.supraTextTertiary)
                    Text("No artifact data — load diagnostics first")
                        .font(.system(size: 12))
                        .foregroundColor(.supraTextTertiary)
                    Spacer()
                }
                .padding(SUPRAOSDesignSystem.paddingTiny)
            } else {
                VStack(spacing: 0) {
                    artifactTableHeader
                    Divider().background(Color.supraBorder)
                    ForEach(manager.state.artifacts) { artifact in
                        artifactRow(artifact)
                        if artifact.id != manager.state.artifacts.last?.id {
                            Divider().background(Color.supraBorder.opacity(0.5))
                        }
                    }
                }
                .background(Color.supraSurfaceLight)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.supraBorder, lineWidth: 1))
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var artifactTableHeader: some View {
        HStack(spacing: 0) {
            Text("Artifact").font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 80, alignment: .leading)
            Text("Exists").font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 50, alignment: .center)
            Text("Readable").font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 60, alignment: .center)
            Text("Decoded").font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 60, alignment: .center)
            Text("Validated").font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 65, alignment: .center)
            Text("Available").font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 65, alignment: .center)
            Text("Hash").font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 85, alignment: .leading)
            Text("Size").font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 55, alignment: .trailing)
            Text("Date").font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 80, alignment: .leading)
            Text("Error").font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    private func artifactRow(_ artifact: ArtifactDiag) -> some View {
        let isExpanded = expandedArtifact == artifact.id
        return VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedArtifact = isExpanded ? nil : artifact.id
                }
            }) {
                HStack(spacing: 0) {
                    Text(artifact.name).font(.system(size: 11, weight: .medium)).foregroundColor(.supraText).frame(width: 80, alignment: .leading)
                    checkIcon(artifact.exists).frame(width: 50, alignment: .center)
                    checkIcon(artifact.readable).frame(width: 60, alignment: .center)
                    checkIcon(artifact.decoded).frame(width: 60, alignment: .center)
                    checkIcon(artifact.validated).frame(width: 65, alignment: .center)
                    checkIcon(artifact.available).frame(width: 65, alignment: .center)
                    Text(artifact.hash ?? "—").font(.system(size: 9, design: .monospaced)).foregroundColor(.supraTextSecondary).frame(width: 85, alignment: .leading).lineLimit(1)
                    Text(artifact.sizeBytes.map { formatBytes($0) } ?? "—").font(.system(size: 9, design: .monospaced)).foregroundColor(.supraTextSecondary).frame(width: 55, alignment: .trailing).lineLimit(1)
                    Text(artifact.modificationDate.map { $0.formatted(date: .numeric, time: .shortened) } ?? "—").font(.system(size: 9)).foregroundColor(.supraTextSecondary).frame(width: 80, alignment: .leading).lineLimit(1)
                    HStack(spacing: 4) {
                        if let reason = artifact.failureReason {
                            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 8)).foregroundColor(.supraOrange)
                            Text(reason).font(.system(size: 9)).foregroundColor(.supraOrange).lineLimit(1)
                        }
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down").font(.system(size: 7)).foregroundColor(.supraTextTertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            if isExpanded {
                artifactDetail(artifact)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func artifactDetail(_ artifact: ArtifactDiag) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            detailRow("Expected Path", artifact.expectedPath)
            detailRow("Resolved Path", artifact.resolvedPath)
            detailRow("Hash", artifact.hash ?? "—")
            detailRow("Size", artifact.sizeBytes.map { "\($0) bytes (\(formatBytes($0)))" } ?? "—")
            detailRow("Modified", artifact.modificationDate?.formatted(date: .long, time: .standard) ?? "—")
            if let reason = artifact.failureReason {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 9)).foregroundColor(.supraRed)
                    Text("Failure: \(reason)").font(.system(size: 10)).foregroundColor(.supraRed)
                }
            }
        }
        .padding(8)
        .background(Color.supraGlass)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text("\(label):").font(.system(size: 10, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 100, alignment: .trailing)
            Text(value).font(.system(size: 10, design: .monospaced)).foregroundColor(.supraTextSecondary).lineLimit(1).textSelection(.enabled)
            Spacer()
        }
    }

    private func checkIcon(_ value: Bool) -> some View {
        Image(systemName: value ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(.system(size: 10))
            .foregroundColor(value ? .supraGreen : .supraRed)
    }

    private var executiveDashboard: some View {
        let indicators = buildHealthIndicators()
        let passCount = indicators.filter { $0.status == .pass }.count
        let warningCount = indicators.filter { $0.status == .warning }.count
        let failureCount = indicators.filter { $0.status == .failure }.count
        return VStack(alignment: .leading, spacing: 8) {
            sectionHeader("EXECUTIVE DASHBOARD  PASS:\(passCount) WARNING:\(warningCount) FAILURE:\(failureCount)")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                ForEach(indicators) { indicator in
                    healthIndicator(indicator)
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func healthIndicator(_ indicator: HealthIndicator) -> some View {
        VStack(spacing: 6) {
            Image(systemName: indicator.status.icon)
                .font(.system(size: 18))
                .foregroundColor(indicator.status.color)
            Text(indicator.value)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.supraText)
                .lineLimit(1)
            Text(indicator.label)
                .font(.system(size: 8))
                .foregroundColor(.supraTextTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 65)
        .padding(6)
        .background(Color.supraSurfaceLight)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(indicator.status.color.opacity(0.2), lineWidth: 1))
    }

    private struct HealthIndicator: Identifiable {
        let id = UUID()
        let label: String
        let value: String
        let status: CheckStatus
    }

    private func buildHealthIndicators() -> [HealthIndicator] {
        [
            HealthIndicator(label: "Executive Boot", value: bootManager.bootState.rawValue, status: bootManager.isBootComplete ? .pass : .warning),
            HealthIndicator(label: "Freeze", value: bootManager.freezeValidity.rawValue, status: bootManager.freezeValidity == .valid ? .pass : bootManager.freezeValidity == .warning ? .warning : .failure),
            HealthIndicator(label: "Continuity", value: manager.state.continuityStatus, status: manager.state.continuityStatus == "AVAILABLE" ? .pass : .failure),
            HealthIndicator(label: "Runtime", value: manager.state.runtimeStatus, status: manager.state.runtimeStatus == "SUCCEEDED" ? .pass : .warning),
            HealthIndicator(label: "Artifacts", value: "\(manager.state.artifacts.filter(\.available).count)/\(manager.state.artifacts.count)", status: manager.state.artifacts.filter(\.available).count == manager.state.artifacts.count && !manager.state.artifacts.isEmpty ? .pass : .warning),
            HealthIndicator(label: "Logger", value: "\(logger.events.count) events", status: logger.isLoggingEnabled ? .pass : .warning),
            HealthIndicator(label: "Build", value: manager.state.buildStatus, status: manager.state.buildStatus == "SUCCEEDED" ? .pass : .warning),
            HealthIndicator(label: "Git", value: manager.state.gitCommit.prefix(8).description, status: manager.state.gitCommit != "—" ? .pass : .warning),
            HealthIndicator(label: "Mission", value: manager.state.currentMission != "—" ? manager.state.currentMission : "IDLE", status: manager.state.currentMission != "—" ? .pass : .warning),
        ]
    }

    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                sectionHeader("RUNTIME LOGS (\(filteredLogs.count))")
                Spacer()
                HStack(spacing: 4) {
                    ForEach(LogFilter.allCases.prefix(7), id: \.self) { filter in
                        logFilterButton(filter)
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(LogFilter.allCases.dropFirst(7), id: \.self) { filter in
                        logFilterButton(filter)
                    }
                }
            }
            if filteredLogs.isEmpty {
                HStack {
                    Image(systemName: "text.badge.xmark").foregroundColor(.supraTextTertiary)
                    Text("No log events match the current filter").font(.system(size: 12)).foregroundColor(.supraTextTertiary)
                    Spacer()
                }
                .padding(SUPRAOSDesignSystem.paddingTiny)
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredLogs) { event in
                        logEventRow(event)
                        if event.id != filteredLogs.last?.id {
                            Divider().background(Color.supraBorder.opacity(0.3))
                        }
                    }
                }
                .background(Color.supraSurfaceLight)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.supraBorder, lineWidth: 1))
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var filteredLogs: [SUPRAEvent] {
        if selectedLogFilter == .all {
            return Array(logger.events.suffix(100).reversed())
        }
        let stageMap: [LogFilter: SUPRAPipelineStage] = [
            .boot: .boot, .root: .root, .discovery: .discovery,
            .artifact: .artifact, .manifest: .manifest, .index: .index,
            .validation: .validation, .snapshot: .snapshot, .dashboard: .dashboard,
            .performance: .performance, .error: .error
        ]
        if let targetStage = stageMap[selectedLogFilter] {
            return logger.events(for: targetStage).suffix(100).reversed()
        }
        return Array(logger.events.suffix(100).reversed())
    }

    private func logFilterButton(_ filter: LogFilter) -> some View {
        Button(action: { selectedLogFilter = filter }) {
            Text(filter.rawValue)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(selectedLogFilter == filter ? .white : .supraTextSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(selectedLogFilter == filter ? Color.supraAccent : Color.supraGlass)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func logEventRow(_ event: SUPRAEvent) -> some View {
        HStack(spacing: 8) {
            Circle().fill(eventColor(event.stage)).frame(width: 6, height: 6)
            Text(event.stage.rawValue)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(eventColor(event.stage))
                .frame(width: 80, alignment: .leading)
            Text(event.message).font(.system(size: 11)).foregroundColor(.supraTextSecondary).lineLimit(1)
            Spacer()
            if let ms = event.durationMs {
                Text("\(ms)ms").font(.system(size: 9, design: .monospaced)).foregroundColor(.supraTextTertiary)
            }
            Text(event.timestamp, style: .time).font(.system(size: 9, design: .monospaced)).foregroundColor(.supraTextTertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private func eventColor(_ stage: SUPRAPipelineStage) -> Color {
        switch stage {
        case .boot: .supraAccent
        case .root: .supraGreen
        case .discovery: .supraTeal
        case .artifact: .supraPurple
        case .manifest: .supraBlue
        case .index: .supraBlue
        case .validation: .supraGreen
        case .snapshot: .supraOrange
        case .dashboard: .supraAccent
        case .performance: .supraTeal
        case .error: .supraRed
        case .decision: .supraGreen
        case .ui: .supraBlue
        case .mission: .supraAccent
        case .capability: .supraTeal
        case .provider: .supraPurple
        case .executor: .supraOrange
        case .model: .supraBlue
        case .memory: .supraTeal
        case .response: .supraGreen
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.supraTextTertiary)
            .tracking(1)
    }

    private func formatBytes(_ bytes: Int64) -> String {
        if bytes < 1024 { return "\(bytes)B" }
        if bytes < 1024 * 1024 { return String(format: "%.1fKB", Double(bytes) / 1024) }
        return String(format: "%.1fMB", Double(bytes) / (1024 * 1024))
    }
}

#Preview {
    RuntimeDiagnosticsView()
}
