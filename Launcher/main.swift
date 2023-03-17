// main.swift
// Copyright (c) 2023 Vadim Ahmerov

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
