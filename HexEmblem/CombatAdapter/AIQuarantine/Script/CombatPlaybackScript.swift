//
//  CombatPlaybackScript.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/9/26.
//

import BAPlayback
import CombatModels
import GameModels


struct CombatPlaybackScript {
    let initiator: Side
    let responder: Side
    let beats: [Beat]
    let defeated: CombatRole?

    struct Side {
        let role: CombatRole
        let healthStatus: UnitHealthStatus
        let idleEvents: [BAPlaybackEvent]
    }

    struct Beat {
        let attacker: CombatRole
        let attackerEvents: [BAPlaybackEvent]
        let defenderEvents: [BAPlaybackEvent]
        let damage: Int
        let defenderRemainingHealth: Int
    }

    func side(for role: CombatRole) -> Side {
        switch role {
        case .initiator: initiator
        case .responder: responder
        }
    }
}
