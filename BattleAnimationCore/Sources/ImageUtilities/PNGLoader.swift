//
//  PNGLoader.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/3/26.
//

import Foundation
import CoreGraphics
import ImageIO

public enum PNGLoader {
    public static func load(from url: URL) throws(PixelImageError) -> PixelImage {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw PixelImageError.cannotCreateImageSource(url)
        }

        guard let image = CGImageSourceCreateImageAtIndex(source, 0, [
            kCGImageSourceShouldCache: false
        ] as CFDictionary) else {
            throw PixelImageError.cannotReadImage(url)
        }

        let width = image.width
        let height = image.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel

        var data = [UInt8](repeating: 0, count: height * bytesPerRow)

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

        context.interpolationQuality = .none
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        let pixels = stride(from: 0, to: data.count, by: 4).map { index in
            RGBA(
                r: data[index],
                g: data[index + 1],
                b: data[index + 2],
                a: data[index + 3]
            )
        }

        return PixelImage(width: width, height: height, pixels: pixels)
    }
}
