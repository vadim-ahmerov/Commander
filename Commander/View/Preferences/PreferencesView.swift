// PreferencesView.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 24.02.2023.

import AppKit
import SwiftUI

// MARK: - PreferencesView

struct PreferencesView: View {
    // MARK: Internal

    @UserDefault("first preferences launch") var firstLaunch = true
    @State var showGreeting = false

    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .top) {
                sidebarContent
                sidebarTopGradient
            }
            Color(nsColor: .separatorColor).frame(width: 1).ignoresSafeArea()
            wheelPicker
        }.onReceive(diContainer.appsManager.apps) { apps in
            self.apps = apps
        }.onReceive(diContainer.appsManager.allApps) { allApps in
            self.allApps = allApps
        }.onChange(of: enteredURL) { url in
            guard let url = url else {
                return
            }
            diContainer.appsManager.apps.value.append(App(url: url, name: url.host ?? url.lastPathComponent))
        }.sheet(isPresented: $urlSheetIsShowing) {
            URLSheetView(isVisible: $urlSheetIsShowing, enteredURL: $enteredURL)
        }.frame(minWidth: Self.width, maxWidth: Self.width).onAppear {
            showGreeting = firstLaunch
            firstLaunch = false
        }
    }

    // MARK: Private

    private static let width: CGFloat = 800
    private static let wheelWidth: CGFloat = 500
    private static let height: CGFloat = 500

    @Environment(\.injected) private var diContainer: DIContainer

    @State private var hoverState = WheelPicker.HoverState.enabledEmpty
    @State private var apps = [App]()
    @State private var allApps = AppSearcher.SearchResult.empty
    @State private var urlSheetIsShowing = false
    @State private var enteredURL: URL?

    private var wheelPicker: some View {
        VStack(spacing: 20) {
            Group {
                if showGreeting {
                    Text("Welcome to Commander!").font(.largeTitle).fontWeight(.light)
                }
                Text(
                    "Access this app launcher at any time by using the specified shortcut and moving your mouse slightly. Once the app picker appears, hover over the desired app and release the shortcut to launch it. You can also rearrange your apps by dragging and dropping them.\nTo choose the apps you want to launch, simply tick them on the left sidebar."
                ).font(.title2).fontWeight(.light).fixedSize(horizontal: false, vertical: true)
            }.multilineTextAlignment(.center).padding([.leading, .trailing], 32)
            WheelPicker(
                apps: diContainer.appsManager.apps,
                hoverState: $hoverState
            )
            ShortcutKeysView()
            Spacer()
        }.frame(minWidth: Self.wheelWidth, maxWidth: Self.wheelWidth)
    }

    private var sidebarContent: some View {
        List {
            HStack {
                Button("Open file or folder", action: {
                    addNewFileOrFolder()
                }).font(.body)
                Button("Open URL", action: {
                    addURL()
                }).font(.body)
            }
            makeSection(title: "Added to launcher", apps: diContainer.appsManager.apps.value).transition(.move(edge: .trailing))
            if !allApps.localApps.isEmpty {
                makeSection(title: "Apps installed by you", apps: allApps.localApps)
            }
            if !allApps.systemApps.isEmpty {
                makeSection(title: "System", apps: allApps.systemApps)
            }
            if !allApps.utilities.isEmpty {
                makeSection(title: "Utilities", apps: allApps.utilities)
            }
        }.animation(.default, value: apps).listStyle(.sidebar)
    }

    private var sidebarTopGradient: some View {
        GeometryReader { reader in
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                .frame(height: reader.safeAreaInsets.top * 4 / 3, alignment: .top)
                .mask(LinearGradient(
                    gradient: Gradient(colors: [.black, .black, .black, .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .ignoresSafeArea()
        }
    }

    private var maxAppsCountNotReached: Bool {
        apps.count < 10
    }

    private func makeSection(title: String, apps: [App]) -> some View {
        Section(title) {
            ForEach(apps) { app in
                ZStack {
                    Toggle(isOn: Binding(get: { self.apps.contains(app) }, set: { enable in
                        if !self.apps.contains(app), enable, maxAppsCountNotReached {
                            self.diContainer.appsManager.apps.value.append(app)
                        } else {
                            self.diContainer.appsManager.apps.value.removeAll(where: { $0 == app })
                        }
                    })) {
                        Label {
                            Text(app.name).font(.body)
                        } icon: {
                            Image(nsImage: diContainer.imageProvider.image(for: app.url, preferredSize: 32))
                        }.labelStyle(.titleAndIcon).padding([.leading, .trailing], 4)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func addNewFileOrFolder() {
        guard maxAppsCountNotReached else {
            return
        }
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        if panel.runModal() == .OK, let url = panel.url {
            try? diContainer.bookmarksManager.addToBookmarks(url: url)
            diContainer.appsManager.apps.value.append(App(url: url, name: url.lastPathComponent))
        }
    }

    private func addURL() {
        guard maxAppsCountNotReached else {
            return
        }
        urlSheetIsShowing = true
    }
}
