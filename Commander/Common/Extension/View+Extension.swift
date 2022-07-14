// View+Extension.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 28.07.2022.

import SwiftUI

extension View {
    func scaleEffect(_ scaleFactor: CGFloat) -> some View {
        scaleEffect(CGSize(width: scaleFactor, height: scaleFactor))
    }
}
