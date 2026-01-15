//
//  WindowConfigurator.swift
//  DontDuckWithMyMac
//
//  Created by Péter Sipos on 2026. 01. 15..
//


import SwiftUI
import Combine
import IOKit.pwr_mgt // Import IOKit for sleep prevention

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