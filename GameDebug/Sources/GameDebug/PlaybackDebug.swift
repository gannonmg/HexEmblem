//
//  PlaybackDebug.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/11/26.
//

import Observation
import SpriteKit
import Synchronization

/// Temporary playback inspector. A singleton on purpose — nothing has to be threaded through
/// a scene or node init, so this file plus its three call sites delete cleanly.
@Observable
public final class PlaybackDebug: @unchecked Sendable {
    public static let shared = PlaybackDebug()

    @ObservationIgnored
    private let speedStorage = Mutex<Double>(1)

    public var speed: Double {
        get {
            access(keyPath: \.speed)
            return speedStorage.withLock { $0 }
        }
        set {
            withMutation(keyPath: \.speed) {
                speedStorage.withLock {
                    $0 = newValue
                }
            }
        }
    }
}
