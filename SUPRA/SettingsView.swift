import SwiftUI
import Combine
import Foundation

struct SettingsView: View {
    @ObservedObject var service: RuntimeDataService
    @ObservedObject private var client = OpenCodeClient.shared
    @State private var runtimePath: String = ""

    private var runtimeVersion: String {
        SUPRARuntimeRegistry.shared.runtimeVersion
    }

    var body: some View {
        Form {
            Section("Runtime Configuration") {
                HStack {
                    TextField("Runtime Path", text: $runtimePath)
                        .font(.body.monospaced())
                        .onAppear { runtimePath = service.runtimePath }
                    Button("Browse") {
                        let panel = NSOpenPanel()
                        panel.canChooseDirectories = true
                        panel.canChooseFiles = false
                        panel.begin { response in
                            if response == .OK, let url = panel.url {
                                runtimePath = url.path
                                UserDefaults.standard.set(url.path, forKey: "runtimePath")
                            }
                        }
                    }
                }
            }

            Section("Runtime Mode") {
                Picker("Source", selection: Binding(
                    get: { client.sourceMode },
                    set: { client.setMode($0) }
                )) {
                    ForEach(RuntimeSourceMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                GroupBox("Connection") {
                    HStack {
                        Circle()
                            .fill(color(for: client.connectionState))
                            .frame(width: 10, height: 10)
                        Text(client.connectionState.rawValue)
                            .fontWeight(.medium)
                    }
                    Divider()
                    if let lastEvent = client.lastEventTimestamp {
                        LabeledContent("Last Event") { Text(lastEvent, style: .relative) }
                    } else {
                        LabeledContent("Last Event", value: "None")
                    }
                    if let lastSync = client.lastSyncTimestamp {
                        LabeledContent("Last Sync") { Text(lastSync, style: .relative) }
                    } else {
                        LabeledContent("Last Sync", value: "Never")
                    }
                    LabeledContent("Events", value: "\(client.events.count)")
                }
            }

            Section("Refresh") {
                HStack {
                    Button("Refresh Now") { client.refresh() }
                    Toggle("Auto Refresh", isOn: Binding(
                        get: { service.autoRefreshInterval > 0 },
                        set: { on in
                            service.autoRefreshInterval = on ? 30 : 0
                            if on { service.startAutoRefresh() }
                            else { service.stopAutoRefresh() }
                        }
                    ))
                }

                if service.autoRefreshInterval > 0 {
                    Slider(value: Binding(
                        get: { service.autoRefreshInterval },
                        set: { service.autoRefreshInterval = $0; service.startAutoRefresh() }
                    ), in: 5...300, step: 5) {
                        Text("Interval: \(Int(service.autoRefreshInterval))s")
                    }
                }
            }

            Section("About") {
                LabeledContent("Runtime Version", value: runtimeVersion)
                LabeledContent("Client Layer", value: "OpenCodeClient v1")
                LabeledContent("Source", value: client.sourceMode.rawValue)
                LabeledContent("Data Files", value: {
                    var count = 0
                    if service.runtimeTrace != nil { count += 1 }
                    if service.delegationTrace != nil { count += 1 }
                    if service.runtimeMetrics != nil { count += 1 }
                    if service.agentExecution != nil { count += 1 }
                    return "\(count)/4 loaded"
                }())
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .frame(maxWidth: 600, maxHeight: .infinity, alignment: .top)
        .padding()
    }

    private func color(for state: RuntimeConnectionState) -> Color {
        switch state {
        case .disconnected, .offline: .red
        case .connecting: .blue
        case .connected: .green
        case .degraded: .orange
        }
    }
}
