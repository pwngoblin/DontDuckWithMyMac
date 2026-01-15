//
//  FullScreenOverlay.swift
//  DontDuckWithMyMac
//
//  Created by Péter Sipos on 2026. 01. 15..
//


import SwiftUI
import Combine
import IOKit.pwr_mgt // Import IOKit for sleep prevention

struct FullScreenOverlay: View {
    static let id = "FullScreenOverlay"
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Background
            BurnInSafeBackground()
            
            VStack(spacing: 40) {
                Image(systemName: "hand.raised.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .foregroundStyle(.red)
                
                Text(appState.message)
                    .font(.system(size: 60, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5) // Allow text to shrink if it's too long
                
                // Emergency Dismiss Instruction
                Text("(Double-click to dismiss if emergency)")
                    .font(.title3)
                    .foregroundStyle(.gray.opacity(0.6))
                    .padding(.top, 50)
            }
            .padding()
            
            // 3. The Magic: This invisible view grabs the window and forces it to be fullscreen
            WindowConfigurator { window in
                // Set the window level to ScreenSaver (High priority: covers Dock, Menu Bar, and other windows)
                window.level = .screenSaver
                
                // Remove all chrome
                window.styleMask = [.borderless]
                
                // Make background opaque black
                window.backgroundColor = .black
                window.isOpaque = true
                
                // Force it to cover the screen
                if let screen = window.screen {
                    window.setFrame(screen.frame, display: true)
                }
                
                // CRITICAL:
                // .canJoinAllSpaces: Ensures it appears on every desktop/space
                // .fullScreenAuxiliary: Allows it to appear ON TOP of other full-screen apps
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                
                // Optional: Hide cursor if you want
                // NSCursor.hide()
            }
        }
        .onTapGesture(count: 2) {
            ScreenOverlayManager.shared.dismissFromOverlay(appState: appState)
        }
        // Sync state when window appears
        .onAppear {
            appState.isShieldActive = true
            // Prevent sleep when shield is active
            SleepManager.shared.preventSleep()
        }
        
    }
}