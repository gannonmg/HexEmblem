//
//  PannableHexGridView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore
import SwiftUI

/// Places a set of hexes and lets the caller decide what each one looks like.
struct HexGridView<Cell: AxialCoordinateProviding>: View {
    @Environment(\.scrollVisibleRect) private var visibleRect

    private struct PlacedCell: Identifiable {
        let id: AxialCoordinate
        let cell: Cell
        let position: CGPoint
    }

    // MARK: Init
    let cells: [Cell]
    let geometry: HexGridGeometry<Cell>
    let appearance: HexGridAppearance<Cell>

    // MARK: Body
    var body: some View {
        let layout = geometry.layout
        let hexSize = geometry.hexSize
        let placed = geometry.visibleCells(from: cells, in: visibleRect)
        let gridLine = appearance.gridLine

        Canvas { context, _ in

            let start = CFAbsoluteTimeGetCurrent()
            defer {
                let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
                print(String(format: "draw %.2f ms, %d cells", elapsed, placed.count))
            }

            // Built once at the current scale; every cell is a translation of it.
            let template = Hexagon(orientation: layout.orientation)
                .path(in: CGRect(origin: .zero, size: hexSize))


            var gridPath = Path()
            let coordinateSet = Set(placed.map(\.cell.axialCoordinate))
            let directions = AxialDirection.allCases

            for placed in placed {
                let style = appearance.style(placed.cell)
                let path = template.applying(
                    CGAffineTransform(
                        translationX: placed.position.x - hexSize.width / 2,
                        y: placed.position.y - hexSize.height / 2
                    )
                )

                context.fill(path, with: style.fill)

                if let gridLine, 0 < gridLine.width {
                    gridPath.addPath(path)
                }
                if let label = style.label {
                    var resolved = context.resolve(label)
                    resolved.shading = style.labelShading
                    context.draw(resolved, at: placed.position, anchor: .center)
                }
            }

            if let gridLine {
                context.stroke(gridPath, with: gridLine.shading, lineWidth: gridLine.width)
            }
        }
        .frame(size: geometry.contentSize)
        .drawingGroup()
    }
}
