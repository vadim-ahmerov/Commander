import AppKit
import SwiftUI

// MARK: - Settings
struct SettingsView: View {
    // MARK: Internal

    var body: some View {
        HStack(spacing: 0) {
            SettingsSidebarView(apps: $apps)
            Color(nsColor: .separatorColor).frame(width: 1).ignoresSafeArea()
            wheelPicker
        }.onReceive(diContainer.appsManager.apps) { apps in
            self.apps = apps
        }.frame(minWidth: Self.width, maxWidth: Self.width).onAppear {
            diContainer.appRatingManager.requestRateIfNeeded()
        }
    }

    // MARK: Private

    private static let width: CGFloat = 900
    private static let wheelWidth: CGFloat = 600
    private static let height: CGFloat = 500

    @Environment(\.injected) private var diContainer: DIContainer

    @State private var hoverState = WheelPicker.HoverState.enabledEmpty
    @State private var apps = [App]()

    private var wheelPicker: some View {
        VStack(spacing: 20) {
            SettingsTutorialView()
                .padding([.leading, .trailing], 32)
            WheelPicker(
                apps: diContainer.appsManager.apps,
                hoverState: $hoverState
            )
            ShortcutKeysView()
            Spacer()
        }.frame(minWidth: Self.wheelWidth, maxWidth: Self.wheelWidth)
    }
}
