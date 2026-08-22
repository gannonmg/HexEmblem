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
