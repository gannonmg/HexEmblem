//
//  CGRect+Extension.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import CoreGraphics

extension CGRect {

    // MARK: - Geometric Arithmetic
    public static func * (lhs: CGRect, scale: CGFloat) -> CGRect {
        CGRect(origin: lhs.origin * scale, size: lhs.size * scale)
    }

    public static func / (lhs: CGRect, scale: CGFloat) -> CGRect {
        CGRect(origin: lhs.origin / scale, size: lhs.size / scale)
    }

    // MARK: - Computed helpers
    public var center: CGPoint { CGPoint(x: midX, y: midY) }

    // MARK: Debug
    public func alignedDebugString(width: Int = 6, decimals: Int = 2) -> String {
        let format = "%\(width).\(decimals)f"
        let xStr = String(format: format, origin.x)
        let yStr = String(format: format, origin.y)
        let wStr = String(format: format, size.width)
        let hStr = String(format: format, size.height)
        return "X: \(xStr) | Y: \(yStr) | W: \(wStr) | H: \(hStr)"
    }
}
