//
//  CharacterEffect.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/4/26.
//

import Foundation

public enum CharacterEffect: Sendable {
    // Stat Effects
    case statBoost(CharacterStat, amount: Int)
    case equipmentWeight(weight: Int)

    // Other riders
    case toHitBonus(percent: Double)
    case evasionBonus(percent: Double)
    case critRateBonus(percent: Double)
    case critAvoidBonus(percent: Double)
    case damageResistance(DamageType, percent: Double)
}
