//
//  AppState.swift
//  DontDuckWithMyMac
//
//  Created by Péter Sipos on 2026. 01. 15..
//

import SwiftUI
import Combine
import IOKit.pwr_mgt // Import IOKit for sleep prevention

class AppState: ObservableObject {
    @Published var message: String = "Do Not Duck With My Mac!! It's doing some shit you probably won't even understand, and I'll get really sad if it stops."
    // We track if the shield is active so the Menu Bar button can toggle it
    @Published var isShieldActive: Bool = false
}
