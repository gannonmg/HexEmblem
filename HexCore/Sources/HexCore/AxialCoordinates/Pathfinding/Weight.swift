//
//  Weight.swift
//  HexCore
//
//  Created by Matt Gannon on 9/1/26.
//

import Foundation

public enum Weight: Hashable, Sendable {
    case passable(weight: Int)
    case impassable
}

extension Weight {
    /// The assumed weight of a hex unless specified otherwise
    public static var standard: Weight { .passable(weight: 1) }
}
