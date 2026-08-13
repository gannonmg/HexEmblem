//
//  MGCombatantNode.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/12/26.
//

import BAPlayback
import CombatModels
import SpriteKit

final class MGCombatantNode: SKNode {

    private let backgroundNode = LayerSpriteNode()
    private let foregroundNode = LayerSpriteNode()

    private lazy var animationRun = KeyedNodeRun(node: self, key: animationKey)

    // MARK: - Init
    private let animationKey: String

    init(role: CombatRole) {
        self.animationKey = "battle_animation_\(String(describing: role))"
        super.init()
        addChild(backgroundNode)
        addChild(foregroundNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Access
    func updateZPosition(to newZ: CGFloat) {
        self.zPosition = newZ
        backgroundNode.zPosition = newZ - 1
        foregroundNode.zPosition = newZ
    }

    func playFrames(_ frames: [BAPlaybackFrame]) async throws {
        animationRun.cancel()
        let sequence = try sequencedFrames(frames)
        await animationRun.run(sequence)
    }

    func loopFrames(_ frames: [BAPlaybackFrame]) throws {
        animationRun.cancel()
        let sequence = try sequencedFrames(frames)
        let loop = SKAction.repeatForever(sequence)
        animationRun.nonBlockingRun(loop)
    }

    private func sequencedFrames(_ frames: [BAPlaybackFrame]) throws -> SKAction {
        // Convert the layer image data to SKTextures before building the sequence
        let playableFrames = try PlayableFrame.buildArray(from: frames)

        // Build our action sequence with SKTexture and duration data
        return sequence(for: playableFrames)
    }

    private func sequence(for playableFrames: [PlayableFrame]) -> SKAction {
        // Helper to build sequence for single frame and avoid pyramid of doom
        func sequence(for playableFrame: PlayableFrame) -> SKAction {
            SKAction.sequence([
                .run { [weak self] in self?.applyTextures(playableFrame.textures) },
                // Division by seconds is the most exact way to convert newer Duration to TimeInterval
                .wait(forDuration: playableFrame.duration / .seconds(1))
            ])
        }

        return SKAction.sequence(playableFrames.map { sequence(for: $0) })
    }

    private func applyTextures(_ layerTextures: AnimationLayer<SKTexture>) {
        switch layerTextures {
        case .single(let texture):
            backgroundNode.resetTexture()
            foregroundNode.showTexture(texture)
        case .dual(let foregroundTexture, let backgroundTexture):
            backgroundNode.showTexture(backgroundTexture)
            foregroundNode.showTexture(foregroundTexture)
        }
    }
}

// MARK: - Texture helpers
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
