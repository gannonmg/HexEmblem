//
//  RadianProviding.swift
//  Utility
//
//  Created by Matt Gannon on 9/1/26.
//

import CoreGraphics

public protocol RadianProviding {
    var radians: Double { get }
}

extension CGPoint {
    /// The point `distance` away at `angle`, measured from the +x axis.
    public func offset(distance: CGFloat, angle: some RadianProviding) -> CGPoint {
        CGPoint(
            x: x + distance * cos(angle.radians),
            y: y + distance * sin(angle.radians)
        )
    }
}
