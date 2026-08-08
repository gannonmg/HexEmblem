//
//  CombatResult.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation
import GameModels

/// The resolution of a round of combat between two characters.
/// Contains the series of Strikes made as part of the encounter, and optionally the ID of a character who was defeated during the Combat.
public struct CombatSummary {
    public let events: [Event]

    public init(events: [Event]) {
        self.events = events
    }

    public enum Event {
        case strike(CombatStrike)
        case defeat(CombatRole)
    }
}
