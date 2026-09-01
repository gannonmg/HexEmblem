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

    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func * (point: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: point.x * scale, y: point.y * scale)
    }

    public static func / (point: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: point.x / scale, y: point.y / scale)
    }
}
