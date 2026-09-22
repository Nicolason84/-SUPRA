
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

    private let retiredBundleIdentifiers: Set<String> = [
        "supra.clean.recomposition.v1"
    ]

    private let retiredProcessNames: Set<String> = [
        "SUPRAClean",
        "OjoCompanion",
        "ChatGPT"
    ]

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard enforceCanonicalSingleInstance() else { return }
        retireNoncanonicalSurfaces()
        NSApp.activate(ignoringOtherApps: true)
    }

    @discardableResult
    private func enforceCanonicalSingleInstance() -> Bool {
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
            return false
        }

        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return true
        }

        let live = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleIdentifier)
            .filter { !$0.isTerminated }

        guard live.count > 1 else {
            return true
        }

        // Canonical instance wins. If more than one canonical process exists,
        // keep the oldest process and terminate only the duplicates.
        let canonical = live.filter {
            $0.bundleURL?.standardizedFileURL.path == canonicalBundleURL.path
        }

        let keeper = (canonical.isEmpty ? live : canonical)
            .min { $0.processIdentifier < $1.processIdentifier }

        guard let keeper else {
            return true
        }

        for application in live
        where application.processIdentifier != keeper.processIdentifier {
            _ = application.terminate()
        }

        if keeper.processIdentifier != current.processIdentifier {
            keeper.activate(options: [.activateIgnoringOtherApps])
            NSApp.terminate(nil)
            return false
        }

        return true
    }

    private func retireNoncanonicalSurfaces() {
        let currentPID = NSRunningApplication.current.processIdentifier

        for application in NSWorkspace.shared.runningApplications {
            guard !application.isTerminated,
                  application.processIdentifier != currentPID else {
                continue
            }

            let bundleID = application.bundleIdentifier ?? ""
            let name = application.localizedName ?? ""

            guard retiredBundleIdentifiers.contains(bundleID)
                    || retiredProcessNames.contains(name) else {
                continue
            }

            // User explicitly requested that legacy/auxiliary visible surfaces
            // close automatically once canonical SUPRA is ready.
            // This is graceful only: no forceTerminate / SIGKILL.
            _ = application.terminate()
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
