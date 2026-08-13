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
public struct CombatSummary: Codable {
    public let events: [Event]

    package init(events: [Event]) {
        self.events = events
    }

    public enum Event: Codable {
        case strike(CombatStrike)
        case defeat(CombatRole)
    }
}
