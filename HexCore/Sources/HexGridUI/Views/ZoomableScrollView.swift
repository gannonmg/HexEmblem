//
//  ZoomableScrollView.swift.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import HexCore // Currently owns some CoreGraphics utility funcs. Should be abstracted out
import SwiftUI
import UIKit

struct ZoomEvent {
    let scale: CGFloat
    let didEnd: Bool
    let contentAnchor: CGPoint
    /// The point in the zoomable content’s own coordinate space that should remain visually stable across the zoom commit.
    let viewportAnchor: CGPoint
}

struct ZoomResetRequest: Equatable {
    let id: Int
    /// The point in the zoomable content’s own coordinate space that should remain visually stable across the zoom commit.
    /// Derived from `ZoomEvent.contentAnchor` updated with the newly applied content scale (in our case, hex radius)
    let anchorInContent: CGPoint
    /// The point in the zoomable content’s own coordinate space that should remain visually stable across the zoom commit.
    ///
    /// This is received from a `ZoomEvent` and serves as the constant between `Event` -> `Request`
    let anchorInViewport: CGPoint
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    let zoomRange: ClosedRange<CGFloat>
    let showsScrollIndicators: Bool
    let onZoomEvent: (ZoomEvent) -> Void
    let zoomResetRequest: ZoomResetRequest?
    let onVisibleRectChange: (CGRect) -> Void
    let content: Content

    init(
        zoomRange: ClosedRange<CGFloat>,
        showsScrollIndicators: Bool = false,
        onZoomEvent: @escaping (ZoomEvent) -> Void,
        zoomResetRequest: ZoomResetRequest?,
        onVisibleRectChange: @escaping (CGRect) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.zoomRange = zoomRange
        self.showsScrollIndicators = showsScrollIndicators
        self.onZoomEvent = onZoomEvent
        self.zoomResetRequest = zoomResetRequest
        self.onVisibleRectChange = onVisibleRectChange
        self.content = content()
    }

    // MARK: Build UIView
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = buildScrollView(delegate: context.coordinator)
        let hosting = buildHostingController(context: context)
        scrollView.addSubview(hosting.view)
        scrollView.contentLayoutGuide.pinSubviewToEdges(subview: hosting.view)
        hosting.view.backgroundColor = .systemPink
        scrollView.backgroundColor = .systemOrange
        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.owner = self
        context.coordinator.hostingController?.rootView = content
        scrollView.minimumZoomScale = zoomRange.lowerBound
        scrollView.maximumZoomScale = zoomRange.upperBound
        context.coordinator.resetZoomIfNeeded(in: scrollView)
    }

    private func buildScrollView(delegate: UIScrollViewDelegate) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = showsScrollIndicators
        scrollView.showsVerticalScrollIndicator = showsScrollIndicators
        scrollView.minimumZoomScale = zoomRange.lowerBound
        scrollView.maximumZoomScale = zoomRange.upperBound
        scrollView.delegate = delegate
        return scrollView
    }

    private func buildHostingController(context: Context) -> UIHostingController<Content> {
        let hosting = UIHostingController(rootView: content)
        hosting.view.backgroundColor = .clear
        hosting.sizingOptions = [.intrinsicContentSize]
        context.coordinator.hostingController = hosting
        return hosting
    }

    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator { Coordinator(owner: self) }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>?
        var owner: ZoomableScrollView
        private var lastZoomResetRequest: ZoomResetRequest?
        private var isApplyingZoomReset: Bool = false

        init(owner: ZoomableScrollView) {
            self.owner = owner
            self.lastZoomResetRequest = owner.zoomResetRequest
        }

        // MARK: UIScrollViewDelegate
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostingController?.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard !isApplyingZoomReset else { return }
            reportChange(in: scrollView)
            reportZoomScale(in: scrollView, zoomEnded: false)
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            reportChange(in: scrollView)
            reportZoomScale(in: scrollView, zoomEnded: true)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            reportChange(in: scrollView)
        }

        private func reportZoomScale(in scrollView: UIScrollView, zoomEnded: Bool) {
            guard let gesture = scrollView.pinchGestureRecognizer else { return }
            let pinchLocationInScrollView = gesture.location(in: scrollView)
            let viewportAnchor = pinchLocationInScrollView - scrollView.bounds.origin
            let contentAnchor = gesture.location(in: hostingController?.view)

            let event = ZoomEvent(
                scale: scrollView.zoomScale,
                didEnd: zoomEnded,
                contentAnchor: contentAnchor,
                viewportAnchor: viewportAnchor
            )
            owner.onZoomEvent(event)
        }

        private func reportChange(in scrollView: UIScrollView) {
            let scale = scrollView.zoomScale
            guard 0 < scale else { return }

            let visibleRect = CGRect(
                x: scrollView.contentOffset.x / scale,
                y: scrollView.contentOffset.y / scale,
                width: scrollView.bounds.width / scale,
                height: scrollView.bounds.height / scale
            )

            owner.onVisibleRectChange(visibleRect)
        }

        func resetZoomIfNeeded(in scrollView: UIScrollView) {
            // Ensure we have a fresh reset request
            guard let request = owner.zoomResetRequest,
                  lastZoomResetRequest?.id != request.id
            else { return }

            // Store new request as most recent
            lastZoomResetRequest = owner.zoomResetRequest

            // Block update reports from zoom interactions until we are done with our reset
            isApplyingZoomReset = true
            scrollView.setZoomScale(1, animated: false)
            scrollView.contentOffset = request.anchorInContent - request.anchorInViewport
            isApplyingZoomReset = false
        }
    }
}
