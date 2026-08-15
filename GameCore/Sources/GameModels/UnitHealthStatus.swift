//
//  UnitHealthStatus.swift
//  GameCore
//
//  Created by Matt Gannon on 8/10/26.
//

public struct UnitHealthStatus: Codable, Sendable {
    public private(set) var currentHealth: Int
    public let maxHealth: Int

    public init(currentHealth: Int, maxHealth: Int) {
        self.currentHealth = currentHealth
        self.maxHealth = maxHealth
    }
}

extension UnitHealthStatus {
    public var isAlive: Bool { 0 < currentHealth }

    public var fraction: Double {
        0 < maxHealth ? Double(currentHealth) / Double(maxHealth) : 0
    }

    public var reducedByOne: UnitHealthStatus {
        UnitHealthStatus(
            currentHealth: max(currentHealth - 1, 0),
            maxHealth: maxHealth
        )
    }

    public mutating func reduceByOne() {
        self = self.reducedByOne
    }
}
