//
//  Hex.swift
//  HexCore
//
//  Created by Matt Gannon on 8/19/26.
//

import Foundation

public struct WeightedHex: Hashable, Sendable {
    public let coordinate: AxialCoordinate
    public let weight: Weight

    public init(q: Int, r: Int, weight: Weight) {
        self.coordinate = AxialCoordinate(q: q, r: r)
        self.weight = weight
    }
}

extension WeightedHex: AxialCoordinateProviding {
    public var axialCoordinate: AxialCoordinate { coordinate }
}

extension WeightedHex {
    public var q: Int { coordinate.q }
    public var r: Int { coordinate.r }
    public var s: Int { coordinate.s }
}

public enum Weight: Hashable, Sendable {
    case passable(weight: Int)
    case impassable
}

extension Weight {
    /// The assumed weight of a hex unless specified otherwise
    public static var standard: Weight { .passable(weight: 1) }
}
