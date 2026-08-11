//
//  Config.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/11/26.
//

import BAPlayback
import CombatModels
import GameModels

extension CombatPlaybackScriptBuilder {
    public struct Config {
        public let initiator: Unit
        public let responder: Unit
        public let range: Int
        public let catalog: BACatalog

        public struct Unit {
            let animationID: AnimationID
            let initialHealth: Int
            let weaponSlot: BAWeaponSlot
            let weaponIsMagical: Bool
        }
    }
}

extension CombatPlaybackScriptBuilder.Config.Unit {
    init(unit: CharacterUnit, startingHealth: Int, atRange encounterRange: Int) {
        self.init(
            animationID: unit.animationID,
            initialHealth: startingHealth,
            weaponSlot: unit.weapon.animationSlot(atRange: encounterRange),
            weaponIsMagical: unit.weapon.hasMagicalDamage
        )
    }
}
