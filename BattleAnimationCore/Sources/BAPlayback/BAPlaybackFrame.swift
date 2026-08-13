//
//  BAPlaybackFrame.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/8/26.
//

import BAModel
import Foundation

public struct BAPlaybackFrame: Equatable, Sendable {

    public let ticks: Int
    public let layerData: AnimationLayer<Data>

    /// Wall-clock length at the GBA's ~59.73 Hz refresh.
//    public var duration: TimeInterval {
//        TimeInterval(ticks) / 59.7275
//    }
}
