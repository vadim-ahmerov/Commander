// App.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 28.07.2022.

import AppKit.NSImage

// MARK: - App

struct App: Codable, Equatable, Hashable {
    let url: URL
    let name: String
}

// MARK: Identifiable

extension App: Identifiable {
    var id: URL {
        url
    }
}
