//
//  ZoomResetRequest.swift
//  HexCore
//
//  Created by Matt Gannon on 8/31/26.
//

import CoreGraphics

/// This is the specific content within ZoomResetCommit that is handed to the coordinator to update the contents of the scrollview
/// and ensure it is stable between scale resets.
struct ZoomResetRequest: Equatable {
    let id: Int
    /// The point in the zoomable content’s own coordinate space that should remain visually stable across the zoom commit.
    /// Derived from `ZoomEvent.contentAnchor` updated with the newly applied content scale
    let anchorInContent: CGPoint
    /// The point in the zoomable content’s own coordinate space that should remain visually stable across the zoom commit.
    ///
    /// This is received from a `ZoomEvent` and serves as the constant between `Event` -> `Request`
    let anchorInViewport: CGPoint
}
