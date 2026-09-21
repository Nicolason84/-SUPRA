import SwiftUI

enum ChatMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case ask = "ASK"
    case plan = "PLAN"

    var id: Self { self }

    var label: String {
        switch self {
        case .ask: return "Demander"
        case .plan: return "Planifier"
        }
    }
}

struct ChatMessage: Identifiable, Equatable, Codable, Sendable {
    enum Role: String, Codable, Sendable {
        case user
        case runtime
    }

    let id: UUID
    let role: Role
    let mode: ChatMode
    let content: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        role: Role,
        mode: ChatMode,
        content: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.mode = mode
        self.content = content
        self.createdAt = createdAt
    }
}

enum SUPRAChatExecutionState: Equatable {
    case idle
    case running
    case success
    case error(String)

    var title: String {
        switch self {
        case .idle: "Prêt"
        case .running: "Réflexion…"
        case .success: "Terminé"
        case .error: "Erreur"
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
        case .checking: "Connexion…"
        case .connected: "Local connecté"
        case .unavailable: "Local indisponible"
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
    @State private var mode: ChatMode = .ask
    @State private var prompt = ""
    @StateObject private var memory = SUPRAChatMemoryStore()
    @State private var executionState: SUPRAChatExecutionState = .idle
    @State private var runtimeHealth: SUPRAChatRuntimeHealthState = .checking
    @State private var healthTask: Task<Void, Never>?
    @State private var executionTask: Task<Void, Never>?
    @FocusState private var composerFocused: Bool

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
            composer
        }
        .background(
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color.black.opacity(0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("Chat")
        .onAppear {
            memory.refreshLongMemorySource()
            checkRuntimeHealth()
            composerFocused = true
        }
        .onDisappear {
            healthTask?.cancel()
            executionTask?.cancel()
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CONVERSATION")
                    .font(.caption2.weight(.bold))
                    .tracking(1.6)
                    .foregroundStyle(.secondary)

                Text("Parler à SUPRA · ojO")
                    .font(.system(size: 27, weight: .semibold, design: .rounded))

                Text("Une conversation, le contexte du système et les capacités locales.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Picker("Mode", selection: $mode) {
                ForEach(ChatMode.allCases) { chatMode in
                    Text(chatMode.label).tag(chatMode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 190)

            memoryPill
            statusPill
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
    }

    private var memoryPill: some View {
        HStack(spacing: 7) {
            Image(systemName: memory.longMemorySource == "Conversation locale"
                ? "externaldrive"
                : "brain.head.profile")
                .foregroundStyle(memory.longMemorySource == "Conversation locale" ? .secondary : .cyan)

            Text("Mémoire · \(memory.messages.count)")
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(.thinMaterial, in: Capsule())
        .help("Conversation persistante · " + memory.longMemorySource)
    }

    private var statusPill: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(runtimeHealth.color)
                .frame(width: 7, height: 7)
            Text(runtimeHealth.title)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(.thinMaterial, in: Capsule())
        .help(runtimeHealthHelp)
    }

    private var runtimeHealthHelp: String {
        switch runtimeHealth {
        case .checking:
            return "Vérification du runtime local."
        case .connected:
            return "Le runtime local répond."
        case .unavailable(let detail):
            return detail
        }
    }

    private var conversation: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    if memory.messages.isEmpty {
                        emptyConversation
                    } else {
                        ForEach(memory.messages) { message in
                            messageRow(message)
                                .id(message.id)
                        }
                    }

                    Color.clear
                        .frame(height: 1)
                        .id("CHAT_BOTTOM")
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .frame(maxWidth: 940)
                .frame(maxWidth: .infinity)
            }
            .onChange(of: memory.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo("CHAT_BOTTOM", anchor: .bottom)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyConversation: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 70)

            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 38))
                .foregroundStyle(.cyan)

            VStack(spacing: 6) {
                Text("Commence ici.")
                    .font(.title2.weight(.semibold))
                Text("Demande un état, une explication, un diagnostic ou un plan.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 8) {
                starter("État de la France")
                starter("Que dois-je regarder ?")
                starter("Explique ce qui change")
            }

            if case .unavailable(let detail) = runtimeHealth {
                HStack(spacing: 10) {
                    Image(systemName: "bolt.horizontal.circle")
                        .foregroundStyle(.orange)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Réessayer", action: checkRuntimeHealth)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                .padding(12)
                .background(.orange.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
            }

            Spacer(minLength: 70)
        }
        .frame(maxWidth: .infinity, minHeight: 420)
    }

    private func starter(_ text: String) -> some View {
        Button {
            prompt = text
            composerFocused = true
        } label: {
            Text(text)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }

    private func messageRow(_ message: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .user {
                Spacer(minLength: 90)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
                Text(
                    message.role == .user
                        ? "VOUS · \(message.mode.label.uppercased())"
                        : "SUPRA · ojO"
                )
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

                Text(message.content)
                    .textSelection(.enabled)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(
                        message.role == .user
                            ? Color.cyan.opacity(0.12)
                            : Color.white.opacity(0.055),
                        in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(.white.opacity(0.06), lineWidth: 1)
                    }
            }

            if message.role == .runtime {
                Spacer(minLength: 90)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var composer: some View {
        VStack(spacing: 0) {
            if executionState == .running {
                ProgressView()
                    .progressViewStyle(.linear)
            }

            HStack(alignment: .bottom, spacing: 10) {
                TextField("Écris à SUPRA / ojO…", text: $prompt, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...6)
                    .focused($composerFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                composerFocused ? Color.cyan.opacity(0.45) : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    }
                    .onSubmit(execute)

                Button(action: execute) {
                    Image(systemName: "arrow.up")
                        .font(.headline.weight(.bold))
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    trimmedPrompt.isEmpty
                    || executionState == .running
                    || !runtimeHealth.isConnected
                )
                .keyboardShortcut(.return, modifiers: [.command])
                .help("Envoyer · ⌘↩")
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 14)

            HStack(spacing: 10) {
                Label(mode.label, systemImage: mode == .ask ? "questionmark.bubble" : "list.bullet.rectangle")
                Text("·")
                Text(executionState.title)
                Spacer()
                if !memory.messages.isEmpty {
                    Button("Effacer le fil") {
                        memory.clearConversation()
                        executionState = .idle
                    }
                    .buttonStyle(.plain)
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
        }
        .background(.ultraThinMaterial)
    }

    private var trimmedPrompt: String {
        prompt.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func execute() {
        guard !trimmedPrompt.isEmpty,
              executionState != .running,
              runtimeHealth.isConnected else {
            return
        }

        let submittedPrompt = trimmedPrompt
        let submittedMode = mode

        let conversationContext = memory.contextTail()

        memory.append(
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
                let longMemory = await SUPRAChatLongMemory.retrieve(submittedPrompt)
                let enrichedPrompt = buildMemoryAwarePrompt(
                    userPrompt: submittedPrompt,
                    conversationContext: conversationContext,
                    longMemory: longMemory
                )

                let response = try await runtime.execute(
                    prompt: enrichedPrompt,
                    mode: submittedMode
                )
                try Task.checkCancellation()
                memory.append(
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
                memory.append(
                    ChatMessage(
                        role: .runtime,
                        mode: submittedMode,
                        content: "Erreur runtime : \(detail)"
                    )
                )
                executionState = .error(detail)
                checkRuntimeHealth()
            }

            composerFocused = true
        }
    }

    private func buildMemoryAwarePrompt(
        userPrompt: String,
        conversationContext: String,
        longMemory: SUPRAChatMemoryPacket
    ) -> String {
        let shortContext = conversationContext.isEmpty
            ? "NO_PRIOR_TURNS"
            : conversationContext

        return """
        SUPRA_CHAT_MEMORY_CONTEXT_V1

        RULES:
        - Use the current conversation first.
        - Use long memory as read-only context.
        - Historical memory is not current machine truth unless supported by current evidence.
        - Preserve contradictions instead of silently resolving them.
        - Do not ask Nicolas to repeat information already present in the supplied memory packet.

        [CURRENT_CONVERSATION]
        \(shortContext)

        \(longMemory.contextText)

        [CURRENT_USER_REQUEST]
        \(userPrompt)
        """
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
                runtimeHealth = .unavailable(error.localizedDescription)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SUPRAChatView()
    }
    .frame(width: 1040, height: 760)
    .preferredColorScheme(.dark)
}
