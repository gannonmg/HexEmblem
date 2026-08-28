//
//  ZoomableScrollView.swift.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import SwiftUI
import UIKit

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    let zoomRange: ClosedRange<CGFloat>
    let showsScrollIndicators: Bool
    let onZoomChange: (_ scale: CGFloat, _ ended: Bool) -> Void
    let zoomResetToken: Int
    let onVisibleRectChange: (CGRect) -> Void
    let content: Content

    init(
        zoomRange: ClosedRange<CGFloat>,
        showsScrollIndicators: Bool = false,
        onZoomChange: @escaping (_ scale: CGFloat, _ ended: Bool) -> Void,
        zoomResetToken: Int,
        onVisibleRectChange: @escaping (CGRect) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.zoomRange = zoomRange
        self.showsScrollIndicators = showsScrollIndicators
        self.onZoomChange = onZoomChange
        self.zoomResetToken = zoomResetToken
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
        private var lastZoomResetToken: Int
        private var isApplyingZoomReset: Bool = false

        init(owner: ZoomableScrollView) {
            self.owner = owner
            self.lastZoomResetToken = owner.zoomResetToken
        }

        // MARK: UIScrollViewDelegate
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostingController?.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard !isApplyingZoomReset else { return }
            reportChange(in: scrollView)
            reportZoomScale(scrollView.zoomScale, zoomEnded: false)
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            reportChange(in: scrollView)
            reportZoomScale(scrollView.zoomScale, zoomEnded: true)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            reportChange(in: scrollView)
        }

        private func reportZoomScale(_ scale: CGFloat, zoomEnded: Bool) {
            owner.onZoomChange(scale, zoomEnded)
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
            guard lastZoomResetToken != owner.zoomResetToken else { return }
            lastZoomResetToken = owner.zoomResetToken
            isApplyingZoomReset = true
            scrollView.setZoomScale(1, animated: false)
            isApplyingZoomReset = false
        }
    }
}
