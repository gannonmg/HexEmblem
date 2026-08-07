//
//  CombatStrike.swift
//  hex-emblem-swift-poc
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation

/// Data representation of a Strike inflicted (or missed) in Combat.
/// Contains the Striker and Receiver IDs, the result of the Strike attempt, and total damage inflicted.
public struct CombatStrike {
    public let strikerID: UUID
    public let receiverID: UUID
    public let result: StrikeResult

    public var totalDamage: Int { result.totalDamage }
}
