//
//  HexGeometry+Screen.swift
//  HexCore
//
//  Created by Matt Gannon on 9/1/26.
//

import Foundation
import HECommon

extension HexGeometry { public enum Screen {} }

extension HexGeometry.Screen {
    // MARK: - Hex to Pixel (center coordinate)
    public static func pointyHexToPixel(
        axialCoordinate coord: some AxialCoordinateProviding,
        size: CGFloat
    ) -> CGPoint {
        HexGeometry.pointyHexToCartesianPoint(axialCoordinate: coord) * size
    }

    public static func flatHexToPixel(
        axialCoordinate coord: some AxialCoordinateProviding,
        size: CGFloat
    ) -> CGPoint {
        HexGeometry.flatHexToCartesianPoint(axialCoordinate: coord) * size
    }

    // MARK: - Pixel (touch/click) input to Hex
    public static func pixelToPointyHex(point: CGPoint, size: CGFloat) -> AxialCoordinate {
        let width = HexGeometry.Constants.inradius
        let height = HexGeometry.Constants.circumradius

        // Invert the scaling
        let x = point.x / size
        let y = point.y / size
        // Convert from scaled cartesian to hex
        let q = (width * x - y) / 3
        let r = y * height / 3
        return axialRound(q: q, r: r)
    }

    public static func pixelToFlatHex(point: CGPoint, size: CGFloat) -> AxialCoordinate {
        let width = HexGeometry.Constants.circumradius
        let height = HexGeometry.Constants.inradius

        // Invert the scaling
        let x = point.x / size
        let y = point.y / size
        // Convert from scaled cartesian to hex
        let q = x * width / 3
        let r = (height * y - x) / 3
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
