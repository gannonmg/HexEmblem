//
//  BAWeaponSlot.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/7/26.
//

import Foundation

public enum BAWeaponSlot: Codable, Hashable, Sendable {
    case sword
    case lance
    case axe
    case handaxe
    case bow
    case magic
    case staff
    case unarmed
    case unknown(Int)
}

extension BAWeaponSlot: RawRepresentable {
    public init(rawValue: Int) {
        self = switch rawValue {
        case Self.sword.rawValue: .sword
        case Self.lance.rawValue: .lance
        case Self.axe.rawValue: .axe
        case Self.handaxe.rawValue: .handaxe
        case Self.bow.rawValue: .bow
        case Self.magic.rawValue: .magic
        case Self.staff.rawValue: .staff
        case Self.unarmed.rawValue: .unarmed
        default: .unknown(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
        case .sword: 1
        case .lance: 2
        case .axe: 3
        case .handaxe: 4
        case .bow: 5
        case .magic: 6
        case .staff: 7
        case .unarmed: 8
        case .unknown(let value): value
        }
    }
}
