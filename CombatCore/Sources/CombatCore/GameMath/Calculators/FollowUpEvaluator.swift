//
//  FollowUpEvaluator.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/4/26.
//

import Foundation
import GameModels

//public protocol SpeedComparable {
//    var characterID: CharacterID { get }
//    var speed: Int { get }
//}

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

//    static func getFollowUpID(
//        initiator: SpeedComparable,
//        responder: SpeedComparable
//    ) -> CharacterID? {
//        let initiatorSpeed = initiator.speed
//        let responderSpeed = responder.speed
//        let speedDifference = initiatorSpeed - responderSpeed
//
//        switch speedDifference {
//        case ...(-CombatRules.followUpStrikeSpeed):
//            return responder.characterID
//        case CombatRules.followUpStrikeSpeed...:
//            return initiator.characterID
//        default:
//            return nil
//        }
//    }
}
