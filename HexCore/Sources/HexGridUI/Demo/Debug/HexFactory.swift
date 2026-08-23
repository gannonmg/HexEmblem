//
//  HexFactory.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore

public enum ColoredHexFactory {
    public static func cells(diskRadius: Int) -> [ColoredHexCell] {
        let cells: [ColoredHexCell] = AxialCoordinate
            .disk(center: AxialCoordinate(q: 0, r: 0), radius: diskRadius)
            .sorted { ($0.r, $0.q) < ($1.r, $1.q) }
            .map { ColoredHexCell(axialCoordinate: $0, diskRadius: diskRadius) }
        return cells
    }
}
