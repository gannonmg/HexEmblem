//
//  GameScene.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import SpriteKit

class GameScene: InteractiveScene {
    override func didMove(to view: SKView) {
//        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.transitionToCombatDemo()
    }

    override func interactionBegan(at location: CGPoint) {
//        let box = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
//        box.position = location
//        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
//        addChild(box)
    }
}
