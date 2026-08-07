//
//  CombatPlan.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/4/26.
//

import CombatModels
import Foundation

public struct CombatPlan {
    public let events: [Event]

    public struct Event {
        public let striker: CombatRole
        public var receiver: CombatRole { striker.opponent }
    }
}
