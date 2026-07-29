import SwiftUI

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -0.5

    let duration: Double
    let tint: Color
    let highlight: Color

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [tint, highlight, tint]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 1.5)
                    .offset(x: geo.size.width * phase)
                    .blur(radius: 12)
                    .opacity(0.6)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    func shimmer(
        duration: Double = 1.8,
        tint: Color = Color.white.opacity(0.08),
        highlight: Color = Color.white.opacity(0.18)
    ) -> some View {
        modifier(ShimmerModifier(duration: duration, tint: tint, highlight: highlight))
    }
}

// MARK: - Skeleton Loading

struct SkeletonModifier: ViewModifier {
    @State private var opacity: Double = 0.4
    let isLoading: Bool
    let shape: SkeletonShape

    func body(content: Content) -> some View {
        if isLoading {
            Group {
                switch shape {
                case .rounded(let radius):
                    RoundedRectangle(cornerRadius: radius)
                        .fill(Color.supraSurfaceLight)
                        .opacity(opacity)
                case .capsule:
                    Capsule()
                        .fill(Color.supraSurfaceLight)
                        .opacity(opacity)
                case .circle:
                    Circle()
                        .fill(Color.supraSurfaceLight)
                        .opacity(opacity)
                case .textLine:
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.supraSurfaceLight)
                        .opacity(opacity)
                        .frame(height: 12)
                case .custom(let width, let height, let radius):
                    RoundedRectangle(cornerRadius: radius)
                        .fill(Color.supraSurfaceLight)
                        .opacity(opacity)
                        .frame(width: width, height: height)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    opacity = 0.8
                }
            }
        } else {
            content
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
    }
}

enum SkeletonShape {
    case rounded(CGFloat)
    case capsule
    case circle
    case textLine
    case custom(width: CGFloat, height: CGFloat, radius: CGFloat)
}

extension View {
    func skeleton(isLoading: Bool, shape: SkeletonShape = .rounded(12)) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading, shape: shape))
    }
}

// MARK: - Fade In Transition

struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 8)
            .blur(radius: isVisible ? 0 : 2)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func fadeIn(delay: Double = 0.0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }
}

// MARK: - Slide Transition

struct SlideTransition: ViewModifier {
    let edge: Edge
    let offset: CGFloat

    func body(content: Content) -> some View {
        content
            .transition(.asymmetric(
                insertion: .move(edge: edge).combined(with: .opacity),
                removal: .move(edge: edge).combined(with: .opacity)
            ))
    }
}

extension AnyTransition {
    static func slideIn(edge: Edge = .trailing) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: edge).combined(with: .opacity),
            removal: .move(edge: edge).combined(with: .opacity)
        )
    }

    static func fadeAndScale(scale: CGFloat = 0.96) -> AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: scale)),
            removal: .opacity.combined(with: .scale(scale: scale))
        )
    }
}

// MARK: - Pulse Effect

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    let color: Color
    let duration: Double

    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 0.6)
            )
            .onAppear {
                withAnimation(.easeOut(duration: duration).repeatForever(autoreverses: false)) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func pulse(color: Color = .supraAccent, duration: Double = 1.5) -> some View {
        modifier(PulseModifier(color: color, duration: duration))
    }
}

// MARK: - Hover Highlight

struct HoverHighlightModifier: ViewModifier {
    @State private var isHovered = false
    let color: Color
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color.opacity(isHovered ? 0.1 : 0))
            )
    }
}

extension View {
    func hoverHighlight(color: Color = .supraAccent, cornerRadius: CGFloat = 8) -> some View {
        modifier(HoverHighlightModifier(color: color, cornerRadius: cornerRadius))
    }
}

// MARK: - Content Unavailable (Empty State) Enhancement

extension View {
    static func supraEmpty(
        _ title: String,
        icon: String,
        description: String? = nil
    ) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
                .font(.system(size: 16, weight: .semibold))
        } description: {
            if let description = description {
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.supraTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Toast Notification

struct ToastView: View {
    let message: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.supraText)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.supraBorder)
        )
        .shadow(color: .black.opacity(0.2), radius: 16, y: 6)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Progress Indicator

struct SupraProgressView: View {
    let progress: Double
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: progress, total: 1.0)
                .tint(color)
                .background(Color.supraSurfaceLight)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.supraTextSecondary)
        }
    }
}

// MARK: - Keyboard Shortcut Label

struct KeyboardShortcutLabel: View {
    let shortcut: String
    let action: String

    var body: some View {
        HStack(spacing: 8) {
            Text(shortcut)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.supraTextTertiary)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(Color.supraSurfaceLight)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            Text(action)
                .font(.system(size: 12))
                .foregroundStyle(Color.supraTextSecondary)
        }
    }
}

// MARK: - Smooth Content Transition

struct SmoothContentSwitch<Content: View>: View {
    let isActive: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        Group {
            if isActive {
                content()
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }
        }
        .animation(.easeOut(duration: 0.25), value: isActive)
    }
}

// MARK: - Progress Bar (Linear)

struct LinearProgressBar: View {
    let progress: CGFloat
    let color: Color
    let height: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.supraSurfaceLight)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: max(0, min(geo.size.width * progress, geo.size.width)))
                    .animation(.easeOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Status Badge with Pulse

struct StatusBadge: View {
    let text: String
    let active: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(active ? Color.supraGreen : Color.supraTextTertiary)
                .frame(width: 6, height: 6)
                .overlay(
                    Circle()
                        .stroke(active ? Color.supraGreen : Color.clear, lineWidth: 2)
                        .scaleEffect(active ? 1.5 : 1.0)
                        .opacity(active ? 0.3 : 0)
                )
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(active ? Color.supraGreen : Color.supraTextTertiary)
        }
    }
}
