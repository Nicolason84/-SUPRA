import SwiftUI

// MARK: - Design System v2.0 — Unified Language

enum SUPRAOSDesignSystem {
    // MARK: Corner Radii — Exactly 4 values
    /// Tiny: 6pt — Badges, small indicators
    static let cornerRadiusTiny: CGFloat = 6
    /// Small: 10pt — Cards, panels, small containers
    static let cornerRadiusSmall: CGFloat = 10
    /// Default: 16pt — Large containers, command palette
    static let cornerRadius: CGFloat = 16
    /// Large: 20pt — Hero sections, prominent containers
    static let cornerRadiusLarge: CGFloat = 20

    // MARK: Spacing — Consistent vertical/horizontal rhythm
    static let spacingMini: CGFloat = 4
    static let spacingTiny: CGFloat = 8
    static let spacingSmall: CGFloat = 12
    static let spacing: CGFloat = 20
    static let spacingLarge: CGFloat = 24

    // MARK: Padding — Consistent inner spacing
    static let paddingMini: CGFloat = 6
    static let paddingTiny: CGFloat = 10
    static let paddingSmall: CGFloat = 16
    static let padding: CGFloat = 24
    static let paddingLarge: CGFloat = 28

    // MARK: Layout Constants
    static let sidebarWidth: CGFloat = 240
    static let sidebarCompactWidth: CGFloat = 56
    static let cardHeight: CGFloat = 200
    static let iconSize: CGFloat = 24
    static let iconSizeLarge: CGFloat = 36
    static let inspectorWidth: CGFloat = 260
    static let headerHeight: CGFloat = 52
    static let statusBarHeight: CGFloat = 28
    static let navigationRowHeight: CGFloat = 34
    static let compactPanelHeight: CGFloat = 132
    static let workspaceMaxWidth: CGFloat = 1280
    static let commandPaletteWidth: CGFloat = 480
    static let notificationWidth: CGFloat = 320
    static let minimumWindowWidth: CGFloat = 1100
    static let minimumWindowHeight: CGFloat = 680

    // MARK: Icon Sizing — Consistent hierarchy
    enum IconSize {
        static let sidebar: CGFloat = 14
        static let cardHeader: CGFloat = 16
        static let sectionHeader: CGFloat = 20
        static let hero: CGFloat = 28
        static let pageHeader: CGFloat = 34
    }

    // MARK: Elevation / Shadow System — 4 tiers
    enum Shadow {
        case tiny
        case small
        case medium
        case large

        var blur: CGFloat {
            switch self {
            case .tiny: return 2
            case .small: return 4
            case .medium: return 12
            case .large: return 28
            }
        }

        var offset: CGSize {
            switch self {
            case .tiny: return CGSize(width: 0, height: 1)
            case .small: return CGSize(width: 0, height: 2)
            case .medium: return CGSize(width: 0, height: 4)
            case .large: return CGSize(width: 0, height: 8)
            }
        }

        var color: Color {
            switch self {
            case .tiny: return .black.opacity(0.08)
            case .small: return .black.opacity(0.12)
            case .medium: return .black.opacity(0.18)
            case .large: return .black.opacity(0.30)
            }
        }
    }

    @ViewBuilder
    /// Apply a shadow from the design system to any view
    static func nsShadow(_ shadow: Shadow) -> NSShadow {
        let ns = NSShadow()
        ns.shadowColor = NSColor(shadow.color)
        ns.shadowBlurRadius = shadow.blur
        ns.shadowOffset = shadow.offset
        return ns
    }

    // MARK: Motion Vocabulary — Every animation has meaning
    enum Motion {
        /// "New content is appearing" — 0.4s easeOut
        static let reveal: SwiftUI.Animation = .easeOut(duration: 0.4)
        /// "Your attention is needed here" — 0.3s spring
        static let focus: SwiftUI.Animation = .spring(response: 0.3, dampingFraction: 0.75)
        /// "You have moved to a new context" — 0.35s spring
        static let transition: SwiftUI.Animation = .spring(response: 0.35, dampingFraction: 0.85)
        /// "Your action was received" — 0.15s easeOut
        static let feedback: SwiftUI.Animation = .easeOut(duration: 0.15)
        /// "Something is happening" — 1.0s linear repeat
        static let progress: SwiftUI.Animation = .linear(duration: 1.0).repeatForever(autoreverses: true)
        /// "Look here" — 0.5s spring repeat
        static let attention: SwiftUI.Animation = .spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true)
        /// "Something completed" — 0.6s spring
        static let celebration: SwiftUI.Animation = .spring(response: 0.6, dampingFraction: 0.7)
    }

    // MARK: Legacy Animation Tokens (now map to Motion)
    enum Animation {
        /// Hover, micro-interactions
        static let fast: Double = 0.15
        /// General transitions
        static let defaultDuration: Double = 0.25
        /// Major transitions
        static let slow: Double = 0.4
        /// Natural movement
        static let spring: SwiftUI.Animation = .spring(response: 0.35, dampingFraction: 0.85)
        /// Smooth reveal
        static let smooth: SwiftUI.Animation = .easeOut(duration: 0.3)
        /// Quick feedback
        static let quick: SwiftUI.Animation = .easeOut(duration: 0.15)
        /// Balanced transition
        static let transition: SwiftUI.Animation = .easeInOut(duration: 0.25)
    }

    // MARK: Typography — One unified scale
    enum Fonts {
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
        static let title = Font.system(size: 26, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let metric = Font.system(size: 24, weight: .bold, design: .rounded)
        static let section = Font.system(size: 14, weight: .semibold)
        static let body = Font.system(size: 13)
        static let bodySmall = Font.system(size: 12)
        static let label = Font.system(size: 11, weight: .bold)
        static let caption = Font.system(size: 10)
        static let monospace = Font.system(size: 12, design: .monospaced)
        static let monospaceSmall = Font.system(size: 10, design: .monospaced)
        static let badge = Font.system(size: 9, weight: .bold, design: .rounded)

        /// Dynamic type variants for accessibility
        static let largeTitleAccessible = Font.system(size: 32, weight: .bold, design: .rounded)
        static let titleAccessible = Font.system(size: 26, weight: .bold, design: .rounded)
        static let bodyAccessible = Font.system(size: 13)
    }

    // MARK: Dividers
    @ViewBuilder
    static func divider() -> some View {
        Divider().overlay(Color.supraBorder)
    }
}

// MARK: - Color Palette — One semantic color system

extension Color {
    // MARK: Backgrounds
    static let supraBackground = Color(red: 0.06, green: 0.06, blue: 0.08)
    static let supraSurface = Color(red: 0.1, green: 0.1, blue: 0.13)
    static let supraSurfaceLight = Color(red: 0.15, green: 0.15, blue: 0.19)
    static let supraSurfaceHighlight = Color(red: 0.18, green: 0.18, blue: 0.23)
    static let supraGlass = Color.white.opacity(0.05)
    static let supraGlassLight = Color.white.opacity(0.08)

    // MARK: Accent
    static let supraAccent = Color(red: 0.4, green: 0.6, blue: 1.0)
    static let supraAccentSecondary = Color(red: 0.6, green: 0.4, blue: 1.0)
    static let supraAccentTertiary = Color(red: 0.3, green: 0.8, blue: 1.0)

    // MARK: Semantic Colors
    static let supraGreen = Color(red: 0.2, green: 0.85, blue: 0.5)
    static let supraOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let supraRed = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let supraYellow = Color(red: 1.0, green: 0.8, blue: 0.2)
    static let supraPurple = Color(red: 0.7, green: 0.3, blue: 1.0)
    static let supraTeal = Color(red: 0.2, green: 0.8, blue: 0.8)
    static let supraBlue = Color(red: 0.2, green: 0.5, blue: 1.0)
    static let supraPink = Color(red: 1.0, green: 0.4, blue: 0.6)

    // MARK: Text
    static let supraText = Color.white
    static let supraTextSecondary = Color.white.opacity(0.6)
    static let supraTextTertiary = Color.white.opacity(0.35)
    static let supraTextQuaternary = Color.white.opacity(0.18)

    // MARK: Borders
    static let supraBorder = Color.white.opacity(0.08)
    static let supraBorderLight = Color.white.opacity(0.12)
    static let supraBorderFocused = Color.white.opacity(0.2)
}

// MARK: - Color for Factories

extension Color {
    static func factoryColor(_ id: Int) -> Color {
        switch id {
        case 1: return .supraAccent
        case 2: return .supraTeal
        case 3: return .supraGreen
        case 4: return .supraPurple
        case 5: return .supraOrange
        case 6: return .supraBlue
        case 7: return .supraPink
        case 8: return .supraYellow
        case 9: return Color(red: 0.5, green: 0.8, blue: 0.4)
        case 10: return .supraRed
        default: return .supraTextSecondary
        }
    }

    static func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "pass", "healthy", "ready", "active", "success", "connected", "succeeded":
            return .supraGreen
        case "warning", "attention", "pending", "running", "analysing":
            return .supraOrange
        case "fail", "failure", "error", "critical", "disconnected":
            return .supraRed
        default:
            return .supraTextSecondary
        }
    }
}

// MARK: - Linear Gradient Presets

extension LinearGradient {
    static let supraBootGradient = LinearGradient(
        colors: [.supraAccent, .supraPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let supraSurfaceGradient = LinearGradient(
        colors: [.supraBackground, Color(red: 0.08, green: 0.08, blue: 0.15), .supraBackground],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Reusable Modifiers

extension View {
    /// Standard card styling with consistent background, corner radius, and border
    func supraCardStyle() -> some View {
        self
            .background(Color.supraSurface)
            .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall)
                    .stroke(Color.supraBorder)
            )
    }

    /// Press animation for buttons — 0.1s scale to 0.97
    func pressAnimation() -> some View {
        self.buttonStyle(SupraPressButtonStyle())
    }

    /// Card hover effect — subtle lift with shadow
    func cardHoverEffect() -> some View {
        self.modifier(CardHoverModifier())
    }

    /// Standard section header style
    func supraSectionHeader() -> some View {
        self.font(SUPRAOSDesignSystem.Fonts.section)
            .foregroundStyle(Color.supraAccent)
            .tracking(1.8)
    }

    /// Accessibility: Add standard accessibility to an icon
    func supraAccessibility(label: String, hint: String = "") -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint.isEmpty ? label : hint)
    }
}

// MARK: - Custom Button Style — Press Animation

struct SupraPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Card Hover Modifier

struct CardHoverModifier: ViewModifier {
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(
                color: isHovered ? .black.opacity(0.2) : .clear,
                radius: isHovered ? 12 : 0,
                y: isHovered ? 4 : 0
            )
            .animation(.easeOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
    }
}

// MARK: - Card Component

struct SUPRAOSCard<Content: View>: View {
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
                    .font(.system(size: SUPRAOSDesignSystem.IconSize.cardHeader, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusTiny))
                    .supraAccessibility(label: icon)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(SUPRAOSDesignSystem.Fonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.supraText)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(SUPRAOSDesignSystem.Fonts.bodySmall)
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
        .supraCardStyle()
        .contentShape(Rectangle())
        .cardHoverEffect()
        .onTapGesture { action?() }
    }
}

struct SUPRAOSStatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    var trend: String? = nil
    var trendDirection: TrendDirection = .neutral

    enum TrendDirection: String {
        case up = "arrow.up"
        case down = "arrow.down"
        case neutral = "arrow.right"

        var icon: String { self.rawValue }

        var isPositive: Bool {
            switch self {
            case .up, .neutral: return true
            case .down: return false
            }
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .supraAccessibility(label: label)
            Text(value)
                .font(SUPRAOSDesignSystem.Fonts.metric)
                .foregroundColor(.supraText)
                .contentTransition(.numericText())
            Text(label)
                .font(SUPRAOSDesignSystem.Fonts.bodySmall)
                .foregroundColor(.supraTextSecondary)
                .multilineTextAlignment(.center)
            if let trend = trend {
                HStack(spacing: 4) {
                    Image(systemName: trendDirection.icon)
                        .font(.system(size: 8, weight: .bold))
                    Text(trend)
                        .font(SUPRAOSDesignSystem.Fonts.caption)
                }
                .foregroundColor(trendDirection.isPositive ? .supraGreen : .supraRed)
            }
        }
        .frame(minWidth: 90, minHeight: 100)
        .padding(SUPRAOSDesignSystem.paddingTiny)
        .supraCardStyle()
        .cardHoverEffect()
    }
}

struct SUPRAOSBadge: View {
    let text: String
    let color: Color
    var showOnlyWhenNotPass: Bool = false

    var body: some View {
        if showOnlyWhenNotPass && text == "PASS" {
            EmptyView()
        } else {
            Text(text)
                .font(SUPRAOSDesignSystem.Fonts.badge)
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(color.opacity(0.15), in: Capsule())
                .accessibilityLabel(text)
        }
    }
}

struct SUPRAOSGradientBackground: View {
    var body: some View {
        LinearGradient.supraSurfaceGradient.ignoresSafeArea()
    }
}

struct SUPRAOSSectionHeader: View {
    let title: String
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(SUPRAOSDesignSystem.Fonts.title3)
                .foregroundColor(.supraText)
            Spacer()
            if let actionLabel = actionLabel {
                Button(actionLabel) { action?() }
                    .font(SUPRAOSDesignSystem.Fonts.bodySmall)
                    .foregroundColor(.supraAccent)
                    .buttonStyle(.plain)
            }
        }
    }
}

struct SUPRAOSButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .pressAnimation()
    }
}

// MARK: - Empty State Helpers

/// Positive framing empty state — shows what CAN be done, not what's missing
struct SupraReadyView: View {
    let title: String
    let icon: String
    let description: String

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(description)
        }
    }
}

/// Action-oriented empty state with suggested next step
struct SupraActionNeededView: View {
    let icon: String
    let title: String
    let action: String

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(action)
        }
    }
}

// MARK: - Reduce Motion Support

extension View {
    /// Applies animation only when Reduce Motion is disabled
    func animatedMotion(using animation: Animation?, value: some Equatable) -> some View {
        self.modifier(ReduceMotionModifierView(animation: animation, value: value))
    }
}

struct ReduceMotionModifierView<Value: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation?
    let value: Value

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}
