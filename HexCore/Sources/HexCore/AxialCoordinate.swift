//
//  AxialCoordinate.swift
//  HexCore
//
//  Created by Matt Gannon on 8/20/26.
//

import Foundation

public protocol AxialCoordinateProviding {
    var axialCoordinate: AxialCoordinate { get }
}

public struct AxialCoordinate: Hashable, Sendable {
    public let q: Int
    public let r: Int
    public var s: Int { -q - r }

    public init(q: Int, r: Int) {
        self.q = q
        self.r = r
    }
}
