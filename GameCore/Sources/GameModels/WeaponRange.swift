//
//  WeaponRange.swift
//  hex-emblem-swift-poc
//
//  Created by Matt Gannon on 8/4/26.
//

public typealias WeaponRange = ClosedRange<Int>

extension WeaponRange {
    /// 1
    public static let melee: ClosedRange<Int> = 1...1

    /// 2
    public static let bow: ClosedRange<Int> = 2...2

    /// 1-2
    public static let magic: ClosedRange<Int> = 1...2
}
