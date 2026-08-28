//
//  Angle.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import Algorithms
import Foundation

// Copy of SwiftUI's Angle helper for hex corner math
struct Angle: Sendable {
    let radians: Double
    let degrees: Double

    init(radians: Double) {
        self.radians = radians
        self.degrees = radians / .pi * 180
    }

    init(degrees: Double) {
        self.radians = degrees * .pi / 180
        self.degrees = degrees
    }

    static func radians(_ radians: Double) -> Angle { .init(radians: radians) }
    static func degrees(_ degrees: Double) -> Angle { .init(degrees: degrees) }
}

extension AxialDirection {
    /// Heading toward this neighbor, straight from the pixel math.
    func angle(for orientation: HexOrientation) -> Angle {
        let point = HexScreenMath.hexToCartesianPoint(
            axialCoordinate: offsetCoordinate,
            orientation: orientation
        )
        return Angle(radians: atan2(point.y, point.x))
    }
}
