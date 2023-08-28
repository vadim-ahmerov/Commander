import AppKit
import SwiftUI

final class DockIconManager {
    // MARK: Internal

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
            settingsWindow?.makeKeyAndOrderFront(nil)
        }
    }

    // MARK: Private

    @AppStorage(AppStorageKey.showDockIcon) private var showDockIcon = true
}
