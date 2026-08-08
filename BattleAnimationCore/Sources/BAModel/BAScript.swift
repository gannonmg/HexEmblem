//
//  BAScript.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/5/26.
//

import Foundation

public struct BAScript {
    public let modes: [BAMode]

    // MARK: - Init
    public init(modes: [BAMode]) {
        self.modes = modes
    }

    // MARK: - Types
    public struct FrameReference: Codable, Hashable {
        public let durationTicks: Int
        public let flags: String
        public let filename: String

        public var durationSeconds: TimeInterval {
            TimeInterval(durationTicks) / 60.0
        }

        public init(durationTicks: Int, flags: String, filename: String) {
            self.durationTicks = durationTicks
            self.flags = flags
            self.filename = filename
        }
    }

    public enum Event: Codable, Hashable {
        case frame(FrameReference)
        case command(Command)
    }

    public struct Command: Codable, Hashable, Sendable {
        public let code: String
        public let comment: String?

        public init(code: String, comment: String?) {
            self.code = code
            self.comment = comment
        }
    }
}
