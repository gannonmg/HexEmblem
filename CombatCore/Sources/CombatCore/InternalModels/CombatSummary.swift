//
//  CombatResult.swift
//  hex-emblem-swift-poc
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation
import GameModels

/// The resolution of a round of combat between two characters.
/// Contains the series of Strikes made as part of the encounter, and optionally the ID of a character who was defeated during the Combat.
public struct CombatSummary {
    public let strikes: [CombatStrike]
    public var defeatedCharacterID: CharacterID? = nil
}
