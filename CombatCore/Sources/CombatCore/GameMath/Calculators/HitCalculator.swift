//
//  HitCalculator.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation

enum HitCalculator {
    static func determineHitChance(
        accuracy: Int,
        evasion: Int,
        toHitBonus: Double,
        evasionBonus: Double
    ) -> Double {
        let hitChance = Double(accuracy) / Double(accuracy + evasion)
        return hitChance + toHitBonus - evasionBonus
    }

    static func determineHit(
        accuracy: Int,
        evasion: Int,
        toHitBonus: Double,
        evasionBonus: Double,
        seed: Int
    ) -> Bool {
        let randomPercentage = Randomizer.percentage(seed: seed)
        let hitChance = determineHitChance(accuracy: accuracy, evasion: evasion, toHitBonus: toHitBonus, evasionBonus: evasionBonus)
        return randomPercentage <= hitChance
    }
}
