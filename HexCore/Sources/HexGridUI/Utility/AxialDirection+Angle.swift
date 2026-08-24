//
//  AxialDirection+Angle.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/23/26.
//

import HexCore
import SwiftUI

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
