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

/// Thin wrapper around `ZoomableScrollUIView` to manage `scrollViewport` and pass it into the environment
struct ZoomableScrollView<Content: View>: View {
    @State private var scrollViewport: CGRect = .zero

    let zoomRange: ClosedRange<CGFloat>
    var showsScrollIndicators: Bool = false
    let onZoomEvent: (ZoomEvent) -> Void
    let zoomResetRequest: ZoomResetRequest?
    let content: () -> Content

    var body: some View {
        ZoomableScrollUIView(
            zoomRange: zoomRange,
            showsScrollIndicators: showsScrollIndicators,
            onZoomEvent: onZoomEvent,
            zoomResetRequest: zoomResetRequest,
            onViewportChange: { scrollViewport = $0 },
            content: {
                content()
                    .environment(\.scrollViewport, scrollViewport)
            }
        )
    }
}

private struct ZoomableScrollUIView<Content: View>: UIViewRepresentable {

    let zoomRange: ClosedRange<CGFloat>
    let showsScrollIndicators: Bool
    let onZoomEvent: (ZoomEvent) -> Void
    let zoomResetRequest: ZoomResetRequest?
    let onViewportChange: (CGRect) -> Void
    let content: Content

    init(
        zoomRange: ClosedRange<CGFloat>,
        showsScrollIndicators: Bool = false,
        onZoomEvent: @escaping (ZoomEvent) -> Void,
        zoomResetRequest: ZoomResetRequest?,
        onViewportChange: @escaping (CGRect) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.zoomRange = zoomRange
        self.showsScrollIndicators = showsScrollIndicators
        self.onZoomEvent = onZoomEvent
        self.zoomResetRequest = zoomResetRequest
        self.onViewportChange = onViewportChange
        self.content = content()
    }

    // MARK: Build UIView
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = buildScrollView(delegate: context.coordinator)
        let hosting = buildHostingController(context: context)
        scrollView.addSubview(hosting.view)
        scrollView.contentLayoutGuide.pinSubviewToEdges(subview: hosting.view)
        publishViewportUpdate(from: scrollView)

        // Debug backgrounds
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
        publishViewportUpdate(from: scrollView)
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

    // MARK: - ScrollView Updates
    private func publishViewportUpdate(from scrollView: UIScrollView) {
        DispatchQueue.main.async {
            let viewport = scrollView.bounds / scrollView.zoomScale
            onViewportChange(viewport)
        }
    }

    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator { Coordinator(owner: self) }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>?
        var owner: ZoomableScrollUIView
        private var lastZoomResetRequest: ZoomResetRequest?
        private var isApplyingZoomReset: Bool = false

        init(owner: ZoomableScrollUIView) {
            self.owner = owner
            self.lastZoomResetRequest = owner.zoomResetRequest
        }

        // MARK: UIScrollViewDelegate
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostingController?.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard !isApplyingZoomReset else { return }
            owner.publishViewportUpdate(from: scrollView)
            reportZoomScale(in: scrollView, didEnd: false)
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            owner.publishViewportUpdate(from: scrollView)
            reportZoomScale(in: scrollView, didEnd: true)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            owner.publishViewportUpdate(from: scrollView)
        }

        private func reportZoomScale(in scrollView: UIScrollView, didEnd zoomEnded: Bool) {
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

            owner.publishViewportUpdate(from: scrollView)
        }
    }
}
