// DIContainer.swift
// Copyright (c) 2023 Vadim Ahmerov

import Combine
import SwiftUI

// MARK: - DIContainer

struct DIContainer {
    let appsManager: AppsManager
    let shortcutNotifier: ShortcutNotifier
    let bookmarksManager: BookmarksManager
    let imageProvider: ImageProvider
}

// MARK: EnvironmentKey

extension DIContainer: EnvironmentKey {
    static var defaultValue = DIContainer(
        appsManager: AppsManager(),
        shortcutNotifier: ShortcutNotifier(),
        bookmarksManager: BookmarksManager(),
        imageProvider: ImageProvider()
    )
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}
