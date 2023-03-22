import Combine
import ServiceManagement
import StoreKit
import SwiftUI

// MARK: - AppDelegate

final class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: Lifecycle

    override init() {
        diContainer = .defaultValue
        window = Self.makeWindow(diContainer: diContainer)
        popover = Self.makePopover(diContainer: diContainer)
        statusItem = Self.makeStatusItem()
        super.init()
    }

    // MARK: Internal

    let window: NSWindow

    func applicationDidFinishLaunching(_: Notification) {
        try? diContainer.bookmarksManager.restoreAllBookmarks()

        diContainer.shortcutNotifier.$shortcutTriggered.sink { [weak self] isTriggered in
            self?.shortcutStateUpdated(isTriggered: isTriggered)
        }.store(in: &cancellables)
        openSettingsIfNeeded()
        NSApplication.shared.mainMenu = AppMenu()
        configureAutoLaunch()

//        #if DEBUG
//        openSettings()
//        #endif
    }

    // MARK: Private

    @UserDefault("first launch") private var firstLaunch = true

    private let diContainer: DIContainer
    private var cancellables = Set<AnyCancellable>()
    private let popover: NSPopover
    private let statusItem: NSStatusItem

    private lazy var settingsWindow = AppDelegate.makeSettingsWindow(diContainer: diContainer)

    private static func makeWindow(diContainer: DIContainer) -> NSWindow {
        let window = NSWindow(
            contentViewController: NSHostingController(
                rootView: CommanderView().environment(\.injected, diContainer)
            )
        )
        window.level = .modalPanel
        window.isReleasedWhenClosed = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask = [.borderless, .fullSizeContentView]
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.toolbarButton)?.isHidden = true
        window.backgroundColor = .clear
        window.hasShadow = false
        window.isOpaque = false
        if #available(macOS 13.0, *) {
            window.collectionBehavior = [
                .auxiliary,
                .moveToActiveSpace,
                .stationary,
                .fullScreenAuxiliary,
                .ignoresCycle,
            ]
        } else {
            window.collectionBehavior = .canJoinAllSpaces
        }
        return window
    }

    private static func makePopover(diContainer: DIContainer) -> NSPopover {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: CommanderView().environment(\.injected, diContainer)
        )
        return popover
    }

    private static func makeStatusItem() -> NSStatusItem {
        let statusBarItem = NSStatusBar.system
            .statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        statusBarItem.menu = NSMenu(title: "Menu")

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        let aboutItem = NSMenuItem(title: "About", action: #selector(openAbout), keyEquivalent: "")

        let rateAppItem = NSMenuItem(title: "Rate App", action: #selector(rateApp), keyEquivalent: "")
        let githubItem = NSMenuItem(title: "View on Github", action: #selector(viewGithub), keyEquivalent: "")

        let requestFeatureItem = NSMenuItem(title: "Request a Feature", action: #selector(requestFeature), keyEquivalent: "")
        let reportBugItem = NSMenuItem(title: "Report a Bug", action: #selector(reportBug), keyEquivalent: "")
        let contactUsItem = NSMenuItem(title: "Contact us", action: #selector(contactUs), keyEquivalent: "")

        [
            settingsItem,
            .separator(),
            requestFeatureItem,
            reportBugItem,
            contactUsItem,
            .separator(),
            rateAppItem,
            githubItem,
            .separator(),
            aboutItem,
            quitItem,
        ].forEach {
            statusBarItem.menu?.addItem($0)
        }

        if let button = statusBarItem.button {
            button.image = NSImage(named: "menu template")
            button.action = #selector(togglePopover)
        }

        return statusBarItem
    }

    private static func makeSettingsWindow(diContainer: DIContainer) -> NSWindow {
        let controller = NSHostingController(
            rootView: SettingsView().environment(\.injected, diContainer)
        )
        let window = NSWindow(contentViewController: controller)
        window.title = "Settings"
        window.titlebarAppearsTransparent = true
        window.styleMask = [
            .unifiedTitleAndToolbar,
            .fullSizeContentView,
            .closable,
            .miniaturizable,
            .resizable,
            .titled,
        ]
        window.toolbar?.isVisible = false
        window.titleVisibility = .hidden

        return window
    }

    private func configureAutoLaunch() {
        let launcherAppID = "com.va.commander.launcher"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == launcherAppID
        }

        SMLoginItemSetEnabled(launcherAppID as CFString, true)

        if isRunning {
            DistributedNotificationCenter.default()
                .post(name: .killLauncher, object: Bundle.main.bundleIdentifier!)
        }
    }

    private func openSettingsIfNeeded() {
        guard firstLaunch else {
            return
        }
        firstLaunch = false
        openSettings()
    }

    @objc
    private func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(
                    relativeTo: button.bounds,
                    of: button,
                    preferredEdge: .minY
                )
            }
        }
    }

    private func shortcutStateUpdated(isTriggered: Bool) {
        if window.isVisible == isTriggered {
            return
        }
        window.setIsVisible(isTriggered)
        if isTriggered {
            window.orderFrontRegardless()
            window.setFrameOrigin(
                NSEvent.mouseLocation.applying(.init(
                    translationX: -window.frame.width / 2,
                    y: -window.frame.height / 2
                ))
            )
            window.makeCompletelyVisibleIfNeeded()
        }
    }
}

extension AppDelegate {
    private static func makeWindow<Content: View>(title: String, swiftUIView: Content, diContainer: DIContainer) -> NSWindow {
        let controller = NSHostingController(
            rootView: swiftUIView.environment(\.injected, diContainer)
        )
        let window = NSWindow(contentViewController: controller)
        window.title = title
        return window
    }

    @objc
    private func quit() {
        NSApp.terminate(nil)
    }

    @objc
    private func openSettings() {
        diContainer.appsManager.updateApps()
        settingsWindow.makeKeyAndOrderFront(nil)
        settingsWindow.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc
    private func openAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel()
    }

    @objc
    private func rateApp() {
        diContainer.appRatingManager.openRatePage()
    }

    @objc
    private func viewGithub() {
        if let url = URL(string: "https://github.com/vadim-ahmerov/Commander") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc
    private func requestFeature() {
        let window = Self.makeWindow(
            title: "Request a Feature",
            swiftUIView: SendFeedbackView(),
            diContainer: diContainer
        )
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc
    private func reportBug() {
        let window = Self.makeWindow(
            title: "Report a Bug",
            swiftUIView: SendFeedbackView(),
            diContainer: diContainer
        )
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc
    private func contactUs() {
        let window = Self.makeWindow(
            title: "Contact us",
            swiftUIView: SendFeedbackView(),
            diContainer: diContainer
        )
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
}
