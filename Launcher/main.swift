// main.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 29.07.2022.

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
