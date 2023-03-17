// ShortcutsAppManager.swift
// Copyright (c) 2023 Vadim Ahmerov

import Foundation
import AppKit

final class ShortcutsAppManager {
    // MARK: Internal

    enum ShortcutError: Error {
        case failedToDecodeOutput
    }

    func getShortcuts() -> [App] {
        do {
            return try run(arguments: ["list"])
                .get()
                .components(separatedBy: .newlines)
                .compactMap { name in
                    guard
                        !name.isEmpty,
                        var components = URLComponents(string: "shortcuts://run-shortcut")
                    else {
                        return nil
                    }
                    components.queryItems = [URLQueryItem(name: "name", value: name)]
                    guard let url = components.url else {
                        return nil
                    }
                    return App(url: url, name: name)
                }
        } catch {
            return []
        }
    }

    func run(app: App) {
        run(arguments: ["run", app.name])
    }

    // MARK: Private

    @discardableResult
    private func run(arguments: [String]) -> Result<String, Error> {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        process.arguments = arguments

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        do {
            try process.run()
            process.waitUntilExit()
            guard
                let data = try outputPipe.fileHandleForReading.readToEnd(),
                let string = String(data: data, encoding: .utf8)
            else {
                return .failure(ShortcutError.failedToDecodeOutput)
            }
            return .success(string)
        } catch {
            return .failure(error)
        }
    }
}
