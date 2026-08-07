//
//  DamageInstance.swift
//  hex-emblem-swift-poc
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation
import GameModels

/// Indivudal instance of damage inflicted by a Strike
///
/// A Strike will minimally contain one of these. A weapon that inflicts multiple types of damage will contain multiple.
public struct DamageInstance {
    let amount: Int
    let type: DamageType

    init(amount: Int, type: DamageType) {
        self.amount = max(0, amount)
        self.type = type
    }
}
