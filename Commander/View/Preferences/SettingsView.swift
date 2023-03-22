import AppKit
import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    // MARK: Internal

    @UserDefault("first preferences launch") var firstLaunch = true
    @State var showGreeting = false

    var body: some View {
        HStack(spacing: 0) {
            SettingsSidebarView(apps: $apps)
            Color(nsColor: .separatorColor).frame(width: 1).ignoresSafeArea()
            wheelPicker
        }.onReceive(diContainer.appsManager.apps) { apps in
            self.apps = apps
        }.frame(minWidth: Self.width, maxWidth: Self.width).onAppear {
            diContainer.appRatingManager.requestRateIfNeeded()
            showGreeting = firstLaunch
            firstLaunch = false
        }
    }

    // MARK: Private

    private static let width: CGFloat = 800
    private static let wheelWidth: CGFloat = 500
    private static let height: CGFloat = 500

    @Environment(\.injected) private var diContainer: DIContainer

    @State private var hoverState = WheelPicker.HoverState.enabledEmpty
    @State private var apps = [App]()

    private var wheelPicker: some View {
        VStack(spacing: 20) {
            Group {
                if showGreeting {
                    Text("Welcome to Commander!").font(.largeTitle).fontWeight(.light)
                }
                Text(
                    "Access this app launcher at any time by using the specified shortcut and moving your mouse slightly. Once the app picker appears, hover over the desired app and release the shortcut to launch it. You can also rearrange your apps by dragging and dropping them.\nTo choose the apps you want to launch, simply tick them on the left sidebar."
                ).font(.title2).fontWeight(.light).fixedSize(horizontal: false, vertical: true)
            }.multilineTextAlignment(.center).padding([.leading, .trailing], 32)
            WheelPicker(
                apps: diContainer.appsManager.apps,
                hoverState: $hoverState
            )
            ShortcutKeysView()
            Spacer()
        }.frame(minWidth: Self.wheelWidth, maxWidth: Self.wheelWidth)
    }
}
