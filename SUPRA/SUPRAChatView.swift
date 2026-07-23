import SwiftUI

enum ChatMode: String, CaseIterable, Identifiable {
    case ask = "ASK"
    case plan = "PLAN"

    var id: Self { self }
}

struct ChatMessage: Identifiable, Equatable {
    enum Role {
        case user
        case runtime
    }

    let id: UUID
    let role: Role
    let mode: ChatMode
    let content: String

    init(
        id: UUID = UUID(),
        role: Role,
        mode: ChatMode,
        content: String
    ) {
        self.id = id
        self.role = role
        self.mode = mode
        self.content = content
    }
}

enum SUPRAChatExecutionState: Equatable {
    case idle
    case running
    case success
    case error(String)

    var title: String {
        switch self {
        case .idle: "Idle"
        case .running: "Running"
        case .success: "Success"
        case .error: "Error"
        }
    }

    var systemImage: String {
        switch self {
        case .idle: "circle"
        case .running: "arrow.trianglehead.2.clockwise.rotate.90"
        case .success: "checkmark.circle.fill"
        case .error: "exclamationmark.triangle.fill"
        }
    }
}

struct SUPRAChatView: View {
    @State private var mode: ChatMode = .ask
    @State private var prompt = ""
    @State private var messages: [ChatMessage] = []
    @State private var executionState: SUPRAChatExecutionState = .idle

    private let runtime: any SUPRAChatRuntimeProtocol

    init() {
        runtime = SUPRAChatRuntimeAdapter()
    }

    init(runtime: any SUPRAChatRuntimeProtocol) {
        self.runtime = runtime
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            conversation
            Divider()
            composer
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("SUPRA Chat")
    }

    private var header: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SUPRA CHAT")
                    .font(.caption.weight(.bold))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
                Text("Command workspace")
                    .font(.title2.bold())
            }

            Spacer()

            Picker("Chat mode", selection: $mode) {
                ForEach(ChatMode.allCases) { chatMode in
                    Text(chatMode.rawValue).tag(chatMode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 220)

            Label(executionState.title, systemImage: executionState.systemImage)
                .font(.caption.weight(.medium))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(.quaternary, in: Capsule())
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
    }

    private var conversation: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                if messages.isEmpty {
                    ContentUnavailableView {
                        Label("Start a conversation", systemImage: "bubble.left.and.bubble.right")
                    } description: {
                        Text("Choose ASK or PLAN, then enter a prompt for SUPRA.")
                    }
                    .frame(maxWidth: .infinity, minHeight: 330)
                } else {
                    ForEach(messages) { message in
                        messageRow(message)
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: 900)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func messageRow(_ message: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .user {
                Spacer(minLength: 80)
            }

            Image(systemName: message.role == .user ? "person.crop.circle.fill" : "bolt.horizontal.circle.fill")
                .font(.title2)
                .foregroundStyle(message.role == .user ? Color.accentColor : .secondary)

            VStack(alignment: .leading, spacing: 5) {
                Text(
                    message.role == .user
                        ? "YOU · \(message.mode.rawValue)"
                        : "SUPRA RUNTIME · \(message.mode.rawValue)"
                )
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(message.content)
                    .textSelection(.enabled)
            }
            .padding(14)
            .background(
                message.role == .user ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.10),
                in: RoundedRectangle(cornerRadius: 14)
            )

            if message.role == .runtime {
                Spacer(minLength: 80)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Ask SUPRA…", text: $prompt, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .padding(13)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.quaternary))
                .onSubmit(execute)

            Button(action: execute) {
                Label("Execute", systemImage: "paperplane.fill")
                    .font(.headline)
                    .padding(.horizontal, 8)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(trimmedPrompt.isEmpty || executionState == .running)
            .keyboardShortcut(.return, modifiers: [.command])
            .overlay {
                if executionState == .running {
                    ProgressView()
                        .controlSize(.small)
                }
            }
        }
        .padding(20)
        .background(.bar)
    }

    private var trimmedPrompt: String {
        prompt.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var statusColor: Color {
        switch executionState {
        case .success: .green
        case .error: .red
        default: .secondary
        }
    }

    private func execute() {
        guard !trimmedPrompt.isEmpty, executionState != .running else {
            return
        }

        let submittedPrompt = trimmedPrompt
        let submittedMode = mode

        messages.append(
            ChatMessage(
                role: .user,
                mode: submittedMode,
                content: submittedPrompt
            )
        )
        prompt = ""
        executionState = .running

        Task {
            do {
                let response = try await runtime.execute(
                    prompt: submittedPrompt,
                    mode: submittedMode
                )
                messages.append(
                    ChatMessage(
                        role: .runtime,
                        mode: submittedMode,
                        content: response
                    )
                )
                executionState = .success
            } catch {
                let detail = error.localizedDescription
                messages.append(
                    ChatMessage(
                        role: .runtime,
                        mode: submittedMode,
                        content: "Erreur runtime : \(detail)"
                    )
                )
                executionState = .error(detail)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SUPRAChatView()
    }
    .frame(width: 980, height: 680)
}
