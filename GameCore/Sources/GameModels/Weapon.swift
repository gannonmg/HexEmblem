//
//  Weapon.swift
//  hex-emblem-swift-poc
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation

public struct Weapon: Sendable {
    public let name: String
    public let damage: [WeaponDamage]
    /// Effects on the character - stat boosts, crit rate/avoid, damage resistance, etc
    public let effects: [CharacterEffect]
    public let range: WeaponRange

    init(
        name: String,
        primaryDamage: WeaponDamage,
        damageRiders: [WeaponDamage] = [],
        effects: [CharacterEffect],
        range: WeaponRange
    ) {
        self.name = name
        self.damage = [primaryDamage] + damageRiders
        self.effects = effects
        self.range = range
    }
}

extension WeaponDamage {
    static func physicalDamage(power: Int, baseStat: CharacterStat = .strength, type: DamageType) -> WeaponDamage {
        return .init(power: power, baseStat: baseStat, damageClass: .physical, damageType: type)
    }

    static func magicalDamage(power: Int, type: DamageType) -> WeaponDamage {
        return .init(power: power, baseStat: .intelligence, damageClass: .magical, damageType: type)
    }
}

// MARK: - Basic Weapons
extension Weapon {
    public static let fists = Weapon(
        name: "Fists",
        primaryDamage: .physicalDamage(power: 10, type: .bludgeoning),
        effects: [
            .toHitBonus(percent: 20),
        ],
        range: .melee
    )

    public static let sword = Weapon(
        name: "Sword",
        primaryDamage: .physicalDamage(power: 10, type: .slashing),
        effects: [
            .statBoost(.dexterity, amount: 1),
            .toHitBonus(percent: 10),
            .critRateBonus(percent: 0.05),
            .equipmentWeight(weight: 4),
        ],
        range: .melee
    )

    public static let dagger = Weapon(
        name: "Dagger",
        primaryDamage: .physicalDamage(power: 4, type: .piercing),
        effects: [
            .statBoost(.dexterity, amount: 2),
            .toHitBonus(percent: 20),
            .critRateBonus(percent: 0.1),
            .equipmentWeight(weight: 1),
        ],
        range: .melee
    )

    public static let bow = Weapon(
        name: "Bow",
        primaryDamage: .physicalDamage(power: 8, baseStat: .dexterity, type: .piercing),
        effects: [
            .toHitBonus(percent: 5),
            .critRateBonus(percent: 0.05),
            .equipmentWeight(weight: 4),
        ],
        range: 2...3
    )

    public static let lightningBolt = Weapon(
        name: "Lightning Bolt",
        primaryDamage: .magicalDamage(power: 15, type: .lightning),
        effects: [
            .toHitBonus(percent: -5),
            .critRateBonus(percent: 0.25),
            .equipmentWeight(weight: 2),
        ],
        range: 1...2
    )

    public static let fireStaff = Weapon(
        name: "Fire Staff",
        primaryDamage: .magicalDamage(power: 20, type: .fire),
        effects: [
            .statBoost(.intelligence, amount: 2),
            .toHitBonus(percent: -10),
            .critRateBonus(percent: 0.2),
            .equipmentWeight(weight: 8),
        ],
        range: 1...3
    )
}
