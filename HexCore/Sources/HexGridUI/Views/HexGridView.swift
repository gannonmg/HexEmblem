//
//  PannableHexGridView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore
import SwiftUI

/// Places a set of hexes and lets the caller decide what each one looks like.
struct HexGridView<Cell: AxialCoordinateProviding, CellContent: View>: View {
    @Environment(\.scrollVisibleRect) private var visibleRect

    private struct PlacedCell: Identifiable {
        let id: AxialCoordinate
        let cell: Cell
        let position: CGPoint
    }

    // MARK: Init
    private let cells: [Cell]
    private let layout: HexGridLayout
    private let hexRadius: CGFloat
    private let cellContent: (Cell) -> CellContent

    init(
        cells: [Cell],
        layout: HexGridLayout,
        hexRadius: CGFloat,
        @ViewBuilder cellContent: @escaping (Cell) -> CellContent
    ) {
        self.cells = cells
        self.layout = layout
        self.hexRadius = hexRadius
        self.cellContent = cellContent
    }

    // MARK: Computed size helpers
    private var unitHexSize: CGSize { Hexagon.fractionalSize(for: layout.orientation) }

    private var hexSize: CGSize {
        CGSize(width: unitHexSize.width * hexRadius, height: unitHexSize.height * hexRadius)
    }

    private var contentSize: CGSize {
        CGSize(
            width: layout.contentRect.width * hexRadius,
            height: layout.contentRect.height * hexRadius
        )
    }

    // MARK: Body
    var body: some View {
        ZStack {
            ForEach(visibleCells) { placed in
                cellContent(placed.cell)
                    .frame(size: hexSize)
                    .clipShape(Hexagon(orientation: layout.orientation))
                    .position(placed.position)
            }
        }
        .frame(size: contentSize)
    }

    /// Culls in unit space — one division on the rect instead of scaling every cell.
    private var visibleCells: [PlacedCell] {
        let cullRect = visibleRect.map { rect in
            CGRect(
                x: rect.minX / hexRadius,
                y: rect.minY / hexRadius,
                width: rect.width / hexRadius,
                height: rect.height / hexRadius
            )
            .insetBy(dx: -unitHexSize.width, dy: -unitHexSize.height)
        }

        return cells.compactMap { cell in
            let point = HexScreenMath.hexToCartesianPoint(
                axialCoordinate: cell,
                orientation: layout.orientation
            )
            // Shift out of lattice space so the content's top-left is the origin.
            let unitPosition = CGPoint(
                x: point.x - layout.contentRect.minX,
                y: point.y - layout.contentRect.minY
            )

            if let cullRect, !cullRect.contains(unitPosition) { return nil }

            return PlacedCell(
                id: cell.axialCoordinate,
                cell: cell,
                position: CGPoint(x: unitPosition.x * hexRadius, y: unitPosition.y * hexRadius)
            )
        }
    }
}
