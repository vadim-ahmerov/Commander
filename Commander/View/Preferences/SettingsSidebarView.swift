import SwiftUI

struct SettingsSidebarView: View {
    var body: some View {
        ZStack(alignment: .top) {
            sidebarContent
            sidebarTopGradient
        }.onReceive(diContainer.appsManager.allApps) { allApps in
            self.allApps = allApps
        }.onChange(of: enteredURL) { url in
            guard let url = url else {
                return
            }
            diContainer.appsManager.apps.value.append(App(url: url, name: url.host ?? url.lastPathComponent))
        }.sheet(isPresented: $urlSheetIsShowing) {
            URLInputView(isVisible: $urlSheetIsShowing, enteredURL: $enteredURL)
        }.alert("App Limit Reached", isPresented: $maxAppsCountSheetIsShowing, actions: {
            Button("Ok") {
                maxAppsCountSheetIsShowing = false
            }
        }, message: {
            Text(
                "You have reached the maximum of \(Self.maxAppsCount) apps. Please remove an existing app before adding a new one."
            )
        }).animation(.default, value: apps)
    }

    private var sidebarContent: some View {
        List {
            HStack {
                button(title: "Open file or folder", action: addNewFileOrFolder)
                button(title: "Open URL", action: addURL)
            }
            SettingsSearchField(searchText: $searchText)

            if searchText.isEmpty {
                makeSection(
                    title: "Added to launcher",
                    apps: diContainer.appsManager.apps.value
                ).transition(.move(edge: .trailing))

                if !allApps.shortcuts.isEmpty {
                    makeSection(title: "Shortcuts", apps: allApps.shortcuts)
                }
                if !allApps.localApps.isEmpty {
                    makeSection(title: "Apps installed by you", apps: allApps.localApps)
                }
                if !allApps.systemApps.isEmpty {
                    makeSection(title: "System", apps: allApps.systemApps)
                }
                if !allApps.utilities.isEmpty {
                    makeSection(title: "Utilities", apps: allApps.utilities)
                }
            } else {
                let matchingApps = allApps.joined.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                if matchingApps.isEmpty {
                    HStack {
                        Spacer()
                        Text("No Results")
                            .font(.title3.weight(.bold))
                        Spacer()
                    }.padding(.top, 32)
                } else {
                    makeSection(title: "Search Results", apps: matchingApps)
                }
            }
        }.listStyle(.sidebar)
    }

    private func button(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            GroupBox {
                Text(title).padding(.horizontal, 2)
            }
        }.buttonStyle(.plain)
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

    private func addNewFileOrFolder() {
        guard maxAppsCountNotReached else {
            maxAppsCountSheetIsShowing = true
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
            maxAppsCountSheetIsShowing = true
            return
        }
        urlSheetIsShowing = true
    }

    private func makeSection(title: String, apps: [App]) -> some View {
        Section(title) {
            ForEach(apps) { app in
                ZStack {
                    Toggle(isOn: Binding(get: { self.apps.contains(app) }, set: { enable in
                        if maxAppsCountReached, enable {
                            maxAppsCountSheetIsShowing = true
                        } else if !self.apps.contains(app), enable {
                            self.diContainer.appsManager.apps.value.append(app)
                        } else {
                            self.diContainer.appsManager.apps.value.removeAll(where: { $0 == app })
                        }
                    })) {
                        Label {
                            Text(app.name).font(.body)
                        } icon: {
                            ZStack {
                                diContainer.imageProvider.image(for: app, preferredSize: 32)
                            }
                        }.labelStyle(.titleAndIcon).padding([.leading, .trailing], 4)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    @Binding var apps: [App]
    @State private var allApps = AppSearcher.SearchResult.empty
    @State private var urlSheetIsShowing = false
    @State private var enteredURL: URL?
    @State private var maxAppsCountSheetIsShowing = false
    @State private var searchText = ""
    @State private var isEditing = false
    @Environment(\.injected) private var diContainer: DIContainer

    private var maxAppsCountNotReached: Bool {
        !maxAppsCountReached
    }
    private var maxAppsCountReached: Bool {
        apps.count >= Self.maxAppsCount
    }
    private static let maxAppsCount = 12
}
