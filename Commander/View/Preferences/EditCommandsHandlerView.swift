// EditCommandsHandlerView.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 01.08.2022.

import SwiftUI

struct EditCommandsHandlerView: View {
    var body: some View {
        Group {
            makeCommandView(title: "Paste", selector: #selector(NSText.paste(_:)), key: "v")
            makeCommandView(title: "Select All", selector: #selector(NSText.selectAll(_:)), key: "a")
            makeCommandView(title: "Cut", selector: #selector(NSText.cut(_:)), key: "x")
            makeCommandView(title: "Copy", selector: #selector(NSText.copy(_:)), key: "c")
        }.opacity(0)
    }

    private func makeCommandView(title: String, selector: Selector, key: Character) -> some View {
        Button(title) {
            NSApp.sendAction(selector, to: nil, from: nil)
        }.keyboardShortcut(KeyboardShortcut(KeyEquivalent(key)))
    }
}
