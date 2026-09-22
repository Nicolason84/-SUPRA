//
//  SUPRAApp.swift
//  SUPRA
//
//  Created by Nicolas Alonso on 17/07/2026.
//

import SwiftUI

@main
struct SUPRAApp: App {
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
