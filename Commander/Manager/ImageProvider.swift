import AppKit
import Foundation
import SwiftUI

final class ImageProvider {
    // MARK: Internal

    @ViewBuilder
    func image(for app: App, preferredSize: CGFloat) -> some View {
        switch app.kind {
        case .shortcut:
            ZStack {
                Image("shortcut")
                    .resizable()
                    .frame(width: preferredSize, height: preferredSize)
                if let firstLetter = app.name.first {
                    Text(String(firstLetter))
                        .font(.system(size: preferredSize * 0.8, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.8)
                }
            }
        case .app, .file:
            Image(nsImage: nsImage(for: app.url, preferredSize: preferredSize))
                .resizable()
                .frame(width: preferredSize, height: preferredSize)
        }
    }

    // MARK: Private

    private func nsImage(for url: URL, preferredSize: CGFloat) -> NSImage {
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
