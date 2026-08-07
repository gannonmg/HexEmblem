//
//  CritCalculator.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/4/26.
//

import Foundation

enum CritCalculator {
    /// (Dex / 2) + Rules.flatCritRateBonus (5%) + weapon bonus + skills + class bonus - enemy luck - crit avoid
    static func determineCritChance(
        striker: Combatant,
        receiver: Combatant
    ) -> Double {
        striker.critRate - receiver.critAvoid
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
