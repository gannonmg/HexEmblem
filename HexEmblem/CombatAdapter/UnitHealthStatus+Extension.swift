//
//  UnitHealthStatus+Extension.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/12/26.
//

import Foundation
import GameModels

extension UnitHealthStatus {
    var isAlive: Bool { 0 < currentHealth }

    var fraction: Double {
        0 < maxHealth ? Double(currentHealth) / Double(maxHealth) : 0
    }

    var reducedByOne: UnitHealthStatus {
        UnitHealthStatus(
            currentHealth: max(currentHealth - 1, 0),
            maxHealth: maxHealth
        )
    }

    mutating func reduceByOne() {
        self = self.reducedByOne
    }
}
