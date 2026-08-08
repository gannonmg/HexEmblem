//
//  BAPlaybackMarker.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/7/26.
//

import BAModel
import Foundation

public enum BAPlaybackEvent {
    case frame(BAPlaybackFrame)
    case marker(BAPlaybackEvent.Marker)

    // TODO: Namespace marker and frame into event
    public struct Marker {
        public let code: String
        public let kind: Kind

        public enum Kind {
            case impact
            case castSpell
            case armHPDepletion
            case waitForHPDepletion
            case beginOpponentTurn
            case startDodge
            case endDodge
            case playSound   // SFE-glossed codes → drives audio engine
            case screenEffect // vibration/flash/particle-glossed codes → drives visual layer
            case unrecognized // no reliable gloss (C17, C53–55, C64, C71, C72, CC0, CDC, etc.)}
        }
    }
}

public struct BAPlaybackFrame {
    public let duration: TimeInterval
    public let layerURLs: LayerURLs

    public enum LayerURLs {
        case single(URL)
        case double(foreground: URL, background: URL)
    }
}
