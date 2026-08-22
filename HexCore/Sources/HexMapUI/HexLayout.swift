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
        let rSize: CGFloat = rDiff * Hexagon.deltaRRatio // 4/3 - height

        let (width, height) = switch hexOrientation {
        case .pointyTop: (qSize, rSize)
        case .flatTop: (rSize, qSize)
        }


        return CachedData(width: width, height: height)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CachedData?) -> CGSize {
        guard let cache else { return .zero }

        let size = proposal.replacingUnspecifiedDimensions()
        let aspectRatio = Hexagon.aspectRatio(for: hexOrientation)
        let step = min(size.width / cache.width, size.height / cache.height / aspectRatio)

        return CGSize(width: step * cache.width, height: step * cache.height * aspectRatio)
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
        let step = min(size.width / cache.width,
                       size.height / cache.height / aspectRatio)

        let widthMult = switch hexOrientation {
        case .pointyTop: Hexagon.deltaQRatio
        case .flatTop: Hexagon.deltaRRatio
        }

        let width = step * widthMult
        let proposal = ProposedViewSize(width: width, height: width / aspectRatio)

        let pixelRadius: CGFloat = 10

        // Convert axial to cartesian coordinates
        for subview in subviews {
            guard let coord = subview[AxialCoordinateLayoutValueKey.self] else { continue }

            // Use the layout's stored orientation to determin which delta converts to which cartesian coordinate
            let unscaledCenter = delta(q: coord.q, r: coord.r)

            // Scale translated coordinates based on our hex's radii
            let dx = unscaledCenter.x * pixelRadius
            let dy = unscaledCenter.y * pixelRadius

            // (0,0) is at the center, and we are using positive and negative values in each direction.
            let hexCenter = CGPoint(x: center.x + dx, y: center.y + dy)
            subview.place(at: hexCenter, anchor: .center, proposal: proposal)
        }
    }

    // MARK: Helpers
    private func delta(q: Int, r: Int) -> CGPoint {
        let (ld, od) = switch hexOrientation {
        case .pointyTop: (q, r)
        case .flatTop: (r, q)
        }

        let dx = Hexagon.xCartesianOffset(linearDiff: ld, offsetDiff: od)
        let dy = Hexagon.yCartesianOffset(offsetDiff: od)
        return CGPoint(x: dx, y: dy)
    }
}
