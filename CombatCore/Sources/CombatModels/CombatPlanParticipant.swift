//
//  CombatPlanParticipant.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/4/26.
//

import Foundation
import GameModels

public protocol CombatPlanParticipant {
    var characterID: CharacterID { get }
    var hasPriority: Bool { get }
    var speed: Int { get }
}
