//
//  ScreenOverlayControlView.swift
//  DontDuckWithMyMac
//
//  Created by Péter Sipos on 2026. 01. 15..
//


import SwiftUI
import Combine
import IOKit.pwr_mgt // Import IOKit for sleep prevention

struct ScreenOverlayControlView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Warning Message:")
                .font(.headline)
            
            TextEditor(text: $appState.message)
                .font(.title2)
                .frame(height: 100)
                .padding(4)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
            
            Button(action: {
                // If it's already active, we just ensure the window is open (brings to front)
                // If not, we open it.
                appState.isShieldActive = true
                ScreenOverlayManager.shared.showOverlays(appState: appState)
                SleepManager.shared.preventSleep()
            }, label: {
                HStack {
                    Image(systemName: appState.isShieldActive ? "checkmark.shield.fill" : "lock.shield")
                    Text(appState.isShieldActive ? "Shield Active" : "Activate Shield")
                }
                .font(.title3)
                .padding()
                .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .tint(appState.isShieldActive ? .green : .blue)
            .controlSize(.large)
            
            Text("Tip: You can also toggle this from the Menu Bar.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}