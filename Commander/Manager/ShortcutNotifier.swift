// ShortcutNotifier.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 26.02.2023.

import AppKit
import SwiftUI

final class ShortcutNotifier: ObservableObject {
    // MARK: Lifecycle

    init() {
        NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged]) { [weak self] event in
            self?.didReceive(event: event)
        }
        NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { [weak self] event in
            self?.didReceive(event: event)
            return event
        }
    }

    // MARK: Internal

    @Published var shortcutTriggered = false
    @UserDefault("shortcut modifiers") var modifiers = NSEvent.ModifierFlags.command

    // MARK: Private

    private func didReceive(event: NSEvent) {
        let newPressedModifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if modifiers == newPressedModifiers {
            shortcutTriggered = true
        } else {
            shortcutTriggered = false
        }
    }
}
