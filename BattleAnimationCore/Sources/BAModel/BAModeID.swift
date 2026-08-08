//
//  BAModeID.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/5/26.
//

import Foundation

public struct BAModeID: Codable, Hashable, Sendable {
    public let rawModeNumber: Int
    public let kind: Kind

    public enum Kind: String, Codable, Hashable, Sendable {
        case meleeAttack, meleeCritical
        case rangedAttack, rangedCritical
        case meleeDodge, rangedDodge
        case meleeEquipped, standing, rangedEquipped
        case attackMissed
        case engineGenerated
        case unknown
    }

    public init(rawModeNumber: Int) {
        self.rawModeNumber = rawModeNumber
        self.kind = switch rawModeNumber {
        case 1: .meleeAttack
        case 2, 4: .engineGenerated
        case 3: .meleeCritical
        case 5: .rangedAttack
        case 6: .rangedCritical
        case 7: .meleeDodge
        case 8: .rangedDodge
        case 9: .meleeEquipped
        case 10: .standing
        case 11: .rangedEquipped
        case 12: .attackMissed
        default: .unknown
        }
    }
}

// MARK: - Mode fallbacks
extension BAModeID.Kind {

    /// Modes to substitute, in preference order, when an animation has no timeline for this mode.
    ///
    /// Resolution is done against a ``BACatalog/Entry``'s known modes before playback starts,
    /// so a missing mode is a lookup miss rather than a runtime failure.
    public var fallbacks: [BAModeID.Kind] {
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
