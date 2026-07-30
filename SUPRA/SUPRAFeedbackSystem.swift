import SwiftUI
import Combine

// MARK: - Feedback Types

enum FeedbackType: Equatable {
    case success(String)
    case warning(String)
    case error(String)
    case info(String)
    case progress(String, Double)

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .progress: return "clock.arrow.circlepath"
        }
    }

    var color: Color {
        switch self {
        case .success: return .supraGreen
        case .warning: return .supraOrange
        case .error: return .supraRed
        case .info: return .supraAccent
        case .progress: return .supraAccent
        }
    }

    var message: String {
        switch self {
        case .success(let m): return m
        case .warning(let m): return m
        case .error(let m): return m
        case .info(let m): return m
        case .progress(let m, _): return m
        }
    }

    var progressValue: Double? {
        if case .progress(_, let v) = self { return v }
        return nil
    }
}

// MARK: - Feedback Manager

final class SUPRAFeedbackManager: ObservableObject {
    static let shared = SUPRAFeedbackManager()

    @Published var currentFeedback: FeedbackType? = nil
    @Published var isPresented = false

    private var dismissWorkItem: DispatchWorkItem?
    private var feedbackQueue: [FeedbackType] = []
    private var isProcessing = false

    private init() {}

    func show(_ feedback: FeedbackType, duration: Double = 2.5) {
        DispatchQueue.main.async {
            self.feedbackQueue.append(feedback)
            if !self.isProcessing {
                self.processNext()
            }
        }
    }

    func success(_ message: String, duration: Double = 2.0) {
        show(.success(message), duration: duration)
    }

    func warning(_ message: String, duration: Double = 3.0) {
        show(.warning(message), duration: duration)
    }

    func error(_ message: String, duration: Double = 3.5) {
        show(.error(message), duration: duration)
    }

    func info(_ message: String, duration: Double = 2.0) {
        show(.info(message), duration: duration)
    }

    func progress(_ message: String, value: Double = 0.0) {
        show(.progress(message, value), duration: 0)
    }

    func dismiss() {
        dismissWorkItem?.cancel()
        withAnimation(.easeOut(duration: 0.2)) {
            isPresented = false
            currentFeedback = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let self = self else { return }
            self.isProcessing = false
            self.processNext()
        }
    }

    private func processNext() {
        guard !feedbackQueue.isEmpty else {
            isProcessing = false
            return
        }

        isProcessing = true
        let feedback = feedbackQueue.removeFirst()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            currentFeedback = feedback
            isPresented = true
        }

        // Auto-dismiss for non-progress feedback
        if case .progress = feedback {
            // Don't auto-dismiss progress
        } else {
            let duration: Double = {
                switch feedback {
                case .success: return 2.0
                case .warning: return 3.0
                case .error: return 4.0
                case .info: return 2.0
                case .progress: return 0
                }
            }()

            let workItem = DispatchWorkItem { [weak self] in
                self?.dismiss()
            }
            dismissWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
        }
    }
}

// MARK: - Feedback View (Overlay)

struct SUPRAFeedbackOverlay: View {
    @ObservedObject private var feedbackManager = SUPRAFeedbackManager.shared

    var body: some View {
        Group {
            if feedbackManager.isPresented, let feedback = feedbackManager.currentFeedback {
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        Image(systemName: feedback.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(feedback.color)

                        Text(feedback.message)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.supraText)

                        if let progress = feedback.progressValue {
                            ProgressView(value: progress, total: 1.0)
                                .tint(feedback.color)
                                .frame(width: 40)
                        }

                        Spacer(minLength: 20)

                        Button {
                            feedbackManager.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.supraTextTertiary)
                        }
                        .buttonStyle(.plain)
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
                }
                .padding(.top, SUPRAOSDesignSystem.headerHeight + 12)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: feedbackManager.isPresented)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: feedbackManager.currentFeedback?.message)
    }
}

// MARK: - View Modifier for Feedback

struct FeedbackModifier: ViewModifier {
    @ObservedObject private var feedbackManager = SUPRAFeedbackManager.shared

    func body(content: Content) -> some View {
        content.overlay(
            SUPRAFeedbackOverlay(),
            alignment: .top
        )
    }
}

extension View {
    func withSUPRAFeedback() -> some View {
        modifier(FeedbackModifier())
    }
}

// MARK: - Simple Feedback Helpers

extension View {
    /// Trigger a success feedback
    func feedbackOnChange<T: Equatable>(of value: T, trigger: @escaping (T) -> FeedbackType?) -> some View {
        self.onChange(of: value) { _, newValue in
            if let feedback = trigger(newValue) {
                SUPRAFeedbackManager.shared.show(feedback)
            }
        }
    }
}
