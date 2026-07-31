import SwiftUI
import Combine

// MARK: - ŒIL View
//
// The first visible manifestation of SUPRA's living runtime.
// ŒIL does not show engines. ŒIL does not show technology.
// ŒIL makes you FEEL where SUPRA is looking, what it understands,
// what it prepares, what it awaits, what it decides.
//
// This view reads ONLY from the ExecutiveContextSnapshot (via SnapshotBus).
// No direct service access. No engine references.

public struct OeilView: View {
    @StateObject private var phoenix = PhoenixRuntime.shared
    @StateObject private var oeil = OeilPerceptionLayer.shared
    @StateObject private var snapshotBus = ExecutiveSnapshotBus.shared

    @State private var isExpanded: Bool = false
    @State private var pulseAnimating: Bool = false

    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            if phoenix.isBooted {
                oeilContent
            } else {
                bootSequence
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 1.5)) {
                pulseAnimating.toggle()
            }
        }
    }

    // MARK: - Boot Sequence

    private var bootSequence: some View {
        VStack(spacing: 24) {
            Spacer()

            // ŒIL dormant
            ZStack {
                Circle()
                    .stroke(Color.supraTextTertiary.opacity(0.3), lineWidth: 1)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: phoenix.bootProgress)
                    .stroke(Color.supraAccent, lineWidth: 2)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.5), value: phoenix.bootProgress)

                Image(systemName: "eye")
                    .font(.system(size: 32, weight: .thin))
                    .foregroundStyle(Color.supraTextTertiary)
            }

            Text("SUPRA")
                .font(.system(size: 20, weight: .light))
                .tracking(6)
                .foregroundStyle(Color.supraTextSecondary)

            Text(phoenix.bootMessage)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Color.supraTextTertiary)

            ProgressView(value: phoenix.bootProgress)
                .progressViewStyle(.linear)
                .tint(Color.supraAccent)
                .frame(width: 160)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.supraBackground)
    }

    // MARK: - ŒIL Content

    private var oeilContent: some View {
        VStack(spacing: 0) {
            // ŒIL Header
            oeilHeader
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            Divider()
                .overlay(Color.supraBorder)

            if isExpanded {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        perceptionPanel
                        understandingPanel
                        gazePanel
                        systemPanel
                        perceptionLogView
                    }
                    .padding(16)
                }
            } else {
                compactPresence
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
        }
        .background(Color.supraBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(oeil.mood == .alert ? Color.supraRed : Color.supraBorder)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
    }

    // MARK: - ŒIL Header

    private var oeilHeader: some View {
        HStack(spacing: 12) {
            // ŒIL Eye indicator
            ZStack {
                Circle()
                    .fill(oeilMoodColor.opacity(0.15))
                    .frame(width: 36, height: 36)

                Circle()
                    .fill(oeilMoodColor)
                    .frame(width: 8, height: 8)
                    .scaleEffect(pulseAnimating ? 1.3 : 0.8)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimating)

                Circle()
                    .stroke(oeilMoodColor, lineWidth: 1)
                    .frame(width: 24, height: 24)
                    .scaleEffect(pulseAnimating ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5), value: pulseAnimating)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("ŒIL")
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(3)
                    .foregroundStyle(Color.supraText)

                Text(oeil.perception)
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(Color.supraTextSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Mood badge
            Text(oeil.mood.rawValue.uppercased())
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(oeilMoodColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(oeilMoodColor.opacity(0.1))
                .clipShape(Capsule())

            // Expand toggle
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.supraTextTertiary)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Compact Presence

    private var compactPresence: some View {
        HStack(spacing: 16) {
            // Gaze
            Label(oeil.gaze.rawValue, systemImage: gazeIcon)
                .font(.system(size: 11))
                .foregroundStyle(Color.supraTextSecondary)

            Spacer()

            // Attention intensity
            HStack(spacing: 4) {
                Text("\(Int(oeil.attentionIntensity * 100))%")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.supraTextTertiary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.supraBorder)
                            .frame(width: geo.size.width, height: 4)
                        Capsule()
                            .fill(oeilMoodColor)
                            .frame(width: geo.size.width * oeil.attentionIntensity, height: 4)
                    }
                }
                .frame(width: 40)
            }

            // Presence
            Circle()
                .fill(oeil.isAlive ? Color.supraGreen : Color.supraRed)
                .frame(width: 6, height: 6)

            Text(oeil.isAlive ? "VIVANT" : "DORMANT")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(oeil.isAlive ? Color.supraGreen : Color.supraRed)
        }
    }

    // MARK: - Expanded Panels

    private var perceptionPanel: some View {
        OeilPanel(title: "PERCEPTION", icon: "eye.fill", color: oeilMoodColor) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Regard")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.supraTextTertiary)
                    Spacer()
                    Text(oeil.gaze.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.supraText)
                }

                HStack {
                    Text("Intensité")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.supraTextTertiary)
                    Spacer()
                    Text("\(Int(oeil.attentionIntensity * 100))%")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.supraText)
                }

                Text(oeil.perception)
                    .font(.system(size: 12, weight: .light, design: .serif))
                    .italic()
                    .foregroundStyle(Color.supraTextSecondary)
                    .padding(.top, 4)
            }
        }
    }

    private var understandingPanel: some View {
        OeilPanel(title: "COMPRÉHENSION", icon: "brain.head.profile", color: .supraTeal) {
            Text(oeil.understanding)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Color.supraTextSecondary)
                .lineSpacing(4)
        }
    }

    private var gazePanel: some View {
        OeilPanel(title: "DIRECTION DU REGARD", icon: "location.fill", color: .supraBlue) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                ForEach(OeilGaze.allCases, id: \.self) { target in
                    Button {
                        oeil.directGaze(target)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: gazeIcon(for: target))
                                .font(.system(size: 14))
                            Text(target.rawValue)
                                .font(.system(size: 8, weight: .medium))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(
                            oeil.gaze == target ?
                                Color.supraAccent.opacity(0.15) :
                                Color.supraSurface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(oeil.gaze == target ? Color.supraAccent : Color.supraBorder.opacity(0.3))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var systemPanel: some View {
        OeilPanel(title: "SYSTÈME", icon: "heart.text.square", color: .supraGreen) {
            let snapshot = snapshotBus.latestSnapshot

            VStack(spacing: 6) {
                systemRow("Runtime", snapshot.runtimeState, snapshot.runtimeState == "active" ? .supraGreen : .supraOrange)
                systemRow("Moteurs", "\(snapshot.runtimeHealthSummary?.activeEngineCount ?? 0)/\(snapshot.runtimeHealthSummary?.engineCount ?? 0) actifs", .supraAccent)
                systemRow("Snapshot", "#\(snapshot.sequenceNumber)", .supraBlue)
                systemRow("Présence", snapshot.presence.rawValue, presenceColor(snapshot.presence.rawValue))
                systemRow("Jumeau", snapshot.digitalTwin.isSynced ? "Synced" : "Desync", snapshot.digitalTwin.isSynced ? .supraGreen : .supraRed)
            }
        }
    }

    private var perceptionLogView: some View {
        OeilPanel(title: "PERCEPTIONS RÉCENTES", icon: "list.bullet", color: .supraPurple) {
            VStack(spacing: 4) {
                ForEach(oeil.perceptionLog.prefix(8)) { entry in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(moodColor(entry.mood))
                            .frame(width: 5, height: 5)

                        Text(entry.perception)
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(Color.supraTextSecondary)
                            .lineLimit(1)

                        Spacer()

                        Text(entry.timestamp, style: .time)
                            .font(.system(size: 8, weight: .light, design: .monospaced))
                            .foregroundStyle(Color.supraTextTertiary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    // MARK: - Helpers

    private var gazeIcon: String {
        switch oeil.gaze {
        case .project: return "folder"
        case .git: return "arrow.triangle.branch"
        case .files: return "doc.text"
        case .runtime: return "gear"
        case .build: return "hammer"
        case .mission: return "flag"
        case .memory: return "memorychip"
        case .system: return "heart.text.square"
        case .providers: return "network"
        case .user: return "person"
        case .horizon: return "eye"
        }
    }

    private func gazeIcon(for target: OeilGaze) -> String {
        switch target {
        case .project: return "folder"
        case .git: return "arrow.triangle.branch"
        case .files: return "doc.text"
        case .runtime: return "gear"
        case .build: return "hammer"
        case .mission: return "flag"
        case .memory: return "memorychip"
        case .system: return "heart.text.square"
        case .providers: return "network"
        case .user: return "person"
        case .horizon: return "eye"
        }
    }

    private var oeilMoodColor: Color {
        switch oeil.mood {
        case .dormant: return .gray
        case .observing: return .blue
        case .attentive: return .orange
        case .curious: return .purple
        case .focused: return .red
        case .processing: return .indigo
        case .waiting: return .yellow
        case .alert: return .red
        case .serene: return .green
        }
    }

    private func moodColor(_ mood: OeilMood) -> Color {
        switch mood {
        case .dormant: return .gray
        case .observing: return .blue
        case .attentive: return .orange
        case .curious: return .purple
        case .focused: return .red
        case .processing: return .indigo
        case .waiting: return .yellow
        case .alert: return .red
        case .serene: return .green
        }
    }

    private func presenceColor(_ state: String) -> Color {
        switch state {
        case "present", "watching": return .green
        case "thinking", "deciding": return .indigo
        case "waiting": return .yellow
        case "dormant": return .gray
        default: return .blue
        }
    }

    private func systemRow(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.supraTextTertiary)
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
                Text(value)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.supraTextSecondary)
            }
        }
    }
}

// MARK: - ŒIL Panel

private struct OeilPanel<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundStyle(color)
            }

            content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.supraBorder.opacity(0.5))
        )
    }
}

// Colors are defined in SUPRAOSDesignSystem.swift — do not duplicate
