// NSWindow+Extension.swift
// Copyright (c) 2023 Vadim Ahmerov

import AppKit

extension NSWindow {
    func makeCompletelyVisibleIfNeeded() {
        guard let visibleFrame = screen?.visibleFrame else {
            return
        }
        var frame = frame
        if frame.minX < visibleFrame.minX {
            frame.origin.x = visibleFrame.minX
        }
        if frame.maxX > visibleFrame.maxX {
            frame.origin.x = visibleFrame.maxX - frame.width
        }
        if frame.minY < visibleFrame.minY {
            frame.origin.y = visibleFrame.minY
        }
        if frame.maxY > visibleFrame.maxY {
            frame.origin.y = visibleFrame.maxY - frame.height
        }
        setFrame(frame, display: true)
    }
}
