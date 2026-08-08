//
//  CombatConfig.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/7/26.
//

import Foundation
import GameModels

public struct CombatConfig {
    public let initiator: Combatant
    public let responder: Combatant
    public let range: Int
    public let seed: Int

    public init(initiator: Combatant, responder: Combatant, range: Int, seed: Int) {
        self.initiator = initiator
        self.responder = responder
        self.range = range
        self.seed = seed
    }
}
