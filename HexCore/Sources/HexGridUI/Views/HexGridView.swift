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
            // Neighbours share an edge exactly, so antialiased fills leave a sub-pixel seam.
            // Growing each hex by half a smidge makes them overlap instead.
            let widthBuffer: CGFloat = 1
            let heightBuffer = widthBuffer * geometry.hexSizeRatio.width / geometry.hexSizeRatio.height
            let fillSize = CGSize(width: hexSize.width + widthBuffer,
                                  height: hexSize.height + heightBuffer)
            let template = Hexagon(orientation: layout.orientation)
                .path(in: CGRect(origin: .zero, size: fillSize))


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
                    let coordinate = placed.cell.axialCoordinate

                    for direction in directions {
                        if !direction.ownsSharedEdge {
                            let offset = direction.offsetCoordinate
                            let neighbor = AxialCoordinate(q: coordinate.q + offset.q, r: coordinate.r + offset.r)
                            guard !coordinateSet.contains(neighbor) else { continue }
                        }

                        let pathEdge = geometry.edge(facing: direction, from: placed.position)
                        gridPath.move(to: pathEdge.start)
                        gridPath.addLine(to: pathEdge.end)
                    }
                }

                if let label = style.label {
                    var resolved = context.resolve(label)
                    resolved.shading = style.labelShading
                    context.draw(resolved, at: placed.position, anchor: .center)
                }
            }

            if let gridLine {
                context.stroke(
                    gridPath,
                    with: gridLine.shading,
                    style: StrokeStyle(lineWidth: gridLine.width, lineCap: .round)
                )
            }
        }
        .frame(size: geometry.contentSize)
        .drawingGroup()
    }
}
