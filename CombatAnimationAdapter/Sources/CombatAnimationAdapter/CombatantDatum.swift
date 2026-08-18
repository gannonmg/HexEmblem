//
//  CombatantDatum.swift
//  CombatAnimationAdapter
//
//  Created by Matt Gannon on 8/18/26.
//

import CombatModels
import Foundation

public struct CombatantDatum<T> {
    private let initiatorDatum: T
    private let responderDatum: T

    public init(_ builder: (CombatRole) throws -> T) rethrows {
        self.initiatorDatum = try builder(.initiator)
        self.responderDatum = try builder(.responder)
    }

    public func `for`(_ role: CombatRole) -> T {
        switch role {
        case .initiator: initiatorDatum
        case .responder: responderDatum
        }
    }
}
