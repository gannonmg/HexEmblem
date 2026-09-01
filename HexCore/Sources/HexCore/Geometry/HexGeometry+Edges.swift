//
//  HexGeometry.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import Algorithms
import Foundation
import HECommon

// MARK: - Edge and Corner Offsets
// These computations are minimal on their own but have a measurable impact when placing hundreds of cells.
// By building and storing these offsets based on fractional values, we can easily derive the geometrically
// important points of a hex later with just the radius and coordinate.
extension HexGeometry {
    /// Struct effectively representing a line.
    public struct EdgeOffset : Sendable, Hashable {
        public let start: CGPoint
        public let end: CGPoint

        public init(start: CGPoint, end: CGPoint) {
            self.start = start
            self.end = end
        }
    }

    // MARK: - Lookup functions
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

    // MARK: - Internal storage shapes for edges
    private typealias CornerContainer = [HexOrientation: [AxialDirection: CGPoint]]
    private typealias EdgeContainer = [HexOrientation: [AxialDirection: EdgeOffset]]

    // MARK: - Precomputation
    private static let precomputedEdgeOffsets: EdgeContainer = {
        Dictionary(uniqueKeysWithValues: HexOrientation.allCases.map { orientation in
            let edgeMap = Dictionary(uniqueKeysWithValues: Constants.directions.map { direction in
                let radians = direction.angle(for: orientation).radians
                let start = CGPoint.zero.offset(distance: 1, angle: HexAngle.radians(radians - .pi / 6))
                let end = CGPoint.zero.offset(distance: 1, angle: HexAngle.radians(radians + .pi / 6))
                return (direction, EdgeOffset(start: start, end: end))
            })
            return (orientation, edgeMap)
        })
    }()

    // Build using the logic we've already done for the edge offsets. Just dropping the end point of each edge.
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
