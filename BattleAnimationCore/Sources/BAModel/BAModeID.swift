//
//  BAModeID.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/5/26.
//

import Foundation

public enum BAModeID: Codable, Hashable, Sendable {
    case meleeAttack, meleeCritical
    case rangedAttack, rangedCritical
    case meleeDodge, rangedDodge
    case meleeEquipped, standing, rangedEquipped
    case attackMissed
    case engineGenerated(Int)
    case unknown(Int)
}

extension BAModeID: RawRepresentable {
    public init(rawValue: Int) {
        self = switch rawValue {
        case Self.meleeAttack.rawValue: .meleeAttack
        case Self.meleeCritical.rawValue: .meleeCritical
        case Self.rangedAttack.rawValue: .rangedAttack
        case Self.rangedCritical.rawValue: .rangedCritical
        case Self.meleeDodge.rawValue: .meleeDodge
        case Self.rangedDodge.rawValue: .rangedDodge
        case Self.meleeEquipped.rawValue: .meleeEquipped
        case Self.standing.rawValue: .standing
        case Self.rangedEquipped.rawValue: .rangedEquipped
        case Self.attackMissed.rawValue: .attackMissed
        case 2, 4: .engineGenerated(rawValue)
        default: .unknown(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
        case .meleeAttack: 1
        case .meleeCritical: 3
        case .rangedAttack: 5
        case .rangedCritical: 6
        case .meleeDodge: 7
        case .rangedDodge: 8
        case .meleeEquipped: 9
        case .standing: 10
        case .rangedEquipped: 11
        case .attackMissed: 12
        case .engineGenerated(let value), .unknown(let value): value
        }
    }
}

extension BAModeID {
    public var isKnown: Bool {
        switch self {
        case .unknown: false
        default: true
        }
    }

    public var isUnknown: Bool { !isKnown }
}

extension BAModeID {
    /// Modes to substitute, in preference order, when an animation has no timeline for this mode.
    ///
    /// Resolution is done against a ``BACatalog/Entry``'s known modes before playback starts,
    /// so a missing mode is a lookup miss rather than a runtime failure.
    public var fallbacks: [BAModeID] {
        switch self {
        case .meleeAttack: []
        case .meleeCritical: [.meleeAttack]
        case .rangedAttack: [.meleeAttack]
        case .rangedCritical: [.rangedAttack, .meleeAttack]
        case .meleeDodge: [.standing]
        case .rangedDodge: [.meleeDodge, .standing]
        case .meleeEquipped: [.standing]
        case .standing: []
        case .rangedEquipped: [.standing, .meleeEquipped]
        case .attackMissed: [.meleeAttack]
        case .engineGenerated: []
        case .unknown: []
        }
    }
}
