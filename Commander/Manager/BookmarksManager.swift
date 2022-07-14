// BookmarksManager.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 28.07.2022.

import Foundation

final class BookmarksManager {
    // MARK: Internal

    /// Call this method to get persistent access for a given URL.
    func addToBookmarks(url: URL) throws {
        var bookmarks = try loadBookmarks()
        bookmarks[url] = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        try save(bookmarks: bookmarks)
    }

    /// Call this method on every app launch to reacquire access for all URLs.
    func restoreAllBookmarks() throws {
        var error: Error?

        for (url, bookmarkData) in try loadBookmarks() {
            var isStale = false
            let restoredUrl = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            let accessSucceeded = restoredUrl.startAccessingSecurityScopedResource()
            if !accessSucceeded {
                error = error ?? .accessFailed(url)
            }
            if isStale {
                error = error ?? .bookmarkDataIsStale(url)
            }
        }

        if let error = error {
            throw error
        }
    }

    // MARK: Private

    private enum Error: Swift.Error {
        case noDocumentsURL
        case bookmarkDataIsStale(URL)
        case accessFailed(URL)
    }

    private func save(bookmarks: [URL: Data]) throws {
        let bookmarksURL = try getBookmarksURL()
        let data = try JSONEncoder().encode(bookmarks)
        try data.write(to: bookmarksURL)
    }

    private func loadBookmarks() throws -> [URL: Data] {
        let bookmarksURL = try getBookmarksURL()
        let bookmarksDictionary = try? JSONDecoder().decode(
            [URL: Data].self,
            from: try Data(contentsOf: bookmarksURL)
        )
        return bookmarksDictionary ?? [:]
    }

    private func getBookmarksURL() throws -> URL {
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw Error.noDocumentsURL
        }
        url = url.appendingPathComponent("bookmarks.json")
        return url
    }
}
