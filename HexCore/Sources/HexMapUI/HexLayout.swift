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
        /// Full grid extent in unit-radius space: center-to-center span plus one hex of overhang.
        let width: CGFloat
        let height: CGFloat
        /// Midpoint of the occupied region in unit-radius space, used to recenter the grid.
        let midX: CGFloat
        let midY: CGFloat
    }

    func makeCache(subviews: Subviews) -> CachedData? {
        let coordinates = subviews.compactMap { $0[AxialCoordinateLayoutValueKey.self] }
        if coordinates.isEmpty { return nil }

        let centers = coordinates.map { delta(q: $0.q, r: $0.r) }
        guard let minX = centers.map(\.x).min(),
              let maxX = centers.map(\.x).max(),
              let minY = centers.map(\.y).min(),
              let maxY = centers.map(\.y).max()
        else { return nil }

        return CachedData(
            width: (maxX - minX) + unitHexSize.width,
            height: (maxY - minY) + unitHexSize.height,
            midX: (minX + maxX) / 2,
            midY: (minY + maxY) / 2
        )
    }

    func updateCache(_ cache: inout CachedData?, subviews: Subviews) {
        cache = makeCache(subviews: subviews)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CachedData?) -> CGSize {
        guard let cache else { return .zero }
        let step = step(for: proposal, cache: cache)
        return CGSize(width: step * cache.width, height: step * cache.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CachedData?) {
        guard let cache else { return }

        let step = step(for: proposal, cache: cache)
        let hexProposal = ProposedViewSize(
            width: step * unitHexSize.width,
            height: step * unitHexSize.height
        )

        for subview in subviews {
            guard let coord = subview[AxialCoordinateLayoutValueKey.self] else { continue }
            let unscaled = delta(q: coord.q, r: coord.r)
            let hexCenter = CGPoint(
                x: bounds.midX + (unscaled.x - cache.midX) * step,
                y: bounds.midY + (unscaled.y - cache.midY) * step
            )
            subview.place(at: hexCenter, anchor: .center, proposal: hexProposal)
        }
    }

    // MARK: Helpers

    /// The hex radius in points — the scale factor from unit-radius space to screen space.
    private func step(for proposal: ProposedViewSize, cache: CachedData) -> CGFloat {
        let size = proposal.replacingUnspecifiedDimensions()
        return min(size.width / cache.width, size.height / cache.height)
    }

    /// Width and height of a single hex at radius 1.
    private var unitHexSize: CGSize {
        switch hexOrientation {
        case .pointyTop: CGSize(width: Hexagon.edgeToEdgeRatio, height: Hexagon.pointToPointRatio)
        case .flatTop: CGSize(width: Hexagon.pointToPointRatio, height: Hexagon.edgeToEdgeRatio)
        }
    }

    private func delta(q: Int, r: Int) -> CGPoint {
        switch hexOrientation {
        case .pointyTop:
            CGPoint(
                x: Hexagon.xCartesianOffset(linearDiff: q, offsetDiff: r),
                y: Hexagon.yCartesianOffset(offsetDiff: r)
            )
        case .flatTop:
            CGPoint(
                x: Hexagon.yCartesianOffset(offsetDiff: q),
                y: Hexagon.xCartesianOffset(linearDiff: r, offsetDiff: q)
            )
        }
    }
}
/*
 struct HexLayout: Layout {
 let hexOrientation: HexOrientation

 struct CachedData {
 //        let qDiff: Int
 //        let rDiff: Int
 let width: CGFloat
 let height: CGFloat
 }

 func makeCache(subviews: Subviews) -> CachedData? {
 let coordinates = subviews.compactMap { $0[AxialCoordinateLayoutValueKey.self] }
 if coordinates.isEmpty { return nil }

 guard let minQ = coordinates.map(\.q).min(),
 let maxQ = coordinates.map(\.q).max(),
 let minR = coordinates.map(\.r).min(),
 let maxR = coordinates.map(\.r).max()
 else { return nil }

 let qDiff = maxQ - minQ
 let rDiff = maxR - minR

 // If pointy
 let qSize: CGFloat = qDiff * Hexagon.deltaQRatio // sqrt(3) - width
 let rSize: CGFloat = Hexagon.yCartesianOffset(offsetDiff: rDiff) // 3/2 * rDiff - height per r step

 let (width, height) = switch hexOrientation {
 case .pointyTop: (qSize, rSize)
 case .flatTop: (rSize, qSize)
 }

 return CachedData(width: width, height: height)
 }

 func updateCache(_ cache: inout CachedData?, subviews: Subviews) {
 cache = makeCache(subviews: subviews)
 }

 func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CachedData?) -> CGSize {
 guard let cache else { return .zero }
 let size = proposal.replacingUnspecifiedDimensions()
 let step = min(size.width / cache.width, size.height / cache.height)
 return CGSize(width: step * cache.width, height: step * cache.height)
 }

 /**
  Place the hexagonal subviews using their axial coordinates and a vector system.
  Determine the q and r vectors first, then adjust them for hexagon orienation.

  For axial coordinates, the way to think about hex to pixel conversion is to look at the basis vectors.

  The arrow `(0,0)→(1,0)` is the q basis vector `(x=sqrt(3), y=0)` and `(0,0)→(0,1)` is the r basis vector `(x=sqrt(3)/2, y=3/2)`.

  The pixel coordinate is `q_basis * q + r_basis * r.`

  For example, the hex at (1,1) is the sum of 1 q vector and 1 r vector. A hex at (3,2) would be the sum of 3 q vectors and 2 r vectors.
  */
 func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CachedData?) {
 guard let cache else { return }

 let center = CGPoint(x: bounds.midX, y: bounds.midY)
 let aspectRatio = Hexagon.aspectRatio(for: hexOrientation)

 let size = proposal.replacingUnspecifiedDimensions()
 let step = min(size.width / cache.width, size.height / cache.height)

 let widthMult = switch hexOrientation {
 case .pointyTop: Hexagon.deltaQRatio
 case .flatTop: Hexagon.pointToPointRatio
 }

 let width = step * widthMult
 let proposal = ProposedViewSize(width: width, height: width / aspectRatio)

 // Convert axial to cartesian coordinates
 for subview in subviews {
 guard let coord = subview[AxialCoordinateLayoutValueKey.self] else { continue }

 // Use the layout's stored orientation to determin which delta converts to which cartesian coordinate
 let unscaledCenter = delta(q: coord.q, r: coord.r)

 // Scale translated coordinates based on our hex's radii
 let dx = unscaledCenter.x * step
 let dy = unscaledCenter.y * step

 // (0,0) is at the center, and we are using positive and negative values in each direction.
 let hexCenter = CGPoint(x: center.x + dx, y: center.y + dy)
 subview.place(at: hexCenter, anchor: .center, proposal: proposal)
 }
 }

 // MARK: Helpers
 private func delta(q: Int, r: Int) -> CGPoint {
 switch hexOrientation {
 case .pointyTop:
 let dx = Hexagon.xCartesianOffset(linearDiff: q, offsetDiff: r)
 let dy = Hexagon.yCartesianOffset(offsetDiff: r)
 return CGPoint(x: dx, y: dy)
 case .flatTop:
 let dx = Hexagon.yCartesianOffset(offsetDiff: q)
 let dy = Hexagon.xCartesianOffset(linearDiff: r, offsetDiff: q)
 return CGPoint(x: dx, y: dy)
 }
 }
 }
 */
