//
//  DontDuckWithMyMacApp.swift
//  DontDuckWithMyMac
//
//  Created by Péter Sipos on 2025. 11. 29..
//

import SwiftUI
import Combine
import IOKit.pwr_mgt // Import IOKit for sleep prevention

// 1. Shared state to hold message and active status
class AppState: ObservableObject {
    @Published var message: String = "Do Not Duck With My Mac!! It's doing some shit you probably won't even understand, and I'll get sad if it stops."
    // We track if the shield is active so the Menu Bar button can toggle it
    @Published var isShieldActive: Bool = false
}

@main
struct DontDuckWithMyMacApp: App {
    @StateObject var appState = AppState()
    
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
                .frame(width: 250) // Give the popover a fixed width
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
        .menuBarExtraStyle(.window) // Uses the popover style you requested
    }
}

// Helper extension to resize NSImage safely
extension NSImage {
    func resizeMaintainingAspectRatio(to size: NSSize) -> NSImage? {
        let newSize = size
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: newSize),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: 1.0)
        newImage.unlockFocus()
        newImage.isTemplate = true // Ensure it treats it as a template (monochrome)
        return newImage
    }
}

// Helper view for Menu Bar to access OpenWindow environment
struct MenuBarControl: View {
    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 12) {
            Text("DontDuckWithMyMac")
                .font(.headline)
                .padding(.top, 8)
            
            Divider()
            
            Button(action: {
                if appState.isShieldActive {
                    appState.isShieldActive = false
                } else {
                    openWindow(id: FullScreenOverlay.id)
                }
            }) {
                Label(appState.isShieldActive ? "Deactivate Shield" : "Activate Shield",
                      systemImage: appState.isShieldActive ? "lock.open.fill" : "lock.fill")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(appState.isShieldActive ? .green : .red)
            .controlSize(.large)
            
            Button("Open Control Panel Window") {
                openWindow(id: "ControlPanel")
            }
            .buttonStyle(.link)
            .font(.caption)
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding()
    }
}

// 2. The View for the Fullscreen Shield
struct FullScreenOverlay: View {
    static let id = "FullScreenOverlay"
    
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .edgesIgnoringSafeArea(.all)
            
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
            // Trigger dismissal via state change
            appState.isShieldActive = false
        }
        // Sync state when window appears
        .onAppear {
            appState.isShieldActive = true
            // Prevent sleep when shield is active
            SleepManager.shared.preventSleep()
        }
        // Removed .onDisappear to prevent race conditions during window configuration
        // Listen for state changes to trigger dismiss
        .onChange(of: appState.isShieldActive) { newValue in
            if !newValue {
                // Allow sleep again
                SleepManager.shared.allowSleep()
                dismiss()
            }
        }
    }
}

// 4. The Control Panel View
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
                openWindow(id: FullScreenOverlay.id)
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

// 5. The Helper Helper: Accesses the underlying NSWindow from SwiftUI
struct WindowConfigurator: NSViewRepresentable {
    var configure: (NSWindow) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                self.configure(window)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // If the window changes (e.g. moves screens), re-configure if needed
        DispatchQueue.main.async {
            if let window = nsView.window {
                self.configure(window)
            }
        }
    }
}

// 6. Sleep Manager Helper
class SleepManager {
    static let shared = SleepManager()
    private var assertionID: IOPMAssertionID = 0
    private var success: IOReturn?
    
    func preventSleep() {
        // Prevent display sleep (which also prevents system sleep)
        // We use the string directly to ensure compatibility if constants aren't bridged
        let assertionType = "PreventUserIdleDisplaySleep" as CFString
        let reason = "DontDuckWithMyMac Shield Active" as CFString
        
        // Release any existing assertion just in case
        allowSleep()
        
        success = IOPMAssertionCreateWithName(
            assertionType,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )
    }
    
    func allowSleep() {
        if let success = success, success == kIOReturnSuccess {
            IOPMAssertionRelease(assertionID)
            self.success = nil
        }
    }
}
