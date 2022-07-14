// CGPoint+Extension.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 28.07.2022.

import Foundation

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - x, 2) + pow(point.y - y, 2))
    }
}
