//
//  HexGridCanvas.swift
//  HexCore
//
//  Created by Matt Gannon on 8/28/26.
//

import HexCore
import SwiftUI

struct HexGridCanvas<Cell: AxialCoordinateProviding>: View {
    let cells: [Cell]
    let orientation: HexOrientation
    let hexRadius: CGFloat
    let contentRect: CGRect
    let fractionalPositions: [AxialCoordinate: CGPoint]
    let appearance: HexGridAppearance<Cell>

    // Technically doing hexes and gridlines in sequence is needlessly O(2n) instead of O(n),
    // but for code clarity we keep separate until performance actually needs improving.
    var body: some View {
        Canvas { context, size in
            // Keep an eye on cavas draw times while building feature
            let start = CFAbsoluteTimeGetCurrent()
            defer {
                let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
                print(String(format: "draw %.2f ms, %d cells, size \(size.alignedDebugString)", elapsed, cells.count))
            }

            // print("Context size: \(size.alignedDebugString)")
            drawHexes(in: context)
            drawGridLines(in: context)
        }
    }
}

// MARK: - Filled Hexes
extension HexGridCanvas {
    private func buildHexTemplate() -> Path {
        // Fractional hex size is sqrt(3):2 or 2:sqrt(3) depending on orientation
        let hexSize = Hexagon.fractionalSize(for: orientation) * hexRadius

        // Add a tiny buffer to close gaps caused by anti aliasing
        let bufferSize = hexSize * (1/hexSize.width)
        let fillSize = hexSize + bufferSize

        let template = Hexagon(orientation: orientation)
            .path(in: CGRect(origin: .zero, size: fillSize))
        return template
    }

    private func drawHexes(in context: GraphicsContext) {
        let template = buildHexTemplate()

        for cell in cells {
            guard let fractionalPosition = fractionalPositions[cell.axialCoordinate] else { continue }
            let position = fractionalPosition * hexRadius
            let path = template.applying(.translation(with: position).translated(by: contentRect.center))
            let style = appearance.style(cell)
            context.fill(path, with: style.fill)
        }
    }
}

// MARK: - Grid Lines
extension HexGridCanvas {
    func drawGridLines(in context: GraphicsContext) {
        if let gridLine = appearance.gridLine, 0 < gridLine.width {
            let gridLines = buildGridLines()
            context.stroke(
                gridLines,
                with: gridLine.shading,
                style: StrokeStyle(lineWidth: gridLine.width, lineCap: .round)
            )
        }
    }

    private func buildGridLines() -> Path {
        var gridLines = Path()
        let coordinateSet = Set(cells.map(\.axialCoordinate))
        let directions = AxialDirection.allCases

        for cell in cells {
            let coordinate = cell.axialCoordinate
            guard let position = fractionalPositions[coordinate] else { continue }
            for direction in directions {
                if !direction.ownsSharedEdge {
                    let offset = direction.offsetCoordinate
                    let neighbor = AxialCoordinate(q: coordinate.q + offset.q, r: coordinate.r + offset.r)
                    guard !coordinateSet.contains(neighbor) else { continue }
                }

                let pathEdge = HexGridGeometry.fractionalEdgeOffset(
                    at: direction,
                    fractionalPosition: position,
                    orientation: orientation
                ).scaled(by: hexRadius)

                let start = pathEdge.start + contentRect.center
                let end = pathEdge.end + contentRect.center
                gridLines.move(to: start)
                gridLines.addLine(to: end)
            }
        }
        return gridLines
    }
}
