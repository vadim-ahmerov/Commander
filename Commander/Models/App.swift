import Foundation

// MARK: - App

struct App: Codable, Equatable, Hashable {
    // MARK: Lifecycle

    init(url: URL, name: String) {
        self.url = url
        self.name = name
    }

    init(url: URL) {
        self.url = url
        switch url.kind {
        case .app:
            name = url.deletingPathExtension().lastPathComponent
        case .file, .shortcut:
            name = url.lastPathComponent
        case .link:
            name = url.host ?? url.absoluteString
        }
    }

    // MARK: Internal

    enum Kind: Decodable {
        case shortcut
        case app
        case file
        case link
    }

    let url: URL
    let name: String

    var kind: Kind {
        url.kind
    }
}

// MARK: Identifiable

extension App: Identifiable {
    var id: URL {
        url
    }
}

extension URL {
    fileprivate var kind: App.Kind {
        switch scheme {
        case "shortcuts":
            return .shortcut
        case "http", "https":
            return .link
        default:
            switch lastPathComponent {
            case "app":
                return .app
            default:
                return .file
            }
        }
    }
}
