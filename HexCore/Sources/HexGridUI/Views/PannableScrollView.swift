//
//  PannableScrollView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import SwiftUI

/// Drag-to-pan for any `ScrollView`, with sampled velocity, momentum, and rubber-band overpull.
///
/// `ScrollPosition` clamps to the scrollable range, so overpull can't come from the scroll view.
/// Past an edge the excess is applied to the content as a resisted `offset` instead.
struct PannableScrollView<Content: View>: View {
    private let axes: Axis.Set
    private let content: Content

    private static var decelerationRate: CGFloat { 0.998 }

    @State private var scrollPosition = ScrollPosition()
    @State private var geometry: ScrollGeometry?
    @State private var overpull: CGSize = .zero
    @State private var dragStartOffset: CGPoint?
    @State private var velocitySampler = VelocitySampler()

    @State private var momentumTask: Task<Void, Never>?

    init(_ axes: Axis.Set = .vertical, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.content = content()
    }

    var body: some View {
        ScrollView(axes) {
            content
                .environment(\.scrollVisibleRect, geometry?.visibleRect)
                .offset(overpull)
        }
        .scrollPosition($scrollPosition)
        .onScrollGeometryChange(for: ScrollGeometry.self) { $0 } action: { oldValue, newValue in
            guard oldValue != newValue else { return }
            geometry = newValue
        }
        .gesture(pan, isEnabled: PointerInput.usesIndirectPointer)
    }

    private var pan: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                momentumTask?.cancel()
                guard let geometry else { return }

                let start = dragStartOffset ?? geometry.visibleRect.origin
                dragStartOffset = start
                velocitySampler.record(value.translation, at: value.time)

                apply(
                    desired: CGPoint(
                        x: start.x - value.translation.width,
                        y: start.y - value.translation.height
                    ),
                    in: geometry
                )
            }
            .onEnded { value in
                guard let geometry else { return }
                let start = dragStartOffset ?? geometry.visibleRect.origin
                dragStartOffset = nil

                velocitySampler.record(value.translation, at: value.time)
                let exitVelocity = velocitySampler.velocity
                velocitySampler.reset()

                // Released while pulled past an edge: snap back, no fling.
                guard overpull == .zero else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        overpull = .zero
                    }
                    return
                }

                let target = clamp(
                    CGPoint(
                        x: start.x - value.translation.width - projection(of: exitVelocity.width),
                        y: start.y - value.translation.height - projection(of: exitVelocity.height)
                    ),
                    in: geometry
                )

                let released = clamp(
                    CGPoint(
                        x: start.x - value.translation.width,
                        y: start.y - value.translation.height
                    ),
                    in: geometry
                )
                let distance = hypot(target.x - released.x, target.y - released.y)
                let speed = hypot(exitVelocity.width, exitVelocity.height)

                withAnimation(
                    .interpolatingSpring(
                        duration: 0.8,
                        bounce: 0,
                        initialVelocity: distance > 0 ? speed / distance : 0
                    )
                ) {
                    momentumTask = momentumTask(released: released, exitVelocity: exitVelocity)
                }
            }
    }

    private func momentumTask(
        released: CGPoint,
        exitVelocity: CGSize,
        decelerationRate: CGFloat = Self.decelerationRate
    ) -> Task<Void, Never> {
        Task { @MainActor in
            var position = released
            var velocity = exitVelocity
            var lastTime = CACurrentMediaTime()

            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(8))
                guard let geometry else { return }

                let now = CACurrentMediaTime()
                // Cap the step so a stalled frame can't teleport the content.
                let elapsed = min(now - lastTime, 1.0 / 30)
                lastTime = now

                // UIScrollView's model: velocity retains `decelerationRate` of itself per millisecond.
                let decay = pow(decelerationRate, elapsed * 1000)
                velocity = CGSize(width: velocity.width * decay, height: velocity.height * decay)
                guard hypot(velocity.width, velocity.height) > 5 else { return }

                position = CGPoint(
                    x: position.x - velocity.width * elapsed,
                    y: position.y - velocity.height * elapsed
                )
                let reachable = clamp(position, in: geometry)
                guard reachable == position else { return }

                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    scrollPosition.scrollTo(point: reachable)
                }
            }
        }
    }

    private func apply(desired: CGPoint, in geometry: ScrollGeometry) {
        let reachable = clamp(desired, in: geometry)
        let excess = CGSize(
            width: desired.x - reachable.x,
            height: desired.y - reachable.y
        )

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            scrollPosition.scrollTo(point: reachable)
            // Content moves opposite to offset, so the excess is negated.
            overpull = CGSize(
                width: -rubberBand(excess.width, dimension: geometry.visibleRect.width),
                height: -rubberBand(excess.height, dimension: geometry.visibleRect.height)
            )
        }
    }

    /// The scrollable range of `visibleRect.origin`. Insets shift both ends — a 32pt top inset
    /// makes `-32` the resting position at the top, not `0`.
    private func clamp(_ point: CGPoint, in geometry: ScrollGeometry) -> CGPoint {
        let insets = geometry.contentInsets
        let minimum = CGPoint(x: -insets.leading, y: -insets.top)
        let maximum = CGPoint(
            x: max(minimum.x, geometry.contentSize.width + insets.trailing - geometry.visibleRect.width),
            y: max(minimum.y, geometry.contentSize.height + insets.bottom - geometry.visibleRect.height)
        )
        return CGPoint(
            x: min(max(point.x, minimum.x), maximum.x),
            y: min(max(point.y, minimum.y), maximum.y)
        )
    }

    /// Resistance curve that asymptotes at `dimension`, so overpull can never run away.
    private func rubberBand(_ distance: CGFloat, dimension: CGFloat, coefficient: CGFloat = 0.55) -> CGFloat {
        guard dimension > 0, distance != 0 else { return 0 }
        let resisted = (1 - (1 / (abs(distance) * coefficient / dimension + 1))) * dimension
        return distance < 0 ? -resisted : resisted
    }

    /// Where a flick comes to rest under constant deceleration. Lower rates stop sooner.
    private func projection(
        of velocity: CGFloat,
        decelerationRate: CGFloat = Self.decelerationRate
    ) -> CGFloat {
        (velocity / 1000) * decelerationRate / (1 - decelerationRate)
    }
}

extension EnvironmentValues {
    /// The enclosing scroll view's visible rect, in content coordinates. `nil` when nothing
    /// publishes it, in which case grid content draws every cell.
    @Entry var scrollVisibleRect: CGRect?
}
