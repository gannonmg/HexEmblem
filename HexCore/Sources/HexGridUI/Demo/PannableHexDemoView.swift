//
//  PannableHexDemoView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import HexCore
import SwiftUI

enum HexMapShape: Equatable {
    case disk(radius: Int)
    case grid(col: Int, row: Int)
}

@Observable
final class PannableHexDemoViewModel {
    // MARK: Computed
    var orientation: HexOrientation { HexOrientation(isPointy: isPointyTop) }

    var gridLines: HexGridLine? { showGrid ? HexGridLine() : nil }


    var showGrid: Bool = true
    var showCoordinates: Bool = false
    var hexRadius: CGFloat = 50

    var mapShape: HexMapShape {
        didSet { rebuildCells() }
    }

    var isPointyTop: Bool {
        didSet {
            guard case .grid = mapShape else { return }
            rebuildCells()
        }
    }

    private(set) var cells: [ColoredHexCell]

    init(
        mapShape: HexMapShape = .disk(radius: 30),
        isPointyTop: Bool = true
    ) {
        self.mapShape = mapShape
        self.isPointyTop = isPointyTop
        self.cells = Self.cells(
            for: mapShape,
            orientation: HexOrientation(isPointy: isPointyTop)
        )
    }

    private func rebuildCells() {
        self.cells = Self.cells(
            for: mapShape,
            orientation: HexOrientation(isPointy: isPointyTop)
        )
    }

    private static func cells(for mapShape: HexMapShape, orientation: HexOrientation) -> [ColoredHexCell] {
        switch mapShape {
        case .disk(let radius):
            ColoredHexFactory.disk(radius: radius)
        case .grid(let col, let row):
            ColoredHexFactory.grid(col: col, row: row, orientation: orientation)
        }
    }
}

public struct PannableHexDemoView: View {

    // MARK: Init
    @State private var viewModel: PannableHexDemoViewModel

    public init() {
        self.viewModel = PannableHexDemoViewModel()
    }

    // MARK: Content
    public var body: some View {
        PannableHexGridView(
            cells: viewModel.cells,
            hexRadius: viewModel.hexRadius,
            orientation: viewModel.orientation,
            gridLine: viewModel.gridLines
        ) { cell in
            HexCellStyle(
                fill: .color(cell.color),
                label: viewModel.showCoordinates
                ? Text("\(cell.axialCoordinate.q), \(cell.axialCoordinate.r)")
                : nil
            )
        }
        .animation(.default, value: viewModel.orientation)
        .animation(.default, value: viewModel.mapShape)
        .animation(.default, value: viewModel.showCoordinates)
        .animation(.default, value: viewModel.hexRadius)
        .settingsPanel(vm: $viewModel)
    }
}
