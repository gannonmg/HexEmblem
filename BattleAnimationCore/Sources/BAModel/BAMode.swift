//
//  BAMode.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/5/26.
//

import Foundation

// TODO: Clean up AI preserving both rawModeNumber and modeID (which is potentially .unknown)
public struct BAMode: Codable, Hashable {
    public let rawModeNumber: Int
    public let id: BAModeID
    public let title: String?
    public let events: [BAScript.Event]

    public var frames: [BAScript.FrameReference] {
        events.compactMap {
            switch $0 {
            case .frame(let frame): frame
            default: nil
            }
        }
    }
}
