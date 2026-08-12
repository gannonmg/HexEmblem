//
//  Weapon+BAWeaponSlot.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/8/26.
//

import BAPlayback
import GameModels

// MARK: - Weapon adapter
extension Weapon {
    func animationSlot(atRange encounterRange: Int) -> BAWeaponSlot {
        switch kind {
        case .sword:
            return .sword
        case .lance:
            return .lance
        case .bow:
            return .bow
        case .magic:
            return .magic
        case .staff:
            return .staff
        case .unarmed:
            return .unarmed
        case .axe:
            let effectiveRange = min(max(encounterRange, range.lowerBound), range.upperBound)
            return 1 < effectiveRange ? .handaxe : .axe
        }
    }

    var hasMagicalDamage: Bool { self.damage.contains { $0.damageClass == .magical } }
}
