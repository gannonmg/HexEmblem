//
//  CombatScene+Demo.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/9/26.
//

import BAPlayback
import CCEvaluator
import CombatModels
import Foundation
import GameModels
import SpriteKit

extension CombatPlaybackScriptBuilder.Config.Unit {
    init(unit: CharacterUnit, startingHealth: Int, atRange encounterRange: Int) {
        self.init(
            animationID: unit.animationID,
            initialHealth: startingHealth,
            weaponSlot: unit.weapon.animationSlot(atRange: encounterRange),
            weaponIsMagical: unit.weapon.hasMagicalDamage
        )
    }
}

extension CombatScene {
    @MainActor
    static func demoScene(size: CGSize) throws -> CombatScene {
        let initiator: CharacterUnit = .gwendolyn
//        let initiator: CharacterUnit = .hunter

        let responder: CharacterUnit = .badGuy
        let range = 1
//        let range = 2

        let combatConfig = CombatConfig(
            initiator: initiator.buildCombatant(),
            responder: responder.buildCombatant(),
            range: range,
            seed: 42
        )

        let summary = try CombatEvaluator(config: combatConfig).getCombatSummary()
        SanityTests.printCombatSummary(summary)

        let builderConfig = CombatPlaybackScriptBuilder.Config(
            initiator: .init(
                unit: initiator,
                startingHealth: combatConfig.initiator.initialHealth,
                atRange: range
            ),
            responder: .init(
                unit: responder,
                startingHealth: combatConfig.responder.initialHealth,
                atRange: range
            ),
            range: range,
            catalog: try BAProcessedAnimationStore.catalog()
        )

        let script = try CombatPlaybackScriptBuilder(config: builderConfig)
            .buildScript(from: summary)

        let scene = CombatScene(script: script, size: size)
        scene.scaleMode = .aspectFill
        return scene
    }
}

extension SKScene {
    @MainActor
    func transitionToCombatDemo() {
        do {
            let combatScene = try CombatScene.demoScene(size: size)
            view?.presentScene(combatScene, transition: .combatSceneTransition)
        } catch {
            print("Failed to build combat demo scene: \(error)")
        }
    }
}
