import SwiftUI

struct RuntimeView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState

    var body: some View {
        SUPRAOSCard(
            title: "Runtime",
            subtitle: state.runtimeSection.map { $0.isConnected ? "Connected" : "Disconnected" } ?? "—",
            icon: "cpu",
            color: state.runtimeSection?.isConnected == true ? .supraGreen : .supraRed
        ) {
            if let runtime = state.runtimeSection {
                VStack(spacing: 8) {
                    row("Agents", value: "\(runtime.agentCount)")
                    row("Active Missions", value: "\(runtime.activeMissions)")
                    row("Last Sync", value: runtime.lastSync)
                    Divider().background(Color.supraBorder)
                    connectionBadge(runtime.connectionState)
                    if runtime.gatewayConnected {
                        HStack(spacing: 12) {
                            VStack(spacing: 2) {
                                Text("\(runtime.gatewayActiveMissions)").font(.system(size: 13, weight: .bold)).foregroundColor(.supraAccent)
                                Text("GW Missions").font(.system(size: 9)).foregroundColor(.supraTextTertiary)
                            }
                            VStack(spacing: 2) {
                                Text("\(runtime.gatewayActiveWorkers)").font(.system(size: 13, weight: .bold)).foregroundColor(.supraAccent)
                                Text("GW Workers").font(.system(size: 9)).foregroundColor(.supraTextTertiary)
                            }
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                    if !runtime.events.isEmpty {
                        Divider().background(Color.supraBorder)
                        Text("Recent Events")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.supraTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(runtime.events.prefix(4)) { event in
                            HStack(spacing: 6) {
                                Image(systemName: event.type.icon)
                                    .font(.system(size: 9))
                                    .foregroundColor(eventColor(event.type))
                                Text(event.title)
                                    .font(.system(size: 10))
                                    .foregroundColor(.supraText)
                                    .lineLimit(1)
                                Spacer()
                                Text(event.timestamp.formatted(date: .omitted, time: .shortened))
                                    .font(.system(size: 9))
                                    .foregroundColor(.supraTextTertiary)
                            }
                        }
                    }
                }
            } else {
                Text("Runtime not initialized")
                    .font(.system(size: 12))
                    .foregroundColor(.supraTextTertiary)
            }
        }
    }

    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 11)).foregroundColor(.supraTextSecondary)
            Spacer()
            Text(value).font(.system(size: 11, weight: .medium)).foregroundColor(.supraText)
        }
    }

    private func connectionBadge(_ state: RuntimeConnectionState) -> some View {
        HStack(spacing: 4) {
            Circle().fill(connectionColor(state)).frame(width: 6, height: 6)
            Text(state.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(connectionColor(state))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(connectionColor(state).opacity(0.12))
        .clipShape(Capsule())
    }

    private func connectionColor(_ state: RuntimeConnectionState) -> Color {
        switch state {
        case .connected: .supraGreen
        case .connecting: .supraBlue
        case .degraded: .supraOrange
        case .disconnected, .offline: .supraRed
        }
    }

    private func eventColor(_ type: RuntimeEventType) -> Color {
        switch type {
        case .error, .validationFailed: .supraRed
        case .validationPassed, .executionCompleted, .missionCompleted: .supraGreen
        case .info, .missionCreated: .supraBlue
        case .executionStarted, .agentSelected: .supraTeal
        default: .supraTextSecondary
        }
    }
}
