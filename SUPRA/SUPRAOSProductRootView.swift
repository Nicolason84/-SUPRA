import SwiftUI

// MARK: - Product Root View

struct SUPRAOSProductRootView: View {
    @StateObject private var bootManager = ExecutiveBootManager.shared
    @State private var bootPhase: BootUIState = .idle
    @State private var showCockpit = false

    enum BootUIState {
        case idle
        case booting
        case completed
    }

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            if showCockpit {
                ExecutiveWindow()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 1.02)),
                        removal: .opacity
                    ))
            }

            if !showCockpit {
                ExecutiveBootView(
                    bootManager: bootManager,
                    onComplete: {
                        withAnimation(.easeOut(duration: 0.6)) {
                            showCockpit = true
                        }
                    },
                    onSkip: {
                        withAnimation(.easeOut(duration: 0.6)) {
                            showCockpit = true
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: showCockpit)
        .onAppear {
            BootTrace.mark("ROOT_VIEW_READY")
            // Auto-skip boot when continuity is restored
            if bootManager.bootState == .restored {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        showCockpit = true
                    }
                }
            }
        }
    }
}

// MARK: - Boot Step Model

struct BootStepModel: Identifiable {
    let id = UUID()
    let phase: BootPhase
    let detail: String
    let icon: String
    let state: BootStepState
    let progress: Double

    enum BootStepState {
        case pending
        case running
        case pass
        case warning
        case failure

        var color: Color {
            switch self {
            case .pending: return .supraTextTertiary
            case .running: return .supraAccent
            case .pass: return .supraGreen
            case .warning: return .supraOrange
            case .failure: return .supraRed
            }
        }

        var icon: String {
            switch self {
            case .pending: return "circle"
            case .running: return "arrow.triangle.2.circlepath"
            case .pass: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .failure: return "xmark.circle.fill"
            }
        }
    }
}

// MARK: - Executive Boot View

struct ExecutiveBootView: View {
    @ObservedObject var bootManager: ExecutiveBootManager
    var onComplete: () -> Void
    var onSkip: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @State private var bootStarted = false
    @State private var appearStep: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var logoOpacity: Double = 0
    @State private var progressValue: Double = 0
    @State private var currentMessage = ""
    @State private var showContent = false

    private let bootMessages: [(Double, String)] = [
        (0.0, "Restoring your workspace..."),
        (0.15, "Checking recent decisions..."),
        (0.30, "Preparing your tools..."),
        (0.45, "Verifying system health..."),
        (0.60, "Connecting to services..."),
        (0.75, "Setting up your environment..."),
        (0.90, "Almost ready..."),
        (1.0, "Welcome back.")
    ]

    var body: some View {
        ZStack {
            // Background
            Color.supraBackground.ignoresSafeArea()

            // Animated gradient overlay
            RadialGradient(
                gradient: Gradient(colors: [
                    .supraAccent.opacity(0.06),
                    .supraPurple.opacity(0.03),
                    .clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                ZStack {
                    // Outer glow
                    Circle()
                        .stroke(
                            LinearGradient.supraBootGradient,
                            lineWidth: 2
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseScale)
                        .opacity(2 - pulseScale)

                    // Inner background
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient.supraBootGradient
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("S")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .supraAccent.opacity(0.3), radius: 20, y: 0)
                }
                .opacity(logoOpacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.8)) {
                        logoOpacity = 1
                    }
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        pulseScale = 1.15
                    }
                }

                Spacer().frame(height: 48)

                // Title
                VStack(spacing: 8) {
                    Text("SUPRA EXECUTIVE OS")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .tracking(4)
                        .foregroundColor(.supraAccent)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 8)

                    Text("Continuity-First Runtime")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.supraTextSecondary)
                        .opacity(showContent ? 0.8 : 0)
                        .offset(y: showContent ? 0 : 8)
                }

                Spacer().frame(height: 56)

                // Progress Section
                VStack(spacing: 20) {
                    // Progress Bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.supraSurfaceLight)
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient.supraBootGradient
                            )
                            .frame(width: max(0, min(280 * progressValue, 280)), height: 4)
                            .animation(.easeOut(duration: 0.4), value: progressValue)
                    }
                    .frame(width: 280)

                    // Status Message
                    Text(currentMessage)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.supraTextSecondary)
                        .lineLimit(1)
                }
                .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 60)

                // Boot Steps
                VStack(spacing: 6) {
                    ForEach(Array(bootSteps.prefix(Int(appearStep)))) { step in
                        BootStepRow(step: step)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                    }
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: 520)

                if !bootStarted && !bootManager.isBootComplete {
                    Spacer().frame(height: 40)
                    StartBootButton(action: startBoot)
                        .opacity(showContent ? 1 : 0)
                }

                if bootManager.isBootComplete {
                    Spacer().frame(height: 32)
                    BootCompleteView(bootManager: bootManager, onContinue: onComplete)
                        .opacity(showContent ? 1 : 0)
                }

                Spacer()

                // Version + Skip
                HStack(spacing: 16) {
                    Text("v\(ContinuityManager.shared.state.runtimeVersion)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.supraTextQuaternary)

                    if bootManager.bootState == .restored {
                        Text("·")
                            .foregroundColor(.supraTextQuaternary)

                        Button("Skip to Cockpit (⌘⏎)") {
                            onSkip?()
                        }
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.supraAccent)
                        .buttonStyle(.plain)
                        .keyboardShortcut(.return, modifiers: [.command])
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    }
                }
                .opacity(showContent ? 0.6 : 0)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            BootTrace.mark("BOOT_VIEW_APPEARED")
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showContent = true
            }
        }
    }

    private var bootSteps: [BootStepModel] {
        bootManager.bootSteps.map { step in
            let state: BootStepModel.BootStepState = {
                switch step.status {
                case .pass: return .pass
                case .warning: return .warning
                case .failure: return .failure
                case .pending: return .pending
                case .running: return .running
                }
            }()
            return BootStepModel(
                phase: step.phase,
                detail: step.detail,
                icon: step.status.icon,
                state: state,
                progress: 1.0
            )
        }
    }

    private func startBoot() {
        bootStarted = true

        // Animate steps appearing
        withAnimation(.easeOut(duration: 0.3)) {
            appearStep = 1
        }

        // Progress simulation with messages
        let totalSteps = bootMessages.count
        for (index, (progress, message)) in bootMessages.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    progressValue = progress
                    currentMessage = message
                    appearStep = CGFloat(min(index + 2, totalSteps))
                }
            }
        }

        // Execute real boot after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            bootManager.executeBoot()
        }
    }
}

// MARK: - Boot Step Row

struct BootStepRow: View {
    let step: BootStepModel

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                if step.state == .running {
                    ProgressView()
                        .controlSize(.small)
                        .progressViewStyle(.circular)
                        .tint(step.state.color)
                } else {
                    Image(systemName: step.state.icon)
                        .font(.system(size: 14))
                        .foregroundColor(step.state.color)
                }
            }
            .frame(width: 20)

            // Phase + Detail
            VStack(alignment: .leading, spacing: 2) {
                Text(step.phase.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.supraText)
                Text(step.detail)
                    .font(.system(size: 11))
                    .foregroundColor(.supraTextSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Status badge
            Text(step.state == .running ? "RUNNING" : step.state == .pass ? "PASS" : step.state == .warning ? "WARN" : step.state == .failure ? "FAIL" : "WAIT")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(step.state.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(step.state.color.opacity(0.12), in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.supraBorder)
        )
    }
}

// MARK: - Start Boot Button

struct StartBootButton: View {
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 16))
                Text("Start Executive Boot")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(
                LinearGradient.supraBootGradient
                    .opacity(isHovered ? 1.0 : 0.85)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .supraAccent.opacity(0.2), radius: isHovered ? 16 : 8, y: isHovered ? 6 : 4)
            .scaleEffect(isHovered ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Boot Complete View

struct BootCompleteView: View {
    let bootManager: ExecutiveBootManager
    let onContinue: () -> Void
    @State private var isHovered = false
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 16) {
            // State indicator
            HStack(spacing: 8) {
                Image(systemName: stateIcon)
                    .font(.system(size: 14))
                    .foregroundColor(stateColor)
                Text(stateMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(stateColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(stateColor.opacity(0.1), in: Capsule())
            .opacity(showContent ? 1 : 0)

            // Continue button
            Button(action: onContinue) {
                HStack(spacing: 10) {
                    Text("Continue to Cockpit")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 14)
                .background(Color.supraSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient.supraBootGradient,
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .supraAccent.opacity(0.15), radius: isHovered ? 12 : 6, y: isHovered ? 4 : 2)
                .scaleEffect(isHovered ? 1.02 : 1.0)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 10)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showContent = true
            }
        }
    }

    private var stateIcon: String {
        switch bootManager.bootState {
        case .restored: return "checkmark.circle.fill"
        case .firstBoot: return "star.fill"
        case .divergence: return "exclamationmark.triangle.fill"
        default: return "checkmark.circle.fill"
        }
    }

    private var stateColor: Color {
        switch bootManager.bootState {
        case .restored: return .supraGreen
        case .firstBoot: return .supraOrange
        case .divergence: return .supraRed
        default: return .supraGreen
        }
    }

    private var stateMessage: String {
        switch bootManager.bootState {
        case .restored: return "Continuity restored — ready to resume"
        case .firstBoot: return "Welcome! Setting up your workspace for the first time"
        case .divergence: return "System state updated — review before continuing"
        default: return "Ready to continue"
        }
    }
}
