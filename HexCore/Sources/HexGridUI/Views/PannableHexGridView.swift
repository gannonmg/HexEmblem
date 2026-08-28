//
//  PannableHexGridView 2.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore
import SwiftUI

enum ZoomableHexMapDefaults {
    static let zoomRange: ClosedRange<CGFloat> = 0.7...5
}
/*
public struct PannableHexGridView<Cell: AxialCoordinateProviding>: View {
    private let cells: [Cell]
    @State private var geometry: HexGridGeometry<Cell>
    private let appearance: HexGridAppearance<Cell>
    @State private var visibleRect: CGRect?

    /// Binding for hexRadius that exposes an internal value unless a binding is passed to override it.
    ///
    /// Similar implementation to how `ScrollView` handles `.scrollPosition()`
    @Overridable var hexRadius: CGFloat
    private let radiusRange: ClosedRange<CGFloat>

    public var body: some View {
        ZoomableScrollView(
            zoomRange: ZoomableHexMapDefaults.zoomRange,
            onVisibleRectChange: { rect in
                print("Rect did change: \(rect.alignedDebugString)")
                self.visibleRect = rect
            },
            content: {
                HexGridView(
                    cells: cells,
                    geometry: geometry,
                    appearance: appearance
                )
                .environment(\.scrollVisibleRect, visibleRect)
                .background(.blue.opacity(0.7))
                .onGeometryChange(for: CGSize.self) { $0.size }
                action: { print("HGV Size Change: \($0.alignedDebugString)") }
            }
        )
        .onChange(of: hexRadius) {
            self.geometry = HexGridGeometry(layout: geometry.layout, hexRadius: hexRadius)
        }
    }
}

// MARK: - Init
extension PannableHexGridView {
    public init(
        cells: [Cell],
        hexRadius: CGFloat = HexGridDefaults.initialRadius,
        radiusRange: ClosedRange<CGFloat> = HexGridDefaults.radiusRange,
        orientation: HexOrientation,
        gridLine: HexGridLine? = nil,
        style: @escaping (Cell) -> HexCellStyle
    ) {
        self.cells = cells
        self.geometry = HexGridGeometry(
            layout: HexGridLayout(cells: cells, orientation: orientation),
            hexRadius: hexRadius
        )
        self.appearance = HexGridAppearance(
            gridLine: gridLine,
            style: style
        )

        self.hexRadius = hexRadius
        self.radiusRange = radiusRange
    }

    public init(
        cells: [Cell],
        hexRadius: Binding<CGFloat>,
        radiusRange: ClosedRange<CGFloat> = HexGridDefaults.radiusRange,
        orientation: HexOrientation,
        gridLine: HexGridLine? = nil,
        style: @escaping (Cell) -> HexCellStyle
    ) {
        self.cells = cells
        self.geometry = HexGridGeometry(
            layout: HexGridLayout(cells: cells, orientation: orientation),
            hexRadius: hexRadius.wrappedValue
        )
        self.appearance = HexGridAppearance(
            gridLine: gridLine,
            style: style
        )

        self._hexRadius = Overridable(hexRadius)
        self.radiusRange = radiusRange
    }
}
*/

