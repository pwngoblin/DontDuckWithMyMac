//
//  ScreenOverlayManager.swift
//  DontDuckWithMyMac
//
//  Created by Sipos Peter on 2026. 01. 09..
//

import AppKit
import SwiftUI

@MainActor
final class ScreenOverlayManager {
    static let shared = ScreenOverlayManager()
    private var windows: [NSWindow] = []

    func showOverlays(appState: AppState) {
        closeOverlays()

        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )

            window.level = .screenSaver
            window.isOpaque = true
            window.backgroundColor = .black
            window.hasShadow = false
            window.ignoresMouseEvents = false

            window.collectionBehavior = [
                .canJoinAllSpaces,
                .fullScreenAuxiliary
            ]

            let hostingView = NSHostingView(
                rootView: FullScreenOverlay()
                    .environmentObject(appState)
            )

            hostingView.autoresizingMask = [.width, .height]
            window.contentView = hostingView

            window.orderFrontRegardless()
            windows.append(window)
        }
    }

    func dismissFromOverlay(appState: AppState) {
        appState.isShieldActive = false
        closeOverlays()
        SleepManager.shared.allowSleep()
    }

    func closeOverlays() {
        for window in windows {
            window.contentView = nil
            window.orderOut(nil)
        }
        windows.removeAll()
    }
}
