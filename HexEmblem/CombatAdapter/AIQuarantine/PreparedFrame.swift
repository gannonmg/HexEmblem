//
//  PreparedFrame.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import BAPlayback
import SpriteKit

/// Adapts a BAPlaybackFrame and prepares for animation.
struct PreparedFrame {
    let duration: Duration
    let layerTextures: LayerTextures

    init(_ frame: BAPlaybackFrame) throws {
        duration = GBAClock.playbackDuration(ticks: frame.ticks)

        layerTextures = switch frame.layerData {
        case .single(let data):
                .single(try .load(imageData: data))
        case .dual(let foregroundData, let backgroundData):
                .dual(
                    foreground: try .load(imageData: foregroundData),
                    background: try .load(imageData: backgroundData)
                )
        }
    }
}
