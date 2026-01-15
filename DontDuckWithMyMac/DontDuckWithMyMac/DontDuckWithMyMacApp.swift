//
//  DontDuckWithMyMacApp.swift
//  DontDuckWithMyMac
//
//  Created by Péter Sipos on 2025. 11. 29..
//

import SwiftUI
import Combine
import IOKit.pwr_mgt // Import IOKit for sleep prevention

@main
struct DontDuckWithMyMacApp: App {
    @StateObject var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        // The Main Control Window (Optional now, since we have the menu bar window)
        WindowGroup("Control Panel", id: "ControlPanel") {
            ScreenOverlayControlView()
                .environmentObject(appState)
                .frame(minWidth: 300, minHeight: 200)
        }
        
        // The Fullscreen "Shield" Window
        WindowGroup(id: FullScreenOverlay.id) {
            FullScreenOverlay()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        
        // Menu Bar Extra for global control
        MenuBarExtra {
            // This is the content of the popover window
            MenuBarControl()
                .environmentObject(appState)
        } label: {
            // Robust Icon Loading:
            // 1. Try to load "menuicon"
            // 2. Resize it to 18x18 points (standard menu bar size) manually
            // 3. Set it to template mode
            // 4. Fallback to a system image if "menuicon" is missing
            let iconImage = NSImage(named: "menuicon")
            if let resizedIcon = iconImage?.resizeMaintainingAspectRatio(to: NSSize(width: 18, height: 18)) {
                Image(nsImage: resizedIcon)
                    .renderingMode(.template)
            } else {
                Image(systemName: "lock.shield")
            }
        }
    }
}
