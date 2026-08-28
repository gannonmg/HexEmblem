//
//  HexGridLayout.swift
//  HexCore
//
//  Created by Matt Gannon on 8/28/26.
//

import HexCore
import SwiftUI

/// Precomputed layout facts for a set of AxialCoordinates given an orientation and radius.
/// Uses HexGridGeometry, which is agnostic to size, to spatially lay out the drawn hexagons.
struct HexGridLayout<Cell: AxialCoordinateProviding> {
    struct PlacedCell {
        let cell: Cell
        let fractionalPosition: CGPoint
        let scaledPosition: CGPoint
        var axialCoordinate: AxialCoordinate { cell.axialCoordinate }
    }

    let placedCells: [PlacedCell]

    /// The orientation of the cells in the grid. Either pointy or flat top.
    let orientation: HexOrientation

    /// The scaled circumradius (center to corner distance and edge length) of each hexagon
    let hexRadius: CGFloat

    /// The scaled size of the hex based on fractionalSize(orientation) and hexRadius
    let hexSize: CGSize

    let coordinateSet: Set<AxialCoordinate>

    /// The scaled, edge-to-edge area requirements for drawing the full grid.
    ///
    /// Note: The origin is (0,0), meaning we must translate from a centered (0,0) system.
    let contentRect: CGRect

    init(
        cells: [Cell],
        orientation: HexOrientation,
        hexRadius: CGFloat
    ) {
        self.placedCells = cells.map { cell in
            let fractionalPosition = HexScreenMath.hexToCartesianPoint(
                axialCoordinate: cell,
                orientation: orientation
            )
            let scaledPosition = fractionalPosition * hexRadius
            return PlacedCell(cell: cell, fractionalPosition: fractionalPosition, scaledPosition: scaledPosition)
        }

        self.orientation = orientation
        self.hexRadius = hexRadius

        // Fractional hex size is sqrt(3):2 or 2:sqrt(3) depending on orientation
        self.hexSize = Hexagon.fractionalSize(for: orientation) * hexRadius

        self.coordinateSet = Set(cells.map(\.axialCoordinate))

        let fractionalRect = HexGridGeometry.deriveContentRect(from: cells, orientation: orientation)
        self.contentRect = CGRect(origin: .zero, size: fractionalRect.size * hexRadius)
    }
}
