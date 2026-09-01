//
//  HexGridGeometry.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import Algorithms
import Foundation
import HECommon

// Constants and Calculations specifically focused on the relative layout of a hex grid, irregardless to actual pixel size.
// All math is done assuming radius = 1.
// As of now, this should not be doing any computations involving actual hex radius.
public struct HexGridGeometry {
    public enum Constants {
        // Small computation save. Otherwise, allCases must build its array with each call.
        // Measurable if small impact when displaying ~1000+ hexes.
        public static let directions = AxialDirection.allCases
        /// 2
        public static let circumradius: CGFloat = 2
        /// sqrt(3)
        public static let inradius: CGFloat = sqrt(3)

        // Calculated
        public static let fractionalPointySize = CGSize(width: inradius, height: circumradius)
        public static let fractionalFlatSize = CGSize(width: circumradius, height: inradius)

        public static let pointyHexSizeRatio: CGFloat = {
            let size = fractionalPointySize
            return size.width / size.height
        }()

        public static let flatHexSizeRatio: CGFloat = {
            let size = fractionalFlatSize
            return size.width / size.height
        }()
    }
}

// MARK: - Edge and Corner Offsets
// These computations are minimal on their own but have a measurable impact when placing hundreds of cells.
// By building and storing these offsets based on fractional values, we can easily derive the geometrically
// important points of a hex later with just the radius and coordinate.
extension HexGridGeometry {
    public struct EdgeOffset : Sendable, Hashable {
        public let start: CGPoint
        public let end: CGPoint

        public init(start: CGPoint, end: CGPoint) {
            self.start = start
            self.end = end
        }
    }

    private typealias CornerContainer = [HexOrientation: [AxialDirection: CGPoint]]
    private typealias EdgeContainer = [HexOrientation: [AxialDirection: EdgeOffset]]

    public static func fractionalEdgeOffset(
        at direction: AxialDirection,
        fractionalPosition position: CGPoint,
        orientation: HexOrientation
    ) -> EdgeOffset {
        guard let offsetMap = precomputedEdgeOffsets[orientation],
              let offset = offsetMap[direction]
        else { return EdgeOffset(start: .zero, end: .zero) }

        return EdgeOffset(
            start: position + offset.start,
            end: position + offset.end
        )
    }

    public static func fractionalCornerOffsets(for orientation: HexOrientation) -> [CGPoint] {
        // Must map directions instead of directly accessing values to maintain order.
        let offsets = precomputedCornerOffsets[orientation]!
        return Constants.directions.compactMap { offsets[$0] }
    }

    private static let precomputedEdgeOffsets: EdgeContainer = {
        Dictionary(uniqueKeysWithValues: HexOrientation.allCases.map { orientation in
            let edgeMap = Dictionary(uniqueKeysWithValues: Constants.directions.map { direction in
                let radians = direction.angle(for: orientation).radians
                let start = CGPoint.zero.offset(distance: 1, angle: .radians(radians - .pi / 6))
                let end = CGPoint.zero.offset(distance: 1, angle: .radians(radians + .pi / 6))
                return (direction, EdgeOffset(start: start, end: end))
            })
            return (orientation, edgeMap)
        })
    }()

    // Build using the logic we've already done for the edge offsets. Just dropping the last point.
    private static let precomputedCornerOffsets: CornerContainer = {
        Dictionary(uniqueKeysWithValues: HexOrientation.allCases.map { orientation in
            guard let edges = precomputedEdgeOffsets[orientation] else { fatalError() }
            let offsetMap = Dictionary(uniqueKeysWithValues: edges.map {
                return ($0, $1.start)
            })
            return (orientation, offsetMap)
        })
    }()
}

// MARK: - Content Rect
extension HexGridGeometry {
    /// Calculates the relative frame (max height and max width) of any given set of hexs based on their axial coordinates and orientation.
    /// Multiply by radius to get the actual size of the rect.
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
                let center = HexScreenMath.hexToCartesianPoint(axialCoordinate: cell, orientation: orientation)
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
