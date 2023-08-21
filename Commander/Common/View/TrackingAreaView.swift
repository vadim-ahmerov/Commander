import SwiftUI

enum MouseLocationUpdate {
    case moved(newLocation: NSPoint)
    case exited

    var point: NSPoint? {
        switch self {
        case let .moved(point):
            return point
        case .exited:
            return nil
        }
    }
}

extension View {
    func trackingMouse(
        onUpdate: @escaping (MouseLocationUpdate) -> Void,
        onWindowFrameChange: (() -> Void)? = nil
    ) -> some View {
        TrackinAreaView(onUpdate: onUpdate, onWindowFrameChange: onWindowFrameChange) { self }
    }

    func trackingMouse(offset: CGFloat, onReachOffset: @escaping () -> Void) -> some View {
        var firstLocation: CGPoint?

        return trackingMouse { update in
            guard let point = update.point else {
                return
            }
            if firstLocation == nil {
                firstLocation = point
            }
            if let firstLocation = firstLocation, firstLocation.distance(to: point) >= offset {
                onReachOffset()
            }
        } onWindowFrameChange: {
            firstLocation = nil
        }
    }
}

// MARK: - TrackinAreaView

struct TrackinAreaView<Content>: View where Content: View {
    let onUpdate: (MouseLocationUpdate) -> Void
    let onWindowFrameChange: (() -> Void)?
    let content: () -> Content

    init(
        onUpdate: @escaping (MouseLocationUpdate) -> Void,
        onWindowFrameChange: (() -> Void)?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.onUpdate = onUpdate
        self.onWindowFrameChange = onWindowFrameChange
        self.content = content
    }

    var body: some View {
        TrackingAreaRepresentable(onUpdate: onUpdate, onWindowFrameChange: onWindowFrameChange, content: content())
    }
}

// MARK: - TrackingAreaRepresentable

struct TrackingAreaRepresentable<Content>: NSViewRepresentable where Content: View {
    let onUpdate: (MouseLocationUpdate) -> Void
    let onWindowFrameChange: (() -> Void)?
    let content: Content

    func makeNSView(context _: Context) -> NSHostingView<Content> {
        TrackingNSHostingView(onUpdate: onUpdate, onWindowFrameChange: onWindowFrameChange, rootView: content)
    }

    func updateNSView(_: NSHostingView<Content>, context _: Context) {}
}

// MARK: - TrackingNSHostingView

final class TrackingNSHostingView<Content>: NSHostingView<Content> where Content: View {
    // MARK: Lifecycle

    init(
        onUpdate: @escaping (MouseLocationUpdate) -> Void,
        onWindowFrameChange: (() -> Void)?,
        rootView: Content
    ) {
        self.onUpdate = onUpdate
        self.onWindowFrameChange = onWindowFrameChange
        super.init(rootView: rootView)
        setupTrackingArea()
    }

    required init(rootView _: Content) {
        fatalError("Should never be called")
    }

    @objc
    @available(*, unavailable)
    dynamic required init?(coder _: NSCoder) {
        fatalError("Should never be called")
    }

    // MARK: Internal

    override func mouseMoved(with event: NSEvent) {
        if lastFrameWindow != window?.frame {
            onWindowFrameChange?()
        } else {
            let point = convert(event.locationInWindow, from: nil)
            onUpdate(.moved(newLocation: point))
        }
        lastFrameWindow = window?.frame
    }

    // MARK: Private

    private let onUpdate: (MouseLocationUpdate) -> Void
    private let onWindowFrameChange: (() -> Void)?
    private var lastFrameWindow: NSRect?

    private func setupTrackingArea() {
        var options: NSTrackingArea.Options = [
            .mouseMoved,
            .activeAlways,
            .inVisibleRect,
        ]

        if #available(macOS 13, *) {
            options.insert(.mouseEnteredAndExited)
        }

        let trackingArea = NSTrackingArea(
            rect: .zero,
            options: options,
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        onUpdate(.exited)
    }
}
