//
//  CombatantProvider.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/8/26.
//

import Foundation
import GameModels

public protocol CombatantProvider {
    func buildCombatant() -> Combatant
}

extension CharacterUnit: CombatantProvider {
    public func buildCombatant() -> Combatant {
        Combatant(
            characterID: characterID,
            initialHealthStatus: healthStatus,
            weaponDamage: weapon.damage,
            weaponRange: weapon.range,
            resistances: getResistances(),
            effectiveStats: effectiveStats,
            // TODO: Implement priority
            hasPriority: false,
            critRateBonus: critRateBonus,
            critAvoidBonus: critAvoidBonus,
            toHitBonus: toHitBonus,
            evasionBonus: evasionBonus
        )
    }
}
