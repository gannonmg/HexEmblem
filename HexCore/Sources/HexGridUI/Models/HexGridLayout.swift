//
//  HexGridLayout.swift
//  HexCore
//
//  Created by Matt Gannon on 8/28/26.
//

import HECommon
import HexCore
import SwiftUI

/// Precomputed layout facts for a set of AxialCoordinates given an orientation and radius.
/// Uses HexGeometry, which is agnostic to size, to spatially lay out the drawn hexagons.
struct HexGridLayout<Cell: AxialCoordinateProviding> {
    struct PlacedCell {
        let cell: Cell
        /// The cell center in fractional hex coordinates.
        let fractionalContentCenter: CGPoint
        /// The cell center in scaled hex coordinates and unadjuseted scaledContentBounds, before shifting into the Canvas frame.
        let contentCenter: CGPoint
        /// The cell center in final Canvas coordinates, where the canvas origin is top-left. Used for culling in visibile rect.
        let canvasCenter: CGPoint
        /// The cell origin in final Canvas coordinates, where the canvas origin is top-left. Used for Canvas drawing.
        let canvasOrigin: CGPoint
        var axialCoordinate: AxialCoordinate { cell.axialCoordinate }
    }

    private let placedCells: [PlacedCell]

    /// The orientation of the cells in the grid. Either pointy or flat top.
    let orientation: HexOrientation
    /// The scaled circumradius, meaning the center-to-corner distance and edge length of each hexagon.
    let hexRadius: CGFloat
    /// The scaled size of each hexagon's bounding box for the current orientation.
    let hexSize: CGSize
    /// The set of axial coordinates included in this layout, used for neighbor and edge checks.
    let coordinateSet: Set<AxialCoordinate>
    /// The unscaled bounds of all hexes in fractional hex coordinates, preserving negative origins.
    let fractionalContentBounds: CGRect
    /// The scaled bounds of all hexes in hex coordinates, preserving negative origins.
    let scaledContentBounds: CGRect
    /// The final drawable size of the Canvas after shifting content bounds into top-left canvas space.
    let scaledContentSize: CGSize
    /// The one translation from scaled, centered hex coordinates into top-left Canvas coordinates.
    let contentOriginInCanvas: CGPoint

    init(
        cells: [Cell],
        orientation: HexOrientation,
        hexRadius: CGFloat
    ) {
        self.orientation = orientation
        self.hexRadius = hexRadius

        // Fractional hex size is sqrt(3):2 or 2:sqrt(3) depending on orientation
        self.hexSize = HexGeometry.Constants.fractionalSize(for: orientation) * hexRadius

        // Store coordinates once so drawing can check neighboring cells without rebuilding the set.
        self.coordinateSet = Set(cells.map(\.axialCoordinate))

        // Preserve the true fractional content bounds so asymmetric maps keep their real origin.
        self.fractionalContentBounds = HexGeometry.deriveContentRect(
            from: cells, orientation: orientation
        )

        // Scale the fractional content bounds into pixel-sized content coordinates without changing the origin.
        self.scaledContentBounds = fractionalContentBounds * hexRadius

        // The canvas only needs the positive drawable size; the origin shift is stored separately.
        self.scaledContentSize = scaledContentBounds.size

        // Shift scaled content coordinates so the content bounds' top-left corner lands at canvas zero.
        let contentOriginInCanvas = CGPoint(x: -scaledContentBounds.minX, y: -scaledContentBounds.minY)
        self.contentOriginInCanvas = contentOriginInCanvas

        self.placedCells = Self.buildPlacedCells(
            from: cells,
            orientation: orientation,
            hexRadius: hexRadius,
            hexSize: hexSize,
            contentOriginInCanvas: contentOriginInCanvas
        )
    }

    private static func buildPlacedCells(
        from cells: [Cell],
        orientation: HexOrientation,
        hexRadius: CGFloat,
        hexSize: CGSize,
        contentOriginInCanvas: CGPoint
    ) -> [PlacedCell] {
        cells.map { cell in
            // Convert axial coordinates into a center point in fractional hex space.
            let fractionalContentCenter = HexGeometry.hexToCartesianPoint(
                axialCoordinate: cell,
                orientation: orientation
            )

            // Scale the fractional content center by the current hex radius.
            let contentCenter = fractionalContentCenter * hexRadius
            // Shift the content center into top-left Canvas coordinates.
            let canvasCenter = contentCenter + contentOriginInCanvas
            // Shift over by half a hex since we are now measuring by frame origin instead of center.
            let canvasOrigin = canvasCenter - CGPoint(x: hexSize.width/2, y: hexSize.height/2)

            return PlacedCell(
                cell: cell,
                fractionalContentCenter: fractionalContentCenter,
                contentCenter: contentCenter,
                canvasCenter: canvasCenter,
                canvasOrigin: canvasOrigin
            )
        }
    }

    func visibleCells(in visibleRect: CGRect) -> [PlacedCell] {
        // Inset by one hex edge on each side to include cells that are not fully on screen.
        let cullRect = visibleRect.insetBy(dx: -hexSize.width, dy: -hexSize.height)
        let visibleCells: [PlacedCell] = placedCells.compactMap { cell in
            guard cullRect.contains(cell.canvasCenter) else { return nil }
            return cell
        }
        return visibleCells
    }

    /*
    /// The smallest radius that keeps the drawn hex count under `maximumVisibleCells`
    /// for a viewport of `size`. Zooming out past this stops shrinking hexes.
    static func minimumHexRadius(
        fitting size: CGSize,
        maximumVisibleCells: Int = 400
    ) -> CGFloat {
        guard maximumVisibleCells > 0, size.width > 0, size.height > 0 else { return 1 }
        let areaPerHex = size.width * size.height / CGFloat(maximumVisibleCells)
        // Inverse of areaPerHex == (3 * sqrt(3) / 2) * radius²
        return sqrt(areaPerHex / (3 * sqrt(3) / 2))
    }
    */
 }
