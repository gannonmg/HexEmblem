//
//  MapShapePanel.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import SwiftUI

struct MapShapePanel: View {
    private enum MapStyle: String, CaseIterable, Hashable, Identifiable {
        var id: MapStyle { self }
        case grid, disk
    }

    private struct Shape: Equatable {
        var style: MapStyle
        var size: CGFloat   // disk radius == grid column count
        var rows: CGFloat
    }

    private let allowedSizes: ClosedRange<CGFloat> = 1...60

    @Binding var viewModel: PannableHexDemoViewModel
    @State private var shape: Shape

    init(viewModel: Binding<PannableHexDemoViewModel>) {
        self._viewModel = viewModel

        switch viewModel.wrappedValue.mapShape {
        case .disk(let radius):
            shape = Shape(style: .disk, size: CGFloat(radius), rows: CGFloat(radius) / 3)
        case .grid(let col, let row):
            shape = Shape(style: .grid, size: CGFloat(col), rows: CGFloat(row))
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Picker("Map Shape", selection: styleBinding) {
                ForEach(MapStyle.allCases) { style in
                    Text(style.rawValue.capitalized)
                        .id(style)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Text("\(shape.style == .disk ? "Disk Radius" : "Columns"): \(Int(shape.size))")
                Slider(value: $shape.size, in: allowedSizes, step: 1)
            }
            if shape.style == .grid {
                HStack {
                    Text("Rows: \(Int(shape.rows))")
                    Slider(value: $shape.rows, in: allowedSizes, step: 1)
                }
            }
        }
        .onChange(of: shape) {
            viewModel.mapShape = shape.style == .grid
            ? .grid(col: Int(shape.size), row: Int(shape.rows))
            : .disk(radius: Int(shape.size))
        }
    }

    private var styleBinding: Binding<MapStyle> {
        Binding(
            get: { shape.style },
            set: { newStyle in
                if newStyle == .grid { shape.rows = shape.size / 3 }
                shape.style = newStyle
            }
        )
    }
}
