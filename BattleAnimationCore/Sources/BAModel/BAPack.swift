//
//  BAPack.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/11/26.
//
//  BAPack.swift — single-file container for processed animations.
//

import Foundation

public enum BAPack {
    public static let magic = Data("BAPACK\u{0}\u{1}".utf8)
    public static let fileName = "animations.bapack"

    public struct Index: Codable, Sendable {
        public struct Slice: Codable, Sendable {
            public let offset: UInt64
            public let length: UInt64

            public init(offset: UInt64, length: UInt64) {
                self.offset = offset
                self.length = length
            }
        }

        public let catalog: BACatalog
        public let manifests: [String: BAManifest]
        /// Keyed "<animationID>/<frame path>", offsets relative to the payload start.
        public let frames: [String: Slice]

        public init(
            catalog: BACatalog,
            manifests: [String: BAManifest],
            frames: [String: Slice]
        ) {
            self.catalog = catalog
            self.manifests = manifests
            self.frames = frames
        }
    }
}
