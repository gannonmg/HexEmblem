//
//  ZoomableScrollView.swift
//  HexCore
//
//  Created by Matt Gannon on 9/2/26.
//

import SwiftUI

/// Thin wrapper around `ZoomableScrollUIView` to manage `scrollViewport` and pass it into the environment
struct ZoomableScrollView<Content: View>: View {
    @State private var scrollViewport: CGRect = .zero

    let zoomRange: ClosedRange<CGFloat>
    var showsScrollIndicators: Bool = false
    let onZoomEvent: (ZoomEvent) -> Void
    let zoomResetCommit: ZoomResetCommit?
    let content: () -> Content

    var body: some View {
        ZoomableScrollUIView(
            zoomRange: zoomRange,
            showsScrollIndicators: showsScrollIndicators,
            onZoomEvent: onZoomEvent,
            zoomResetCommit: zoomResetCommit,
            onViewportChange: { scrollViewport = $0 },
            content: {
                content()
                    .environment(\.scrollViewport, scrollViewport)
            }
        )
        .onChange(of: zoomResetCommit) {
            // Ensures that consumers have a fresh viewport after a zoom scale reset.
            guard let zoomResetCommit else { return }
            scrollViewport = zoomResetCommit.viewportAfterReset
        }
    }
}
