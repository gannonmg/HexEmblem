//
//  HexScreenMath.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import CoreGraphics

public enum HexScreenMath {
    /*
     Yes, these pairs of functions are similar enough that they are duplicating a bit of effort.
     To combine, we'd just pass orientation and flip the x/y logic as well as where q and r are used.
     Ultimately, it's just clearer and easier to debug to keep them separated.
     */

    // MARK: - Hex to fractional point (equivalent to size = 1)
    public static func hexToCartesianPoint(
        axialCoordinate coord: some AxialCoordinateProviding,
        orientation: HexOrientation
    ) -> CGPoint {
        switch orientation {
        case .pointyTop: pointyHexToCartesianPoint(axialCoordinate: coord)
        case .flatTop: flatHexToCartesianPoint(axialCoordinate: coord)
        }
    }

    public static func pointyHexToCartesianPoint(
        axialCoordinate coord: some AxialCoordinateProviding
    ) -> CGPoint {
        let coord = coord.axialCoordinate
        let (q, r) = (CGFloat(coord.q), CGFloat(coord.r))
        let x = sqrt(3) * (q + r/2)
        let y = 3 * r/2
        return CGPoint(x: x, y: y)
    }

    public static func flatHexToCartesianPoint(
        axialCoordinate coord: some AxialCoordinateProviding
    ) -> CGPoint {
        let coord = coord.axialCoordinate
        let (q, r) = (CGFloat(coord.q), CGFloat(coord.r))
        let x = 3 * q/2
        let y = sqrt(3) * (r + q/2)
        return CGPoint(x: x, y: y)
    }

    // MARK: - Hex to Pixel (center coordinate)
    public static func pointyHexToPixel(
        axialCoordinate coord: some AxialCoordinateProviding,
        size: CGFloat
    ) -> CGPoint {
        pointyHexToCartesianPoint(axialCoordinate: coord) * size
    }

    public static func flatHexToPixel(
        axialCoordinate coord: some AxialCoordinateProviding,
        size: CGFloat
    ) -> CGPoint {
        flatHexToCartesianPoint(axialCoordinate: coord) * size
    }

    // MARK: - Pixel (touch/click) input to Hex
    public static func pixelToPointyHex(point: CGPoint, size: CGFloat) -> AxialCoordinate {
        // Invert the scaling
        let x = point.x / size
        let y = point.y / size
        // Convert from scaled cartesian to hex
        let q = (sqrt(3) * x - y) / 3
        let r = y * 2/3
        return axialRound(q: q, r: r)
    }

    public static func pixelToFlatHex(point: CGPoint, size: CGFloat) -> AxialCoordinate {
        // Invert the scaling
        let x = point.x / size
        let y = point.y / size
        // Convert from scaled cartesian to hex
        let q = x * 2/3
        let r = (sqrt(3) * y - x) / 3
        return axialRound(q: q, r: r)
    }

    /// This takes a fractional coordinate from a pixel to hex conversion and enforces that `q + r + s = 0`
    ///
    /// [Source](https://www.redblobgames.com/grids/hexagons/#rounding)
    private static func axialRound(q fractionalQ: CGFloat, r fractionalR: CGFloat) -> AxialCoordinate {
        let fractionalS = -fractionalQ - fractionalR
        var q = round(fractionalQ)
        var r = round(fractionalR)
        var s = round(fractionalS)

        // We figure out which of the coordinates is the furthest off, and correct it using the other two.
        // If `s` is the furthest off, we can ignore that, since axial only takes `q` and `r`.
        let qDiff = abs(q-fractionalQ)
        let rDiff = abs(r-fractionalR)
        let sDiff = abs(s-fractionalS)

        if qDiff > rDiff && qDiff > sDiff {
            q = -r-s
        } else if rDiff > sDiff {
            r = -q-s
        }

        return AxialCoordinate(q: Int(q), r: Int(r))
    }
}
