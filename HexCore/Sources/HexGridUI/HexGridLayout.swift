//
//  HexGridLayout.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import CoreGraphics
import HexCore

public struct HexGridLayout<Cell: AxialCoordinateProviding> {
    public struct Placement: Identifiable {
        public let id: AxialCoordinate
        public let cell: Cell
        public let position: CGPoint
    }

    public let placements: [Placement]
    public let hexSize: CGSize
    public let contentSize: CGSize
    public let orientation: HexOrientation

    public init(
        cells: some Sequence<Cell>,
        hexRadius: CGFloat,
        orientation: HexOrientation
    ) {
        self.orientation = orientation

        let hexSize = CGSize(
            width: Hex.width(radius: hexRadius, orientation: orientation),
            height: Hex.height(radius: hexRadius, orientation: orientation)
        )

        self.hexSize = hexSize

        let frames = Self.frames(for: Array(cells), hexRadius: hexRadius, hexSize: hexSize, orientation: orientation)
        let contentRect = frames.reduce(CGRect.null) { $0.union($1) }

        guard !contentRect.isNull else {
            self.placements = []
            self.contentSize = .zero
            return
        }

        self.contentSize = contentRect.size
        self.placements = zip(cells, frames).map { cell, frame in
            Placement(
                id: cell.axialCoordinate,
                cell: cell,
                position: CGPoint(
                    x: frame.midX - contentRect.minX,
                    y: frame.midY - contentRect.minY
                )
            )
        }
    }

    private static func frames(
        for cells: [some AxialCoordinateProviding],
        hexRadius: CGFloat,
        hexSize: CGSize,
        orientation: HexOrientation
    ) -> [CGRect] {
        cells.map { cell in
            let center = switch orientation {
            case .pointyTop: HexScreenMath.pointyHexToPixel(axialCoordinate: cell.axialCoordinate, size: hexRadius)
            case .flatTop: HexScreenMath.flatHexToPixel(axialCoordinate: cell.axialCoordinate, size: hexRadius)
            }
            return CGRect(
                x: center.x - hexSize.width / 2,
                y: center.y - hexSize.height / 2,
                width: hexSize.width,
                height: hexSize.height
            )
        }
    }
}
