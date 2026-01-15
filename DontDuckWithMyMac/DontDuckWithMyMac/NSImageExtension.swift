//
//  NSImageExtension.swift
//  DontDuckWithMyMac
//
//  Created by Péter Sipos on 2026. 01. 15..
//

import SwiftUI
import Combine
import IOKit.pwr_mgt // Import IOKit for sleep prevention

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
