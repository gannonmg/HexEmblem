//
//  ZoomableHexGridView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import HexCore
import SwiftUI

struct ZoomableHexGridView<Cell: AxialCoordinateProviding>: View {
    @State private var visibleRect: CGRect?

    let cells: [Cell]
    let fractionalPositions: [AxialCoordinate: CGPoint]
    let contentRect: CGRect
    @Binding var hexRadius: CGFloat
    let radiusRange: ClosedRange<CGFloat>
    let orientation: HexOrientation
    private let appearance: HexGridAppearance<Cell>

    var body: some View {
        ZoomableScrollView(
            zoomRange: ZoomableHexMapDefaults.zoomRange,
            onVisibleRectChange: { rect in
                self.visibleRect = rect
            },
            content: {
                HexGridCanvas(
                    cells: cells,
                    orientation: orientation,
                    hexRadius: hexRadius,
                    contentRect: contentRect,
                    fractionalPositions: fractionalPositions,
                    appearance: appearance
                )
                .background(.green.opacity(0.7))
                .frame(size: contentRect.size)
                .background(.blue.opacity(0.7))
//                .environment(\.scrollVisibleRect, visibleRect)
            }
        )
    }
}

extension CGAffineTransform {
    static func translation(with point: CGPoint) -> Self {
        CGAffineTransform(translationX: point.x, y: point.y)
    }

    func translated(by point: CGPoint) -> Self {
        self.translatedBy(x: point.x, y: point.y)
    }
}

// MARK: - Init
extension ZoomableHexGridView {
    public init(
        cells: [Cell],
        hexRadius: Binding<CGFloat>,
        radiusRange: ClosedRange<CGFloat> = 20...200,
        orientation: HexOrientation,
        gridLine: HexGridLine? = nil,
        style: @escaping (Cell) -> HexCellStyle
    ) {
        self.cells = cells
        self.fractionalPositions = Dictionary(uniqueKeysWithValues: cells.map { cell in
            let fractionalPosition = HexScreenMath.hexToCartesianPoint(
                axialCoordinate: cell,
                orientation: orientation
            )
            return (cell.axialCoordinate, fractionalPosition)
        })

        self.orientation = orientation
        self.appearance = HexGridAppearance(
            gridLine: gridLine,
            style: style
        )

        self._hexRadius = hexRadius
        self.radiusRange = radiusRange
        let fractionalRect = HexGridGeometry.deriveContentRect(from: cells, orientation: orientation)
        self.contentRect = CGRect(origin: .zero, size: fractionalRect.size * hexRadius.wrappedValue)
    }
}
