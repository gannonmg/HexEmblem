//
//  CombatRole.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/7/26.
//

import Foundation

public enum CombatRole: Codable, Sendable {
    case initiator
    case responder

    public var opponent: CombatRole {
        switch self {
        case .initiator: .responder
        case .responder: .initiator
        }
    }
}
