import AppKit
import Combine

// MARK: - AppsManager

final class AppsManager {
    // MARK: Lifecycle

    init() {
        try? addStoredAppsIfNeeded()
        apps.send(storedApps)
        apps.dropFirst().sink { [weak self] apps in
            self?.storedApps = apps
        }.store(in: &cancellables)
        allApps.send(searcher.search())
    }

    // MARK: Internal

    let apps = CurrentValueSubject<[App], Never>([])
    let allApps = CurrentValueSubject<AppSearcher.SearchResult, Never>(.empty)

    func updateApps() {
        allApps.send(searcher.search())
    }

    func open(app: App) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            switch app.kind {
            case .shortcut:
                searcher.shortcutsAppManager.run(app: app)
            case .general:
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

    // MARK: Private

    @UserDefault("apps.json") private var storedApps: [App] = []
    private let searcher = AppSearcher()
    private var cancellables = Set<AnyCancellable>()

    private func addStoredAppsIfNeeded() throws {
        guard storedApps.isEmpty else {
            return
        }
        let allApps = searcher.search()
        let recommendedApps = allApps.localApps.shuffled().prefix(6)
        storedApps = Array(recommendedApps)
    }
}
