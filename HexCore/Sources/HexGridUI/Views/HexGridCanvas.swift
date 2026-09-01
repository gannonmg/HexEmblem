//
//  HexGridCanvas.swift
//  HexCore
//
//  Created by Matt Gannon on 8/28/26.
//

import HexCore
import SwiftUI

struct HexGridCanvas<Cell: AxialCoordinateProviding>: View {
    typealias PlacedCell = HexGridLayout<Cell>.PlacedCell

    @Environment(\.scrollViewport) private var scrollViewport

    let layout: HexGridLayout<Cell>
    let appearance: HexGridAppearance<Cell>

    // Technically doing hexes and gridlines in sequence is needlessly O(2n) instead of O(n),
    // but for code clarity we keep separate until performance actually needs improving.
    var body: some View {
        let visibleCells = layout.visibleCells(in: scrollViewport)
        Canvas { context, size in
            // Keep an eye on cavas draw times while building feature
            let start = CFAbsoluteTimeGetCurrent()
            defer {
                let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
                print(String(format: "draw %.2f ms, %d cells, size \(size.alignedDebugString)", elapsed, visibleCells.count))
            }

            // print("Context size: \(size.alignedDebugString)")
            drawHexes(for: visibleCells, in: context)
            drawGridLines(for: visibleCells, in: context)
        }
        .frame(size: layout.scaledContentSize)
    }
}

// MARK: - Filled Hexes
extension HexGridCanvas {
    private func buildHexTemplate() -> Path {
        // Add a tiny buffer to hexSize to close gaps caused by anti aliasing
        let hexSize = layout.hexSize
        let bufferSize = hexSize * (1/hexSize.width)
        let fillSize = hexSize + bufferSize

        let template = Hexagon(orientation: layout.orientation)
            .path(in: CGRect(origin: .zero, size: fillSize))
        return template
    }

    private func drawHexes(for cells: [PlacedCell], in context: GraphicsContext) {
        let template = buildHexTemplate()
        for placedCell in cells {
            let path = template.applying(.translation(with: placedCell.canvasOrigin))
            let style = appearance.style(placedCell.cell)
            context.fill(path, with: style.fill)
        }
    }
}

// MARK: - Grid Lines
extension HexGridCanvas {
    func drawGridLines(for cells: [PlacedCell], in context: GraphicsContext) {
        if let gridLine = appearance.gridLine, 0 < gridLine.width {
            let gridLinePath = buildGridLinePath(for: cells)
            context.stroke(
                gridLinePath,
                with: gridLine.shading,
                style: StrokeStyle(lineWidth: gridLine.width, lineCap: .round)
            )
        }
    }

    private func buildGridLinePath(for cells: [PlacedCell]) -> Path {
        var path = Path()
        let directions = HexGridGeometry.Constants.directions

        for placedCell in cells {
            let coordinate = placedCell.axialCoordinate

            for direction in directions {
                // Check if this coordinate "owns" it's edge
                // If not, make sure neighbor is actually in our coordinate set before moving along
                if !direction.ownsSharedEdge {
                    let offset = direction.offsetCoordinate
                    let neighbor = AxialCoordinate(q: coordinate.q + offset.q, r: coordinate.r + offset.r)
                    if layout.coordinateSet.contains(neighbor) { continue }
                }

                let edge = HexGridGeometry.fractionalEdgeOffset(
                    at: direction,
                    fractionalPosition: placedCell.fractionalContentCenter,
                    orientation: layout.orientation
                )
                    .scaled(by: layout.hexRadius)
                    .offset(by: layout.contentOriginInCanvas)

                path.move(to: edge.start)
                path.addLine(to: edge.end)
            }
        }

        return path
    }
}

extension HexGridGeometry.EdgeOffset {
    public func scaled(by hexRadius: CGFloat) -> Self {
        return Self(
            start: start * hexRadius,
            end: end * hexRadius
        )
    }

    public func offset(by point: CGPoint) -> Self {
        return Self(
            start: start + point,
            end: end + point
        )
    }
}
