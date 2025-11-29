//
//  AppDelegate.swift
//  DontDuckWithMyMac
//
//  Created by Péter Sipos on 2025. 11. 29..
//


import Foundation
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard sender.activationPolicy() != .accessory else {
            return .terminateNow
        }

        return quit(sender)
    }
    
    private func quit(_ app: NSApplication) -> NSApplication.TerminateReply {
        app.windows.filter { $0.title != "Item-0" }.forEach { $0.close() }
        app.setActivationPolicy(.accessory)
        return .terminateCancel
    }
}
