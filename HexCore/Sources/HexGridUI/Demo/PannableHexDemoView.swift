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

    var mapShape: HexMapShape {
        didSet {
            self.cells = Self.cells(
                for: mapShape,
                orientation: HexOrientation(isPointy: isPointyTop)
            )
        }
    }
    var hexRadius: CGFloat
    var isPointyTop: Bool
    var showCoordinates: Bool
    private(set) var cells: [ColoredHexCell]

    init(
        mapShape: HexMapShape = .disk(radius: 30),
        hexRadius: CGFloat = 50,
        isPointyTop: Bool = true,
        showCoordinates: Bool = true,
    ) {
        self.mapShape = mapShape
        self.hexRadius = hexRadius
        self.isPointyTop = isPointyTop
        self.showCoordinates = showCoordinates
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
        PannableHexGridView(cells: viewModel.cells, hexRadius: viewModel.hexRadius, orientation: viewModel.orientation) { cell in
            HexCellStyle(
                fill: .color(cell.color),
                stroke: .color(.black.opacity(0.25)),
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
