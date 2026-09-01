//
//  ZoomEvent.swift
//  HexCore
//
//  Created by Matt Gannon on 8/31/26.
//

import CoreGraphics

/// Transmitted to the consuming view, allowing it to update it's content appropriately before resetting the zoomscale to 1.
struct ZoomEvent {
    let scale: CGFloat
    let didEnd: Bool
    let contentAnchor: CGPoint
    /// The point in the zoomable content’s own coordinate space that should remain visually stable across the zoom commit.
    let viewportAnchor: CGPoint
    let viewport: CGRect
}
