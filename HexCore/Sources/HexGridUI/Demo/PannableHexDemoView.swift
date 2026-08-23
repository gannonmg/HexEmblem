//
//  PannableHexDemoView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import HexCore
import SwiftUI

@Observable
final class PannableHexDemoViewModel {

    var diskRadius: Int {
        didSet {
            self.cells = ColoredHexFactory.cells(diskRadius: diskRadius)
        }
    }
    var hexRadius: CGFloat
    var isPointyTop: Bool
    var showCoordinates: Bool
    private(set) var cells: [ColoredHexCell]

    init(
        diskRadius: Int = 3,
        hexRadius: CGFloat = 50,
        isPointyTop: Bool = true,
        showCoordinates: Bool = true,
    ) {
        self.diskRadius = diskRadius
        self.hexRadius = hexRadius
        self.isPointyTop = isPointyTop
        self.showCoordinates = showCoordinates
        self.cells = ColoredHexFactory.cells(diskRadius: diskRadius)
    }
}

public struct PannableHexDemoView: View {
    // MARK: Computed
    private var orientation: HexOrientation { viewModel.isPointyTop ? .pointyTop : .flatTop }

    // MARK: Init
    @State private var viewModel: PannableHexDemoViewModel

    public init() {
        self.viewModel = PannableHexDemoViewModel()
    }

    // MARK: Content
    public var body: some View {
        PannableHexGridView(cells: viewModel.cells, hexRadius: viewModel.hexRadius, orientation: orientation) { cell in
            Hexagon(orientation: orientation)
                .overlay {
                    Text("\(cell.axialCoordinate.q), \(cell.axialCoordinate.r)")
                        .foregroundStyle(.white)
                        .opacity(viewModel.showCoordinates ? 1 : 0)
                }
                .foregroundStyle(cell.color)
                .transition(.opacity)
        }
        .animation(.default, value: orientation)
        .animation(.default, value: viewModel.showCoordinates)
        .animation(.default, value: viewModel.hexRadius)
        .settingsPanel(vm: $viewModel)
    }
}
