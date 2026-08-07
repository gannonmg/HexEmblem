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
        while initiator.isAlive && responder.isAlive {
            print("Seed is \(seed)")
            let config = CombatConfig(
                initiator: initiator,
                responder: responder,
                range: 1,
                seed: seed
            )

            let evaluator = CombatEvaluator(config: config)
            let summary = evaluator.getCombatSummary()
            for strike in summary.strikes {
                switch strike.result {
                case .miss:
                    print("\(String(describing: strike.strikerRole)) missed their attack")
                case .hit:
                    print("\(String(describing: strike.strikerRole)) dealt \(strike.totalDamage) to \(String(describing: strike.receiverRole))")
                case .critical:
                    print("\(String(describing: strike.strikerRole)) dealt \(strike.totalDamage) to \(String(describing: strike.receiverRole)) with a critical hit")
                }

                switch strike.strikerRole {
                case .initiator:
                    initiator.takeDamage(strike.totalDamage)
                case .responder:
                    responder.takeDamage(strike.totalDamage)
                }
            }

            switch summary.defeatedCharacterRole {
            case .initiator:
                print("Responder Won")
            case .responder:
                print("Initator Won")
            default:
                break
            }

            seed += 1
        }
        print("------------------- End Combat -------------------")
    }
}
