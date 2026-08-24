//
//  HexTileCache.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import SwiftUI

@MainActor
final class HexTileCache {
    /// Tiles are rasterized at the largest hex the app will ever draw, then downscaled
    /// at draw time. Zooming never invalidates the cache.
    let maximumHexSize: CGSize
    let scale: CGFloat

    private var tiles: [AnyHashable: CGImage] = [:]

    init(maximumHexSize: CGSize, scale: CGFloat) {
        self.maximumHexSize = maximumHexSize
        self.scale = scale
    }

    func tile(for key: some Hashable, @ViewBuilder content: () -> some View) -> CGImage? {
        let key = AnyHashable(key)
        if let cached = tiles[key] { return cached }

        let renderer = ImageRenderer(
            content: content()
                .frame(width: maximumHexSize.width, height: maximumHexSize.height)
        )
        renderer.scale = scale

        guard let image = renderer.cgImage else { return nil }
        tiles[key] = image
        return image
    }

    func removeAll() { tiles.removeAll() }
}

extension GraphicsContext {
    func drawTile(_ image: CGImage, in rect: CGRect, pixelArt: Bool) {
        let image = Image(decorative: image, scale: 1)
            .interpolation(pixelArt ? .none : .high)
            .antialiased(!pixelArt)
        draw(image, in: rect)
    }
}
