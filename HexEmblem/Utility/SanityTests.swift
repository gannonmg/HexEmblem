//
//  SanityTests.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/7/26.
//

// This is a transient file which exists to check that packages import correctly and are able to perform their functions.

import CCEvaluator
import CombatModels
import Foundation
import GameModels

enum SanityTests {
    static func testCombatEvaluator() {
        let initiator: CharacterUnit = .gwendolyn
        let responder: CharacterUnit = .badGuy
        var seed = 0

        print("------------------ Begin Combat ------------------")
        print("Seed is \(seed)")

        var bothAlive = true
        while bothAlive {
            let config = CombatConfig(
                initiator: initiator.buildCombatant(),
                responder: responder.buildCombatant(),
                range: 1,
                seed: seed
            )

            let evaluator = CombatEvaluator(config: config)

            // force try ok for testing - shouldn't ever throw anyways
            let summary = try! evaluator.getCombatSummary()
            for event in summary.events {
                switch event {
                case .strike(let combatStrike):
                    printStrike(combatStrike)
                    switch combatStrike.receiverRole {
                    case .initiator: initiator.takeDamage(combatStrike.totalDamage)
                    case .responder: responder.takeDamage(combatStrike.totalDamage)
                    }
                case .defeat(let combatRole):
                    print("\(combatRole) was defeated")
                    bothAlive = false
                }
            }

            seed += 1
        }
        print("------------------- End Combat -------------------")
    }

    private static func printStrike(_ strike: CombatStrike) {
        switch strike.result {
        case .miss:
            print("\(String(describing: strike.strikerRole)) missed their attack")
        case .hit:
            print("\(String(describing: strike.strikerRole)) hit \(String(describing: strike.receiverRole)) for \(strike.totalDamage) damage")
            print("     \(strike.receiverRole) hp: \(strike.receiverRemainingHealth)")
        case .critical:
            print("\(String(describing: strike.strikerRole)) crit on \(String(describing: strike.receiverRole)) for \(strike.totalDamage) damage")
            print("     \(strike.receiverRole) hp: \(strike.receiverRemainingHealth)")

        }
    }
}
