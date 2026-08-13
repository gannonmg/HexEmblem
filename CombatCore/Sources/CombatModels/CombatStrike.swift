//
//  CombatStrike.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation

/// Data representation of a Strike inflicted (or missed) in Combat.
/// Contains the Striker and Receiver IDs, the result of the Strike attempt, and total damage inflicted.
public struct CombatStrike: Codable {
    public let strikerRole: CombatRole
    public let receiverRole: CombatRole
    public let result: StrikeResult
    public let receiverRemainingHealth: Int

    public var totalDamage: Int { result.totalDamage }

    public init(
        strikerRole: CombatRole,
        receiverRole: CombatRole,
        result: StrikeResult,
        receiverRemainingHealth: Int
    ) {
        self.strikerRole = strikerRole
        self.receiverRole = receiverRole
        self.result = result
        self.receiverRemainingHealth = receiverRemainingHealth
    }
}
