//
//  HexGridLayout.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import CoreGraphics
import HexCore

public struct HexGridLayout {
    public let contentRect: CGRect
    public let orientation: HexOrientation

    public init(
        cells: some Sequence<some AxialCoordinateProviding>,
        orientation: HexOrientation
    ) {
        self.orientation = orientation

        let contentRect = Self.buildContentRect(from: cells, orientation: orientation)

        guard !contentRect.isNull else {
            self.contentRect = .zero
            return
        }

        self.contentRect = contentRect
    }

    private static func buildContentRect(
        from cells: some Sequence<some AxialCoordinateProviding>,
        orientation: HexOrientation
    ) -> CGRect {
        let hexSize = Hexagon.fractionalSize(for: orientation)

        let contentRect: CGRect = cells
            .reduce(CGRect.null) { partialResult, cell in
                let center = HexScreenMath.hexToCartesianPoint(axialCoordinate: cell, orientation: orientation)
                let cellRect = CGRect(
                    x: center.x - hexSize.width / 2,
                    y: center.y - hexSize.height / 2,
                    width: hexSize.width,
                    height: hexSize.height
                )
                return partialResult.union(cellRect)
            }

        return contentRect
    }
}
