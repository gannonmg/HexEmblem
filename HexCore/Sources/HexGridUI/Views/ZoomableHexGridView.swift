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

    @State private var zoomResetRequest: ZoomResetRequest?
    private let zoomRange: ClosedRange<CGFloat> = 0.75...1.33

    var body: some View {
        ZoomableScrollView(
            zoomRange: zoomRange,
            onZoomEvent: zoomChanged(event:),
            zoomResetRequest: zoomResetRequest,
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

    private func zoomChanged(event: ZoomEvent) {
        let zoomScale = event.scale

        // If zoom scale is in our zoom range, ignore - stagger redraw efforts
        guard event.didEnd || !zoomRange.contains(zoomScale) else { return }

        // Calculate the current hex radius displayed
        let oldRadius = layout.hexRadius
        let newRadius = zoomScale * oldRadius
        guard radiusRange.contains(newRadius) else { return }
        self.hexRadius = newRadius

        // Rebuild layout with the displayed radius, triggering a rebuild
        self.layout = layout.rebuilt(with: newRadius)

        // Compute the new content anchor
        // ie, translate the content anchor from the previous layout to a corrected content offset for our new layout
        // Viewport anchor is where in the scroll's visible bounds the new content anchor should appear.
        let radiusRatio = newRadius / oldRadius
        let newContentAnchor = event.contentAnchor * radiusRatio

        let nextRequestId = (zoomResetRequest?.id ?? 0) + 1
        self.zoomResetRequest = ZoomResetRequest(
            id: nextRequestId,
            anchorInContent: newContentAnchor,
            anchorInViewport: event.viewportAnchor
        )
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
