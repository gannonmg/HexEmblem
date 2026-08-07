//
//  GameScene.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import SpriteKit

class GameScene: InteractiveScene {
    override func didMove(to view: SKView) {
        self.transitionToCombatDemo()
    }

    override func interactionBegan(at location: CGPoint) {}
}
