// TrackingAreaView.swift
// Copyright (c) 2023 Vadim Ahmerov

import SwiftUI

extension View {
    func trackingMouse(
        onMove: @escaping (_ mouseLocation: NSPoint) -> Void,
        onWindowFrameChange: (() -> Void)? = nil
    ) -> some View {
        TrackinAreaView(onMove: onMove, onWindowFrameChange: onWindowFrameChange) { self }
    }

    func trackingMouse(offset: CGFloat, onReachOffset: @escaping () -> Void) -> some View {
        var firstLocation: CGPoint?

        return trackingMouse { mouseLocation in
            if firstLocation == nil {
                firstLocation = mouseLocation
            }
            if let firstLocation = firstLocation, firstLocation.distance(to: mouseLocation) >= offset {
                onReachOffset()
            }
        } onWindowFrameChange: {
            firstLocation = nil
        }
    }
}

// MARK: - TrackinAreaView

struct TrackinAreaView<Content>: View where Content: View {
    let onMove: (_ mouseLocation: NSPoint) -> Void
    let onWindowFrameChange: (() -> Void)?
    let content: () -> Content

    init(
        onMove: @escaping (_ mouseLocation: NSPoint) -> Void,
        onWindowFrameChange: (() -> Void)?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.onMove = onMove
        self.onWindowFrameChange = onWindowFrameChange
        self.content = content
    }

    var body: some View {
        TrackingAreaRepresentable(onMove: onMove, onWindowFrameChange: onWindowFrameChange, content: content())
    }
}

// MARK: - TrackingAreaRepresentable

struct TrackingAreaRepresentable<Content>: NSViewRepresentable where Content: View {
    let onMove: (_ mouseLocation: NSPoint) -> Void
    let onWindowFrameChange: (() -> Void)?
    let content: Content

    func makeNSView(context _: Context) -> NSHostingView<Content> {
        TrackingNSHostingView(onMove: onMove, onWindowFrameChange: onWindowFrameChange, rootView: content)
    }

    func updateNSView(_: NSHostingView<Content>, context _: Context) {}
}

// MARK: - TrackingNSHostingView

final class TrackingNSHostingView<Content>: NSHostingView<Content> where Content: View {
    // MARK: Lifecycle

    init(
        onMove: @escaping (NSPoint) -> Void,
        onWindowFrameChange: (() -> Void)?,
        rootView: Content
    ) {
        self.onMove = onMove
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
            onMove(convert(event.locationInWindow, from: nil))
        }
        lastFrameWindow = window?.frame
    }

    // MARK: Private

    private let onMove: (NSPoint) -> Void
    private let onWindowFrameChange: (() -> Void)?
    private var lastFrameWindow: NSRect?

    private func setupTrackingArea() {
        let options: NSTrackingArea.Options = [.mouseMoved, .activeAlways, .inVisibleRect]
        let trackingArea = NSTrackingArea(
            rect: .zero,
            options: options,
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }
}
