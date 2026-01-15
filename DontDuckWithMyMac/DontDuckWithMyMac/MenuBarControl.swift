//
//  MenuBarControl.swift
//  DontDuckWithMyMac
//
//  Created by Péter Sipos on 2026. 01. 15..
//

import SwiftUI
import Combine
import IOKit.pwr_mgt // Import IOKit for sleep prevention

struct MenuBarControl: View {
    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
            Button(action: {
                if appState.isShieldActive {
                    appState.isShieldActive = false
                    ScreenOverlayManager.shared.closeOverlays()
                    SleepManager.shared.allowSleep()
                } else {
                    appState.isShieldActive = true
                    ScreenOverlayManager.shared.showOverlays(appState: appState)
                    SleepManager.shared.preventSleep()
                }
            }) {
                Label(appState.isShieldActive ? "Deactivate Shield" : "Activate Shield",
                      systemImage: appState.isShieldActive ? "lock.shield.fill" : "lock.shield")
            }
                
        Button(action: {
            openWindow(id: "ControlPanel")

        }) {
            Label("Settings...",
                  systemImage: "gear")
            .frame(maxWidth: .infinity)
        }
        
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")

    }
}
