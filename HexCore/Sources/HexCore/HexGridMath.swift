//
//  HexGridMath.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/18/26.
//

import Foundation

/**
 We will be using pointy-top hexes

 Radius: Center to edge vertex
 Height: 2x radius
 Width: sqrt(3) x size

 Vertical distance: 3/2 x size

 */

public struct Hex: Codable, Sendable {
    public let q: Int
    public let r: Int
    public var s: Int { -(q+r) }
}

extension Hex {
    public static func distance(lhs: Hex, rhs: Hex) -> Int {
        max(
            lhs.q - rhs.q,
            lhs.r - rhs.r,
            lhs.s - rhs.s
        )
    }

    public func offsetBy(q qOffset: Int = 0, r rOffset: Int = 0) -> Hex {
        Hex(q: q + qOffset, r: r + rOffset)
    }

    /// Returns exactly 6 neighbors, beginning with the NE
    public static func neighborCoordinates(hex: Hex) -> [Hex] {
        [
            hex.offsetBy(q: 1, r: 0), hex.offsetBy(q: 0, r: 1), hex.offsetBy(q: -1, r: 1),
            hex.offsetBy(q: -1, r: 0), hex.offsetBy(q: 0, r: -1), hex.offsetBy(q: 1, r: -1),
        ]
    }

    public static func getRange(_ range: Int) -> [Hex] {
        var results: [Hex] = []
        for q in -range...range+1 {
            let minR = max(-range, (q - range))
            let maxR = min(range, (-q + range))
            for r in minR...maxR+1 {
                results.append(Hex(q: q, r: r))
            }
        }
        return results
    }
}
