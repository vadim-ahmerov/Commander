import Combine
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct WheelPicker: View {
    // MARK: Internal

    @State private var isTargetedForDrop = false

    struct IndexedApp: Equatable {
        var visualIndex: Int
        let app: App
    }

    enum DragState: Equatable {
        case inactive
        case active(appVisualIndex: Int, offset: CGPoint)

        // MARK: Internal

        func isDragging(appVisualIndex: Int) -> Bool {
            switch self {
            case .active(let index, _):
                return index == appVisualIndex
            case .inactive:
                return false
            }
        }
    }

    private let diContainer = DIContainer.shared
    let apps: CurrentValueSubject<[App], Never>
    @Binding var hoverState: HoverState
    private var textInTheMiddle: String? {
        if let hoverIndex = hoverState.hoveringAppIndex, indexedApps.indices.contains(hoverIndex) {
            return indexedApps[hoverIndex].app.name
        } else if isTargetedForDrop {
            if apps.value.count < AppsManager.maxAppsCount {
                return "Release the mouse button or trackpad to add a new item to the picker"
            } else {
                return "Maximum item limit reached. Please remove an item before adding another"
            }
        } else {
            return nil
        }
    }

    var body: some View {
        ZStack {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                .clipShape(Circle())
                .shadow(radius: 3)
            sections

            if let textInTheMiddle {
                Text(textInTheMiddle)
                    .foregroundColor(Color(.secondaryLabelColor))
                    .bold().frame(width: emptySpaceRadius)
                    .multilineTextAlignment(.center)
                    .animation(.default, value: hoverState)
            }
        }.onReceive(apps) { newApps in
            let oldApps = indexedApps.sorted(by: \.visualIndex).map(\.app)
            if oldApps != newApps {
                withAnimation(oldApps.isEmpty ? nil : .default) {
                    indexedApps = newApps.enumerated().map(IndexedApp.init)
                    sectionAngle = indexedApps.isEmpty ? 0 : 2 * .pi / CGFloat(indexedApps.count)
                }
            }
        }.onChange(of: dragState) { state in
            guard state == .inactive else {
                return
            }
            apps.send(indexedApps.sorted(by: \.visualIndex).map(\.app))
        }
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isTargetedForDrop) { providers in
            providers.forEach { provider in
                provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
                    if let data, let path = String(data: data, encoding: .utf8), let url = URL(string: path) {
                        DispatchQueue.main.async {
                            try? diContainer.appsManager.add(appURL: url)
                        }
                    }
                }
            }
            return true
        }
        .onChange(of: isTargetedForDrop) { isTargeted in
            if isTargeted {
                hoverState = .disabled
            } else {
                hoverState = .enabledEmpty
            }
        }
        .opacity(isTargetedForDrop ? 0.8 : 1).padding(6).frame(width: size, height: size)
    }

    // MARK: Private

    @State private var indexedApps = [IndexedApp]()
    @State private var dragState = DragState.inactive
    @State private var sectionAngle: CGFloat = 0

    private var sections: some View {
        GeometryReader { proxy in
            ForEach(indexedApps.indices, id: \.self) { index in
                makeSection(index: index, proxy: proxy)
            }
        }
    }

    private var size: CGFloat {
        260 + CGFloat(indexedApps.count) * 10
    }

    private var emptySpaceRadius: CGFloat {
        size * 0.35
    }

    private func makeSection(index: Int, proxy: GeometryProxy) -> WheelPicker.Section {
        Section(
            indexedApp: indexedApps[index],
            appsCount: indexedApps.count,
            emptySpaceRadius: emptySpaceRadius,
            proxy: proxy,
            hoverState: $hoverState,
            dragState: $dragState,
            sectionAngle: $sectionAngle
        ) { visualIndex in
            guard
                let toApp = indexedApps
                    .enumerated()
                    .first(where: { visualIndex == $0.element.visualIndex }),
                let fromApp = indexedApps
                    .enumerated()
                    .first(where: { indexedApps[index].visualIndex == $0.element.visualIndex })
            else {
                assertionFailure()
                return
            }
            withAnimation {
                let fromAppVisualIndex = indexedApps[fromApp.offset].visualIndex
                indexedApps[fromApp.offset].visualIndex = indexedApps[toApp.offset].visualIndex
                indexedApps[toApp.offset].visualIndex = fromAppVisualIndex
            }
        }
    }
}
