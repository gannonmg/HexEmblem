//
//  CGSize+Extension.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import CoreGraphics

extension CGSize {
    public static func * (lhs: Self, rhs: CGFloat) -> Self {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    public var alignedDebugString: String {
        let wStr = String(format: "%6.1f", width)
        let hStr = String(format: "%6.1f", height)
        return "W: \(wStr) | H: \(hStr)"
    }
}
