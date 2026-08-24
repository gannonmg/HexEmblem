//
//  PannableHexGridView 2.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore
import SwiftUI

public struct PannableHexGridView<Cell: AxialCoordinateProviding>: View {

    private let cells: [Cell]
    @State private var geometry: HexGridGeometry<Cell>
    private let appearance: HexGridAppearance<Cell>

    /// Binding for hexRadius that exposes an internal value unless a binding is passed to override it.
    ///
    /// Similar implementation to how `ScrollView` handles `.scrollPosition()`
    @State private var internalHexRadius: CGFloat
    private let externalHexRadius: Binding<CGFloat>?
    private var hexRadius: Binding<CGFloat> { externalHexRadius ?? $internalHexRadius }
    private let radiusRange: ClosedRange<CGFloat>

    public var body: some View {
        PannableScrollView([.horizontal, .vertical]) {
            HexGridView(
                cells: cells,
                geometry: geometry,
                appearance: appearance
            )
        }
        .hexMagnifier(radius: hexRadius, in: radiusRange)
        .onChange(of: hexRadius.wrappedValue) { oldValue, newValue in
            let layout = geometry.layout
            self.geometry = HexGridGeometry(layout: layout, hexRadius: hexRadius.wrappedValue)
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

        self.externalHexRadius = nil
        self.internalHexRadius = hexRadius
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

        self.externalHexRadius = hexRadius
        self.internalHexRadius = hexRadius.wrappedValue
        self.radiusRange = radiusRange
    }
}
