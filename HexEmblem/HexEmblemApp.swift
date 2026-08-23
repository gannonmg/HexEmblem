//
//  HexEmblemApp.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import HexCore
import HexGridUI
import SwiftUI

@main
struct HexEmblemApp: App {

    let cells = ColoredHexFactory.cells(diskRadius: 20)

    var body: some Scene {
        WindowGroup {
            let orientation: HexOrientation = .pointyTop
            PannableHexGridView(cells: cells, hexRadius: 60, orientation: orientation) { cell in
                Hexagon(orientation: orientation)
                    .overlay {
                        Text("\(cell.axialCoordinate.q), \(cell.axialCoordinate.r)")
                            .foregroundStyle(.white)
                    }
                    .foregroundStyle(cell.color)
            }
//            HexMapView(cells: cells, hexRadius: 60, orientation: .pointyTop)
//            ContentView()
        }
    }
}
