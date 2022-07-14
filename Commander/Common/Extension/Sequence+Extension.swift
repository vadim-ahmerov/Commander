// Sequence+Extension.swift
// Copyright (c) 2023 Vadim Ahmerov
// Created on 19.07.2022.

import Foundation

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { lhs, rhs in
            lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
        }
    }
}
