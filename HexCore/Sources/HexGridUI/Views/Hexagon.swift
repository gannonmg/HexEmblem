//
//  Hexagon.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore
import SwiftUI

public struct Hexagon: Shape, HexShapeProviding {
    /// A percent represented by a float `0...1` to aide in interpolating the rotation angle for animation
    /// `0` represents no rotation and a flat top hex
    /// `1` represents 30º rotation and a pointy top hex
    private var hexRotationPercent: CGFloat
    public var animatableData: CGFloat {
        get { hexRotationPercent }
        set { hexRotationPercent = newValue }
    }

    public init(orientation: HexOrientation) {
        self.hexRotationPercent = switch orientation {
        case .flatTop: 0
        case .pointyTop: 1
        }
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width = min(rect.width, rect.height * interpolatedAspectRatio)
        let radius = width / interpolatedRadiusRatio

        let corners = (0..<6)
            .map { corner(center: center, radius: radius, cornerIndex: $0) }

        path.move(to: corners[0])
        corners[1..<6].forEach { point in
            path.addLine(to: point)
        }
        path.closeSubpath()

        return path
    }

    private var interpolatedAspectRatio: CGFloat {
        let pointy = Self.aspectRatio(for: .pointyTop)
        let flat = Self.aspectRatio(for: .flatTop)
        return flat + (pointy - flat) * hexRotationPercent
    }

    /// Pointy top inscribes edge-to-edge across the width; flat top inscribes point-to-point.
    private var interpolatedRadiusRatio: CGFloat {
        Self.pointToPointRatio + (Self.edgeToEdgeRatio - Self.pointToPointRatio) * hexRotationPercent
    }

    private func corner(center: CGPoint, radius: CGFloat, cornerIndex: Int) -> CGPoint {
        let angleOffset: CGFloat = 30 * hexRotationPercent
        let angleDegree: CGFloat = 60 * cornerIndex - angleOffset
        let angleRadian = CGFloat.pi / 180 * angleDegree
        return CGPoint(
            x: center.x + radius * cos(angleRadian),
            y: center.y + radius * sin(angleRadian)
        )
    }
}
