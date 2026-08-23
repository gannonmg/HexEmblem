//
//  PannableHexGridView 2.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore
import SwiftUI

public struct PannableHexGridView<Cell: AxialCoordinateProviding, CellContent: View>: View {
    private let cells: [Cell]
    private let hexRadius: CGFloat
    private let orientation: HexOrientation
    private let cellContent: (Cell) -> CellContent

    public init(
        cells: [Cell],
        hexRadius: CGFloat,
        orientation: HexOrientation,
        @ViewBuilder cellContent: @escaping (Cell) -> CellContent
    ) {
        self.cells = cells
        self.hexRadius = hexRadius
        self.orientation = orientation
        self.cellContent = cellContent
    }

    public var body: some View {
        PannableScrollView([.horizontal, .vertical]) {
            HexGridView(cells: cells, hexRadius: hexRadius, orientation: orientation, cellContent: cellContent)
        }
    }
}
