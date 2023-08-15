import SwiftUI

extension WheelPicker {
    struct Section: View {
        // MARK: Internal

        let indexedApp: IndexedApp
        let appsCount: Int
        let emptySpaceRadius: CGFloat
        let proxy: GeometryProxy

        @Binding var hoverState: HoverState
        @Binding var dragState: DragState
        @Binding var sectionAngle: CGFloat
        private let diContainer = DIContainer.shared

        var onIndexChange: (_ newIndex: Int) -> Void

        var body: some View {
            sectionBackground
            EmptyView().trackingMouse { point in
                hoverState.set(isHovering: sectionPath.contains(point), at: indexedApp.visualIndex)
            }

            ZStack {
                diContainer.imageProvider.image(for: indexedApp.app, preferredSize: 64)
                    .scaleEffect(imageScale)
                    .background(
                        Color.clear.contentShape(Circle()).frame(width: 90, height: 90)
                    )
                    .animation(.default, value: isHovering)
                runningDotView
            }.position(
                x: dragOffset?.x ?? imageXOffset,
                y: dragOffset?.y ?? imageYOffset
            ).gesture(dragGesture)
        }

        // MARK: Private

        private var dragOffset: CGPoint? {
            switch dragState {
            case .inactive:
                return nil
            case let .active(appVisualIndex, offset):
                if appVisualIndex == indexedApp.visualIndex {
                    return offset
                } else {
                    return nil
                }
            }
        }

        private var isHovering: Bool {
            hoverState.isHovering(appIndex: indexedApp.visualIndex)
        }

        private var imageScale: CGFloat {
            if isHovering {
                return 1.1
            } else if dragState.isDragging(appVisualIndex: indexedApp.visualIndex) {
                return 1
            } else {
                return 0.9
            }
        }

        private var imageXOffset: CGFloat {
            proxy.size.width / 2 + cos(sectionAngle * CGFloat(indexedApp.visualIndex)) * proxy.size.width * 0.35
        }

        private var imageYOffset: CGFloat {
            proxy.size.height / 2 - sin(sectionAngle * CGFloat(indexedApp.visualIndex)) * proxy.size.width * 0.35
        }

        private var dragGesture: some Gesture {
            DragGesture()
                .onChanged { (gesture: DragGesture.Value) in
                    hoverState = .disabled

                    let width = proxy.size.width
                    let height = proxy.size.height
                    let center = CGPoint(x: width * 0.5, y: height * 0.5)
                    let locationX = center.x - gesture.location.x
                    let locationY = -center.y + gesture.location.y
                    let gestureAngle = atan2(locationY, locationX) + .pi

                    var angleDistances = [CGFloat]()
                    for sectionIndex in 0 ..< appsCount {
                        let startAngle = sectionAngle * CGFloat(sectionIndex) + sectionAngle / 2 - sectionAngle

                        angleDistances.append(
                            abs((gestureAngle - startAngle - sectionAngle / 2).remainder(dividingBy: 2 * .pi))
                        )
                    }
                    let minDistanceIndex = angleDistances.enumerated().min {
                        $0.element < $1.element
                    }?.offset
                    if let minDistanceIndex = minDistanceIndex, indexedApp.visualIndex != minDistanceIndex {
                        onIndexChange(minDistanceIndex)
                    }
                    withAnimation {
                        dragState = .active(appVisualIndex: indexedApp.visualIndex, offset: gesture.location)
                    }
                }.onEnded { _ in
                    withAnimation {
                        dragState = .inactive
                        hoverState = .enabledEmpty
                    }
                }
        }

        private var sectionPath: Path {
            Path { path in
                let width = proxy.size.width
                let height = proxy.size.height

                let center = CGPoint(x: width * 0.5, y: height * 0.5)
                let startAngle = Angle(radians: -sectionAngle * CGFloat(indexedApp.visualIndex) + sectionAngle / 2)
                let diffAngle = Angle(radians: -sectionAngle)

                path.addArc(
                    center: center,
                    radius: emptySpaceRadius / 2,
                    startAngle: startAngle,
                    endAngle: startAngle + diffAngle,
                    clockwise: true
                )

                path.addArc(
                    center: center,
                    radius: width * 0.5,
                    startAngle: startAngle + diffAngle,
                    endAngle: startAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
        }

        @ViewBuilder private var sectionBackground: some View {
            if hoverState.isEnabled, isHovering {
                VisualEffectView(material: .selection, blendingMode: .behindWindow)
                    .clipShape(sectionPath)
            }
        }

        @ViewBuilder private var runningDotView: some View {
            if diContainer.appsManager.isLaunched(app: indexedApp.app), !isHovering {
                Circle()
                    .fill(Color(nsColor: NSColor.tertiaryLabelColor))
                    .frame(width: 5, height: 5)
                    .offset(runningDotOffset)
            }
        }

        private var runningDotOffset: CGSize {
            let offset: CGFloat = proxy.size.width * 0.12
            return CGSize(
                width: cos(sectionAngle * CGFloat(indexedApp.visualIndex)) * offset,
                height: -sin(sectionAngle * CGFloat(indexedApp.visualIndex)) * offset
            )
        }
    }
}
