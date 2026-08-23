//
//  PinchToZoomModifier.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import SwiftUI

struct PinchToZoomModifier: ViewModifier {
    @Binding var currentZoom: CGFloat
    @State private var totalZoom = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(currentZoom + totalZoom)
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        currentZoom = value.magnification - 1
                    }
                    .onEnded { value in
                        totalZoom += currentZoom
                        currentZoom = 0
                    }
            )
            .accessibilityZoomAction { action in
                switch action.direction {
                case .zoomIn: totalZoom += 1
                case .zoomOut: totalZoom -= 1
                }
            }
    }
}
