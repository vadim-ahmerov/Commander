import AppKit
import SwiftUI

final class MenuBarItemManager {
    // MARK: Lifecycle

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem

        statusItem.isVisible = showMenuBarItem
    }

    // MARK: Internal

    func set(isVisible: Bool) {
        statusItem.isVisible = isVisible
    }

    // MARK: Private

    private let statusItem: NSStatusItem
    @AppStorage(AppStorageKey.showMenuBarItem) private var showMenuBarItem = false
}
