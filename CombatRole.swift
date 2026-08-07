//
//  CombatRole.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/7/26.
//

import Foundation

enum CombatRole {
    case initiator
    case responder

    var opponent: CombatRole {
        switch self {
        case .initiator: .responder
        case .responder: .initiator
        }
    }
}
