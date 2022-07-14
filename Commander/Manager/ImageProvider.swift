// ImageProvider.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 28.07.2022.

import AppKit
import Foundation

final class ImageProvider {
    func image(for url: URL, preferredSize: CGFloat = 64) -> NSImage {
        let nsImage: NSImage
        let imageRepresentation = NSWorkspace.shared
            .icon(forFile: url.path)
            .bestRepresentation(
                for: NSRect(
                    x: 0,
                    y: 0,
                    width: preferredSize,
                    height: preferredSize
                ),
                context: nil,
                hints: nil
            )
        if let imageRepresentation = imageRepresentation {
            nsImage = NSImage(size: imageRepresentation.size)
            nsImage.addRepresentation(imageRepresentation)
        } else {
            nsImage = NSWorkspace.shared.icon(forFile: url.path)
        }
        return nsImage
    }
}
