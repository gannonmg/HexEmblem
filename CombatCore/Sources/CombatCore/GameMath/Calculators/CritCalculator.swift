//
//  CritCalculator.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/4/26.
//

import CombatModels
import Foundation
import GameRules

enum CritCalculator {
    /// (Dex / 2) + Rules.flatCritRateBonus (5%) + weapon bonus + skills + class bonus - enemy luck - crit avoid
    static func determineCritChance(
        striker: Combatant,
        receiver: Combatant
    ) -> Double {
        /// Halve Dex, and divide by 100 to get percent value
        let halfDex = Double(striker.effectiveStats[.dexterity]) / 2 / 100
        let critRate = halfDex + CombatRules.flatCritRateBonus + striker.critRateBonus
        let luck = Double(receiver.effectiveStats[.luck])
        let critPenalty = luck + receiver.critAvoidBonus
        return critRate - critPenalty
    }

    static func determineCrit(
        striker: Combatant,
        receiver: Combatant,
        seed: Int
    ) -> Bool {
        let randomPercentage = Randomizer.percentage(seed: seed)
        let critChance = determineCritChance(striker: striker, receiver: receiver)
        return randomPercentage <= critChance
    }
}
