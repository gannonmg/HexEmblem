//
//  HexMagnifierModifier.swift
//  HexCore
//
//  Created by Matt Gannon on 8/24/26.
//

import SwiftUI

extension View {
    func hexMagnifier(radius: Binding<CGFloat>, in range: ClosedRange<CGFloat>) -> some View {
        self.modifier(HexMagnifierModifier(hexRadius: radius, radiusRange: range))
    }
}

private struct HexMagnifierModifier: ViewModifier {
    @Binding var hexRadius: CGFloat
    let radiusRange: ClosedRange<CGFloat>
    @State private var radiusAtPinchStart: CGFloat?

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(magnify)
    }

    private var magnify: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0)
            .onChanged { value in
                let start = radiusAtPinchStart ?? hexRadius
                radiusAtPinchStart = start
                hexRadius = min(
                    max(start * value.magnification, radiusRange.lowerBound),
                    radiusRange.upperBound
                )
            }
            .onEnded { _ in radiusAtPinchStart = nil }
    }
}
