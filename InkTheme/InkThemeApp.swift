//
//  InkThemeApp.swift
//  InkTheme
//
//  Created by Qilei on 2026/9/9.
//

import InkTheme
import SwiftUI

@main
struct InkThemeApp: App {
    @State private var appearanceStore = InkAppearanceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appearanceStore)
                .inkAppearance(
                    appearanceStore.appearance,
                    accent: appearanceStore.accent,
                    ground: appearanceStore.ground,
                    radius: appearanceStore.radius
                )
                .inkKeyboardBar()
        }
    }
}
