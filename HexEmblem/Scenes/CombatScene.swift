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
    private let onDamage: @MainActor (CombatRole, Int) async -> Void

    init(
        script: CombatPlaybackScript,
        size: CGSize,
        onDamage: @escaping @MainActor (CombatRole, Int) async -> Void
    ) {
        self.script = script
        self.onDamage = onDamage
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

        initiator.name = "initiator"
        responder.name = "responder"

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

    override func update(_ currentTime: TimeInterval) {
        speed = PlaybackDebug.shared.speed
    }

    private func playCombat() async {
        print("beats: \(script.beats.count) — \(script.beats.map { "\($0.attacker) dmg \($0.damage)" })")
        do {
            for beat in script.beats {
                print("     playing beat: \(beat.attacker)")
                try await playBeat(beat)
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

    /// The attacker swings alone up to the damage beat. The defender reacts while the bar drains,
    /// and the follow-through is held until the drain finishes — that hold is what `C01`
    /// (wait-for-HP-deplete) waits on in the scripts.
    private func playBeat(_ beat: CombatPlaybackScript.Beat) async throws {
        let defenderRole = beat.attacker.opponent

        let attacker = node(for: beat.attacker)
        let defender = node(for: defenderRole)

        attacker.updateZPosition(to: 1)
        defender.updateZPosition(to: 0.9)

        let (windUp, followThrough) = beat.attackerEvents.splitAtHPDepletionHold()

        try await attacker.playOnce(events: windUp)

        async let reaction: Void = defender.playOnce(events: beat.defenderEvents)
        async let drain: Void = onDamage(defenderRole, beat.defenderRemainingHealth)

        _ = try await (reaction, drain)

        try await attacker.playOnce(events: followThrough)
    }

    private func node(for role: CombatRole) -> CombatantNode {
        switch role {
        case .initiator: initiator
        case .responder: responder
        }
    }
}
