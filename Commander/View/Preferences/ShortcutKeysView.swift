import SwiftUI

extension SettingsView {
    struct ShortcutKeysView: View {
        // MARK: Internal

        var body: some View {
            VStack(spacing: 10) {
                HStack {
                    Toggle("⌘", isOn: $isCommandEnabled)
                    Toggle("⌥", isOn: $isOptionEnabled)
                    Toggle("⌃", isOn: $isControlEnabled)
                    Toggle("⇧", isOn: $isShiftEnabled)
                    Toggle("fn", isOn: $isFunctionEnabled)
                }
                Toggle("Show only after mouse move", isOn: $showOnMouseMove)
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
            }.onAppear {
                isCommandEnabled = diContainer.shortcutNotifier.modifiers.contains(.command)
                isOptionEnabled = diContainer.shortcutNotifier.modifiers.contains(.option)
                isControlEnabled = diContainer.shortcutNotifier.modifiers.contains(.control)
                isShiftEnabled = diContainer.shortcutNotifier.modifiers.contains(.shift)
                isFunctionEnabled = diContainer.shortcutNotifier.modifiers.contains(.function)
            }
        }

        // MARK: Private

        @Environment(\.injected) private var diContainer: DIContainer
        @AppStorage(AppStorageKey.showOnMouseMove) private var showOnMouseMove = true
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
