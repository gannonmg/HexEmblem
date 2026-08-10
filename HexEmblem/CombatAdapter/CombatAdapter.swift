//
//  CombatAdapter.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/8/26.
//

import BAPlayback
import CombatCore
import CombatModels
import Foundation
import GameModels

// MARK: - Weapon adapter
extension Weapon {
    func animationSlot(atRange encounterRange: Int) -> BAWeaponSlot {
        switch kind {
        case .sword:
            return .sword
        case .lance:
            return .lance
        case .bow:
            return .bow
        case .magic:
            return .magic
        case .staff:
            return .staff
        case .unarmed:
            return .unarmed
        case .axe:
            let effectiveRange = min(max(encounterRange, range.lowerBound), range.upperBound)
            return 1 < effectiveRange ? .handaxe : .axe
        }
    }

    var hasMagicalDamage: Bool { self.damage.contains { $0.damageClass == .magical } }
}

// MARK: - BattleAnimationResolver
enum BattleAnimationResolver {
    static func entry(
        for unit: CharacterUnit,
        atRange encounterRange: Int,
        in catalog: BACatalog
    ) throws(BattleAnimationResolverError) -> BACatalog.Entry {
        // Ensure we have a sprite set at all for this unit
        guard !catalog.entries(spriteSetID: unit.animationID).isEmpty else {
            throw .spriteSetNotFound(unit.animationID)
        }

        // Retrieve the appropriate animation set within the broader sprite set
        // (ie sword, hand axe, magic, etc)
        let weapon = unit.weapon
        let weaponSlot = weapon.animationSlot(atRange: encounterRange)

        guard let entry = catalog.entry(
            spriteSetID: unit.animationID,
            slot: weaponSlot,
            qualifier: weapon.hasMagicalDamage ? .magic : nil
        ) else {
            throw .slotNotFound(animationID: unit.animationID, slot: weaponSlot)
        }

        return entry
    }
}

enum BattleAnimationResolverError: Error {
    case spriteSetNotFound(AnimationID)
    case slotNotFound(animationID: AnimationID, slot: BAWeaponSlot)
}

// MARK: - CombatPlaybackScript
struct CombatPlaybackScript {
    let range: Int
    let initiator: Side
    let responder: Side
    let beats: [Beat]
    let defeated: CombatRole?

    struct Side {
        let role: CombatRole
        let entry: BACatalog.Entry
        let startingHealth: Int
    }

    struct Beat {
        let attacker: CombatRole
        let attackerEvents: [BAPlaybackEvent]
        let defenderEvents: [BAPlaybackEvent]
        let damage: Int
        let defenderRemainingHealth: Int
    }
}
