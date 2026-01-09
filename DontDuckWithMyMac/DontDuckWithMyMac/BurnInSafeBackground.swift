//
//  BurnInSafeBackground.swift
//  DontDuckWithMyMac
//
//  Created by Sipos Peter on 2026. 01. 09..
//

import SwiftUI

struct BurnInSafeBackground: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let hue = (t.truncatingRemainder(dividingBy: 60)) / 60

            Color(
                hue: hue,
                saturation: 0.4,
                brightness: 0.15
            )
            .ignoresSafeArea()
        }
    }
}
