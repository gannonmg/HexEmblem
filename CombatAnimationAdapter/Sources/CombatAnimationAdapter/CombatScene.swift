//
//  CombatScene.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/12/26.
//

import BAPlayback
import CombatModels
import Foundation
import SpriteKit

public struct CombatantDatum<T> {
    private let initiatorDatum: T
    private let responderDatum: T

    public init(_ builder: (CombatRole) throws -> T) rethrows {
        self.initiatorDatum = try builder(.initiator)
        self.responderDatum = try builder(.responder)
    }

    public func `for`(_ role: CombatRole) -> T {
        switch role {
        case .initiator: initiatorDatum
        case .responder: responderDatum
        }
    }
}

public final class CombatScene: SKScene {
    typealias CPAScript = CombatPlaybackAdapter.Script

    private let initiatorNode = CombatantNode(role: .initiator)
    private let responderNode = CombatantNode(role: .responder)

    // MARK: - Init
    private let script: CPAScript
    private let onDamage: @MainActor (CombatRole, Int) async -> Void

    public init(
        size: CGSize,
        script: CombatPlaybackAdapter.Script,
        onDamage: @escaping @MainActor (CombatRole, Int) async -> Void
    ) {
        self.script = script
        self.onDamage = onDamage
        super.init(size: size)

        // Setup
        addCombatants()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func addCombatants() {
        addCharacterToScene(initiatorNode)
        addCharacterToScene(responderNode)

        do {
            let initiatorIdles = script.idleEvents.for(.initiator).frames
            let responderIdles = script.idleEvents.for(.responder).frames

            try initiatorNode.loopFrames(initiatorIdles)
            try responderNode.loopFrames(responderIdles)
        } catch {
            print("Failed to load idle frames")
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
        if character == initiatorNode {
            character.xScale *= -1.0
        }

        addChild(character)
    }

    // MARK: - Playback
    public func beginPlayback() async {
        do {
            for beat in script.beats {
                try await playBeat(beat)
            }
        } catch {
            print("⚠️ Playback failed: \(error)")
        }
    }

    private func playBeat(_ beat: CPAScript.Beat) async throws {
        let strikerNode = node(for: beat.strikerRole)

        // Update the Z positions based on this beat's striker
        setZPositions(striker: beat.strikerRole)

        // Split up the attack in two halves: pre- and post- impact
        // This is like a "dramatic pause" when the hit lands
        let (windUp, followThrough) = beat.strikerEvents.splitAtHPDepletionHold()

        // Play the attack up to the point of impact
        try await strikerNode.playFrames(windUp.frames)

        // Receiver reacts based on the actual result of the strike (hit, miss)
        // The events for this animation are included with the beat
        // We must also wait for the health to drain, driven by an outside clock
        let receiverRole = beat.strikerRole.opponent
        async let react = try playReaction(receiverRole, beat: beat)
        async let drain = onDamage(receiverRole, beat.damage)

        // Run the reaction and health drain simultaneously
        _ = try await (react, drain)

        // Finish out the strik after the pause
        try await strikerNode.playFrames(followThrough.frames)
    }
    
    /// Some units have a lean away pose on the final frame of the attacker sequence, so idle must be restored
    private func playReaction(_ receiverRole: CombatRole, beat: CPAScript.Beat) async throws {
        let receiverNode = node(for: receiverRole)
        let reactionFrames = beat.receiverEvents.frames

        try await receiverNode.playFrames(reactionFrames)
        let receiverIdleFrames = script.idleEvents.for(receiverRole).frames
        try receiverNode.loopFrames(receiverIdleFrames)
    }

    /// Updates the Z positions of the two combatant nodes, placing the striker slightly in front of the receiver.
    ///
    /// Desired layering is: Striker FG, Receiver FG, Str BG, Rec BG.
    private func setZPositions(striker: CombatRole) {
        let (fgNode, bgNode) = (node(for: striker), node(for: striker.opponent))

        let z: CGFloat = 2
        fgNode.updateZPosition(to: z)
        bgNode.updateZPosition(to: z - 0.1)
    }

    private func node(for role: CombatRole) -> CombatantNode {
        switch role {
        case .initiator: initiatorNode
        case .responder: responderNode
        }
    }
}

extension AnimationLayer<Data> {
    func animationTextures() throws -> AnimationLayer<SKTexture> {
        switch self {
        case .single(let data):
            let texture = try SKTexture.load(imageData: data)
            return .single(texture)
        case .dual(let fgData, let bgData):
            let fgTexture = try SKTexture.load(imageData: fgData)
            let bgTexture = try SKTexture.load(imageData: bgData)
            return .dual(foreground: fgTexture, background: bgTexture)
        }
    }
}
