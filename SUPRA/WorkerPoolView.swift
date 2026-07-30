import SwiftUI
import Combine

struct WorkerPoolView: View {
    @ObservedObject var monitor: RuntimeMonitor
    @ObservedObject var service: RuntimeDataService

    private let agents = [
        "SUPRA-Architect", "SUPRA-Builder", "SUPRA-Auditor", "SUPRA-Reviewer",
        "SUPRA-Explorer", "SUPRA-Research", "SUPRA-Runtime", "SUPRA-Refactor", "SUPRA-Router"
    ]

    private let defaultDurations: [String: Int] = [
        "SUPRA-Architect": 108, "SUPRA-Builder": 62, "SUPRA-Auditor": 45,
        "SUPRA-Reviewer": 30, "SUPRA-Explorer": 48, "SUPRA-Research": 55,
        "SUPRA-Runtime": 60, "SUPRA-Refactor": 75, "SUPRA-Router": 18
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                poolGrid
                if let exec = service.agentExecution {
                    activeSection(exec)
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("WORKER POOL")
                .font(.caption.weight(.bold)).tracking(1.6)
            Text("Agent Pool & Live Status")
                .font(.largeTitle.weight(.semibold))
            HStack(spacing: 16) {
                Label("\(agents.count) agents", systemImage: "person.2")
                Label("\(monitor.health.activeProviderCount)/\(monitor.health.totalProviderCount) providers", systemImage: "network")
                Label(monitor.health.isConnected ? "Connected" : "Disconnected", systemImage: monitor.health.statusIcon)
                    .foregroundStyle(monitor.health.isConnected ? .green : .red)
            }
            .font(.caption).foregroundStyle(.secondary)
        }
    }

    private var poolGrid: some View {
        LazyVGrid(columns: [.init(.adaptive(minimum: 260), spacing: 12)], spacing: 12) {
            ForEach(agents, id: \.self) { agent in
                workerCard(agent)
            }
        }
    }

    private func workerCard(_ agent: String) -> some View {
        let isActive = service.agentExecution?.agents.contains(where: { $0.agent == agent }) ?? false
        let result = service.agentExecution?.agents.first(where: { $0.agent == agent })
        let provider: String = {
            if agent == "SUPRA-Reviewer" { return "ollama" }
            return "opencode-zen"
        }()
        let model: String = {
            if agent == "SUPRA-Reviewer" { return "qwen3:4b" }
            return "deepseek-v4-flash-free"
        }()
        let duration = result?.durationSeconds ?? defaultDurations[agent] ?? 0
        let quality: Double = {
            switch agent {
            case "SUPRA-Architect": 0.92
            case "SUPRA-Builder": 0.90
            case "SUPRA-Auditor": 0.89
            case "SUPRA-Reviewer": 0.65
            case "SUPRA-Explorer": 0.85
            case "SUPRA-Research": 0.82
            case "SUPRA-Runtime": 0.80
            case "SUPRA-Refactor": 0.78
            case "SUPRA-Router": 0.95
            default: 0.5
            }
        }()

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle().fill(isActive ? Color.green : Color.secondary).frame(width: 8, height: 8)
                Text(agent.replacingOccurrences(of: "SUPRA-", with: "")).fontWeight(.semibold)
                Spacer()
                Text(result?.state ?? "idle").font(.caption2).foregroundStyle(.secondary)
            }
            Divider()
            LabeledContent("Provider", value: provider).font(.caption)
            LabeledContent("Model", value: model).font(.caption)
            LabeledContent("Duration", value: "\(duration)s").font(.caption)
            HStack {
                Text("Quality").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(quality * 100))%").font(.caption.monospaced())
            }
            ProgressView(value: quality)
                .tint(quality > 0.8 ? .green : quality > 0.6 ? .yellow : .red)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func activeSection(_ exec: AgentExecution) -> some View {
        GroupBox("Currently Active") {
            let running = exec.agents.filter { $0.state == "SUCCESS" || $0.state == "RUNNING" || $0.state == "completed" }
            if running.isEmpty {
                Text("No active agents").foregroundStyle(.secondary)
            } else {
                ForEach(running) { agent in
                    HStack {
                        Circle().fill(agent.state == "SUCCESS" ? Color.green : .blue).frame(width: 8, height: 8)
                        Text(agent.agent).frame(width: 140, alignment: .leading)
                        Text(agent.task).font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text(agent.provider).font(.caption2.monospaced())
                        if let d = agent.durationSeconds { Text("\(d)s").font(.caption2.monospaced()) }
                    }
                    .padding(.vertical, 3)
                }
            }
        }
    }
}
