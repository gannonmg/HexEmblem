//
//  WeightMap.swift
//  HexCore
//
//  Created by Matt Gannon on 8/20/26.
//

import Foundation

public typealias WeightMap = [Int: [Int: [Int: Weight]]]

extension WeightMap {
    public subscript(_ coordinate: AxialCoordinate) -> Weight? {
        get { weight(at: coordinate) }
        set { storeWeight(newValue, at: coordinate) }
    }

    public func weight(at coordinate: AxialCoordinate) -> Weight? {
        self[coordinate.q]?[coordinate.r]?[coordinate.s]
    }

    public mutating func storeWeight(_ weight: Weight?, at coordinate: AxialCoordinate) {
        self[coordinate.q, default: [:]][coordinate.r, default: [:]][coordinate.s] = weight
    }
}
