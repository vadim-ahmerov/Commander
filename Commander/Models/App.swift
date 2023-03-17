// App.swift
// Copyright (c) 2023 Vadim Ahmerov

import Foundation

// MARK: - App

struct App: Codable, Equatable, Hashable {
    let url: URL
    let name: String
}

// MARK: Identifiable

extension App: Identifiable {
    var id: URL {
        url
    }
}

extension App {
    enum Kind {
        case shortcut
        case general
    }

    var kind: Kind {
        switch url.scheme {
        case "shortcuts":
            return .shortcut
        default:
            return .general
        }
    }
}
