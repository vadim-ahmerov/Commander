// View+Extension.swift
// Copyright (c) 2023 Vadim Ahmerov

import SwiftUI

extension View {
    func scaleEffect(_ scaleFactor: CGFloat) -> some View {
        scaleEffect(CGSize(width: scaleFactor, height: scaleFactor))
    }
}
