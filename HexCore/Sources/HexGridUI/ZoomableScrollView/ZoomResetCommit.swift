//
//  ZoomResetCommit.swift
//  HexCore
//
//  Created by Matt Gannon on 8/31/26.
//

import CoreGraphics
import HexCore // Currently owns some CoreGraphics utility funcs. Should be abstracted out
import Foundation

/// After the consumer handles updating its content based on the forthcoming viewport changes,
/// this resets the zoom scale to one and updates the viewport based on the projected size.
///
/// It is necessary to group the zoom reset and the viewport update publishing to ensure the Content view is all refreshed atomically.
struct ZoomResetCommit: Equatable {
    /// The immediate requests that UIKit needs to fulfill: resetting zoomScale to 1 and updating the content offset.
    let request: ZoomResetRequest
    /// The viewport value that any consumer should use to update content based on visible bounds.
    let viewportAfterReset: CGRect

    init(previousId: Int?, event: ZoomEvent) {
        let contentScaleRatio = event.scale
        let scaledContentAnchor = event.contentAnchor * contentScaleRatio

        self.request = ZoomResetRequest(
            id: (previousId ?? 0) + 1,
            anchorInContent: scaledContentAnchor,
            anchorInViewport: event.viewportAnchor
        )

        self.viewportAfterReset = CGRect(
            origin: scaledContentAnchor - event.viewportAnchor,
            size: event.viewport.size * contentScaleRatio
        )
    }
}
