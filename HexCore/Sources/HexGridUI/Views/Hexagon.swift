//
//  Hexagon.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore
import SwiftUI

public struct Hexagon: Shape, HexShapeProviding {
    let orientation: HexOrientation

    public init(orientation: HexOrientation) {
        self.orientation = orientation
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width = min(rect.width, rect.height * Self.aspectRatio(for: orientation))
        let size = switch orientation {
        case .pointyTop: width / Self.edgeToEdgeRatio
        case .flatTop: width / Self.pointToPointRatio
        }

        let corners = (0..<6)
            .map { corner(center: center, size: size, cornerIndex: $0) }

        path.move(to: corners[0])
        corners[1..<6].forEach { point in
            path.addLine(to: point)
        }

        path.closeSubpath()

        return path
    }

    private func corner(center: CGPoint, size: CGFloat, cornerIndex: Int) -> CGPoint {
        let angleDegree = switch orientation {
        case .pointyTop: pointyTopCornerDegree(for: cornerIndex)
        case .flatTop: flatTopCornerDegree(for: cornerIndex)
        }

        let angleRadian: CGFloat = CGFloat.pi / 180 * CGFloat(angleDegree)
        let cornerPoint = CGPoint(
            x: center.x + size * cos(angleRadian),
            y: center.y + size * sin(angleRadian)
        )
        return cornerPoint
    }

    private func flatTopCornerDegree(for cornerIndex: Int) -> Int {
        60 * cornerIndex
    }

    private func pointyTopCornerDegree(for cornerIndex: Int) -> Int {
        60 * cornerIndex - 30
    }
}
