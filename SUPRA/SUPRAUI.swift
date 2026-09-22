import SwiftUI

enum SUPRAUI {
    static let pageSpacing: CGFloat = 24
    static let sectionSpacing: CGFloat = 14
    static let cardRadius: CGFloat = 18
    static let heroRadius: CGFloat = 24
    static let compactRadius: CGFloat = 12
    static let pagePadding: CGFloat = 28
    static let contentMaxWidth: CGFloat = 1400

    enum Vocabulary {
        static let live = "LIVE"
        static let historical = "HISTORICAL"
        static let unproven = "UNPROVEN"
        static let blocked = "BLOCKED"
        static let pass = "PASS"
        static let humanGate = "HUMAN GATE"
        static let proofFirst = "PROOF-FIRST"
        static let readOnly = "READ-ONLY"
    }
}

struct SUPRASectionTitle: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.title2.bold())
    }
}

struct SUPRAStatusPill: View {
    let text: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption2.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.10), in: Capsule())
    }
}

struct SUPRAWorkspaceHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(eyebrow)
                .font(.caption.weight(.heavy))
                .tracking(1.6)
                .foregroundStyle(tint)

            Text(title)
                .font(.system(size: 36, weight: .bold, design: .rounded))

            Text(subtitle)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}

struct SUPRAEmptyState: View {
    let title: String
    let systemImage: String
    let detail: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text(detail)
        )
    }
}

private struct SUPRACardModifier: ViewModifier {
    let radius: CGFloat
    let strokeOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(.white.opacity(strokeOpacity))
            )
    }
}

extension View {
    func supraCard(
        radius: CGFloat = SUPRAUI.cardRadius,
        strokeOpacity: Double = 0.06
    ) -> some View {
        modifier(SUPRACardModifier(radius: radius, strokeOpacity: strokeOpacity))
    }
}
