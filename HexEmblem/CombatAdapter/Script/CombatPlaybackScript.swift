//
//  CombatPlaybackScript.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/9/26.
//

import BAPlayback
import CombatModels

struct CombatPlaybackScript {
    let initiator: Side
    let responder: Side
    let beats: [Beat]
    let defeated: CombatRole?

    struct Side {
        let role: CombatRole
        let startingHealth: Int
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

extension [BAPlaybackEvent] {
    /// Splits an attacker's stream at the beat where damage lands: everything through the
    /// damage marker, then the follow-through. Streams with no damage beat — idles, dodges —
    /// come back whole, with an empty follow-through.
    func splitAtDamageBeat() -> (windUp: [BAPlaybackEvent], followThrough: [BAPlaybackEvent]) {
        guard let beatIndex = firstDamageBeatIndex else { return (self, []) }

        return (Array(self[...beatIndex]), Array(self[(beatIndex + 1)...]))
    }
}
