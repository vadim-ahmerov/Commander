import Combine
import SwiftUI

// MARK: - DIContainer

struct DIContainer {
    let appsManager: AppsManager
    let shortcutNotifier: ShortcutNotifier
    let imageProvider: ImageProvider
    let appRatingManager: AppRatingManager
}

// MARK: EnvironmentKey

extension DIContainer: EnvironmentKey {
    static var defaultValue = DIContainer(
        appsManager: AppsManager(bookmarksManager: BookmarksManager()),
        shortcutNotifier: ShortcutNotifier(),
        imageProvider: ImageProvider(),
        appRatingManager: AppRatingManager()
    )
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}
