//
//  HexGridGeometry.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import HexCore
import SwiftUI

struct HexGridGeometryOld<Cell: AxialCoordinateProviding> {
    struct PlacedCell: Identifiable {
        let id: AxialCoordinate
        let cell: Cell
        let position: CGPoint
    }

    struct EdgeOffset {
        let start: CGPoint
        let end: CGPoint
    }

    private let directions = AxialDirection.allCases

    let layout: HexGridLayout
    let contentSize: CGSize
    /// Bounding-box dimensions per unit of radius. Pointy top is (√3, 2); flat top is (2, √3).
    let hexSizeRatio: CGSize
    /// Center-to-corner distance in points. The one dimensional input.
    let hexRadius: CGFloat
    /// The drawn hex's bounding box: `hexSizeRatio * hexRadius`.
    let hexSize: CGSize
    /// Corner offsets from a hex's center, one pair per direction. Identical for every cell,
    /// so the trig runs once per geometry instead of once per edge per frame.
    let edgeOffsets: [AxialDirection: EdgeOffset]

    init(layout: HexGridLayout, hexRadius: CGFloat) {
        self.layout = layout
        self.hexRadius = hexRadius
        self.contentSize = layout.contentRect.size * hexRadius

        let hexSizeRatio = Hexagon.fractionalSize(for: layout.orientation)
        self.hexSizeRatio = hexSizeRatio
        self.hexSize = hexSizeRatio * hexRadius
        self.edgeOffsets = [:]
//        Self.precomputeEdgeOffsets(orientation: layout.orientation, hexRadius: hexRadius)
    }

    /// Lattice position shifted so the content's top-left is the origin, at radius 1.
    func unitPosition(of coordinate: some AxialCoordinateProviding) -> CGPoint {
        let point = HexScreenMath.hexToCartesianPoint(
            axialCoordinate: coordinate,
            orientation: layout.orientation
        )
        return CGPoint(
            x: point.x - layout.contentRect.minX,
            y: point.y - layout.contentRect.minY
        )
    }

    /// The hex's center in content coordinates at the current radius.
    func position(of coordinate: some AxialCoordinateProviding) -> CGPoint {
        let unit = unitPosition(of: coordinate)
        return CGPoint(x: unit.x * hexRadius, y: unit.y * hexRadius)
    }

    /// The edge facing `AxialCoordinate.directions[direction]`.
    func edge(facing direction: AxialDirection, from center: CGPoint) -> (start: CGPoint, end: CGPoint) {
        guard let offset = edgeOffsets[direction] else { return (center, center) }
        return (
            CGPoint(x: center.x + offset.start.x, y: center.y + offset.start.y),
            CGPoint(x: center.x + offset.end.x, y: center.y + offset.end.y)
        )
    }

    /*
    private static func precomputeEdgeOffsets(
        orientation: HexOrientation,
        hexRadius: CGFloat
    ) -> [AxialDirection: EdgeOffset] {
        Dictionary(uniqueKeysWithValues: AxialDirection.allCases.map { direction in
            let radians = direction.angle(for: orientation).radians
            let start = CGPoint.zero.offset(distance: hexRadius, angle: .radians(radians - .pi / 6))
            let end = CGPoint.zero.offset(distance: hexRadius, angle: .radians(radians + .pi / 6))
            return (direction, EdgeOffset(start: start, end: end))
        })
    }
*/
    func visibleCells(
        from cells: [Cell],
        in visibleRect: CGRect?
    ) -> [PlacedCell] {
        let cullRect = visibleRect.map { rect in
            CGRect(
                x: rect.minX / hexRadius,
                y: rect.minY / hexRadius,
                width: rect.width / hexRadius,
                height: rect.height / hexRadius
            )
            .insetBy(dx: -hexSizeRatio.width, dy: -hexSizeRatio.height)
        }

        return cells.compactMap { cell in
            let unitPosition = unitPosition(of: cell)
            if let cullRect, !cullRect.contains(unitPosition) { return nil }
            return PlacedCell(
                id: cell.axialCoordinate,
                cell: cell,
                position: CGPoint(x: unitPosition.x * hexRadius, y: unitPosition.y * hexRadius)
            )
        }
    }
}
