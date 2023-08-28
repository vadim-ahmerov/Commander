// MARK: - AppGroup

struct AppGroup {
    let name: String
    let apps: [App]
}

extension Collection where Element == AppGroup {
    var apps: [App] {
        flatMap(\.apps)
    }
}
