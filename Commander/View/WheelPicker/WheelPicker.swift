import Combine
import Foundation
import SwiftUI

struct WheelPicker: View {
    // MARK: Internal

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

    let apps: CurrentValueSubject<[App], Never>
    @Binding var hoverState: HoverState

    var body: some View {
        ZStack {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                .clipShape(Circle())
                .shadow(radius: 3)
            sections

            if let hoverIndex = hoverState.hoveringAppIndex, indexedApps.indices.contains(hoverIndex) {
                Text(indexedApps[hoverIndex].app.name)
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
            self.apps.send(indexedApps.sorted(by: \.visualIndex).map(\.app))
        }.padding(6).frame(width: size, height: size)
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
