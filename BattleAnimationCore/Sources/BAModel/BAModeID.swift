//
//  BAModeID.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/5/26.
//

import Foundation

public enum BAModeID: String, Codable, Hashable, Sendable {
    case meleeAttack
    case meleeCritical
    case rangedAttack
    case rangedCritical
    case meleeDodge
    case rangedDodge
    case meleeEquipped
    case standing
    case rangedEquipped
    case attackMissed
    case unknown
}

extension BAModeID {
    public init(rawModeNumber: Int) {
        self = switch rawModeNumber {
        case 1:  .meleeAttack
        case 3:  .meleeCritical
        case 5:  .rangedAttack
        case 6:  .rangedCritical
        case 7:  .meleeDodge
        case 8:  .rangedDodge
        case 9:  .meleeEquipped
        case 10: .standing
        case 11: .rangedEquipped
        case 12: .attackMissed
        default: .unknown
        }
    }
}
