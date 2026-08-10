//
//  CombatScene+Demo.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/9/26.
//

import BAPlayback
import Foundation
import GameModels
import SpriteKit

extension CombatScene {
    @MainActor
    static func demoScene(size: CGSize) throws -> CombatScene {
        let catalog = try BAProcessedAnimationStore.catalog()

        let initiatorEntry = try BattleAnimationResolver.entry(
            for: .gwendolyn,
            atRange: 1,
            in: catalog
        )

        let responderEntry = try BattleAnimationResolver.entry(
            for: .badGuy,
            atRange: 1,
            in: catalog
        )

        let scene = CombatScene(
            size: size,
            initiatorEvents: try BAProcessedAnimationStore.playableEvents(
                entry: initiatorEntry,
                mode: .meleeAttack
            ),
            responderEvents: try BAProcessedAnimationStore.playableEvents(
                entry: responderEntry,
                mode: .meleeEquipped
            )
        )

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
