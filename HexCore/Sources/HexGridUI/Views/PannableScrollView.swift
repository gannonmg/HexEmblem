//
//  PannableScrollView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import SwiftUI

@Observable
final class PannableScrollViewModel {
    var scrollPosition = ScrollPosition()
    var geometry: ScrollGeometry?
    var overpull: CGSize = .zero
    var dragStartOffset: CGPoint?
    var velocitySampler = VelocitySampler()
    var momentumTask: Task<Void, Never>?
}

/// Drag-to-pan for any `ScrollView`, with sampled velocity, momentum, and rubber-band overpull.
///
/// `ScrollPosition` clamps to the scrollable range, so overpull can't come from the scroll view.
/// Past an edge the excess is applied to the content as a resisted `offset` instead.
struct PannableScrollView<Content: View>: View {
    private let axes: Axis.Set
    private let content: Content

    @State private var vm = PannableScrollViewModel()

    init(_ axes: Axis.Set = .vertical, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.content = content()
    }

    var body: some View {
        ScrollView(axes) {
            content
                .environment(\.scrollVisibleRect, vm.geometry?.visibleRect)
                .offset(vm.overpull)
        }
        .scrollPosition($vm.scrollPosition)
        .onScrollGeometryChange(for: ScrollGeometry.self) { $0 } action: { oldValue, newValue in
            guard oldValue != newValue else { return }
            vm.geometry = newValue
        }
        .mousePannable(vm: $vm)
    }
}

extension EnvironmentValues {
    /// The enclosing scroll view's visible rect, in content coordinates. `nil` when nothing
    /// publishes it, in which case grid content draws every cell.
    @Entry var scrollVisibleRect: CGRect?
}
