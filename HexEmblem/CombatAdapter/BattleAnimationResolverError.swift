//
//  BattleAnimationResolverError.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/9/26.
//

import BAPlayback
import Foundation
import GameModels

enum BattleAnimationResolverError: LocalizedError {
    case spriteSetNotFound(AnimationID)
    case slotNotFound(animationID: AnimationID, slot: BAWeaponSlot)
}
