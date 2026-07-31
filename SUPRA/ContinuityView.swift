import SwiftUI

struct ContinuityView: View {
    @StateObject private var manager = ContinuityManager.shared
    @EnvironmentObject private var bootManager: ExecutiveBootManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                    header
                    bootPipelineSection
                    continuityStatusSection
                    missionSection
                    buildRuntimeSection
                    gitSection
                    lastFreezeSection
                    freezeValiditySection
                    divergenceSection
                    knownIssuesSection
                    resumeSection
                }
                .padding(SUPRAOSDesignSystem.padding)
                .frame(maxWidth: 1280, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background(Color.supraBackground)
            .task { manager.load() }
            .toolbar {
                Button(action: manager.load) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(manager.isLoading)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("EXECUTIVE CONTINUITY")
                .font(.caption.weight(.bold))
                .tracking(2)
                .foregroundColor(.supraAccent)
            Text("Continuity Manager")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.supraText)
            Text("Session state persistence and resume engine.")
                .font(.system(size: 12))
                .foregroundColor(.supraTextSecondary)
        }
    }

    private var missionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("MISSIONS")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 12)], spacing: 12) {
                continuityCard(
                    title: "Current Mission",
                    value: manager.state.currentMission,
                    icon: "flag.fill",
                    color: .supraAccent
                )
                continuityCard(
                    title: "Previous Mission",
                    value: manager.state.previousMission,
                    icon: "arrow.left.circle.fill",
                    color: .supraGreen
                )
                continuityCard(
                    title: "Next Mission",
                    value: manager.state.nextMission,
                    icon: "arrow.right.circle.fill",
                    color: .supraTeal
                )
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var buildRuntimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("BUILD & RUNTIME")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 12)], spacing: 12) {
                continuityCard(
                    title: "Build Status",
                    value: manager.state.buildStatus,
                    icon: "hammer.fill",
                    color: manager.state.buildStatus == "SUCCEEDED" ? .supraGreen : .supraRed
                )
                continuityCard(
                    title: "Runtime Status",
                    value: manager.state.runtimeStatus,
                    icon: "bolt.shield.fill",
                    color: manager.state.runtimeStatus == "SUCCEEDED" ? .supraGreen : .supraOrange
                )
                continuityCard(
                    title: "Last Validation",
                    value: manager.state.lastValidation,
                    icon: "checkmark.seal.fill",
                    color: .supraBlue
                )
                continuityCard(
                    title: "Runtime Version",
                    value: manager.state.runtimeVersion,
                    icon: "number",
                    color: .supraPurple
                )
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var gitSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("GIT STATE")
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.branch")
                        .foregroundColor(.supraGreen)
                    Text("Branch:")
                        .font(.system(size: 11))
                        .foregroundColor(.supraTextSecondary)
                    Text(manager.state.gitBranch)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.supraText)
                }
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .foregroundColor(.supraBlue)
                    Text("Commit:")
                        .font(.system(size: 11))
                        .foregroundColor(.supraTextSecondary)
                    Text(manager.state.gitCommit)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.supraText)
                }
                Spacer()
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var lastFreezeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("LAST FREEZE")
            HStack(spacing: 10) {
                Image(systemName: "snowflake")
                    .foregroundColor(.supraTeal)
                    .frame(width: 24)
                Text(manager.state.lastFreeze)
                    .font(.system(size: 12))
                    .foregroundColor(.supraTextSecondary)
                Spacer()
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var knownIssuesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("KNOWN ISSUES")
            HStack(spacing: 10) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.supraGreen)
                    .frame(width: 24)
                Text(manager.state.knownIssues)
                    .font(.system(size: 12))
                    .foregroundColor(.supraTextSecondary)
                Spacer()
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var bootPipelineSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("BOOT PIPELINE")
            VStack(spacing: 6) {
                ForEach(bootManager.bootSteps) { step in
                    HStack(spacing: 10) {
                        Image(systemName: step.status.icon)
                            .font(.system(size: 12))
                            .foregroundColor(step.status.color)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.phase.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.supraText)
                            Text(step.detail)
                                .font(.system(size: 10))
                                .foregroundColor(.supraTextSecondary)
                        }
                        Spacer()
                        Text(step.status.rawValue)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(step.status.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(step.status.color.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.supraSurfaceLight)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            if bootManager.bootSteps.isEmpty {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.supraTextTertiary)
                    Text("No boot data — execute boot first")
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

    private var continuityStatusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("CONTINUITY STATUS")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 12)], spacing: 12) {
                continuityCard(
                    title: "Boot State",
                    value: manager.state.bootState,
                    icon: "bolt.shield.fill",
                    color: manager.state.bootState == "RESTORED" ? .supraGreen : .supraOrange
                )
                continuityCard(
                    title: "Freeze Status",
                    value: manager.state.freezeStatus,
                    icon: "snowflake",
                    color: manager.state.freezeStatus == "VALID" ? .supraGreen : .supraRed
                )
                continuityCard(
                    title: "Continuity",
                    value: manager.state.continuityStatus,
                    icon: "arrow.triangle.branch",
                    color: manager.state.continuityStatus == "AVAILABLE" ? .supraGreen : .supraOrange
                )
                continuityCard(
                    title: "Resume Available",
                    value: manager.state.resumeAvailable ? "YES" : "NO",
                    icon: "arrow.clockwise.circle.fill",
                    color: manager.state.resumeAvailable ? .supraGreen : .supraTextTertiary
                )
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var freezeValiditySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("FREEZE VALIDATION")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 12)], spacing: 12) {
                continuityCard(
                    title: "Frozen Commit",
                    value: bootManager.freezeMetadata.gitCommit,
                    icon: "chevron.left.forwardslash.chevron.right",
                    color: .supraBlue
                )
                continuityCard(
                    title: "Frozen Branch",
                    value: bootManager.freezeMetadata.gitBranch,
                    icon: "arrow.triangle.branch",
                    color: .supraGreen
                )
                continuityCard(
                    title: "Runtime Version",
                    value: bootManager.freezeMetadata.runtimeVersion,
                    icon: "number",
                    color: .supraPurple
                )
                continuityCard(
                    title: "Freeze Timestamp",
                    value: bootManager.freezeMetadata.timestamp,
                    icon: "calendar",
                    color: .supraTeal
                )
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var divergenceSection: some View {
        Group {
            if bootManager.divergence.hasDivergence {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("FREEZE DIVERGENCE")
                    VStack(spacing: 8) {
                        if bootManager.divergence.gitCommitDiff {
                            divergenceRow(
                                "Git Commit",
                                frozen: bootManager.divergence.frozenCommit,
                                current: bootManager.divergence.currentCommit
                            )
                        }
                        if bootManager.divergence.gitBranchDiff {
                            divergenceRow(
                                "Git Branch",
                                frozen: bootManager.divergence.frozenBranch,
                                current: bootManager.divergence.currentBranch
                            )
                        }
                        if bootManager.divergence.runtimeDiff {
                            divergenceRow(
                                "Runtime",
                                frozen: bootManager.divergence.frozenRuntime,
                                current: bootManager.divergence.currentRuntime
                            )
                        }
                        if bootManager.divergence.buildDiff {
                            divergenceRow(
                                "Build",
                                frozen: bootManager.divergence.frozenBuild,
                                current: bootManager.divergence.currentBuild
                            )
                        }
                    }
                }
                .padding(SUPRAOSDesignSystem.paddingSmall)
                .background(Color.supraSurface)
                .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
                .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraRed.opacity(0.4), lineWidth: 1))
            }
        }
    }

    private func divergenceRow(_ label: String, frozen: String, current: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 10))
                .foregroundColor(.supraRed)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.supraRed)
                HStack(spacing: 4) {
                    Text("Frozen:")
                        .font(.system(size: 9))
                        .foregroundColor(.supraTextTertiary)
                    Text(frozen)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.supraTextSecondary)
                }
                HStack(spacing: 4) {
                    Text("Current:")
                        .font(.system(size: 9))
                        .foregroundColor(.supraTextTertiary)
                    Text(current)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.supraTextSecondary)
                }
            }
            Spacer()
        }
        .padding(SUPRAOSDesignSystem.paddingTiny)
        .background(Color.supraRed.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var resumeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("SESSION RESUME")
            Button(action: { manager.resumeSession() }) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Resume Session")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Restores CONTINUITY.md + SUPRA_STATE.json + NEXT_MISSION.md + Runtime Status")
                            .font(.system(size: 11))
                            .foregroundColor(.supraTextSecondary)
                    }
                    Spacer()
                    if manager.state.resumeAvailable {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.supraGreen)
                            .font(.system(size: 12))
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(.supraTextTertiary)
                }
                .foregroundColor(.white)
                .padding(SUPRAOSDesignSystem.paddingSmall)
                .background(manager.state.resumeAvailable ? Color.supraAccent.opacity(0.15) : Color.supraTextTertiary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
                .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(manager.state.resumeAvailable ? Color.supraAccent.opacity(0.3) : Color.supraTextTertiary.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(!manager.state.resumeAvailable)
            .opacity(manager.state.resumeAvailable ? 1 : 0.6)
        }
    }

    private func continuityCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.supraTextTertiary)
                    .tracking(0.5)
                Spacer()
            }
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.supraText)
                .lineLimit(2)
        }
        .padding(SUPRAOSDesignSystem.paddingTiny)
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .background(Color.supraSurfaceLight)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.2), lineWidth: 1))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.supraTextTertiary)
            .tracking(1)
    }
}

#Preview {
    ContinuityView()
}
