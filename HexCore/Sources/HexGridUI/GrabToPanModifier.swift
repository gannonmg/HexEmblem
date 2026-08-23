//
//  GrabToPanModifier.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import SwiftUI

extension View {
    /// Click-and-drag panning, macOS only. `NSScrollView` ignores a pressed left-drag, so this
    /// can't collide with its own recognizer.
    ///
    /// This gesture is otherwise already handled by an iOS/iPadOS finger drag, or macOS two-finger drag,
    /// so the modifier is a no-op there.
    func grabToPan(visibleRect: CGRect, scrollPosition: Binding<ScrollPosition>) -> some View {
        modifier(GrabToPanModifier(visibleRect: visibleRect, scrollPosition: scrollPosition))
    }
}

private struct GrabToPanModifier: ViewModifier {
    let visibleRect: CGRect
    @Binding var scrollPosition: ScrollPosition

    @State private var panOrigin: CGPoint?

    func body(content: Content) -> some View {
        content.gesture(pan, isEnabled: PointerInput.usesIndirectPointer)
    }

    private var pan: some Gesture {
        DragGesture()
            .onChanged { value in
                let origin = panOrigin ?? visibleRect.origin
                panOrigin = origin
                scrollPosition.scrollTo(point: CGPoint(
                    x: origin.x - value.translation.width,
                    y: origin.y - value.translation.height
                ))
            }
            .onEnded { _ in panOrigin = nil }
    }
}

enum PointerInput {
    /// True where the primary input is an indirect pointer, so a pressed drag can never also
    /// be a scroll. Direct-touch platforms return false: there, a finger drag *is* the
    /// scroll gesture and a competing `DragGesture` fights the scroll view.
    static var usesIndirectPointer: Bool {
#if os(macOS) || targetEnvironment(macCatalyst)
        true
#else
        ProcessInfo.processInfo.isiOSAppOnMac
#endif
    }
}
