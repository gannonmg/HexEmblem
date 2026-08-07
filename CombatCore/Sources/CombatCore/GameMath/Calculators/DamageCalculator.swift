//
//  DamageCalculator.swift
//  hex-emblem-swift-poc
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation

enum DamageCalculator {
    /// Calculates the base amount of damage done by an attack, before accounting for resistances.
    /// Returns a minimum value of `0`.
    static func calculateBaseDamage(attack: Int, defense: Int) -> Int {
        let damage = attack - defense
        return max(0, damage)
    }

    static func calculateDamage(
        attackPower: Int,
        defense: Int,
        resistance: Double
    ) -> Int {
        let baseDamage = calculateBaseDamage(attack: attackPower, defense: defense)
        let amountResisted = Double(baseDamage) * resistance
        let actualDamage = baseDamage - Int(amountResisted)
        return actualDamage
    }
}
