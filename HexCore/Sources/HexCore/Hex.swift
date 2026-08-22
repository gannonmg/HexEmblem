//
//  Hex.swift
//  HexCore
//
//  Created by Matt Gannon on 8/21/26.
//

import Foundation

public enum HexOrientation: Sendable { case pointyTop, flatTop }

public protocol HexSizeProviding: HexShapeProviding {
    var radius: CGFloat { get }
    var orientation: HexOrientation { get }
}

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

extension HexSizeProviding {
    /// Returns aspect ratio of the frame around the hex, accounting for orientation.
    public var aspectRatio: CGFloat { width / height }

    /// Returns the width of the hex, accounting for orientation.
    public var width: CGFloat {
        switch orientation {
        case .pointyTop: Self.edgeToEdgeRatio * radius
        case .flatTop: Self.pointToPointRatio * radius
        }
    }

    /// Returns the height of the hex, accounting for orientation.
    public var height: CGFloat {
        switch orientation {
        case .pointyTop: Self.pointToPointRatio * radius
        case .flatTop: Self.edgeToEdgeRatio * radius
        }
    }

    public var innerRadius: CGFloat {
        Self.innerRadiusRatio * radius
    }
}

public protocol HexShapeProviding {}
extension HexShapeProviding {

    // Helpers
    public static func aspectRatio(for orientation: HexOrientation) -> CGFloat {
        switch orientation {
        case .pointyTop: edgeToEdgeRatio / pointToPointRatio
        case .flatTop: pointToPointRatio / edgeToEdgeRatio
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
