import SwiftUI

enum ChatMode: String, CaseIterable, Identifiable, Codable {
    case ask = "ASK"
    case plan = "PLAN"

    var id: Self { self }
}

struct ChatMessage: Identifiable, Equatable, Codable {
    enum Role: String, Codable {
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

enum SUPRAChatRuntimeHealthState: Equatable {
    case checking
    case connected
    case unavailable(String)

    var title: String {
        switch self {
        case .checking: "Runtime · Checking"
        case .connected: "Runtime · Connected"
        case .unavailable: "Runtime · Unavailable"
        }
    }

    var systemImage: String {
        switch self {
        case .checking: "arrow.trianglehead.2.clockwise.rotate.90"
        case .connected: "checkmark.circle.fill"
        case .unavailable: "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .checking: .secondary
        case .connected: .green
        case .unavailable: .orange
        }
    }

    var isConnected: Bool {
        self == .connected
    }
}

struct SUPRAChatView: View {
    @AppStorage("supra.chat.mode.v1") private var storedMode = ChatMode.ask.rawValue
    @AppStorage("supra.chat.draft.v1") private var prompt = ""
    @AppStorage("supra.chat.messages.v1") private var messagesJSON = "[]"
    @State private var executionState: SUPRAChatExecutionState = .idle
    @State private var runtimeHealth: SUPRAChatRuntimeHealthState = .checking
    @State private var healthTask: Task<Void, Never>?
    @State private var executionTask: Task<Void, Never>?

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
            runtimeHealthMessage
            Divider()
            conversation
            Divider()
            composer
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("SUPRA Chat")
        .onAppear(perform: checkRuntimeHealth)
        .onDisappear {
            // Navigation between universes must not erase or cancel chat work.
            // Draft + conversation persist via AppStorage.
            healthTask?.cancel()
        }
    }

    private var header: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SUPRA CHAT")
                    .font(.caption.weight(.bold))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
                Text("Conversation workspace")
                    .font(.title2.bold())
            }

            Spacer()

            Picker("Chat mode", selection: modeBinding) {
                ForEach(ChatMode.allCases) { chatMode in
                    Text(chatMode.rawValue).tag(chatMode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 220)

            Label(runtimeHealth.title, systemImage: runtimeHealth.systemImage)
                .font(.caption.weight(.medium))
                .foregroundStyle(runtimeHealth.color)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(.quaternary, in: Capsule())

            Label(executionState.title, systemImage: executionState.systemImage)
                .font(.caption)
                .foregroundStyle(statusColor)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
    }

    @ViewBuilder
    private var runtimeHealthMessage: some View {
        if case .unavailable(let message) = runtimeHealth {
            HStack(spacing: 12) {
                Label(message, systemImage: "bolt.horizontal.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 8)

                Button("Retry", action: checkRuntimeHealth)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 14)
        }
    }

    private var conversation: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                if messages.isEmpty {
                    ContentUnavailableView {
                        Label("Start a conversation", systemImage: "bubble.left.and.bubble.right")
                    } description: {
                        Text("Use ASK to understand or PLAN to prepare work. Execute system work from the SUPRA universe.")
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
            .disabled(
                trimmedPrompt.isEmpty
                || executionState == .running
                || !runtimeHealth.isConnected
            )
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

    private var mode: ChatMode {
        ChatMode(rawValue: storedMode) ?? .ask
    }

    private var modeBinding: Binding<ChatMode> {
        Binding(
            get: { ChatMode(rawValue: storedMode) ?? .ask },
            set: { storedMode = $0.rawValue }
        )
    }

    private var messages: [ChatMessage] {
        guard let data = messagesJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) else {
            return []
        }
        return decoded
    }

    private func appendMessage(_ message: ChatMessage) {
        var updated = messages
        updated.append(message)
        guard let data = try? JSONEncoder().encode(updated),
              let json = String(data: data, encoding: .utf8) else {
            return
        }
        messagesJSON = json
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
        guard !trimmedPrompt.isEmpty,
              executionState != .running,
              runtimeHealth.isConnected else {
            return
        }

        let submittedPrompt = trimmedPrompt
        let submittedMode = mode

        appendMessage(
            ChatMessage(
                role: .user,
                mode: submittedMode,
                content: submittedPrompt
            )
        )
        prompt = ""
        executionState = .running

        executionTask = Task {
            do {
                let response = try await runtime.execute(
                    prompt: submittedPrompt,
                    mode: submittedMode
                )
                try Task.checkCancellation()
                appendMessage(
                    ChatMessage(
                        role: .runtime,
                        mode: submittedMode,
                        content: response
                    )
                )
                executionState = .success
            } catch is CancellationError {
                return
            } catch {
                let detail = error.localizedDescription
                appendMessage(
                    ChatMessage(
                        role: .runtime,
                        mode: submittedMode,
                        content: "Erreur runtime : \(detail)"
                    )
                )
                executionState = .error(detail)
                checkRuntimeHealth()
            }
        }
    }

    private func checkRuntimeHealth() {
        healthTask?.cancel()
        runtimeHealth = .checking

        healthTask = Task {
            do {
                try await runtime.checkHealth()
                try Task.checkCancellation()
                runtimeHealth = .connected
            } catch is CancellationError {
                return
            } catch {
                runtimeHealth = .unavailable(
                    "\(error.localizedDescription) Lancez le bridge, puis choisissez Retry."
                )
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
