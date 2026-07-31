import SwiftUI
import Combine

struct SUPRACompanionMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
    let source: String
}

@MainActor
final class SUPRACompanionViewModel: ObservableObject {
    @Published var messages: [SUPRACompanionMessage] = []
    @Published var inputText = ""

    private let access = SUPRACanonicalWorldAccess.shared
    private let intelligence = SUPRAIntelligenceEngine.shared

    func sendMessage(_ text: String) {
        let msg = SUPRACompanionMessage(text: text, isUser: true, timestamp: Date(), source: "user")
        messages.append(msg)
        generateReply(to: text)
    }

    private func generateReply(to query: String) {
        let all = access.getAllStates()
        let eng = intelligence.state

        let reply: String
        let q = query.lowercased()

        if q.contains("status") || q.contains("health") {
            reply = """
            System status: \(all.globalHealth). CPU \(Int(all.resources.cpuUsage * 100))%, \
            RAM \(Int(all.resources.ramFraction * 100))%, Disk \(Int(all.resources.freeDiskGB))GB free. \
            \(all.missions.active) active missions, \(all.missions.blocked) blocked.
            """

        } else if q.contains("memory") || q.contains("source") || q.contains("cannonico") {
            reply = """
            CAnnoNico: \(all.cannonico.sourceCount) sources, \(all.cannonico.recoveredCount) recovered. \
            Projects: \(all.projects.totalProjects). Runtime: \(all.runtime.isConnected ? "connected" : "disconnected").
            """

        } else if q.contains("mission") || q.contains("task") || q.contains("proposal") {
            reply = """
            \(all.missions.total) missions total · \(all.missions.active) active · \(all.missions.blocked) blocked. \
            Queues: \(all.missions.autoQueue) auto · \(all.missions.supervisionQueue) supervision · \(all.missions.humanQueue) human.
            """

        } else if q.contains("suggest") || q.contains("what should") || q.contains("next") {
            if let action = eng.nextBestAction {
                reply = "Recommendation: \(action). System confidence Φ \(Int(eng.confidenceScore * 100))%."
            } else {
                reply = "No recommendations at this time. All systems nominal."
            }

        } else if q.contains("autonomy") || q.contains("control") || q.contains("authority") {
            let proposals = SUPRAMissionProposalEngine.shared
            let auto = proposals.autoQueue.count
            let total = max(proposals.proposals.count, 1)
            let level = Double(auto) / Double(total)
            reply = "Autonomy level \(Int(level * 100))%. \(auto) auto-execute proposals queued. \(proposals.humanQueue.count) require human approval."

        } else {
            reply = """
            I can help with: system status, memory sources, missions, suggestions, and autonomy control. \
            Try asking about any of these topics. Current health: \(all.globalHealth).
            """
        }

        let response = SUPRACompanionMessage(text: reply, isUser: false, timestamp: Date(), source: "SUPRA")
        messages.append(response)
    }
}

struct SUPRACompanionView: View {
    @StateObject private var model = SUPRACompanionViewModel()
    @EnvironmentObject private var state: SUPRACommandCenterState
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            SUPRAOSSectionHeader(title: "SUPRA Command Companion")
                .padding(.horizontal, SUPRAOSDesignSystem.padding)
                .padding(.vertical, SUPRAOSDesignSystem.spacingSmall)

            Divider().background(Color.supraBorder)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        welcomeMessage
                        ForEach(model.messages) { msg in
                            messageBubble(msg)
                        }
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(SUPRAOSDesignSystem.spacing)
                }
                .onChange(of: model.messages.count) {
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
            }

            Divider().background(Color.supraBorder)

            inputBar
        }
        .background(Color.supraBackground)
    }

    private var welcomeMessage: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("SUPRA Companion")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.supraAccent)
                Text("Ask me about system status, missions, memory sources, or what to do next.")
                    .font(.system(size: 11))
                    .foregroundColor(.supraTextSecondary)
            }
            .padding(12)
            .background(Color.supraSurface)
            .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
            .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
            Spacer()
        }
    }

    private func messageBubble(_ msg: SUPRACompanionMessage) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if msg.isUser { Spacer(minLength: 40) }
            if !msg.isUser {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.system(size: 10))
                    .foregroundColor(.supraAccent)
                    .frame(width: 20, height: 20)
                    .background(Color.supraAccent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            VStack(alignment: msg.isUser ? .trailing : .leading, spacing: 2) {
                Text(msg.text)
                    .font(.system(size: 11))
                    .foregroundColor(msg.isUser ? .supraText : .supraText)
                    .lineSpacing(3)
                HStack(spacing: 4) {
                    Text(msg.source)
                        .font(.system(size: 8))
                        .foregroundColor(.supraTextTertiary)
                    Text(msg.timestamp, style: .time)
                        .font(.system(size: 8))
                        .foregroundColor(.supraTextTertiary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(msg.isUser ? Color.supraAccent.opacity(0.2) : Color.supraSurfaceLight)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.supraBorder, lineWidth: msg.isUser ? 0 : 1))
            if msg.isUser {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.supraAccent)
            }
            if !msg.isUser { Spacer(minLength: 40) }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Ask SUPRA...", text: $model.inputText)
                .font(.system(size: 12))
                .textFieldStyle(.plain)
                .foregroundColor(.supraText)
                .focused($isFocused)
                .onSubmit(submit)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.supraSurface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.supraBorder, lineWidth: 1))
            SUPRAOSButton(title: "Send", icon: "arrow.up.circle.fill", color: .supraAccent, action: submit)
        }
        .padding(SUPRAOSDesignSystem.spacingSmall)
        .background(Color.supraSurface)
    }

    private func submit() {
        let text = model.inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        model.sendMessage(text)
        model.inputText = ""
    }
}
