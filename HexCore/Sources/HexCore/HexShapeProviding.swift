//
//  HexShapeProviding.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import Foundation

/// Abstract representation of the shape of a hex, without regards to size
public protocol HexShapeProviding {}

extension HexShapeProviding {

    // Helpers
    public static func aspectRatio(for orientation: HexOrientation) -> CGFloat {
        let size = fractionalSize(for: orientation)
        return size.width / size.height
    }

    public static func fractionalSize(for orientation: HexOrientation) -> CGSize {
        switch orientation {
        case .pointyTop: CGSize(width: edgeToEdgeRatio, height: pointToPointRatio)
        case .flatTop: CGSize(width: pointToPointRatio, height: edgeToEdgeRatio)
        }
    }

    /// Multiply size (radius) by this to get the distances between two opposite points in the hex..
    /// Effectively the diameter of a circle that passes through each point of the hex.
    public static var pointToPointRatio: CGFloat { 2 }

    /// Multiply size (radius) by this to get the distances between two opposite points in the hex..
    /// Effectively the diameter of the largest circle that can fit within the hex.
    public static var edgeToEdgeRatio: CGFloat { sqrt(3) }

    public static var centerSingleQDiff: CGFloat { edgeToEdgeRatio }

    /// The ratio at which `∆r` changes spatially, relative to size.
    /// Assumes `q` remains constant.
    ///
    /// Discussion: This is easy to visualize if you know that two r adjacent hexes share exactly 1/4 of their heights in a cartesian space.
    /// So, the distance between them is `3/4 * height`, where `height` is `2*size`. Inverted to convert from `∆r`
    public static var deltaRRatio: CGFloat { 4 / 3 }

    /// The ratio at which `∆q` changes spatially, relative to size.
    /// Assumes `r` remains constant.
    ///
    /// It's also just the distance from 2 opposing edges in the same hex.
    public static var deltaQRatio: CGFloat { sqrt(3) }

    /// Distance from the center of the hex to the center of any given edge of the hex.
    /// The largest circle radius you could have without exceeding the inside of the hex.
    public static var innerRadiusRatio: CGFloat { edgeToEdgeRatio / 2 }
}

extension HexShapeProviding {
    /// Linear diff is the horizontal q movement on a pointy hex or the vertical r movevement on flat top.
    /// Offset diff is the inverse, and represents a move that includes both x and y movement due to the staggered nature
    /// of hex columns (pointy) or rows (flat top).
    ///
    /// See [section](https://www.redblobgames.com/grids/hexagons/#hex-to-pixel-axial)
    public static func xCartesianOffset(linearDiff: Int, offsetDiff: Int) -> CGFloat {
        sqrt(3) * (linearDiff + offsetDiff/2)
    }

    /// Linear diff is the horizontal q movement on a pointy hex or the vertical r movevement on flat top.
    /// Offset diff is the inverse, and represents a move that includes both x and y movement due to the staggered nature
    /// of hex columns (pointy) or rows (flat top).
    ///
    /// See [section](https://www.redblobgames.com/grids/hexagons/#hex-to-pixel-axial)
    public static func yCartesianOffset(offsetDiff: Int) -> CGFloat {
        3/2 * offsetDiff
    }

    /// Linear diff is the horizontal q movement on a pointy hex or the vertical r movevement on flat top.
    /// Offset diff is the inverse, and represents a move that includes both x and y movement due to the staggered nature
    /// of hex columns (pointy) or rows (flat top).
    ///
    /// See [section](https://www.redblobgames.com/grids/hexagons/#hex-to-pixel-axial)
    public static func centerCartesianOffset(linearDiff: Int, offsetDiff: Int) -> CGFloat {
        let qDist = xCartesianOffset(linearDiff: linearDiff, offsetDiff: offsetDiff)
        let rDist = yCartesianOffset(offsetDiff: offsetDiff)
        return sqrt(pow(qDist, 2) + pow(rDist, 2))
    }
}
