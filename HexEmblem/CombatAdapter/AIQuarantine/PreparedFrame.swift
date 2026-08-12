//
//  PreparedFrame.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import BAPlayback
import SpriteKit

// TODO: This should live in an adapter layer, not the main codebase.

/// Adapts a BAPlaybackFrame and prepares for animation.
struct PreparedFrame {
    let duration: TimeInterval
    let layerTextures: LayerTextures

    init(_ frame: BAPlaybackFrame) throws {
        duration = frame.duration

        layerTextures = switch frame.layerData {
        case .single(let data):
                .single(try .load(imageData: data))
        case .double(let foregroundData, let backgroundData):
                .double(
                    foreground: try .load(imageData: foregroundData),
                    background: try .load(imageData: backgroundData)
                )
        }
//        {
//        case .single(let url):
//                .single(try .load(imageURL: url))
//        case .double(let foregroundURL, let backgroundURL):
//                .double(
//                    foreground: try .load(imageURL: foregroundURL),
//                    background: try .load(imageURL: backgroundURL)
//                )
//        }
    }
}
