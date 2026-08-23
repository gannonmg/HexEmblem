//
//  HexOrientation+Extension.swift
//  HexCore
//
//  Created by Matt Gannon on 8/21/26.
//

import HexCore
import SwiftUI

extension HexOrientation {
    /// A pointy-top grid is a flat-top grid turned -30°, hexes and positions alike.
    public var rotationFromFlatTop: Angle {
        switch self {
        case .flatTop: .degrees(0)
        case .pointyTop: .degrees(-30)
        }
    }
}

extension CGPoint {
    func rotated(by angle: Angle) -> CGPoint {
        let cosine = cos(angle.radians)
        let sine = sin(angle.radians)
        return CGPoint(x: x * cosine - y * sine, y: x * sine + y * cosine)
    }
}
