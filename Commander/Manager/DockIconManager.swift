//
//  DockIconManager.swift
//  Commander
//
//  Created by Vadim Ahmerov on 28.08.2023.
//

import AppKit
import SwiftUI

final class DockIconManager {
    @AppStorage(AppStorageKey.showDockIcon) private var showDockIcon = true
    var settingsWindow: NSWindow? {
        didSet {
            updateIconVisibility()
        }
    }

    func updateIconVisibility() {
        if showDockIcon {
            NSApp.setActivationPolicy(.regular)
        } else {
            settingsWindow?.canHide = false
            NSApp.setActivationPolicy(.accessory)
            settingsWindow?.canHide = true
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
