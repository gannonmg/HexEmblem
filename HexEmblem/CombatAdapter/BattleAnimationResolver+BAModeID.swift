//
//  BattleAnimationResolver+BAModeID.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/9/26.
//

import BAPlayback
import CombatModels
import Foundation

// MARK: - Derive BAModeIDs from strike results
extension BattleAnimationResolver {
    /// The at-rest pose a combatant holds when not acting.
    static func idleMode(at encounterRange: Int) -> BAModeID {
        encounterRange <= 1 ? .meleeEquipped : .rangedEquipped
    }

    static func attackerMode(for strike: StrikeResult, at encounterRange: Int) -> BAModeID {
        let isMelee = encounterRange <= 1

        switch strike {
        case .miss:
            return .attackMissed
        case .hit:
            return isMelee ? .meleeAttack : .rangedAttack
        case .critical:
            return isMelee ? .meleeCritical : .rangedCritical
        }
    }

    /// The receiver's pose. A hit has no dedicated defender mode — the engine drives recoil
    /// off the HP drain, so the defender holds an equipped idle.
    static func defenderMode(for strike: StrikeResult, at encounterRange: Int) -> BAModeID {
        let isMelee = encounterRange <= 1

        switch strike {
        case .miss:
            return isMelee ? .meleeDodge : .rangedDodge
        case .hit, .critical:
            return isMelee ? .meleeEquipped : .rangedEquipped
        }
    }
}
