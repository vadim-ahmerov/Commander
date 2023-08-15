import AppKit
import Combine
import SwiftUI

// MARK: - CommanderView

struct CommanderView: View {
    // MARK: Internal

    var body: some View {
        WheelPicker(
            apps: diContainer.appsManager.apps,
            hoverState: $hoverState
        ).onReceive(clearHoverSubject) { _ in
            hoverState = .enabledEmpty
        }.onReceive(diContainer.shortcutNotifier.$shortcutTriggered) { isTriggered in
            if isTriggered {
                shortcutTriggerDate = Date()
            } else {
                let lastHoveredAppIndex = hoverState.hoveringAppIndex
                let lastHoveredApp = lastHoveredAppIndex.map { diContainer.appsManager.apps.value[$0] }

                clearHoverSubject.send(())
                if
                    let app = lastHoveredApp,
                    let keyDownDate = shortcutTriggerDate,
                    -keyDownDate.timeIntervalSinceNow > 0.2
                {
                    self.diContainer.appsManager.open(app: app)
                    self.shortcutTriggerDate = nil
                }
            }
        }.opacity(showOnMouseMove && isHidden ? 0 : 1).overlay {
            if showOnMouseMove {
                EmptyView().trackingMouse(offset: 32) {
                    isHidden = false
                }.onReceive(diContainer.shortcutNotifier.$shortcutTriggered) { _ in
                    isHidden = true
                }
            }
        }
    }

    // MARK: Private

    @State private var shortcutTriggerDate: Date?
    @AppStorage(AppStorageKey.showOnMouseMove) private var showOnMouseMove = true
    private let diContainer = DIContainer.shared
    @State private var hoverState = WheelPicker.HoverState.enabledEmpty
    @State private var isHidden = true
    private let clearHoverSubject = PassthroughSubject<Void, Never>()
}
