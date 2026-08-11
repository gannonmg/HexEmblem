//
//  UnitHealthStatus.swift
//  GameCore
//
//  Created by Matt Gannon on 8/10/26.
//

public struct UnitHealthStatus: Sendable {
    public let currentHealth: Int
    public let maxHealth: Int

    public init(currentHealth: Int, maxHealth: Int) {
        self.currentHealth = currentHealth
        self.maxHealth = maxHealth
    }
}
