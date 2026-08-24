//
//  HexFactory.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore

public enum ColoredHexFactory {
    public static func disk(radius: Int) -> [ColoredHexCell] {
        let cells: [ColoredHexCell] = AxialCoordinate
            .disk(center: AxialCoordinate(q: 0, r: 0), radius: radius)
            .sorted { $0 < $1 }
            .map { ColoredHexCell(axialCoordinate: $0, span: radius * 2) }
        return cells
    }

    static func grid(col: Int, row: Int, orientation: HexOrientation) -> [ColoredHexCell] {
        let cells: [ColoredHexCell] = AxialCoordinate
            .rectangle(columns: col, rows: row, orientation: orientation)
            .sorted { $0 < $1 }
            .map { ColoredHexCell(axialCoordinate: $0, span: max(col, row)) }
        return cells
    }
}

