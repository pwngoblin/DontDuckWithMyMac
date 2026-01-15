//
//  SleepManager.swift
//  DontDuckWithMyMac
//
//  Created by Péter Sipos on 2026. 01. 15..
//


import SwiftUI
import Combine
import IOKit.pwr_mgt // Import IOKit for sleep prevention

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