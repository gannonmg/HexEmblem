//
//  Randomizer.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/2/26.
//

import GameplayKit

enum Randomizer {
    static func percentage(seed: Int) -> Double {
        let randomSource = GKMersenneTwisterRandomSource(seed: UInt64(abs(seed)))
        let randomNumber = randomSource.nextInt(upperBound: 100)
        let randomDouble = Double(randomNumber)
        return randomDouble / 100
    }
}
