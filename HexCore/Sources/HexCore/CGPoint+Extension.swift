//
//  CGPoint+Extension.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import CoreGraphics

extension CGPoint {
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func * (point: CGPoint, mult: CGFloat) -> CGPoint {
        CGPoint(x: point.x * mult, y: point.y * mult)
    }

    /// The point `distance` away at `angle`, measured from the +x axis.
    func offset(distance: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: x + distance * cos(angle.radians),
            y: y + distance * sin(angle.radians)
        )
    }
}
