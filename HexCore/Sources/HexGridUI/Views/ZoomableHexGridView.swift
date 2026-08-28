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

    private let layout: HexGridLayout<Cell>
    private let appearance: HexGridAppearance<Cell>
    @Binding var hexRadius: CGFloat

    var body: some View {
        ZoomableScrollView(
            zoomRange: ZoomableHexMapDefaults.zoomRange,
            onVisibleRectChange: { rect in
                self.visibleRect = rect
            },
            content: {
                HexGridCanvas(
                    layout: layout,
                    appearance: appearance
                )
                .background(.green.opacity(0.7))
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
        self.layout = HexGridLayout(cells: cells, orientation: orientation, hexRadius: hexRadius.wrappedValue)
        self.appearance = HexGridAppearance(
            gridLine: gridLine,
            style: style
        )
        self._hexRadius = hexRadius
    }
}
