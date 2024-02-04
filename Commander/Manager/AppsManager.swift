import AppKit
import Combine

// MARK: - AppsManagerError

enum AppsManagerError: Error {
    case maxCountReached
    case alreadyAdded
}

// MARK: - AppsManager

final class AppsManager {
    // MARK: Lifecycle

    init(bookmarksManager: BookmarksManager) {
        self.bookmarksManager = bookmarksManager

        try? addStoredAppsIfNeeded()
        apps.send(storedApps)
        apps.dropFirst().sink { [weak self] apps in
            self?.storedApps = apps
        }.store(in: &cancellables)
        appGroups.send(searcher.search())
    }

    // MARK: Internal

    static let maxAppsCount = 12

    let apps = CurrentValueSubject<[App], Never>([])
    let appGroups = CurrentValueSubject<[AppGroup], Never>([])

    func updateApps() {
        appGroups.send(searcher.search())
    }

    func open(app: App) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            switch app.kind {
            case .shortcut:
                searcher.shortcutsAppManager.run(app: app)
            case .file, .app, .link:
                NSWorkspace.shared.open(app.url)
            }
        }
    }

    func isLaunched(app: App) -> Bool {
        NSWorkspace.shared.runningApplications.contains {
            $0.bundleURL == app.url
        }
    }

    func recentApps() -> [App] {
        searcher.getRecentApps()
    }

    func add(appURL: URL) throws {
        guard apps.value.count < Self.maxAppsCount else {
            throw AppsManagerError.maxCountReached
        }
        if apps.value.map(\.url).contains(appURL) {
            throw AppsManagerError.alreadyAdded
        }
        let app = App(url: appURL)
        switch app.kind {
        case .file:
            try bookmarksManager.addToBookmarks(url: app.url)
        default:
            break // noop
        }
        apps.value.append(app)
    }

    // MARK: Private

    @UserDefault("apps.json") private var storedApps: [App] = []
    private let searcher = AppSearcher()
    private let bookmarksManager: BookmarksManager
    private var cancellables = Set<AnyCancellable>()

    private func addStoredAppsIfNeeded() throws {
        guard storedApps.isEmpty else {
            return
        }
        let allApps = searcher.search()
//        let recommendedApps = allApps.localApps.shuffled().prefix(6)
//        storedApps = Array(recommendedApps)
    }
}
