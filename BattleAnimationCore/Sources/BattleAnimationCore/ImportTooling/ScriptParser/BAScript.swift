//
//  BAScript.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/5/26.
//

import Foundation

public struct BAScript {
    public let modes: [BAMode]

    public struct FrameReference: Codable, Hashable {
        public let durationTicks: Int
        public let flags: String
        public let filename: String

        public var durationSeconds: TimeInterval {
            TimeInterval(durationTicks) / 60.0
        }
    }

    public enum Event: Codable, Hashable {
        case frame(FrameReference)
        case command(Command)
    }

    public struct Command: Codable, Hashable {
        public let code: String
        public let comment: String?
    }
}
