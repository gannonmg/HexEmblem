//
//  Comparable+Extension.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
