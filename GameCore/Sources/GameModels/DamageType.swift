//
//  DamageType.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/4/26.
//

import Foundation

public enum DamageType: Codable, Sendable {
    case slashing, piercing, bludgeoning
    case fire, ice, lightning
    case acid, poison
    case arcane, holy, necrotic
}
