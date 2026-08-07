//
//  Combatant.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation
import GameModels

public protocol Combatant: CombatPlanParticipant {
    var characterID: CharacterID { get }

    /// Health at beginning of this combat
    var initialHealth: Int { get }

    // Weapon / Armor effects
    var weaponDamage: [WeaponDamage] { get }
    var weaponRange: WeaponRange { get }
    var resistances: [DamageType: Double] { get }

    /// StatBlock Accounting for all relevant boosts
    var effectiveStats: CharacterStatBlock { get }

    /// Whether the unit has strike priority (from skills like FE Vantage)
    var hasPriority: Bool { get }

    // Bonuses from equipped weapon + armor + skills
    /// Striker crit chance from `dexterity`, ``CombatRules.flatCritRateBonus``, weapon, skills, and class.
    /// Not including any enemy evasion bonuses.
    var critRate: Double { get }
    /// Penalty applied to Striker's crit chance based on `luck` and equipment crit avoid bonuses.
    var critAvoid: Double { get }
    var toHitBonus: Double { get }
    var evasionBonus: Double { get }
}

extension Combatant {
    public var speed: Int { effectiveStats[.speed] }

    /// Helper for getting the correct defense for physical or melee damage
    public func defenseValue(for damageClass: DamageClass) -> Int {
        switch damageClass {
        case .physical: effectiveStats[.defense]
        case .magical: effectiveStats[.willpower]
        }
    }
}

extension CharacterUnit: Combatant {
    public var initialHealth: Int { currentHealth }
    public var weaponDamage: [WeaponDamage] { weapon.damage }
    public var weaponRange: WeaponRange { weapon.range }
    public var resistances: [DamageType : Double] { getResistances() }
    public var hasPriority: Bool { false }
    public var critRate: Double { critRateBonus() }
    public var critAvoid: Double { critAvoidBonus() }
}
