//
//  PNGWriter.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/3/26.
//

import BAModel
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

public enum PNGWriter {
    public static func write(png: PixelImage, to url: URL) throws {
        let width = png.width
        let height = png.height
        let pixels = png.pixels

        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel

        var data = pixels.flatMap { [$0.r, $0.g, $0.b, $0.a] }

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: &data,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                | CGBitmapInfo.byteOrder32Big.rawValue
              ) else {
            throw PixelImageError.cannotCreateContext
        }

        guard let image = context.makeImage() else {
            throw PixelImageError.cannotCreateCGImage
        }

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw PixelImageError.cannotCreateDestination(url)
        }

        CGImageDestinationAddImage(destination, image, nil)

        guard CGImageDestinationFinalize(destination) else {
            throw PixelImageError.cannotWritePNG(url)
        }
    }
}

public enum IndexBufferWriter {
    /// Writes one byte per pixel, row-major, matching the sibling PNG's dimensions.
    public static func write(indices: [UInt8], to url: URL) throws {
        try Data(indices).write(to: url, options: .atomic)
    }
}
