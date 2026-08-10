//
//  CombatScene.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import BAPlayback
import CombatModels
import SpriteKit

final class CombatScene: SKScene {
    private let initiator = CombatantNode()
    private let responder = CombatantNode()

    private let script: CombatPlaybackScript

    init(
        script: CombatPlaybackScript,
        size: CGSize
    ) {
        self.script = script
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
            try initiator.play(events: script.initiator.idleEvents)
            try responder.play(events: script.responder.idleEvents)
        } catch {
            print("Failed to establish idle poses: \(error)")
        }

        Task { @MainActor in
            await playCombat()
        }
    }

    private func playCombat() async {
        print("beats: \(script.beats.count) — \(script.beats.map { "\($0.attacker) dmg \($0.damage)" })")
        do {
            for beat in script.beats {
                print("     playing beat: \(beat.attacker)")
                try await play(beat)
            }

            try returnToIdle()
        } catch {
            print("Combat playback failed: \(error)")
        }
    }

    private func returnToIdle() throws {
        for side in [script.initiator, script.responder] where side.role != script.defeated {
            try node(for: side.role).play(events: side.idleEvents)
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

    /// The attacker swings alone up to the damage beat, then the defender reacts while the
    /// attacker follows through.
    private func play(_ beat: CombatPlaybackScript.Beat) async throws {
        let attacker = node(for: beat.attacker)
        let defender = node(for: beat.attacker.opponent)

        let (windUp, followThrough) = beat.attackerEvents.splitAtDamageBeat()

        try await attacker.playOnce(events: windUp)

        async let reaction: Void = defender.playOnce(events: beat.defenderEvents)
        async let follow: Void = attacker.playOnce(events: followThrough)

        _ = try await (reaction, follow)
    }

    private func node(for role: CombatRole) -> CombatantNode {
        switch role {
        case .initiator: initiator
        case .responder: responder
        }
    }
}
