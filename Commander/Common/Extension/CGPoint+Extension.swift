// CGPoint+Extension.swift
// Copyright (c) 2023 Vadim Ahmerov

import Foundation

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(pow(point.x - x, 2) + pow(point.y - y, 2))
    }
}
