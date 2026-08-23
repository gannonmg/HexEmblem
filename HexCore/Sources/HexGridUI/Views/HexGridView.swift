//
//  PannableHexGridView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore
import SwiftUI

// Temporary thin layer to supply to Canvas before introducing more complex tiles
public struct HexCellStyle {
    public var fill: GraphicsContext.Shading
    public var stroke: GraphicsContext.Shading?
    public var lineWidth: CGFloat
    public var label: Text?
    public var labelShading: GraphicsContext.Shading

    public init(
        fill: GraphicsContext.Shading,
        stroke: GraphicsContext.Shading? = nil,
        lineWidth: CGFloat = 1,
        label: Text? = nil,
        labelShading: GraphicsContext.Shading = .color(.white)
    ) {
        self.fill = fill
        self.stroke = stroke
        self.lineWidth = lineWidth
        self.label = label
        self.labelShading = labelShading
    }
}

/// Places a set of hexes and lets the caller decide what each one looks like.
struct HexGridView<Cell: AxialCoordinateProviding>: View {
    @Environment(\.scrollVisibleRect) private var visibleRect

    private struct PlacedCell: Identifiable {
        let id: AxialCoordinate
        let cell: Cell
        let position: CGPoint
    }

    // MARK: Init
    private let cells: [Cell]
    private let layout: HexGridLayout
    private let hexRadius: CGFloat
    private let style: (Cell) -> HexCellStyle

    init(
        cells: [Cell],
        layout: HexGridLayout,
        hexRadius: CGFloat,
        style: @escaping (Cell) -> HexCellStyle
    ) {
        self.cells = cells
        self.layout = layout
        self.hexRadius = hexRadius
        self.style = style
    }

    // MARK: Computed size helpers
    private var unitHexSize: CGSize { Hexagon.fractionalSize(for: layout.orientation) }

    private var hexSize: CGSize {
        CGSize(width: unitHexSize.width * hexRadius, height: unitHexSize.height * hexRadius)
    }

    private var contentSize: CGSize {
        CGSize(
            width: layout.contentRect.width * hexRadius,
            height: layout.contentRect.height * hexRadius
        )
    }

    // MARK: Body
    var body: some View {
        Canvas { context, _ in
            // Built once at the current scale; every cell is a translation of it.
            let template = Hexagon(orientation: layout.orientation)
                .path(in: CGRect(origin: .zero, size: hexSize))

            for placed in visibleCells {
                let style = style(placed.cell)
                let path = template.applying(
                    CGAffineTransform(
                        translationX: placed.position.x - hexSize.width / 2,
                        y: placed.position.y - hexSize.height / 2
                    )
                )

                context.fill(path, with: style.fill)

                if let stroke = style.stroke {
                    context.stroke(path, with: stroke, lineWidth: style.lineWidth)
                }

                if let label = style.label {
                    var resolved = context.resolve(label)
                    resolved.shading = style.labelShading
                    context.draw(resolved, at: placed.position, anchor: .center)
                }
            }
        }
        .frame(size: contentSize)
    }

    /// Culls in unit space — one division on the rect instead of scaling every cell.
    private var visibleCells: [PlacedCell] {
        let cullRect = visibleRect.map { rect in
            CGRect(
                x: rect.minX / hexRadius,
                y: rect.minY / hexRadius,
                width: rect.width / hexRadius,
                height: rect.height / hexRadius
            )
            .insetBy(dx: -unitHexSize.width, dy: -unitHexSize.height)
        }

        return cells.compactMap { cell in
            let point = HexScreenMath.hexToCartesianPoint(
                axialCoordinate: cell,
                orientation: layout.orientation
            )
            // Shift out of lattice space so the content's top-left is the origin.
            let unitPosition = CGPoint(
                x: point.x - layout.contentRect.minX,
                y: point.y - layout.contentRect.minY
            )

            if let cullRect, !cullRect.contains(unitPosition) { return nil }

            return PlacedCell(
                id: cell.axialCoordinate,
                cell: cell,
                position: CGPoint(x: unitPosition.x * hexRadius, y: unitPosition.y * hexRadius)
            )
        }
    }
}
