import SwiftUI
import Combine

struct MissionGraphView: View {
    @ObservedObject var service: RuntimeDataService

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 24) {
                header
                if let trace = service.delegationTrace {
                    dagCanvas(trace)
                    dagLegend
                } else {
                    ContentUnavailableView("No graph data", systemImage: "point.connected", description: Text("Run a mission graph to visualize."))
                }
            }
            .padding(32)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("MISSION GRAPH")
                .font(.caption.weight(.bold)).tracking(1.6)
            Text("Directed Acyclic Graph")
                .font(.largeTitle.weight(.semibold))
            if let trace = service.delegationTrace {
                Text("\(trace.delegations.count) tasks · \(trace.mission)")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func dagCanvas(_ trace: DelegationTrace) -> some View {
        let nodes = trace.delegations
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
                HStack(spacing: 16) {
                    dagNode(node)
                    if index < nodes.count - 1 {
                        VStack(spacing: 0) {
                            Rectangle().fill(.tertiary).frame(width: 2, height: 24)
                            Image(systemName: "arrowtriangle.down.fill").font(.caption2).foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func dagNode(_ del: Delegation) -> some View {
        HStack(spacing: 12) {
            statusIcon(del.status)
            VStack(alignment: .leading, spacing: 2) {
                Text(del.taskName).fontWeight(.medium)
                HStack(spacing: 8) {
                    Label(del.agent, systemImage: "person").font(.caption2)
                    Label(del.provider, systemImage: "network").font(.caption2)
                    Label(del.model, systemImage: "cpu").font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                if let d = del.durationSeconds { Text("\(d)s").font(.caption.monospaced()) }
                Text(del.status).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: 600)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.35), lineWidth: 0.5))
    }

    private func statusIcon(_ status: String) -> some View {
        let color: Color = {
            switch status {
            case "completed", "completed_parallel", "SUCCESS": .green
            case "dispatched", "running": .blue
            case "pending_blocked", "FAILED": .red
            default: .gray
            }
        }()
        return Circle().fill(color).frame(width: 12, height: 12)
    }

    private var dagLegend: some View {
        HStack(spacing: 24) {
            Label("Completed", systemImage: "circle.fill").foregroundStyle(.green).font(.caption)
            Label("Running", systemImage: "circle.fill").foregroundStyle(.blue).font(.caption)
            Label("Blocked", systemImage: "circle.fill").foregroundStyle(.red).font(.caption)
        }
    }
}
