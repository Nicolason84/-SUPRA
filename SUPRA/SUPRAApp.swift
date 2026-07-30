//
//  SUPRAApp.swift
//  SUPRA
//
//  Created by Nicolas Alonso on 17/07/2026.
//

import SwiftUI

// @main moved to SUPRACommandCenterApp.swift
// kept for reference — remove if unused
//@main
struct SUPRAApp: App {
    @StateObject private var compositionRoot = SUPRACompositionRoot.shared

    var body: some Scene {
        WindowGroup {
            SUPRAOSProductRootView()
                .environmentObject(TwinUniverse.shared)
                .environmentObject(compositionRoot.runtimeDataService)
                .environmentObject(compositionRoot.missionStore)
                .environmentObject(compositionRoot.decisionStore)
                .environmentObject(compositionRoot.runtimeMonitor)
                .environmentObject(compositionRoot.eventBus)
                .environmentObject(compositionRoot.controlTowerState)
        }
    }
}
