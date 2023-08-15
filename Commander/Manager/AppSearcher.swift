import AppKit
import ApplicationServices
import Foundation

final class AppSearcher {
    enum SearchError: Error {
        case failedToInitializeFileEnumerator
    }

    // MARK: Internal

    let shortcutsAppManager = ShortcutsAppManager()

    func search() -> [AppGroup] {
        var groups = [AppGroup]()

        groups.append(contentsOf: readApplications(
            directory: .applicationDirectory,
            domain: .localDomainMask,
            parentPath: ["Local"]
        ))

        groups.append(AppGroup(
            name: "Shortcuts",
            apps: shortcutsAppManager.getShortcuts()
        ))

        if let finderURL = readFinderURL(), let finderApp = app(at: finderURL) {
            groups.append(AppGroup(name: "Core Services", apps: [finderApp]))
        }

        groups.append(contentsOf: readApplications(
            directory: .applicationDirectory,
            domain: .systemDomainMask,
            parentPath: ["System"]
        ))

        return groups
    }

    func getRecentApps() -> [App] {
        let applicationDirectory: URL
        do {
            applicationDirectory = try FileManager.default.url(
                for: .applicationDirectory,
                in: .localDomainMask,
                appropriateFor: nil,
                create: false
            )
        } catch {
            return []
        }
        let recentApps = NSWorkspace.shared.runningApplications

        let now = Date()
        let urls = recentApps
            .sorted { ($0.launchDate ?? now) > ($1.launchDate ?? now) }
            .compactMap { $0.bundleURL }
            .filter { $0.absoluteString.hasPrefix(applicationDirectory.absoluteString) }
        let apps = urls.compactMap { app(at: $0) }
        return Array(
            apps.prefix(5)
        )
    }

    // MARK: Private

    private func app(at url: URL) -> App? {
        let resourceKeys = [URLResourceKey.isExecutableKey, .isApplicationKey]
        let resourceValues = try? url.resourceValues(forKeys: Set(resourceKeys))
        if resourceValues?.isApplication == true, resourceValues?.isExecutable == true {
            let name = url.deletingPathExtension().lastPathComponent
            return App(url: url, name: name)
        } else {
            return nil
        }
    }

    private func apps(at urls: [URL]) -> [App] {
        urls.compactMap { url in
            app(at: url)
        }.sorted(by: \.name)
    }

    private func readApplications(
        directory: FileManager.SearchPathDirectory,
        domain: FileManager.SearchPathDomainMask,
        parentPath: [String]
    ) -> [AppGroup] {
        do {
            let directoryURL = try FileManager.default.url(
                for: directory,
                in: domain,
                appropriateFor: nil,
                create: false
            )
            return try readApplications(at: directoryURL, parentPath: parentPath)
        } catch {
            return []
        }
    }

    private func readApplications(at url: URL, parentPath: [String]) throws -> [AppGroup] {
        let childURLs = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: []
        )
        let appURLs = childURLs.filter { url in
            url.lastPathComponent.hasSuffix(".app")
        }
        let directoryURLs = childURLs.filter {
            $0.pathExtension.isEmpty && !$0.lastPathComponent.starts(with: ".")
        }

        let newPath = parentPath + [url.lastPathComponent]
        let childAppGroups = directoryURLs.compactMap { url in
            (try? readApplications(at: url, parentPath: newPath)) ?? []
        }.flatMap {
            $0
        }

        let appGroupPath = parentPath + [url.lastPathComponent]
        let appGroup = AppGroup(
            name: appGroupPath.joined(separator: " → "),
            apps: apps(at: appURLs)
        )
        let appGroups = [appGroup] + childAppGroups

        return appGroups.filter { group in
            !group.apps.isEmpty
        }
    }

    private func readFinderURL() -> URL? {
        guard let coreServicesURL = try? FileManager.default.url(
            for: .coreServiceDirectory,
            in: .systemDomainMask,
            appropriateFor: nil,
            create: false
        ) else {
            return nil
        }

        let finderURL = coreServicesURL.appendingPathComponent("Finder.app")
        let executableExists = FileManager.default.fileExists(atPath: finderURL.path)

        if executableExists {
            return finderURL
        } else {
            return nil
        }
    }
}
