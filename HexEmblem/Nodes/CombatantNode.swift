//
//  CombatantNode.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import BAPlayback
import SpriteKit

final class CombatantNode: SKNode {
    private let animationID: String
    private let backNode = LayerSpriteNode()
    private let frontNode = LayerSpriteNode()

    private var animationKey: String { "battleAnimation_\(animationID)" }

    init(
        animationID: String,
        initialZPosition: CGFloat = 0
    ) {
        self.animationID = animationID

        super.init()

        updateZPosition(to: initialZPosition)

        addChild(backNode)
        addChild(frontNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateZPosition(to newZ: CGFloat) {
        self.zPosition = newZ
        backNode.zPosition = newZ - 1
        frontNode.zPosition = newZ
    }

    private func play(frames: [BAPlaybackFrame], repeatForever: Bool) throws {
        removeAction(forKey: animationKey)

        let preparedFrames = try frames.map { frame in
            try PreparedFrame(frame)
        }

        let sequence = SKAction.sequence(
            preparedFrames.map { frame in
                SKAction.sequence([
                    .run { [weak self] in
                        self?.apply(frame)
                    },
                    .wait(forDuration: frame.duration)
                ])
            }
        )

        let action = repeatForever ? SKAction.repeatForever(sequence) : sequence
        run(action, withKey: animationKey)
    }


    private func apply(_ frame: PreparedFrame) {
        switch frame.layerTextures {
        case .single(let texture):
            backNode.resetTexture()
            frontNode.showTexture(texture)
        case .double(let foreground, let background):
            backNode.showTexture(background)
            frontNode.showTexture(foreground)
        }
    }

    func play(mode: BAModeID, repeatForever: Bool = true) throws {
        let sequence = try animationAction(mode: mode)
        let action = repeatForever ? SKAction.repeatForever(sequence) : sequence

        removeAction(forKey: animationKey)
        run(action, withKey: animationKey)
    }

    // Plays one battle animation and returns after the final frame.
    func playOnce(mode: BAModeID) async throws {
        let action = try animationAction(mode: mode)

        removeAction(forKey: animationKey)

        await withCheckedContinuation { continuation in
            run(.sequence([
                action,
                .run { continuation.resume() }
            ]), withKey: animationKey)
        }
    }

    private func animationAction(mode: BAModeID) throws -> SKAction {
        let events = try BAProcessedAnimationStore.playableEvents(
            animationID: animationID,
            mode: mode
        )

        events.forEach { print($0) }

        let frames: [BAPlaybackFrame] = events.compactMap {
            guard case let .frame(baPlaybackFrame) = $0 else { return nil }
            return baPlaybackFrame
        }

        let preparedFrames = try frames.map { try PreparedFrame($0) }

        return SKAction.sequence(
            preparedFrames.map { frame in
                SKAction.sequence([
                    .run { [weak self] in self?.apply(frame) },
                    .wait(forDuration: frame.duration)
                ])
            }
        )
    }
    func stop() {
        removeAction(forKey: animationKey)
        backNode.resetTexture()
        frontNode.resetTexture()
    }

}

final class LayerSpriteNode: SKSpriteNode {
    func showTexture(_ texture: SKTexture) {
        self.texture = texture
        self.size = texture.size()
        self.isHidden = false
    }

    func resetTexture() {
        self.texture = nil
        self.isHidden = true
    }
}

enum LayerTextures {
    case single(SKTexture)
    case double(foreground: SKTexture, background: SKTexture)
}

extension SKTexture {
    static func load(
        imageURL: URL,
        filteringMode: SKTextureFilteringMode = .nearest
    ) throws -> SKTexture {
        guard let image = NSImage(contentsOf: imageURL) else {
            fatalError("Could not find image for url \(imageURL)")
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = filteringMode
        return texture
    }
}
