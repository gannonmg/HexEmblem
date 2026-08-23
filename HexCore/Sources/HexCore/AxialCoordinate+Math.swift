//
//  AxialCoordinate+Math.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/18/26.
//

import Foundation

// MARK: - Instance methods
extension AxialCoordinate {
    public func distance(from coordinate: AxialCoordinate) -> Int {
        AxialCoordinate.distance(lhs: self, rhs: coordinate)
    }

    public func offsetBy(q qOffset: Int, r rOffset: Int) -> AxialCoordinate {
        Self.offsetCoordinate(of: self, byQ: qOffset, r: rOffset)
    }

    public func neighbors() -> Set<AxialCoordinate> { AxialCoordinate.neighbors(of: self)  }
}

// MARK: - Static Implementations
extension AxialCoordinate {
    private static var directions: [(q: Int, r: Int)] {
        [(1, -1), (1, 0), (0, 1), (-1, 1), (-1, 0), (0, -1)]
    }

    // MARK: Distance
    public static func distance(lhs: AxialCoordinate, rhs: AxialCoordinate) -> Int {
        max(
            abs(lhs.q - rhs.q),
            abs(lhs.r - rhs.r),
            abs(lhs.s - rhs.s)
        )
    }

    // MARK: Neighbors
    /// Returns exactly 6 neighbors, all distance 1, beginning with the NorthEast neighbors
    public static func neighbors(of coordinate: AxialCoordinate) -> Set<AxialCoordinate> {
        Set(directions.map { offsetCoordinate(of: coordinate, byQ: $0, r: $1) })
    }

    public static func offsetCoordinate(of coordinate: AxialCoordinate, byQ qOffset: Int, r rOffset: Int) -> AxialCoordinate {
        AxialCoordinate(q: coordinate.q + qOffset, r: coordinate.r + rOffset)
    }

    /// A rectangular block of coordinates centered as closely as possible on `(0,0)`.
    ///
    /// `columns` and `rows` are counts of hexes across and down as they appear on screen, so the
    /// same arguments give the same visual shape in either orientation. An odd count puts `(0,0)`
    /// exactly at the center; an even count has no true center, so the extra column or row is
    /// added on the positive side.
    public static func rectangle(columns: Int, rows: Int, orientation: HexOrientation) -> Set<AxialCoordinate> {
        guard columns > 0, rows > 0 else { return [] }

        let firstColumn = -((columns - 1) / 2)
        let firstRow = -((rows - 1) / 2)

        var results: Set<AxialCoordinate> = []
        for column in firstColumn..<(firstColumn + columns) {
            for row in firstRow..<(firstRow + rows) {
                results.insert(coordinate(column: column, row: row, orientation: orientation))
            }
        }
        return results
    }

    /// Converts a screen-space column/row index into an axial coordinate, cancelling the stagger
    /// that axial coordinates build into whichever axis runs diagonally for this orientation.
    /// Without the correction the block renders as a parallelogram rather than a rectangle.
    private static func coordinate(column: Int, row: Int, orientation: HexOrientation) -> AxialCoordinate {
        switch orientation {
        case .flatTop:
            // Columns are lines of constant q, and each successive column sits half a row lower.
            AxialCoordinate(q: column, r: row - flooredHalf(of: column))
        case .pointyTop:
            // Rows are lines of constant r, and each successive row sits half a column right.
            AxialCoordinate(q: column - flooredHalf(of: row), r: row)
        }
    }

    /// Halves toward negative infinity. Plain `/ 2` truncates toward zero, which would shift the
    /// negative half of the grid the wrong way and shear it.
    private static func flooredHalf(of value: Int) -> Int {
        Int((Double(value) / 2).rounded(.down))
    }

    public static func disk(center: AxialCoordinate, radius: Int) -> Set<AxialCoordinate> {
        var results: Set<AxialCoordinate> = []
        for q in -radius...radius {
            // Calculate valid r bounds using the implicit s component logic (s == -q - r)
            let minR = max(-radius, (-q - radius))
            let maxR = min(radius, (-q + radius))

            for r in minR...maxR {
                let member = self.offsetCoordinate(of: center, byQ: q, r: r)
                results.insert(member)
            }
        }
        return results
    }

    public static func ring(center: AxialCoordinate, radius: Int) throws(HexCoreError) -> Set<AxialCoordinate> {
        guard 0 <= radius else { throw .nonPositiveRadiusRequest }
        if radius == 0 { return [center] }

        var results: Set<AxialCoordinate> = []

        guard let startingDirection = directions.first else {
            fatalError("Directions should always have 6 values")
        }

        var current = offsetCoordinate(
            of: center,
            byQ: radius * startingDirection.q,
            r: radius * startingDirection.r
        )

        let directionsCount = directions.count
        directions.indices.forEach { i in
            let direction = directions[(i+2) % directionsCount]
            (0..<radius).forEach { _ in
                results.insert(current)
                current = offsetCoordinate(of: current, byQ: direction.q, r: direction.r)
            }
        }

        return results
    }
}
