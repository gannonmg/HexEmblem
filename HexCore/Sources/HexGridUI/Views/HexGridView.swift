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
    
    private let layout: HexGridLayout<Cell>
    private let cellContent: (Cell) -> CellContent

    init(
        cells: some Sequence<Cell>,
        hexRadius: CGFloat,
        orientation: HexOrientation,
        @ViewBuilder cellContent: @escaping (Cell) -> CellContent
    ) {
        self.layout = HexGridLayout(cells: cells, hexRadius: hexRadius, orientation: orientation)
        self.cellContent = cellContent
    }

    var body: some View {
        ZStack {
            ForEach(visiblePlacements) { placement in
                cellContent(placement.cell)
                    .frame(size: layout.hexSize)
                    .clipShape(Hexagon(orientation: layout.orientation))
                    .position(placement.position)
            }
        }
        .frame(size: layout.contentSize)
    }

    private var visiblePlacements: [HexGridLayout<Cell>.Placement] {
        guard let visibleRect else { return layout.placements }
        let cullRect = visibleRect.insetBy(
            dx: -layout.hexSize.width,
            dy: -layout.hexSize.height
        )

        return layout.placements.filter { cullRect.contains($0.position) }
    }
}
