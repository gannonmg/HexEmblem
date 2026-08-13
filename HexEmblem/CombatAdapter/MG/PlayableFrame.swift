//
//  PlayableFrame.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/12/26.
//

import BAPlayback
import SpriteKit

struct PlayableFrame {
    let textures: AnimationLayer<SKTexture>
    let duration: Duration

    static func buildArray(from frames: [BAPlaybackFrame]) throws -> [PlayableFrame] {
        try frames.map {
            let textures = try $0.layerData.animationTextures()
            let duration = GBAClock.playbackDuration(ticks: $0.ticks)
            return PlayableFrame(textures: textures, duration: duration)
        }
    }
}
