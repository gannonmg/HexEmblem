//
//  AnimationLookup.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/11/26.
//

import BAPlayback
import CombatModels
import Foundation
import GameModels

enum AnimationLookup {
    struct EntryRequest {
        let animationID: AnimationID
        let weaponSlot: BAWeaponSlot
        let weaponIsMagical: Bool
        let range: Int
        let catalog: BACatalog
    }

    /// Retrieve the specific animation sequence within a spriteset
    static func entry(
        request: EntryRequest
    ) throws(BattleAnimationResolverError) -> BACatalog.Entry {
        
        // Ensure we have a sprite set at all for this unit
        guard !request.catalog.entries(spriteSetID: request.animationID).isEmpty else {
            throw .spriteSetNotFound(request.animationID)
        }

        // Retrieve the appropriate animation set within the broader sprite set
        // (ie sword, hand axe, magic, etc)
        guard let entry = request.catalog
            .candidateEntries(spriteSetID: request.animationID, slot: request.weaponSlot)
            .qualifiedEntry(qualifier: request.weaponIsMagical ? .magic : nil)
        else {
            throw .slotNotFound(animationID: request.animationID, slot: request.weaponSlot)

        }

        return entry
    }
}

// MARK: - Mode helpers
extension AnimationLookup {
    /// The at-rest pose a combatant holds when not acting.
    static func idleMode(at encounterRange: Int) -> BAModeID {
        encounterRange <= 1 ? .meleeEquipped : .rangedEquipped
    }

    static func strikerMode(
        strike: StrikeResult,
        range: Int
    ) -> BAModeID {
        let isMelee = range <= 1

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
    static func receiverMode(
        strike: StrikeResult,
        range: Int
    ) -> BAModeID {
        let isMelee = range <= 1

        switch strike {
        case .miss:
            return isMelee ? .meleeDodge : .rangedDodge
        case .hit, .critical:
            return isMelee ? .meleeEquipped : .rangedEquipped
        }
    }
}
