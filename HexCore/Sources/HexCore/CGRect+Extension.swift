//
//  CGRect+Extension.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import CoreGraphics

extension CGRect {
    public static func * (lhs: CGRect, scale: CGFloat) -> CGRect {
        CGRect(origin: lhs.origin * scale, size: lhs.size * scale)
    }

    public var center: CGPoint { CGPoint(x: midX, y: midY) }

    public var alignedDebugString: String {
        // "%7.2f" means: total 7 characters wide, exactly 2 decimal places
        let xStr = String(format: "%6.1f", origin.x)
        let yStr = String(format: "%6.1f", origin.y)
        let wStr = String(format: "%6.1f", size.width)
        let hStr = String(format: "%6.1f", size.height)
        return "X: \(xStr) | Y: \(yStr) | W: \(wStr) | H: \(hStr)"
    }
}
