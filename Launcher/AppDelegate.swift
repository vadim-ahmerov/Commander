// AppDelegate.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 29.07.2022.

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: Internal

    func applicationDidFinishLaunching(_: Notification) {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == Self.mainAppIdentifier
        }

        if isRunning {
            terminateSelf()
        } else {
            launchMainApp()
        }
    }

    @objc
    func terminateSelf() {
        NSApp.terminate(nil)
    }

    // MARK: Private

    private static let mainAppIdentifier = "com.va.commander"

    private func launchMainApp() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(terminateSelf),
            name: .killLauncher,
            object: Self.mainAppIdentifier
        )
        NSWorkspace.shared.openApplication(
            at: mainAppURL(),
            configuration: NSWorkspace.OpenConfiguration()
        )
    }

    private func mainAppURL() -> URL {
        var path = Bundle.main.bundlePath as NSString
        for _ in 1...4 {
            path = path.deletingLastPathComponent as NSString
        }
        return URL(fileURLWithPath: path as String)
    }
}
