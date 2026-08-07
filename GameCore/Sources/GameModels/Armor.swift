//
//  Armor.swift
//  hex-emblem-swift-poc
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation

public struct Armor: Sendable {
    let name: String
    let effects: [CharacterEffect]
}

// MARK: - Basic Armors
extension Armor {
    public static let unarmored = Armor(
        name: "Unarmored",
        effects: [
            .critAvoidBonus(percent: 0.3),
            .statBoost(.dexterity, amount: 4),
        ]
    )

    public static let leather = Armor(
        name: "Leather",
        effects: [
            .statBoost(.defense, amount: 2),
            .equipmentWeight(weight: 2),
        ]
    )

    public static let plate = Armor(
        name: "Plate",
        effects: [
            .statBoost(.defense, amount: 6),
            .damageResistance(.slashing, percent: 0.2),
            .damageResistance(.piercing, percent: 0.15),
            .equipmentWeight(weight: 10),
        ]
    )
}
