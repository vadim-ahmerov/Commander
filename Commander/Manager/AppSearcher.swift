// AppSearcher.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 28.07.2022.

import AppKit
import ApplicationServices
import Foundation

final class AppSearcher {
    // MARK: Internal

    struct SearchResult {
        let localApps: [App]
        let systemApps: [App]
        let utilities: [App]

        static let empty = Self(localApps: [], systemApps: [], utilities: [])

        var joined: [App] {
            localApps + systemApps + utilities
        }
    }

    func search() -> SearchResult {
        let localAppsURLs = readApplications(directory: .applicationDirectory, domain: .localDomainMask)
        let systemAppsURLs = readApplications(directory: .applicationDirectory, domain: .systemDomainMask)
        let utilitiesURLs = readApplications(
            directory: .applicationDirectory,
            domain: .systemDomainMask,
            subpath: "/Utilities"
        )
        return SearchResult(
            localApps: apps(at: localAppsURLs),
            systemApps: apps(at: systemAppsURLs),
            utilities: apps(at: utilitiesURLs)
        )
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
            apps
                .prefix(5)
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
        subpath: String = ""
    ) -> [URL] {
        let fileManager = FileManager()
        do {
            let folderUrl = try FileManager.default.url(for: directory, in: domain, appropriateFor: nil, create: false)
            guard let folderUrlWithSubpath = NSURL(string: folderUrl.path + subpath) as? URL else {
                return []
            }
            let applicationUrls = try fileManager.contentsOfDirectory(
                at: folderUrlWithSubpath,
                includingPropertiesForKeys: [],
                options: [
                    FileManager.DirectoryEnumerationOptions.skipsPackageDescendants,
                    FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants,
                ]
            )
            return applicationUrls
        } catch {
            return []
        }
    }
}
