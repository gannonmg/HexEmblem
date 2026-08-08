//
//  WeaponDamage.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/4/26.
//

import Foundation

public struct WeaponDamage: Codable, Sendable {
    public let power: Int
    /// The stat that the character uses to determine damage
    /// Typically Str, Int, maybe Dex
    public let baseStat: CharacterStat
    /// Determines what defense stat (defense or willpower) this is tested against
    public let damageClass: DamageClass
    /// Physical weapon type, element, or holy/necrotic
    public let damageType: DamageType
}
