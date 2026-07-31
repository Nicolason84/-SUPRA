import SwiftUI

// MARK: - Boot Trace Instrumentation
// Structured, captureable startup markers (stdout) — Runtime Hang Investigation.
// Extended for Startup Timeline profiling: measure() logs BEGIN/END + duration.
enum BootTrace {
    static func mark(_ stage: String) {
        let ts = String(format: "%.3f", Date().timeIntervalSinceReferenceDate)
        print("[BOOT] \(stage) t=\(ts)")
        fflush(stdout)
    }

    static func measure(_ label: String, _ block: () async throws -> Void) async rethrows {
        let t0 = Date()
        let ts0 = String(format: "%.3f", t0.timeIntervalSinceReferenceDate)
        print("[BOOT] \(label)_BEGIN t=\(ts0)")
        fflush(stdout)
        try await block()
        let dt = (Date().timeIntervalSince(t0) * 1000)
        let ts1 = String(format: "%.3f", Date().timeIntervalSinceReferenceDate)
        print("[BOOT] \(label)_END t=\(ts1) duration=\(String(format: "%.1f", dt)) ms")
        fflush(stdout)
    }
}

@main
struct SUPRAOperationalCoreApp: App {
    @StateObject private var compositionRoot = SUPRACompositionRoot.shared
    @StateObject private var nucleo = SUPRANucleoOrchestrator.shared
    @StateObject private var state = SUPRACommandCenterState.shared
    @StateObject private var governor = SUPRAResourceGovernor.shared
    @StateObject private var snapshotStore = CAnnoNicoSnapshotStore.shared

    @State private var showSettings = false

    init() {
        BootTrace.mark("APP_START")
    }

    var body: some Scene {
        WindowGroup {
            SUPRAOSProductRootView()
                .environmentObject(state)
                .environmentObject(TwinUniverse.shared)
                .environmentObject(compositionRoot.runtimeDataService)
                .environmentObject(compositionRoot.missionStore)
                .environmentObject(compositionRoot.decisionStore)
                .environmentObject(compositionRoot.runtimeMonitor)
                .environmentObject(compositionRoot.eventBus)
                .environmentObject(compositionRoot.controlTowerState)
                .environmentObject(compositionRoot.executiveBootManager)
                .onAppear {
                    BootTrace.mark("ONAPPEAR_BEGIN")
                    nucleo.start()
                    BootTrace.mark("NUCLEO_STARTED")
                    governor.startMonitoring()
                    BootTrace.mark("GOVERNOR_STARTED")
                    compositionRoot.runtimeMonitor.start()
                    BootTrace.mark("MONITOR_STARTED")
                    compositionRoot.controlTowerState.load()
                    BootTrace.mark("TOWER_LOADED")
                    compositionRoot.loadRuntime()
                    BootTrace.mark("RUNTIME_LOADED")
                    state.configure(
                        towerState: compositionRoot.controlTowerState,
                        monitor: compositionRoot.runtimeMonitor
                    )
                    BootTrace.mark("STATE_CONFIGURED")
                    state.loadMissions()
                    BootTrace.mark("MISSIONS_LOADED")

                    // PROJECT PHOENIX — Activate the living executive runtime
                    // NOTE: Désactivé en contexte XCTest (TEST_HOST) pour éviter
                    // la contamination de l'état du singleton avant les tests.
                    // Voir ROOT_CAUSE_CERTIFICATION_OMEGA1.md — Hypothèse H1.
                    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
                        Task {
                            BootTrace.mark("PHOENIX_BOOT_BEGIN")
                            await PhoenixRuntime.shared.boot()
                            BootTrace.mark("PHOENIX_BOOT_COMPLETE")
                        }
                        BootTrace.mark("PHOENIX_BOOT_TASK_LAUNCHED")
                    }
                    BootTrace.mark("ONAPPEAR_COMPLETE")
                }
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1400, height: 900)
        .windowResizability(.contentMinSize)
        .commands {
            // MARK: - File Menu
            CommandGroup(after: .newItem) {
                Button("New Mission") {
                    NotificationCenter.default.post(name: .supraNewMission, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command])

                Divider()

                Button("Close Window") {
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut("w", modifiers: [.command])
            }

            CommandGroup(before: .saveItem) {
                Button("Save State") {
                    NotificationCenter.default.post(name: .supraSaveState, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command])
            }

            CommandGroup(after: .saveItem) {
                Divider()
                Button("Settings...") {
                    showSettings = true
                }
                .keyboardShortcut(",", modifiers: [.command])
            }

            // MARK: - Edit Menu
            CommandGroup(after: .pasteboard) {
                Divider()
                Button("Find") {
                    NotificationCenter.default.post(name: .supraSearch, object: nil)
                }
                .keyboardShortcut("f", modifiers: [.command])
            }

            CommandMenu("Navigation") {
                Button("Cockpit") {
                    NotificationCenter.default.post(name: .supraNavigate, object: "Cockpit")
                }
                .keyboardShortcut("1", modifiers: [.command])

                Button("Missions") {
                    NotificationCenter.default.post(name: .supraNavigate, object: "Mission Center")
                }
                .keyboardShortcut("3", modifiers: [.command])

                Button("Decisions") {
                    NotificationCenter.default.post(name: .supraNavigate, object: "Decision Center")
                }
                .keyboardShortcut("6", modifiers: [.command])

                Button("Runtime") {
                    NotificationCenter.default.post(name: .supraNavigate, object: "Runtime")
                }
                .keyboardShortcut("8", modifiers: [.command])

                Divider()

                Button("Back") {
                    NotificationCenter.default.post(name: .supraNavigateBack, object: nil)
                }
                .keyboardShortcut("[", modifiers: [.command])

                Button("Forward") {
                    NotificationCenter.default.post(name: .supraNavigateForward, object: nil)
                }
                .keyboardShortcut("]", modifiers: [.command])
            }

            // MARK: - View Menu
            CommandMenu("View") {
                Button("Toggle Sidebar") {
                    NotificationCenter.default.post(name: .supraToggleSidebar, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])

                Button("Toggle Inspector") {
                    NotificationCenter.default.post(name: .supraToggleInspector, object: nil)
                }
                .keyboardShortcut("i", modifiers: [.command])

                Divider()

                Button("Toggle Full Screen") {
                    NSApp.keyWindow?.toggleFullScreen(nil)
                }
                .keyboardShortcut("f", modifiers: [.command, .control])

                Divider()

                Button("Refresh") {
                    NotificationCenter.default.post(name: .supraRefresh, object: nil)
                }
                .keyboardShortcut("r", modifiers: [.command])
            }

            // MARK: - Window Menu
            CommandMenu("Window") {
                Button("Minimize") {
                    NSApp.keyWindow?.miniaturize(nil)
                }
                .keyboardShortcut("m", modifiers: [.command])

                Button("Zoom") {
                    NSApp.keyWindow?.zoom(nil)
                }
                .keyboardShortcut("m", modifiers: [.command, .shift])

                Divider()

                Button("Cycle Through Windows") {
                    NSApp.keyWindow?.makeKey()
                }
                .keyboardShortcut("`", modifiers: [.command])
            }

            // MARK: - Help Menu
            CommandMenu("Help") {
                Button("SUPRA Help") {
                    NSWorkspace.shared.open(URL(string: "https://supra-os.local/help")!)
                }
                .keyboardShortcut("?", modifiers: [.command, .shift])

                Divider()

                Button("About SUPRA Executive OS") {
                    NSApplication.shared.orderFrontStandardAboutPanel(nil)
                }
            }
        }
        // Settings available via ⌘, in menu bar
    }
}

// MARK: - Notification Names for Menu Actions

extension Notification.Name {
    static let supraNewMission = Notification.Name("supraNewMission")
    static let supraSaveState = Notification.Name("supraSaveState")
    static let supraSearch = Notification.Name("supraSearch")
    static let supraNavigate = Notification.Name("supraNavigate")
    static let supraNavigateBack = Notification.Name("supraNavigateBack")
    static let supraNavigateForward = Notification.Name("supraNavigateForward")
    static let supraToggleSidebar = Notification.Name("supraToggleSidebar")
    static let supraToggleInspector = Notification.Name("supraToggleInspector")
    static let supraRefresh = Notification.Name("supraRefresh")
}
