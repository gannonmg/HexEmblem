//
//  CombatRules.swift
//  hex-emblem-swift-poc
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation

enum CombatRules {
    /// The speed difference needed for a Combatant to perform a follow-up strike.
    ///
    /// - Note: The value is `5`.
    static let followUpStrikeSpeed: Int = 5

    /// Flat rate added to a Striker's critical hit chance.
    ///
    /// - Note: The value is `0.05`, equivalent to `5%`.
    static let flatCritRateBonus: Double = 0.05

    /// How much the base damage is multiplied by on a critical hit.
    ///
    /// - Note: Crit results in `3x` damage
    static let critDamageMultiplier: Int = 3
}
