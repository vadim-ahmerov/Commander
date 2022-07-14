// TextArea.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 19.02.2023.

import SwiftUI

struct TextArea: NSViewRepresentable {
    class Coordinator: NSObject, NSTextViewDelegate {
        // MARK: Lifecycle

        init(text: Binding<String>) {
            self.text = text
        }

        // MARK: Internal

        var text: Binding<String>

        func textView(_ textView: NSTextView, shouldChangeTextIn range: NSRange, replacementString text: String?) -> Bool {
            defer {
                self.text.wrappedValue = (textView.string as NSString).replacingCharacters(in: range, with: text!)
            }
            return true
        }

        func createTextViewStack(maximumNumberOfLines: Int) -> NSScrollView {
            let contentSize = scrollview.contentSize

            textContainer.containerSize = CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
            textContainer.widthTracksTextView = true
            textContainer.maximumNumberOfLines = maximumNumberOfLines

            textView.textContainerInset = NSSize(width: 2, height: 8)
            textView.minSize = CGSize(width: 0, height: 0)
            textView.maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            textView.isVerticallyResizable = true
            textView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
            textView.autoresizingMask = [.width]
            textView.delegate = self
            textView.font = NSFont.preferredFont(forTextStyle: .body)

            scrollview.borderType = .noBorder
            scrollview.hasVerticalScroller = true
            scrollview.documentView = textView

            textStorage.addLayoutManager(layoutManager)
            layoutManager.addTextContainer(textContainer)

            return scrollview
        }

        // MARK: Fileprivate

        fileprivate lazy var textStorage = NSTextStorage()
        fileprivate lazy var layoutManager = NSLayoutManager()
        fileprivate lazy var textContainer = NSTextContainer()
        fileprivate lazy var textView = NSTextView(frame: CGRect(), textContainer: textContainer)
        fileprivate lazy var scrollview = NSScrollView()
    }

    @Binding var text: String
    let maximumNumberOfLines: Int

    func makeNSView(context: Context) -> NSScrollView {
        context.coordinator.createTextViewStack(maximumNumberOfLines: maximumNumberOfLines)
    }

    func updateNSView(_ nsView: NSScrollView, context _: Context) {
        if let textArea = nsView.documentView as? NSTextView, textArea.string != self.text {
            textArea.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
}
