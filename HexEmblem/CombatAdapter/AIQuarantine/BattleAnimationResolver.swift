//
//  BattleAnimationResolver.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/9/26.
//

import BAPlayback
import CombatModels
import GameModels

enum BattleAnimationResolver {
    struct EntryRequest {
        let animationID: AnimationID
        let weaponSlot: BAWeaponSlot
        let weaponIsMagical: Bool
        let range: Int
        let catalog: BACatalog
    }

    /// Retrieve the specific animation sequence within a spriteset
    static func entry(request: EntryRequest) throws(BattleAnimationResolverError) -> BACatalog.Entry {
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

// MARK: CombatPlaybackScriptBuilder.Config builder
extension CombatPlaybackScriptBuilder.Config {
    func entryRequest(for combatRole: CombatRole) -> BattleAnimationResolver.EntryRequest {
        let unit = switch combatRole {
        case .initiator: initiator
        case .responder: responder
        }

        return BattleAnimationResolver.EntryRequest(
            animationID: unit.animationID,
            weaponSlot: unit.weaponSlot,
            weaponIsMagical: unit.weaponIsMagical,
            range: range,
            catalog: catalog
        )
    }
}
