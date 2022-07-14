// URLSheetView.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 28.07.2022.

import SwiftUI

extension PreferencesView {
    struct URLSheetView: View {
        // MARK: Internal

        @Binding var isVisible: Bool
        @Binding var enteredURL: URL?

        var body: some View {
            VStack(alignment: .leading) {
                Text("Add new URL").font(.title3)
                TextField("Paste your URL here", text: $enteredText).padding(.bottom, 8)
                HStack {
                    Spacer()
                    Button("Cancel") {
                        isVisible = false
                    }.keyboardShortcut(.cancelAction)
                    Button("Create") {
                        isVisible = false
                        enteredURL = URL(string: enteredText)
                    }.disabled(urlIsInvalid).keyboardShortcut(.defaultAction)
                }
            }.onChange(of: enteredText) { newValue in
                urlIsInvalid = URL(string: newValue) == nil
            }.padding().overlay(EditCommandsHandlerView()).frame(width: 400)
        }

        // MARK: Private

        @State private var urlIsInvalid = true
        @State private var enteredText = ""
    }
}
