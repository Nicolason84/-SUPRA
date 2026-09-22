//
//  SUPRAApp.swift
//  SUPRA
//
//  Created by Nicolas Alonso on 17/07/2026.
//

import SwiftUI
import AppKit

@MainActor
final class SUPRASingleInstanceDelegate: NSObject, NSApplicationDelegate {
    private let canonicalBundleURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Applications/SUPRA.app")
        .standardizedFileURL

    func applicationDidFinishLaunching(_ notification: Notification) {
        enforceCanonicalSingleInstance()
    }

    private func enforceCanonicalSingleInstance() {
        let current = NSRunningApplication.current
        let currentBundleURL = Bundle.main.bundleURL.standardizedFileURL

        // Any legacy/alternate SUPRA bundle redirects immediately to the
        // one canonical installation. This prevents old app copies from
        // becoming a second visible SUPRA surface after restart/login.
        if currentBundleURL.path != canonicalBundleURL.path,
           FileManager.default.fileExists(atPath: canonicalBundleURL.path) {
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true

            NSWorkspace.shared.openApplication(
                at: canonicalBundleURL,
                configuration: configuration
            ) { _, _ in
                NSApp.terminate(nil)
            }
            return
        }

        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return
        }

        let live = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleIdentifier)
            .filter { !$0.isTerminated }

        guard live.count > 1 else {
            return
        }

        // Canonical instance wins. If more than one canonical process exists,
        // keep the oldest process and terminate only the duplicates.
        let canonical = live.filter {
            $0.bundleURL?.standardizedFileURL.path == canonicalBundleURL.path
        }

        let keeper = (canonical.isEmpty ? live : canonical)
            .min { $0.processIdentifier < $1.processIdentifier }

        guard let keeper else {
            return
        }

        for application in live
        where application.processIdentifier != keeper.processIdentifier {
            _ = application.terminate()
        }

        if keeper.processIdentifier != current.processIdentifier {
            keeper.activate(options: [.activateIgnoringOtherApps])
            NSApp.terminate(nil)
        }
    }
}

@main
struct SUPRAApp: App {
    @NSApplicationDelegateAdaptor(SUPRASingleInstanceDelegate.self)
    private var appDelegate

    var body: some Scene {
        Window("SUPRA", id: "main") {
            SUPRAOJOHomeView()
        }
        .defaultSize(width: 1440, height: 900)
        .commands {
            CommandGroup(replacing: .newItem) {
                EmptyView()
            }
        }
    }
}
