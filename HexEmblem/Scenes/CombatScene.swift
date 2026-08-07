//
//  CombatScene.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import BattleAnimationCore
import SpriteKit

final class CombatScene: SKScene {
    private let combatant: CombatantNode

    init(
        size: CGSize,
        combatant: CombatantNode
    ) {
        self.combatant = combatant
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Play the Combat
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray

        addCharacterToScene(combatant, mirror: true)

        do {
            try combatant.play(modeID: .meleeEquipped)
        } catch {
            print("Failed to start idle combat animations: \(error)")
        }

        Task {
            try combatant.play(modeID: .meleeCritical)
        }
    }

    private func addCharacterToScene(_ character: CombatantNode, mirror: Bool) {
        character.position = CGPoint(
            x: frame.midX,
            y: frame.midY
        )

        character.setScale(3)

        if mirror {
            character.xScale *= -1.0
        }

        addChild(character)
    }
}

// MARK: - Scene Construction
extension CombatScene {
    static func demoScene(size: CGSize) -> CombatScene {
        let combatant = CombatantNode(animationID: "LanceHalberdier")
        let scene = CombatScene(size: size, combatant: combatant)
        scene.scaleMode = .aspectFill
        return scene
    }

    static func newScene(size: CGSize, combatant: CombatantNode) -> CombatScene {
        let scene = CombatScene(size: size, combatant: combatant)
        scene.scaleMode = .aspectFill
        return scene
    }
}

extension SKScene {
    func transitionToCombatDemo() {
        let combatScene = CombatScene.demoScene(size: size)
        combatScene.scaleMode = .aspectFill
        view?.presentScene(combatScene, transition: .combatSceneTransition)
    }

    func transitionToCombatScene(combatant: CombatantNode) {
        let combatScene = CombatScene.newScene(
            size: self.size,
            combatant: combatant
        )

        combatScene.scaleMode = .aspectFill
        view?.presentScene(combatScene, transition: .combatSceneTransition)
    }
}
