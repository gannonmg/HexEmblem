//
//  BAMode.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/5/26.
//

import Foundation

// TODO: Clean up AI preserving both rawModeNumber and modeID (which is potentially .unknown)
public struct BAMode: Codable, Hashable {
    public let modeID: BAModeID
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

    public init(modeID: BAModeID, title: String?, events: [BAScript.Event]) {
        self.modeID = modeID
        self.title = title
        self.events = events
    }

    public init(rawModeNumber: Int, title: String?, events: [BAScript.Event]) {
        self.modeID = BAModeID(rawValue: rawModeNumber)
        self.title = title
        self.events = events
    }
}
