import SwiftUI

extension SettingsView {
    struct ShortcutKeysView: View {
        // MARK: Internal

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Toggle("⌘", isOn: $isCommandEnabled)
                    Toggle("⌥", isOn: $isOptionEnabled)
                    Toggle("⌃", isOn: $isControlEnabled)
                    Toggle("⇧", isOn: $isShiftEnabled)
                    Toggle("fn", isOn: $isFunctionEnabled)
                }
                Toggle("Show only after mouse move", isOn: $showOnMouseMove)
                Toggle("Show menu bar icon", isOn: $showMenuBarItem)
                Toggle("Show dock icon", isOn: $showDockIcon)
                Toggle("Launch on Login", isOn: $launchOnLogin)
                Toggle("Enable Haptic Feedback", isOn: $hapticFeedbackEnabled)
            }.onChange(of: isOptionEnabled) { _ in
                diContainer.shortcutNotifier.modifiers = enabledModifiers
            }.onChange(of: isControlEnabled) { _ in
                diContainer.shortcutNotifier.modifiers = enabledModifiers
            }.onChange(of: isShiftEnabled) { _ in
                diContainer.shortcutNotifier.modifiers = enabledModifiers
            }.onChange(of: isFunctionEnabled) { _ in
                diContainer.shortcutNotifier.modifiers = enabledModifiers
            }.onChange(of: isCommandEnabled) { _ in
                diContainer.shortcutNotifier.modifiers = enabledModifiers
            }.onChange(of: showMenuBarItem) { showMenuBarItem in
                diContainer.menuBarItemManager.set(isVisible: showMenuBarItem)
            }.onChange(of: launchOnLogin) { launchOnLogin in
                diContainer.autoLaunchManager.configureAutoLaunch(enabled: launchOnLogin)
            }.onChange(of: showDockIcon) { _ in
                diContainer.dockIconManager.updateIconVisibility()
            }.onAppear {
                isCommandEnabled = diContainer.shortcutNotifier.modifiers.contains(.command)
                isOptionEnabled = diContainer.shortcutNotifier.modifiers.contains(.option)
                isControlEnabled = diContainer.shortcutNotifier.modifiers.contains(.control)
                isShiftEnabled = diContainer.shortcutNotifier.modifiers.contains(.shift)
                isFunctionEnabled = diContainer.shortcutNotifier.modifiers.contains(.function)
            }
        }

        // MARK: Private

        private let diContainer = DIContainer.shared
        @AppStorage(AppStorageKey.showOnMouseMove) private var showOnMouseMove = true
        @AppStorage(AppStorageKey.showMenuBarItem) private var showMenuBarItem = false
        @AppStorage(AppStorageKey.showDockIcon) private var showDockIcon = true
        @AppStorage(AppStorageKey.launchOnLogin) private var launchOnLogin = false
        @AppStorage(AppStorageKey.hapticFeedbackEnabled) private var hapticFeedbackEnabled = true
        @State private var isCommandEnabled = false
        @State private var isOptionEnabled = false
        @State private var isControlEnabled = false
        @State private var isShiftEnabled = false
        @State private var isFunctionEnabled = false

        private var enabledModifiers: NSEvent.ModifierFlags {
            var flags = NSEvent.ModifierFlags()
            if isCommandEnabled {
                flags.insert(.command)
            }
            if isOptionEnabled {
                flags.insert(.option)
            }
            if isControlEnabled {
                flags.insert(.control)
            }
            if isShiftEnabled {
                flags.insert(.shift)
            }
            if isFunctionEnabled {
                flags.insert(.function)
            }
            return flags
        }
    }
}
