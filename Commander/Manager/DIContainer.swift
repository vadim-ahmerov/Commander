import Combine
import SwiftUI

// MARK: - DIContainer

final class DIContainer {
    // MARK: Lifecycle

    init(statusItem: NSStatusItem) {
        appsManager = AppsManager(bookmarksManager: BookmarksManager())
        shortcutNotifier = ShortcutNotifier()
        imageProvider = ImageProvider()
        appRatingManager = AppRatingManager()
        menuBarItemManager = MenuBarItemManager(statusItem: statusItem)
        autoLaunchManager = AutoLaunchManager()
        dockIconManager = DockIconManager()
    }

    // MARK: Internal

    static var shared: DIContainer {
        guard let appDelegate = NSApp.delegate as? AppDelegate else {
            fatalError()
        }
        return appDelegate.diContainer
    }

    let appsManager: AppsManager
    let shortcutNotifier: ShortcutNotifier
    let imageProvider: ImageProvider
    let appRatingManager: AppRatingManager
    let menuBarItemManager: MenuBarItemManager
    let dockIconManager: DockIconManager
    let autoLaunchManager: AutoLaunchManager
}
