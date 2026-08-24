//
//  HexGridAppearance.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import HexCore

struct HexGridAppearance<Cell: AxialCoordinateProviding> {
    let gridLine: HexGridLine?
    let style: (Cell) -> HexCellStyle
}
