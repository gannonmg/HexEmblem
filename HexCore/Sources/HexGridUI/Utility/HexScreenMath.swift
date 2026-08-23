//
//  HexScreenMath.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import CoreGraphics
import HexCore

enum HexScreenMath {
    static func pointyHexToPixel(axialCoordinate coord: AxialCoordinate, size: CGFloat) -> CGPoint {
        let (q, r) = (CGFloat(coord.q), CGFloat(coord.r))
        let x = sqrt(3) * (q + r/2)
        let y = 3 * r/2
        return CGPoint(x: x * size, y: y * size)
    }

    static func flatHexToPixel(axialCoordinate coord: AxialCoordinate, size: CGFloat) -> CGPoint {
        let (q, r) = (CGFloat(coord.q), CGFloat(coord.r))
        let x = 3 * q/2
        let y = sqrt(3) * (r + q/2)
        return CGPoint(x: x * size, y: y * size)
    }
}
