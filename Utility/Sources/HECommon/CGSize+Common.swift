//
//  CGSize+Common.swift
//  Utility
//
//  Created by Matt Gannon on 8/18/26.
//

import CoreGraphics

extension CGSize {
    // MARK: - Static variables
    public static let combatFrame = CGSize(width: 240, height: 160)

    // MARK: - Static Helpers
    public static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    // MARK: - Computed helpers
    public var center: CGPoint { CGPoint(x: width / 2, y: height / 2) }
}
