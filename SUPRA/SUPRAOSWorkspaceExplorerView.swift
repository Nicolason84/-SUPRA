import Foundation
import SwiftUI

struct SUPRAOSWorkspaceExplorerView: View {
    @EnvironmentObject private var runtimeService: RuntimeDataService
    @State private var selectedModule: WorkspaceRuntimeModule?

    private enum WorkspaceRuntimeModule: String, Identifiable {
        case projects = "Projects"
        case repositories = "Git repositories"
        case storage = "Storage"
        case services = "Services"
        case xcode = "Xcode"

        var id: String { rawValue }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                runtimeGrid
                if let selectedModule {
                    detail(for: selectedModule)
                }
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
        .task {
            if needsInitialRefresh {
                runtimeService.refreshSystemMetrics()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: SUPRAOSDesignSystem.spacingSmall) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Workspace")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.supraText)

                HStack(spacing: 8) {
                    statusDot
                    Text(headerStatus)
                        .font(.system(size: 13))
                        .foregroundColor(.supraTextSecondary)
                    Text("·")
                        .foregroundColor(.supraTextTertiary)
                    Text(runtimeService.systemMetrics.timestamp.formatted(date: .abbreviated, time: .standard))
                        .font(.system(size: 12))
                        .foregroundColor(.supraTextTertiary)
                }

                if !runtimeService.systemMetrics.failedMetrics.isEmpty {
                    Text("Unavailable: \(runtimeService.systemMetrics.failedMetrics.joined(separator: ", "))")
                        .font(.system(size: 11))
                        .foregroundColor(.supraOrange)
                }
            }

            Spacer()

            Button {
                runtimeService.refreshSystemMetrics()
            } label: {
                HStack(spacing: 7) {
                    if isRefreshing {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text(isRefreshing ? "Refreshing…" : "Refresh")
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.supraAccent)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.supraSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.supraBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(isRefreshing)
        }
    }

    private var runtimeGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 260), spacing: SUPRAOSDesignSystem.spacingSmall)],
            spacing: SUPRAOSDesignSystem.spacingSmall
        ) {
            projectsCard
            repositoriesCard
            storageCard
            servicesCard
            xcodeCard
        }
    }

    private var projectsCard: some View {
        Group {
            switch runtimeService.systemMetrics.projects {
            case .loading:
                metricCard(.projects, icon: "folder.fill", color: .supraBlue, state: "Loading", detail: "Discovering projects", isLoading: true)
            case .available(let info):
                metricCard(
                    .projects,
                    icon: "folder.fill",
                    color: .supraBlue,
                    state: "\(info.discovered) discovered",
                    detail: "\(info.active) active · \(info.validated) validated · \(info.unavailable) unavailable"
                )
            case .unavailable(let reason):
                metricCard(.projects, icon: "folder.fill", color: .supraOrange, state: "Unavailable", detail: reason)
            }
        }
    }

    private var repositoriesCard: some View {
        Group {
            switch runtimeService.systemMetrics.gitRepos {
            case .loading:
                metricCard(.repositories, icon: "arrow.triangle.branch", color: .supraGreen, state: "Loading", detail: "Inspecting repositories", isLoading: true)
            case .available(let info):
                metricCard(
                    .repositories,
                    icon: "arrow.triangle.branch",
                    color: .supraGreen,
                    state: "\(info.total) repositories",
                    detail: "\(info.clean) clean · \(info.dirty) dirty · \(info.unavailable) unavailable"
                )
            case .unavailable(let reason):
                metricCard(.repositories, icon: "arrow.triangle.branch", color: .supraOrange, state: "Unavailable", detail: reason)
            }
        }
    }

    private var storageCard: some View {
        Group {
            switch runtimeService.systemMetrics.storage {
            case .loading:
                metricCard(.storage, icon: "internaldrive.fill", color: .supraTeal, state: "Loading", detail: "Measuring storage", isLoading: true)
            case .available(let info):
                metricCard(
                    .storage,
                    icon: "internaldrive.fill",
                    color: .supraTeal,
                    state: "\(byteCount(info.availableBytes)) available",
                    detail: "\(byteCount(info.usedBytes)) used of \(byteCount(info.totalBytes)) · \(byteCount(info.recoverableBytes)) recoverable"
                )
            case .unavailable(let reason):
                metricCard(.storage, icon: "internaldrive.fill", color: .supraOrange, state: "Unavailable", detail: reason)
            }
        }
    }

    private var servicesCard: some View {
        Group {
            switch runtimeService.systemMetrics.services {
            case .loading:
                metricCard(.services, icon: "gearshape.2.fill", color: .supraPurple, state: "Loading", detail: "Inspecting services", isLoading: true)
            case .available(let info):
                metricCard(
                    .services,
                    icon: "gearshape.2.fill",
                    color: .supraPurple,
                    state: "\(info.active) active",
                    detail: "\(info.total) detected · \(info.unavailable) unavailable"
                )
            case .unavailable(let reason):
                metricCard(.services, icon: "gearshape.2.fill", color: .supraOrange, state: "Unavailable", detail: reason)
            }
        }
    }

    private var xcodeCard: some View {
        Group {
            switch runtimeService.systemMetrics.xcode {
            case .loading:
                metricCard(.xcode, icon: "hammer.fill", color: .supraAccent, state: "Loading", detail: "Inspecting developer tools", isLoading: true)
            case .available(let info):
                metricCard(
                    .xcode,
                    icon: "hammer.fill",
                    color: info.installed ? .supraAccent : .supraOrange,
                    state: info.installed ? "Xcode \(info.version)" : "Not installed",
                    detail: info.installed ? "Build \(info.buildVersion) · Swift \(info.swiftVersion)" : xcodeStatus(info.status)
                )
            case .unavailable(let reason):
                metricCard(.xcode, icon: "hammer.fill", color: .supraOrange, state: "Unavailable", detail: reason)
            }
        }
    }

    private func metricCard(
        _ module: WorkspaceRuntimeModule,
        icon: String,
        color: Color,
        state: String,
        detail: String,
        isLoading: Bool = false
    ) -> some View {
        Button {
            selectedModule = module
        } label: {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(color)
                    }
                    Text(module.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.supraText)
                    Spacer()
                    if isLoading {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: selectedModule == module ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.supraTextTertiary)
                    }
                }
                Text(state)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundColor(.supraTextSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
            .padding(SUPRAOSDesignSystem.paddingSmall)
            .background(Color.supraSurface)
            .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall)
                    .stroke(selectedModule == module ? color.opacity(0.7) : Color.supraBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func detail(for module: WorkspaceRuntimeModule) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SUPRAOSSectionHeader(title: module.rawValue)
            ForEach(detailRows(for: module), id: \.0) { label, value in
                HStack(alignment: .firstTextBaseline) {
                    Text(label)
                        .foregroundColor(.supraTextSecondary)
                    Spacer()
                    Text(value)
                        .foregroundColor(.supraText)
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                }
                .font(.system(size: 12))
                Divider().background(Color.supraBorder)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func detailRows(for module: WorkspaceRuntimeModule) -> [(String, String)] {
        switch module {
        case .projects:
            switch runtimeService.systemMetrics.projects {
            case .loading: return [("Status", "Loading")]
            case .unavailable(let reason): return [("Status", "Unavailable"), ("Reason", reason)]
            case .available(let info):
                return [("Discovered", "\(info.discovered)"), ("Active", "\(info.active)"), ("Validated", "\(info.validated)"), ("Unavailable", "\(info.unavailable)")]
            }
        case .repositories:
            switch runtimeService.systemMetrics.gitRepos {
            case .loading: return [("Status", "Loading")]
            case .unavailable(let reason): return [("Status", "Unavailable"), ("Reason", reason)]
            case .available(let info):
                return [("Total", "\(info.total)"), ("Clean", "\(info.clean)"), ("Dirty", "\(info.dirty)"), ("Unavailable", "\(info.unavailable)")]
            }
        case .storage:
            switch runtimeService.systemMetrics.storage {
            case .loading: return [("Status", "Loading")]
            case .unavailable(let reason): return [("Status", "Unavailable"), ("Reason", reason)]
            case .available(let info):
                return [("Total", byteCount(info.totalBytes)), ("Used", byteCount(info.usedBytes)), ("Available", byteCount(info.availableBytes)), ("Recoverable", byteCount(info.recoverableBytes)), ("Confidence", info.recoverableConfidence.rawValue.capitalized)]
            }
        case .services:
            switch runtimeService.systemMetrics.services {
            case .loading: return [("Status", "Loading")]
            case .unavailable(let reason): return [("Status", "Unavailable"), ("Reason", reason)]
            case .available(let info):
                return [("Detected", "\(info.total)"), ("Active", "\(info.active)"), ("Unavailable", "\(info.unavailable)")]
            }
        case .xcode:
            switch runtimeService.systemMetrics.xcode {
            case .loading: return [("Status", "Loading")]
            case .unavailable(let reason): return [("Status", "Unavailable"), ("Reason", reason)]
            case .available(let info):
                return [("Status", xcodeStatus(info.status)), ("Version", info.version), ("Build", info.buildVersion), ("Swift", info.swiftVersion), ("Developer directory", info.developerDir)]
            }
        }
    }

    private var isRefreshing: Bool {
        runtimeService.systemMetrics.refreshState == .refreshing
    }

    private var needsInitialRefresh: Bool {
        if isRefreshing { return false }
        if case .loading = runtimeService.systemMetrics.projects { return true }
        if case .loading = runtimeService.systemMetrics.gitRepos { return true }
        if case .loading = runtimeService.systemMetrics.storage { return true }
        if case .loading = runtimeService.systemMetrics.services { return true }
        if case .loading = runtimeService.systemMetrics.xcode { return true }
        return false
    }

    private var headerStatus: String {
        if isRefreshing { return "Refreshing Runtime data" }
        let failures = runtimeService.systemMetrics.failedMetrics.count
        if failures > 0 { return "\(failures) metric\(failures == 1 ? "" : "s") unavailable" }
        if needsInitialRefresh { return "Waiting for Runtime data" }
        if let duration = runtimeService.systemMetrics.refreshDuration {
            return String(format: "Runtime data available · %.2fs", duration)
        }
        return "Runtime data available"
    }

    private var statusDot: some View {
        Circle()
            .fill(isRefreshing || needsInitialRefresh ? Color.supraOrange : (runtimeService.systemMetrics.failedMetrics.isEmpty ? Color.supraGreen : Color.supraOrange))
            .frame(width: 7, height: 7)
    }

    private func byteCount(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }

    private func xcodeStatus(_ status: XcodeInfo.XcodeStatus) -> String {
        switch status {
        case .available: return "Available"
        case .missing: return "Missing"
        case .commandFailure: return "Command failure"
        }
    }
}
