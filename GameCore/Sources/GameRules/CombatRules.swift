//
//  CombatRules.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation

public enum CombatRules {
    /// The speed difference needed for a Combatant to perform a follow-up strike.
    ///
    /// - Note: The value is `5`.
    public static let followUpStrikeSpeed: Int = 5

    /// Flat rate added to a Striker's critical hit chance.
    ///
    /// - Note: The value is `0.05`, equivalent to `5%`.
    public static let flatCritRateBonus: Double = 0.05

    /// How much the base damage is multiplied by on a critical hit.
    ///
    /// - Note: Crit results in `3x` damage
    public static let critDamageMultiplier: Int = 3
}
