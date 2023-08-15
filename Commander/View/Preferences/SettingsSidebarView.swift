import SwiftUI

struct SettingsSidebarView: View {
    // MARK: Internal

    @Binding var apps: [App]

    var body: some View {
        ZStack(alignment: .top) {
            sidebarContent
            sidebarTopGradient
        }.onReceive(diContainer.appsManager.appGroups) { allApps in
            self.appGroups = allApps
        }.onChange(of: enteredURL) { url in
            guard let url = url else {
                return
            }
            try? diContainer.appsManager.add(appURL: url)
        }.sheet(isPresented: $urlSheetIsShowing) {
            URLInputView(isVisible: $urlSheetIsShowing, enteredURL: $enteredURL)
        }.alert("App Limit Reached", isPresented: $maxAppsCountSheetIsShowing, actions: {
            Button("Ok") {
                maxAppsCountSheetIsShowing = false
            }
        }, message: {
            Text(
                "You have reached the maximum of \(AppsManager.maxAppsCount) apps. Please remove an existing app before adding a new one."
            )
        }).animation(.default, value: apps)
    }

    // MARK: Private

    @State private var appGroups = [AppGroup]()
    @State private var urlSheetIsShowing = false
    @State private var enteredURL: URL?
    @State private var maxAppsCountSheetIsShowing = false
    @State private var searchText = ""
    @State private var isEditing = false
    private let diContainer = DIContainer.shared

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

                ForEach(appGroups, id: \.name) { group in
                    makeSection(title: group.name, apps: group.apps)
                }
            } else {
                let matchingApps = appGroups.apps.filter { app in
                    app.name.localizedCaseInsensitiveContains(searchText)
                }
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
        !maxAppsCountReached
    }

    private var maxAppsCountReached: Bool {
        apps.count >= AppsManager.maxAppsCount
    }

    private func button(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            GroupBox {
                Text(title).padding(.horizontal, 2)
            }
        }.buttonStyle(.plain)
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
            do {
                try diContainer.appsManager.add(appURL: url)
            } catch {
                // do nothing
            }
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
}
