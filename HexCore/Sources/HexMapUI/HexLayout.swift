//
//  HexLayout.swift
//  HexCore
//
//  Created by Matt Gannon on 8/21/26.
//

import HexCore
import SwiftUI

struct AxialCoordinateLayoutValueKey: LayoutValueKey {
    static let defaultValue: AxialCoordinate? = nil
}

// MARK: - Cache
struct HexLayout: Layout {
    let hexOrientation: HexOrientation

    struct CachedData {
        /// Size of the grid as painted, in unit-radius space.
        let extent: CGSize
        /// Midpoint the arrangement must be centered on before the rotation is applied,
        /// in unit-radius space.
        let midpoint: CGPoint
    }

    func makeCache(subviews: Subviews) -> CachedData? {
        let coordinates = subviews.compactMap { $0[AxialCoordinateLayoutValueKey.self] }
        if coordinates.isEmpty { return nil }

        let rotation = hexOrientation.rotationFromFlatTop
        let rotatedCenters = coordinates.map { flatTopPosition(of: $0).rotated(by: rotation) }

        guard let minimumX = rotatedCenters.map(\.x).min(),
              let maximumX = rotatedCenters.map(\.x).max(),
              let minimumY = rotatedCenters.map(\.y).min(),
              let maximumY = rotatedCenters.map(\.y).max()
        else { return nil }

        let paintedHexSize = unitHexSize(for: hexOrientation)
        let paintedMidpoint = CGPoint(
            x: (minimumX + maximumX) / 2,
            y: (minimumY + maximumY) / 2
        )

        return CachedData(
            // Centers only span to the outermost hex center, so add half a hex of overhang on each side.
            extent: CGSize(
                width: (maximumX - minimumX) + paintedHexSize.width,
                height: (maximumY - minimumY) + paintedHexSize.height
            ),
            // Subviews are placed before the rotation is applied, so un-rotate the painted midpoint.
            midpoint: paintedMidpoint.rotated(by: .radians(-rotation.radians))
        )
    }

    func updateCache(_ cache: inout CachedData?, subviews: Subviews) {
        cache = makeCache(subviews: subviews)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CachedData?) -> CGSize {
        guard let cache else { return .zero }

        let hexRadius = fittedHexRadius(in: proposal, extent: cache.extent)
        return CGSize(
            width: hexRadius * cache.extent.width,
            height: hexRadius * cache.extent.height
        )
    }

    /**
     Place the hexagonal subviews using their axial coordinates and a vector system.

     For axial coordinates, the way to think about hex to pixel conversion is to look at the basis vectors.

     The arrow `(0,0)→(1,0)` is the q basis vector and `(0,0)→(0,1)` is the r basis vector, and the pixel
     coordinate is `q_basis * q + r_basis * r`. For example, the hex at (1,1) is the sum of 1 q vector and
     1 r vector. A hex at (3,2) would be the sum of 3 q vectors and 2 r vectors.

     Positions here are always flat-top. `HexGrid` rotates the finished grid to reach pointy-top, so this
     method only ever deals with one basis.
     */
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CachedData?) {
        guard let cache else { return }

        let hexRadius = fittedHexRadius(in: proposal, extent: cache.extent)
        let flatTopHexSize = unitHexSize(for: .flatTop)
        let hexProposal = ProposedViewSize(
            width: hexRadius * flatTopHexSize.width,
            height: hexRadius * flatTopHexSize.height
        )

        for subview in subviews {
            guard let coordinate = subview[AxialCoordinateLayoutValueKey.self] else { continue }

            let position = flatTopPosition(of: coordinate)
            let hexCenter = CGPoint(
                x: bounds.midX + (position.x - cache.midpoint.x) * hexRadius,
                y: bounds.midY + (position.y - cache.midpoint.y) * hexRadius
            )
            subview.place(at: hexCenter, anchor: .center, proposal: hexProposal)
        }
    }

    // MARK: Helpers

    /// Position of a hex center in unit-radius space. Always flat-top; `HexGrid` applies the rotation.
    private func flatTopPosition(of coordinate: AxialCoordinate) -> CGPoint {
        CGPoint(
            x: Hexagon.yCartesianOffset(offsetDiff: coordinate.q),
            y: Hexagon.xCartesianOffset(linearDiff: coordinate.r, offsetDiff: coordinate.q)
        )
    }

    /// Width and height of a single hex at radius 1.
    private func unitHexSize(for orientation: HexOrientation) -> CGSize {
        switch orientation {
        case .pointyTop: CGSize(width: Hexagon.edgeToEdgeRatio, height: Hexagon.pointToPointRatio)
        case .flatTop: CGSize(width: Hexagon.pointToPointRatio, height: Hexagon.edgeToEdgeRatio)
        }
    }

    /// The hex radius in points — the scale from unit-radius space to screen space.
    private func fittedHexRadius(in proposal: ProposedViewSize, extent: CGSize) -> CGFloat {
        let availableSize = proposal.replacingUnspecifiedDimensions()
        return min(availableSize.width / extent.width, availableSize.height / extent.height)
    }
}
