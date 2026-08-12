//
//  CombatantNode.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import BAPlayback
import GameModels
import SpriteKit

final class CombatantNode: SKNode {

    private static let animationKey = "battleAnimation"

    private let backNode = LayerSpriteNode()
    private let frontNode = LayerSpriteNode()

    override init() {
        super.init()
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

    func play(events: [BAPlaybackEvent], repeatForever: Bool = true) throws {
        let sequence = try animationAction(for: events)
        let action = repeatForever ? SKAction.repeatForever(sequence) : sequence

        removeAction(forKey: Self.animationKey)
        run(action, withKey: Self.animationKey)
    }

    /// Plays one battle animation and returns after the final frame.
    func playOnce(events: [BAPlaybackEvent]) async throws {
        let action = try animationAction(for: events)

        removeAction(forKey: Self.animationKey)

        await withCheckedContinuation { continuation in
            run(.sequence([
                action,
                .run { continuation.resume() }
            ]), withKey: Self.animationKey)
        }
    }

    private func animationAction(for events: [BAPlaybackEvent]) throws -> SKAction {
        let frames: [BAPlaybackFrame] = events.compactMap {
            guard case let .frame(playbackFrame) = $0 else { return nil }
            return playbackFrame
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

    private func apply(_ frame: PreparedFrame) {
        switch frame.layerTextures {
        case .single(let texture):
            backNode.resetTexture()
            frontNode.showTexture(texture)
        case .double(let foreground, let background):
            backNode.showTexture(background)
            frontNode.showTexture(foreground)
//            backNode.showTexture(foreground)
//            frontNode.showTexture(background)
        }
    }

    func stop() {
        removeAction(forKey: Self.animationKey)
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
        imageData: Data,
        filteringMode: SKTextureFilteringMode = .nearest
    ) throws -> SKTexture {
        guard let image = NSImage(data: imageData) else {
            fatalError("Could not find image for url") // \(imageURL)")
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = filteringMode
        return texture
    }
}
