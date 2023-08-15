import AppKit

// MARK: - AppMenuEditActions

@objc
protocol AppMenuEditActions {
    func redo(_ sender: AnyObject)
    func undo(_ sender: AnyObject)
}

// MARK: - AppMenu

final class AppMenu: NSMenu {
    // MARK: Lifecycle

    override init(title: String) {
        super.init(title: title)
        let menu = NSMenuItem()
        menu.submenu = NSMenu(title: "Main")
        menu.submenu?.items = Self.allItems()
        items = [menu]
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError()
    }

    // MARK: Internal

    static func allItems() -> [NSMenuItem] {
        [
            NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"),
            NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"),
            NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"),
            NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"),

            NSMenuItem(title: "Undo", action: #selector(AppMenuEditActions.undo(_:)), keyEquivalent: "z"),
            NSMenuItem(title: "Redo", action: #selector(AppMenuEditActions.redo(_:)), keyEquivalent: "Z"),

            NSMenuItem(title: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"),
            NSMenuItem(
                title: "Quit \(ProcessInfo.processInfo.processName)",
                action: #selector(NSApplication.shared.terminate(_:)),
                keyEquivalent: "q"
            ),
        ]
    }
}
