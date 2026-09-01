//
//  HexScreenMath.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import CoreGraphics
import HECommon

extension HexGeometry {
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
}


// MARK: - Content Rect
extension HexGeometry {
    /// Calculates the relative frame (max height and max width) of any given set of hexs based on their axial coordinates and orientation.
    /// Multiply output by radius to get the actual size of the rect.
    public static func deriveContentRect(
        from cells: some Sequence<some AxialCoordinateProviding>,
        orientation: HexOrientation
    ) -> CGRect {
        let hexSize = switch orientation {
        case .pointyTop: Constants.fractionalPointySize
        case .flatTop: Constants.fractionalFlatSize
        }

        let contentRect: CGRect = cells
            .reduce(CGRect.null) { partialResult, cell in
                let center = hexToCartesianPoint(axialCoordinate: cell, orientation: orientation)
                let cellRect = CGRect(
                    x: center.x - hexSize.width / 2,
                    y: center.y - hexSize.height / 2,
                    width: hexSize.width,
                    height: hexSize.height
                )
                return partialResult.union(cellRect)
            }

        return contentRect
    }
}
