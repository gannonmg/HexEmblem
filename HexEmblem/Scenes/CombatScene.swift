//
//  CombatScene.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import BAPlayback
import SpriteKit

final class CombatScene: SKScene {
    private let initiator = CombatantNode()
    private let responder = CombatantNode()

    private let initiatorEvents: [BAPlaybackEvent]
    private let responderEvents: [BAPlaybackEvent]

    init(
        size: CGSize,
        initiatorEvents: [BAPlaybackEvent],
        responderEvents: [BAPlaybackEvent],
    ) {
        self.initiatorEvents = initiatorEvents
        self.responderEvents = responderEvents
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Play the Combat
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray

        addCharacterToScene(initiator)
        addCharacterToScene(responder)

        do {
            try initiator.play(events: initiatorEvents)
            try responder.play(events: responderEvents)
        } catch {
            print("Failed to start combat animations: \(error)")
        }
    }

    private func addCharacterToScene(_ character: CombatantNode) {
        character.position = CGPoint(
            x: frame.midX,
            y: frame.midY
        )

        character.setScale(3)

        // Animations face left by default.
        // Initiator should be on the left, facing/attacking right
        if character == initiator {
            character.xScale *= -1.0
        }

        addChild(character)
    }
}
