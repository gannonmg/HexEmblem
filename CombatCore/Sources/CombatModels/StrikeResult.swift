//
//  StrikeResult.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation
import GameRules

public enum StrikeResult {
    case miss
    case hit(damageInstances: [DamageInstance])
    case critical(damageInstances: [DamageInstance])

    var totalDamage: Int {
        switch self {
        case .miss:
            return 0
        case .hit(let damageInstances):
            return damageInstances.totalDamage
        case .critical(let damageInstances):
            return damageInstances.totalDamage * CombatRules.critDamageMultiplier
        }
    }
}

extension [DamageInstance] {
    var totalDamage: Int { reduce(0) { $0 + $1.amount } }
}
