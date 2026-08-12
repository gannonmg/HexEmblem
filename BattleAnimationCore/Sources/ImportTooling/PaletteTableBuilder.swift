//
//  PaletteTableBuilder.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/11/26.
//

import BAModel
import ImageUtilities

struct PaletteTableBuilder {
    private(set) var table: [RGBA] = []
    private var lookup: [RGBA: UInt8] = [:]

    /// Seeds the animation's palette from a frame's embedded top-right swatch.
    mutating func establish(from swatch: [RGBA]) {
        for color in swatch {
            guard lookup[color] == nil else { continue }
            lookup[color] = UInt8(table.count)
            table.append(color)
        }
    }

    /// Maps a frame's visible pixels to indices into the established palette.
    /// Throws if a pixel's color isn't part of the declared palette.
    func indices(for image: PixelImage, frame: String, animationID: String) throws -> [UInt8] {
        try image.pixels.map { pixel in
            guard let index = lookup[pixel] else {
                throw BAImportError.paletteMismatch(animationID: animationID, frame: frame, color: pixel)
            }
            return index
        }
    }
}
