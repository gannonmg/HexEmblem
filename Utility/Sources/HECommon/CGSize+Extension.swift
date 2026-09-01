//
//  CGSize+Extension.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import CoreGraphics

extension CGSize {
    // MARK: - Static variables
    /// The frame size of a GBA Fire Emblem combat animation
    public static let combatFrame = CGSize(width: 240, height: 160)

    // MARK: - Static Helpers
    public static func + (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    public static func * (lhs: Self, scale: CGFloat) -> Self {
        CGSize(width: lhs.width * scale, height: lhs.height * scale)
    }

    public static func / (lhs: Self, scale: CGFloat) -> Self {
        CGSize(width: lhs.width / scale, height: lhs.height / scale)
    }
    
    // MARK: - Computed helpers
    public var center: CGPoint { CGPoint(x: width / 2, y: height / 2) }

    // MARK: Debug
    public func alignedDebugString(width: Int = 6, decimals: Int = 2) -> String {
        let format = "%\(width).\(decimals)f"
        let wStr = String(format: format, width)
        let hStr = String(format: format, height)
        return "W: \(wStr) | H: \(hStr)"
    }
}
