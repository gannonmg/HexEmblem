//
//  ZoomableHexGridView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import HexCore
import SwiftUI

struct ZoomableHexGridView<Cell: AxialCoordinateProviding>: View {
    let layout: HexGridLayout<Cell>
    @Binding var hexRadius: CGFloat
    let appearance: HexGridAppearance<Cell>
    var radiusRange: ClosedRange<CGFloat> = 20...200

    @State private var zoomResetCommit: ZoomResetCommit?
    private let zoomRange: ClosedRange<CGFloat> = 0.75...1.33

    var body: some View {
        ZoomableScrollView(
            zoomRange: zoomRange,
            onZoomEvent: zoomChanged(event:),
            zoomResetCommit: zoomResetCommit,
            content: {
                HexGridCanvas(
                    layout: layout,
                    appearance: appearance
                )
                .background(.green.opacity(0.7))
                .background(.blue.opacity(0.7))
            }
        )
    }

    private func zoomChanged(event: ZoomEvent) {
        let zoomScale = event.scale

        // If zoom scale is in our zoom range, ignore - stagger redraw efforts
        guard event.didEnd || !zoomRange.contains(zoomScale) else { return }

        // Calculate the current hex radius displayed
        let newRadius = zoomScale * layout.hexRadius
        guard radiusRange.contains(newRadius) else { return }
        self.hexRadius = newRadius

        self.zoomResetCommit = ZoomResetCommit(
            previousId: zoomResetCommit?.request.id,
            event: event
        )
    }
}
