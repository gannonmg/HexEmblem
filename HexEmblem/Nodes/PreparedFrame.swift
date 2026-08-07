//
//  PreparedFrame.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import BattleAnimationCore
import SpriteKit

/// Adapts a BAPlayback.Frame and prepares for animation.
struct PreparedFrame {
    let duration: TimeInterval
    let layerTextures: LayerTextures

    init(_ frame: BAPlayback.Frame) throws {
        duration = frame.duration

        layerTextures = switch frame.layerURLs {
        case .single(let url):
                .single(try .load(imageURL: url))

        case .double(let foregroundURL, let backgroundURL):
                .double(
                    foreground: try .load(imageURL: foregroundURL),
                    background: try .load(imageURL: backgroundURL)
                )
        }
    }
}
