//
//  FollowUpEvaluator.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/4/26.
//

import CombatModels
import Foundation
import GameModels
import GameRules

enum FollowUpEvaluator {
    static func getFollowUpRole(
        initiatorSpeed: Int,
        responderSpeed: Int
    ) -> CombatRole? {
        let speedDifference = initiatorSpeed - responderSpeed

        switch speedDifference {
        case ...(-CombatRules.followUpStrikeSpeed):
            return .responder
        case CombatRules.followUpStrikeSpeed...:
            return .initiator
        default:
            return nil
        }
    }
}
