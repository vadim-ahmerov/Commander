import AppKit
import SwiftUI

final class MenuBarItemManager {
    private let statusItem: NSStatusItem
    @AppStorage(AppStorageKey.showMenuBarItem) private var showMenuBarItem = false

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem

        statusItem.isVisible = showMenuBarItem
    }

    func set(isVisible: Bool) {
        statusItem.isVisible = isVisible
    }
}
