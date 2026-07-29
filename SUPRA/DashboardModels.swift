import SwiftUI

// MARK: - DashboardSection

enum DashboardSection: String, CaseIterable, Identifiable {
    case systemHealth
    case runtime
    case memory
    case missions
    case intelligence
    case healthAlerts

    var id: String { rawValue }

    var title: String {
        switch self {
        case .systemHealth:  return "System Health"
        case .runtime:       return "Runtime"
        case .memory:        return "CAnnoNico Memory"
        case .missions:      return "Missions"
        case .intelligence:  return "Intelligence"
        case .healthAlerts:  return "Health Alerts"
        }
    }

    var icon: String {
        switch self {
        case .systemHealth:  return "heart.fill"
        case .runtime:       return "cpu"
        case .memory:        return "memorychip.fill"
        case .missions:      return "flag.fill"
        case .intelligence:  return "brain.head.profile"
        case .healthAlerts:  return "bell.fill"
        }
    }

    var color: Color {
        switch self {
        case .systemHealth:  return .supraGreen
        case .runtime:       return .supraBlue
        case .memory:        return .supraPurple
        case .missions:      return .supraAccent
        case .intelligence:  return .supraOrange
        case .healthAlerts:  return .supraRed
        }
    }

    var sortOrder: Int {
        switch self {
        case .systemHealth:  return 0
        case .runtime:       return 1
        case .memory:        return 2
        case .missions:      return 3
        case .intelligence:  return 4
        case .healthAlerts:  return 5
        }
    }
}

// MARK: - DashboardGridLayout

struct DashboardGridLayout {
    let columns: [GridItem]
    let spacing: CGFloat
    let sectionSpacing: CGFloat

    static let `default` = DashboardGridLayout(
        columns: [GridItem(.adaptive(minimum: 260), spacing: SUPRAOSDesignSystem.spacingSmall)],
        spacing: SUPRAOSDesignSystem.spacingSmall,
        sectionSpacing: SUPRAOSDesignSystem.spacing
    )
}

// MARK: - DashboardSectionOrder

enum DashboardSectionOrder {
    static let defaultOrder: [DashboardSection] = DashboardSection.allCases.sorted {
        $0.sortOrder < $1.sortOrder
    }
}

// MARK: - DashboardHeaderConfig

struct DashboardHeaderConfig {
    let title: String
    let subtitle: String
    let showLiveIndicator: Bool
    let showStatusStrip: Bool

    static let `default` = DashboardHeaderConfig(
        title: "SUPRA Dashboard",
        subtitle: "Unified project overview",
        showLiveIndicator: true,
        showStatusStrip: true
    )
}
