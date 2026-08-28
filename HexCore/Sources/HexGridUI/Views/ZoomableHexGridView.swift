//
//  ZoomableHexGridView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import HexCore
import SwiftUI

struct ZoomableHexGridView<Cell: AxialCoordinateProviding>: View {
    @State private var visibleRect: CGRect?

    let cells: [Cell]
    let fractionalPositions: [AxialCoordinate: CGPoint]
    let contentRect: CGRect
    @Binding var hexRadius: CGFloat
    let radiusRange: ClosedRange<CGFloat>
    let orientation: HexOrientation
    private let appearance: HexGridAppearance<Cell>

    var body: some View {
        ZoomableScrollView(
            zoomRange: ZoomableHexMapDefaults.zoomRange,
            onVisibleRectChange: { rect in
//                print("Rect did change: \(rect.alignedDebugString)")
                self.visibleRect = rect
            },
            content: {
                Canvas { context, size in
                    print("Context size: \(size.alignedDebugString)")
                    let hexSize = Hexagon.fractionalSize(for: orientation) * hexRadius
                    let bufferSize = hexSize * (1/hexSize.width)
                    let fillSize = hexSize + bufferSize
                    print("Fill size: \(fillSize.alignedDebugString)")
                    let template = Hexagon(orientation: orientation)
                        .path(in: CGRect(origin: .zero, size: fillSize))

                    for cell in cells {
                        guard let fractionalPosition = fractionalPositions[cell.axialCoordinate] else { continue }

                        let position = fractionalPosition * hexRadius
                        let path = template.applying(.translation(with: position).translated(by: contentRect.center))

                        let style = appearance.style(cell)
                        context.fill(path, with: style.fill)
                    }

                    if let gridLine = appearance.gridLine, 0 < gridLine.width {
                        let gridPath = buildGridPath()
                        context.stroke(
                            gridPath,
                            with: gridLine.shading,
                            style: StrokeStyle(lineWidth: gridLine.width, lineCap: .round)
                        )
                    }

                }
                .frame(width: 600, height: 600)
                .background(.blue.opacity(0.7))
//                .environment(\.scrollVisibleRect, visibleRect)
//                .onGeometryChange(for: CGSize.self) { $0.size }
//                action: { print("HGV Size Change: \($0.alignedDebugString)") }
            }
        )
    }
}

extension CGAffineTransform {
    static func translation(with point: CGPoint) -> Self {
        CGAffineTransform(translationX: point.x, y: point.y)
    }

    func translated(by point: CGPoint) -> Self {
        self.translatedBy(x: point.x, y: point.y)
    }
}

// MARK: - Canvas
extension ZoomableHexGridView {
    func buildGridPath() -> Path {
        var gridPath = Path()
        let coordinateSet = Set(cells.map(\.axialCoordinate))
        let directions = AxialDirection.allCases

        for cell in cells {
            let coordinate = cell.axialCoordinate
            guard let position = fractionalPositions[coordinate] else { continue }
            for direction in directions {
                if !direction.ownsSharedEdge {
                    let offset = direction.offsetCoordinate
                    let neighbor = AxialCoordinate(q: coordinate.q + offset.q, r: coordinate.r + offset.r)
                    guard !coordinateSet.contains(neighbor) else { continue }
                }

                let pathEdge = HexGridGeometry.fractionalEdgeOffset(
                    at: direction,
                    fractionalPosition: position,
                    orientation: orientation
                ).scaled(by: hexRadius)

                let start = pathEdge.start + contentRect.center
                let end = pathEdge.end + contentRect.center
                gridPath.move(to: start)
                gridPath.addLine(to: end)
            }
        }
        return gridPath
    }
}

// MARK: - Init
extension ZoomableHexGridView {
    public init(
        cells: [Cell],
        hexRadius: Binding<CGFloat>,
        radiusRange: ClosedRange<CGFloat> = HexGridDefaults.radiusRange,
        orientation: HexOrientation,
        gridLine: HexGridLine? = nil,
        style: @escaping (Cell) -> HexCellStyle
    ) {
        self.cells = cells
        self.fractionalPositions = Dictionary(uniqueKeysWithValues: cells.map { cell in
            let fractionalPosition = HexScreenMath.hexToCartesianPoint(
                axialCoordinate: cell,
                orientation: orientation
            )
            return (cell.axialCoordinate, fractionalPosition)
        })

        self.orientation = orientation
        self.appearance = HexGridAppearance(
            gridLine: gridLine,
            style: style
        )

        self._hexRadius = hexRadius
        self.radiusRange = radiusRange
        let fractionalRect = HexGridGeometry.deriveContentRect(from: cells, orientation: orientation)
        print("fractionalRect: \(fractionalRect.alignedDebugString)")
        print("contentRect: \((fractionalRect * hexRadius.wrappedValue).alignedDebugString)")
        self.contentRect = CGRect(origin: .zero, size: fractionalRect.size * hexRadius.wrappedValue)
    }
}

extension CGRect {
    static func * (lhs: Self, mult: CGFloat) -> Self {
        return .init(x: lhs.minX * mult,
                     y: lhs.minY * mult,
                     width: lhs.width * mult,
                     height: lhs.height * mult)
    }
}
