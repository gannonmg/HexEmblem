//
//  Combatant.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation
import GameModels

public struct Combatant: CombatPlanParticipant, Codable, Sendable {
    public let characterID: CharacterID

    /// Health at beginning of this combat
    public let initialHealthStatus: UnitHealthStatus

    // Weapon / Armor effects
    public let weaponDamage: [WeaponDamage]
    public let weaponRange: WeaponRange
    public let resistances: [DamageType: Double]

    /// StatBlock Accounting for all relevant boosts
    public let effectiveStats: CharacterStatBlock

    /// Whether the unit has strike priority (from skills like FE Vantage)
    public let hasPriority: Bool

    // Bonuses from equipped weapon + armor + skills
    /// Striker crit rate bonus from equipment weapon, skills, and class.
    /// Does **not** include Dexterity skill or flat rate.
    public let critRateBonus: Double
    /// Penalty applied to Striker's crit chance based on equipment crit avoid bonuses.
    /// Does **not** include Luck skill.
    public let critAvoidBonus: Double
    public let toHitBonus: Double
    public let evasionBonus: Double
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
