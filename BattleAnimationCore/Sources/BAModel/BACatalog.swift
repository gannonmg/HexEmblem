//
//  BACatalog.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/8/26.
//

import Foundation

public struct BACatalog: Codable, Sendable {
    public let version: Int
    public let animations: [Entry]

    public init(version: Int = 1, animations: [Entry]) {
        self.version = version
        self.animations = animations
    }

    public struct Entry: Codable, Sendable {
        public let id: String
        public let spriteSet: BASpriteSet
        public let variant: BAVariant
        public let modes: [BAModeID]
        public let frameCount: Int
        public let renderSize: FrameSize

        public init(
            id: String,
            spriteSet: BASpriteSet,
            variant: BAVariant,
            modes: [BAModeID],
            frameCount: Int,
            renderSize: FrameSize
        ) {
            self.id = id
            self.spriteSet = spriteSet
            self.variant = variant
            self.modes = modes
            self.frameCount = frameCount
            self.renderSize = renderSize
        }
    }
}

extension BACatalog {
    public func entries(spriteSetID: String) -> [Entry] {
        animations.filter { $0.spriteSet.id == spriteSetID }
    }

    public func entry(
        spriteSetID: String,
        slot: BAWeaponSlot,
        qualifier: BAVariant.Qualifier? = nil
    ) -> Entry? {
        let candidates = entries(spriteSetID: spriteSetID)
            .filter { $0.variant.slot == slot }

        if let qualifier {
            if let exact = candidates.first(where: { $0.variant.qualifier == qualifier }) {
                return exact
            }
        }

        // Prefer the unqualified base variant, else whatever fills the slot.
        return candidates.first { $0.variant.qualifier == nil } ?? candidates.first
    }
}

extension BACatalog.Entry {
    public func contains(_ mode: BAModeID) -> Bool {
        modes.contains(mode)
    }
}
