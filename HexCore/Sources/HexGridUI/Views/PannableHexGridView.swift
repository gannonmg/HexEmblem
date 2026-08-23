//
//  PannableHexGridView 2.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore
import SwiftUI

public struct PannableHexGridView<Cell: AxialCoordinateProviding>: View {
    private let cells: [Cell]
    private let hexRadius: CGFloat
    private let orientation: HexOrientation
    private let style: (Cell) -> HexCellStyle

    public init(
        cells: [Cell],
        hexRadius: CGFloat,
        orientation: HexOrientation,
        style: @escaping (Cell) -> HexCellStyle

    ) {
        self.cells = cells
        self.hexRadius = hexRadius
        self.orientation = orientation
        self.style = style
    }

    public var body: some View {
        let layout = HexGridLayout(cells: cells, orientation: orientation)
        PannableScrollView([.horizontal, .vertical]) {
            HexGridView(cells: cells, layout: layout, hexRadius: hexRadius, style: style)
        }
    }
}
