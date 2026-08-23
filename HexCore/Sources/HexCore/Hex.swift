//
//  Hex.swift
//  HexCore
//
//  Created by Matt Gannon on 8/21/26.
//

import Foundation

/// A `Hex` provides a coordinate as well as an actual physical size
///
/// - Parameters:
///     - axialCoordinate: The axial (q,r) coordinate of the hex on the map
///     - size: the distance from the center of the hex to any of its six points
///     - topStyle:  Determines whether the top of the hex is pointy or flat. Defaults to `pointy`.
public struct Hex: HexSizeProviding, AxialCoordinateProviding {
    public let axialCoordinate: AxialCoordinate
    public let radius: CGFloat
    public var orientation: HexOrientation = .pointyTop
}
