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

    @State private var layout: HexGridLayout<Cell>
    private let appearance: HexGridAppearance<Cell>
    @Binding var hexRadius: CGFloat
    private let radiusRange: ClosedRange<CGFloat>

    @State private var zoomResetToken: Int = 0
    private let zoomRange: ClosedRange<CGFloat> = 0.75...1.33

    var body: some View {
        ZoomableScrollView(
            zoomRange: zoomRange,
            onZoomChange: zoomChanged(_:_:),
            zoomResetToken: zoomResetToken,
            onVisibleRectChange: { rect in
//                self.visibleRect = rect
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

    private func zoomChanged(_ zoomScale: CGFloat, _ zoomEnded: Bool) {
        print("Zoom scale: \(zoomScale)")

        // If zoom scale is in our zoom range, ignore - stagger redraw efforts
        if zoomRange.contains(zoomScale) { return }

        // Calculate the current hex radius displayed
        var visibleRadius = zoomScale * layout.hexRadius
        guard radiusRange.contains(visibleRadius) else { return }
        self.hexRadius = visibleRadius

        // Rebuild layout with the displayed radius, triggering a rebuild
        self.layout = layout.rebuilt(with: visibleRadius)

        // Set the ScrollViews zoom scale back to 1
        zoomResetToken += 1
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
        self.radiusRange = radiusRange
    }
}
