import SwiftUI

// MARK: - SUPRACard (generic container, replaces SUPRAOSCard)

struct SUPRACard<Content: View>: View {
    let title: String
    let subtitle: String?
    let icon: String
    let color: Color
    let content: Content
    let action: (() -> Void)?

    init(title: String, subtitle: String? = nil, icon: String, color: Color = .supraAccent,
         action: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.action = action
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.supraText)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.supraTextSecondary)
                    }
                }
                Spacer()
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.supraTextTertiary)
                }
            }
            content
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture { action?() }
    }
}

// MARK: - SUPRAStatCard (unified stat display, replaces SUPRAOSStatCard, MetricCard, StatCard)

enum SUPRAStatVariant {
    case large
    case compact
    case inline

    var iconSize: CGFloat {
        switch self {
        case .large: 24
        case .compact: 14
        case .inline: 10
        }
    }

    var valueSize: CGFloat {
        switch self {
        case .large: 24
        case .compact: 12
        case .inline: 11
        }
    }

    var labelSize: CGFloat {
        switch self {
        case .large: 11
        case .compact: 8
        case .inline: 9
        }
    }

    var minHeight: CGFloat? {
        switch self {
        case .large: 110
        case .compact: nil
        case .inline: nil
        }
    }
}

struct SUPRAStatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    var variant: SUPRAStatVariant = .large
    var trend: String? = nil
    var detail: String? = nil

    var body: some View {
        VStack(spacing: variant == .large ? 8 : 4) {
            Image(systemName: icon)
                .font(.system(size: variant.iconSize))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: variant.valueSize, weight: .bold))
                .foregroundColor(color)
                .lineLimit(1)
            Text(label)
                .font(.system(size: variant.labelSize))
                .foregroundColor(.supraTextSecondary)
                .multilineTextAlignment(.center)
            if let trend = trend {
                Text(trend)
                    .font(.system(size: 10))
                    .foregroundColor(.supraGreen)
            }
            if let detail = detail {
                Text(detail)
                    .font(.system(size: 8))
                    .foregroundColor(.supraTextTertiary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, minHeight: variant.minHeight)
        .padding(SUPRAOSDesignSystem.paddingTiny)
        .background(variant == .compact ? Color.supraGlass : Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: variant == .compact ? 8 : SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(variant != .compact
            ? RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1)
            : nil
        )
    }
}

// MARK: - SUPRAStatusCard (status display, replaces ContentView's SUPRAStatusCard)

struct SUPRAStatusCard: View {
    let title: String
    let status: String
    let detail: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(status)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(color)
            Text(detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(5)
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.quaternary))
    }
}

// MARK: - SUPRAActionCard (replaces ContentView's SUPRAActionCard)

struct SUPRAActionCard: View {
    let title: String
    let actions: [String]
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(.supraText)
            }
            ForEach(actions, id: \.self) { action in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(color)
                    Text(action)
                        .font(.system(size: 11))
                        .foregroundColor(.supraTextSecondary)
                        .textSelection(.enabled)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.quaternary))
    }
}

// MARK: - SUPRAMetricRow (inline metric, replaces structureMetric, statBlock, row helpers)

struct SUPRAMetricRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.supraTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(color)
        }
    }
}

// MARK: - SUPRATimelineEntry (timeline card item)

struct SUPRATimelineEntry: View {
    let date: Date
    let title: String
    let subtitle: String?
    let icon: String
    let color: Color
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .padding(.top, 4)
                if !isLast {
                    Rectangle()
                        .fill(Color.supraBorder)
                        .frame(width: 1, height: .infinity)
                        .padding(.leading, 3.5)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.supraText)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.supraTextTertiary)
                }
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 8))
                    .foregroundColor(.supraTextTertiary)
            }
            Spacer()
        }
    }
}

// MARK: - SUPRAInfoRow (key-value row)

struct SUPRAInfoRow: View {
    let label: String
    let value: String
    var valueColor: Color? = nil

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.supraTextTertiary)
            Spacer()
            Text(value)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(valueColor ?? .supraText)
        }
    }
}
