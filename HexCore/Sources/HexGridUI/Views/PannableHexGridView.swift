//
//  PannableHexGridView 2.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore
import SwiftUI

public struct PannableHexGridView<Cell: AxialCoordinateProviding>: View {
    let cells: [Cell]
    let geometry: HexGridGeometry<Cell>
    let appearance: HexGridAppearance<Cell>

    public init(
        cells: [Cell],
        hexRadius: CGFloat,
        orientation: HexOrientation,
        gridLine: HexGridLine? = nil,
        style: @escaping (Cell) -> HexCellStyle
    ) {
        self.cells = cells
        self.geometry = HexGridGeometry(
            layout: HexGridLayout(cells: cells, orientation: orientation),
            hexRadius: hexRadius
        )
        self.appearance = HexGridAppearance(
            gridLine: gridLine,
            style: style
        )
    }

    public var body: some View {
        PannableScrollView([.horizontal, .vertical]) {
            HexGridView(
                cells: cells,
                geometry: geometry,
                appearance: appearance
            )
        }
    }
}
